package main

import (
	"fmt"

	gowebhooks "./../../../go"
)

func main() {
	err := gowebhooks.StartServer()
	fmt.Println(err)
}
