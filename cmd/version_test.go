package cmd_test

import (
	"strings"
	"testing"

	"github.com/johandry/__APPNAME__/version"
)

// TestVersionCmd tests the 'version' command
func TestVersionCmd(t *testing.T) {
	version.Version = "1.0"
	version.AppName = "__APPNAME__"
	version.VersionPrerelease = "dev"
	version.GitCommit = "t35t1ng"

	rootCmd.SetArgs(strings.Split("version", " "))
	actualVer, err := getOutput(rootCmd.Execute)
	if err != nil {
		t.Error(err)
	}

	expectedVer := "__APPNAME__ v1.0-dev (t35t1ng)"

	if actualVer != expectedVer {
		t.Errorf("Expected '%s', but got '%s'", expectedVer, actualVer)
	}
}
