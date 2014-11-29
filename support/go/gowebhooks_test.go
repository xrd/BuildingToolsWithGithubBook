package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"

	"github.com/google/go-github/github"
)

var (
	testJSON = []byte(`{
  "head_commit": {
    "id": "a"
  },
  "repository": {
    "name": "b",
    "owner": {
      "name": "c"
    } } }`)

	testOutput = []byte("d")

	mux    *http.ServeMux
	server *httptest.Server
)

func setup() {
	mux = http.NewServeMux()
	server = httptest.NewServer(mux)

	// Replace the client in gowebhooks.go
	client = github.NewClient(nil)
	url, _ := url.Parse(server.URL)
	client.BaseURL = url
	client.UploadURL = url
}

func teardown() {
	server.Close()
}

func TestCommentOutput(t *testing.T) {
	setup()
	defer teardown()

	testPayload := github.WebHookPayload{}

	err := json.Unmarshal(testJSON, &testPayload)
	if err != nil {
		t.Fatal(err)
	}

	buff := bytes.NewBuffer(testOutput)
	mux.HandleFunc("/repos/c/b/commits/a/comments",
		func(w http.ResponseWriter, r *http.Request) {
			fmt.Fprint(w, `{"id":1}`)
		})

	err = CommentOutput(testPayload, buff)
	if err != nil {
		t.Fatal(err)
	}
}
