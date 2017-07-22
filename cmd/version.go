package cmd

import (
	"github.com/johandry/__APPNAME__/version"
	"github.com/spf13/cobra"
)

// versionCmd represents the version command
var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print the __APPNAME__ version",
	Long:  `Print the __APPNAME__ version and git SHA`,
	Run: func(cmd *cobra.Command, args []string) {
		version.Println()
	},
}

func init() {
	RootCmd.AddCommand(versionCmd)
}
