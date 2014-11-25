package gowebhooks

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

	output, err := RunMakeTest(payload)
	if err != nil {
		fmt.Println(err)
		return
	}

	err = WriteOutput(payload, output)
	if err != nil {
		fmt.Println(err)
		return
	}

	log.Printf("Completed %s", eventType)

	fmt.Fprintf(w, "OK")
}

func RunMakeTest(payload github.WebHookPayload) ([]byte, error) {
	tempDir, _ := ioutil.TempDir("/tmp", "gowebhooks")

	giturl := *payload.Repo.GitURL
	gitref := *payload.HeadCommit.ID

	cloneCmd := exec.Command("git", "clone", giturl, tempDir)
	cloneOutput, err := cloneCmd.CombinedOutput()
	if err != nil {
		return cloneOutput, err
	}

	checkoutCmd := exec.Command("git", "checkout", "-b", gitref, gitref)
	checkoutCmd.Dir = tempDir
	checkoutOutput, err := checkoutCmd.CombinedOutput()
	if err != nil {
		return checkoutOutput, err
	}

	makeTestCmd := exec.Command("make", "test")
	makeTestCmd.Dir = tempDir
	makeTestOutput, err := makeTestCmd.CombinedOutput()

	outputs := [][]byte{cloneOutput, checkoutOutput, makeTestOutput}
	output := bytes.Join(outputs, []byte("\n"))

	return output, err
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

func StartServer() error {
	publicFileServer := http.FileServer(http.Dir("./public"))
	http.Handle("/", publicFileServer)
	http.HandleFunc("/webhook", webhookHandler)

	fmt.Println("Listening on 4567")
	return http.ListenAndServe(":4567", nil)
}
