package version_test

import (
	"testing"

	"github.com/johandry/__APPNAME__/version"
)

func TestVersionString(t *testing.T) {
	version.Version = "1.0"
	version.AppName = "__APPNAME__"
	version.VersionPrerelease = "dev"
	version.GitCommit = "t35t1ng"
	actualVer := version.String()

	expectedVer := "__APPNAME__ v1.0-dev (t35t1ng)"

	if actualVer != expectedVer {
		t.Errorf("Expected %s, but got %s", expectedVer, actualVer)
	}
}
