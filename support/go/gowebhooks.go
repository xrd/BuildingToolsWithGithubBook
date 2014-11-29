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

	"code.google.com/p/goauth2/oauth"
	"github.com/google/go-github/github"
)

var accessToken = os.Getenv("GITHUB_ACCESS_TOKEN")
var t = &oauth.Transport{
	Token: &oauth.Token{AccessToken: accessToken},
}
var client = github.NewClient(t.Client())

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

	go func() {
		buffer, err := RunMakeTest(payload)
		if err != nil {
			fmt.Println(err)
			return
		}

		err = CommentOutput(payload, buffer)
		if err != nil {
			fmt.Println(err)
			return
		}
		log.Printf("Commented on: %s", *payload.HeadCommit.ID)
	}()

	fmt.Fprintf(w, "OK")
	log.Printf("Responded: OK")
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

func CommentOutput(payload github.WebHookPayload, output *bytes.Buffer) error {
	owner := *payload.Repo.Owner.Name
	repo := *payload.Repo.Name
	gitref := *payload.HeadCommit.ID

	commentBody := bytes.NewBufferString("Created by gowebhooks!")
	commentBody.WriteString("\n```")
	commentBody.Write(output.Bytes())
	commentBody.WriteString("```")

	commentBodyString := commentBody.String()

	comment := &github.RepositoryComment{
		Body: &commentBodyString,
	}

	_, _, err := client.Repositories.CreateComment(owner, repo, gitref, comment)
	return err
}

func main() {
	publicFileServer := http.FileServer(http.Dir("./public"))
	http.Handle("/", publicFileServer)
	http.HandleFunc("/webhook", webhookHandler)

	fmt.Println("Listening on 4567")
	err := http.ListenAndServe(":4567", nil)
	fmt.Println(err)
}
