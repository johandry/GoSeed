package cmd

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/johandry/log"
	homedir "github.com/mitchellh/go-homedir"
	"github.com/spf13/cobra"
	"github.com/spf13/viper"
)

const (
	defVerbose        = false
	defDebug          = false
	defLogLevel       = "error"
	defLogForceColors = true
	defLog            = ""
	defPort           = "8080"
)

var (
	cfgFile string
	verbose bool
	debug   bool
	logFile string
)

// RootCmd represents the base command when called without any subcommands
var RootCmd = &cobra.Command{
	Use:   "__APPNAME__",
	Short: "A brief description of your application",
	Long: `A longer description that spans multiple lines and likely contains
examples and usage of using your application. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	// Uncomment the following line if your bare application
	// has an action associated with it:
	//	Run: func(cmd *cobra.Command, args []string) { },
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() {
	if err := RootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func init() {
	cobra.OnInitialize(initConfig)
	setPersistentFlags()
}

// setPersistentFlags set global flags, these flags will be available to the
// root command (__APPNAME__) as well as every subcommand
func setPersistentFlags() {
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.
	RootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file (default are /etc/__APPNAME__/config.yaml then $HOME/.__APPNAME__.yaml)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
	RootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")

	RootCmd.PersistentFlags().BoolVarP(&verbose, "verbose", "v", defVerbose, "verbose output")
	setValueFromFlag("verbose")
	viper.SetDefault("verbose", defVerbose)

	RootCmd.PersistentFlags().BoolVarP(&debug, "debug", "", defDebug, "debug output useful for develpment")
	RootCmd.PersistentFlags().MarkHidden("debug")
	setValueFromFlag("debug")
	viper.SetDefault("debug", defDebug)

	RootCmd.PersistentFlags().StringVar(&logFile, "log", defLog, "log file (default is Stderr)")
	setValueFromFlag("log")
	viper.SetDefault("log", defLog)
}

// initConfig reads in config file and ENV variables if set. It's executed before
// a command Run() function is executed.
func initConfig() {
	if cfgFile != "" {
		viper.SetConfigFile(cfgFile)
	} else {
		home, err := homedir.Dir()
		if err != nil {
			fmt.Println(err)
			os.Exit(1)
		}

		viper.AddConfigPath(filepath.Join(home, ".__APPNAME__", "config"))
		viper.AddConfigPath(filepath.Join("/", "etc", "__APPNAME__", "config"))
		viper.AddConfigPath(".")
		viper.SetConfigName("config")
	}

	viper.SetEnvPrefix("__APPNAME__")
	viper.AutomaticEnv()

	viper.ReadInConfig()
}

func setValueFromFlag(key string) {
	flag := RootCmd.PersistentFlags().Lookup(key)
	if flag != nil {
		viper.BindPFlag(key, flag)
		// viper.Set(key, flag.Value.String())
	}
}

func setLogginSettings() {
	viper.SetDefault(log.LevelKey, defLogLevel)
	viper.SetDefault(log.ForceColorsKey, defLogForceColors)

	if viper.GetBool("verbose") {
		viper.Set(log.LevelKey, "info")
	} else if viper.GetBool("debug") {
		viper.Set(log.LevelKey, "debug")
	}
	if !viper.IsSet(log.LevelKey) {
		viper.Set(log.LevelKey, "error")
	}

	if viper.IsSet("log") {
		logFileName := viper.GetString("log")
		if logFileName != "" {
			viper.Set(log.FilenameKey, logFileName)
		}
	} else {
		viper.Set(log.OutputKey, os.Stderr)
	}
}
