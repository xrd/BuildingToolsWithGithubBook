package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"

	"github.com/google/go-github/github"
)

func webhookHandler(w http.ResponseWriter, r *http.Request) {
	eventType := r.Header.Get("X-GitHub-Event")
	log.Printf("Received: %s event", eventType)

	if eventType != "push" {
		return
	}

	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		fmt.Println(err)
		return
	}

	payload := github.WebHookPayload{}
	json.Unmarshal(body, &payload)

	buffer, err := RunMakeTest(payload)
	if err != nil {
		fmt.Println(err)
		return
	}

	err = WriteOutput(payload, buffer.Bytes())
	if err != nil {
		fmt.Println(err)
		return
	}

	log.Printf("Completed. Available at http://localhost:4567/%s/%s",
		*payload.Repo.Name, *payload.HeadCommit.ID)

	fmt.Fprintf(w, "OK")
}

func RunMakeTest(payload github.WebHookPayload) (*bytes.Buffer, error) {
	buffer := bytes.NewBuffer([]byte{})
	tempDir, _ := ioutil.TempDir("/tmp", "gowebhooks")

	giturl := *payload.Repo.GitURL
	gitref := *payload.HeadCommit.ID

	var commands [3]*exec.Cmd

	cloneCmd := exec.Command("git", "clone", giturl, tempDir)

	checkoutCmd := exec.Command("git", "checkout", "-b", gitref, gitref)
	checkoutCmd.Dir = tempDir

	makeTestCmd := exec.Command("make", "test")
	makeTestCmd.Dir = tempDir

	commands[0] = cloneCmd
	commands[1] = checkoutCmd
	commands[2] = makeTestCmd

	for _, cmd := range commands {
		buffer.WriteString(fmt.Sprintf("\n%s\n", cmd.Args))
		cmdOutput, err := cmd.CombinedOutput()
		buffer.Write(cmdOutput)
		if err != nil {
			return buffer, err
		}
	}

	return buffer, nil
}

func WriteOutput(payload github.WebHookPayload, output []byte) (err error) {
	full_path := filepath.Join("./public", *payload.Repo.Name)
	file_path := filepath.Join(full_path, *payload.HeadCommit.ID)

	err = os.MkdirAll(full_path, 0774)
	if err != nil {
		return err
	}

	file, err := os.Create(file_path)
	if err != nil {
		return err
	}
	defer file.Close()
	file.Write(output)

	return
}

func main() error {
	publicFileServer := http.FileServer(http.Dir("./public"))
	http.Handle("/", publicFileServer)
	http.HandleFunc("/webhook", webhookHandler)

	fmt.Println("Listening on 4567")
	return http.ListenAndServe(":4567", nil)
}
