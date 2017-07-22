package cmd_test

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/johandry/__APPNAME__/cmd"
)

var rootCmd = cmd.RootCmd

type cmdExecFunc func() error

func getOutput(f cmdExecFunc) (string, error) {
	oldStdout := os.Stdout
	r, w, _ := os.Pipe()
	os.Stdout = w

	err := f()

	outCh := make(chan string)
	go func() {
		var buf bytes.Buffer
		io.Copy(&buf, r)
		outCh <- buf.String()
	}()

	w.Close()
	os.Stdout = oldStdout
	if err != nil {
		return "", fmt.Errorf("Failed executing '%s' command. %s ", "version", err)
	}
	out := <-outCh

	return strings.TrimSpace(string(out)), nil
}
