package version

import (
	"bytes"
	"fmt"
)

var (
	// GitCommit is the git commit that was compiled. This will be filled in by the compiler
	// in the Makefile from Git short SHA-1 of HEAD commit.
	GitCommit string

	// Version is the main version number that is being run at the moment. This will be
	// filled in by the compiler in the Makefile from latest.go
	Version string

	// VersionPrerelease is a pre-release marker for the  If this is "" (empty string)
	// then it means that it is a final release. Otherwise, this is a pre-release
	// such as "dev" (in development), "beta", "rc1", etc.
	// This will be filled in by the compiler in the Makefile from latest.go
	VersionPrerelease string

	// AppName is the application name to show with the version. It may be empty
	// but looks good to have a name.
	// TODO: Replace 'App' with the correct application name.
	AppName = "App"
)

// Println prints the version using the output of String()
func Println() {
	fmt.Println(String())
}

// String return the version as it will be show in the terminal
func String() string {
	var version bytes.Buffer
	if AppName != "" {
		fmt.Fprintf(&version, "%s ", AppName)
	}
	fmt.Fprintf(&version, "v%s", Version)
	if VersionPrerelease != "" {
		fmt.Fprintf(&version, "-%s", VersionPrerelease)
		if GitCommit != "" {
			fmt.Fprintf(&version, " (%s)", GitCommit)
		}
	}

	return version.String()
}
