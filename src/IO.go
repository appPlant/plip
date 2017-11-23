package main

import (
	"fmt"
	"io"
	"os"
	"path"
	"strings"

	"github.com/fatih/color"
	log "github.com/sirupsen/logrus"
)

func printUnformatted(planets []Planet, writer io.Writer) {
	if !strings.HasSuffix(planets[len(planets)-1].outputStruct.output, "\n") {
		planets[len(planets)-1].outputStruct.output += "\n"
	}
	for _, planet := range planets {
		if planet.outputStruct.errored {
			fmt.Fprint(writer, colorize(planet.outputStruct.errors["output"]))
			continue
		}
		fmt.Fprint(writer, planet.outputStruct.output)
	}
}

func makeLoadCommand(command string, opts *Opts) string {
	if opts.Load {
		log.Debugf("profile load has been applied")
		return fmt.Sprintf(`sh -lc "echo -----APPPLANT-ORBIT----- && %s "`, command)
	}
	return command
}

func cleanProfileLoadedOutput(output string, opts *Opts) string {
	if opts.Load {
		splitOut := strings.Split(output, "-----APPPLANT-ORBIT-----\n")
		log.Debugf("cleaned part: %s", splitOut[0])
		return splitOut[len(splitOut)-1]
	}
	return output
}

func makeDir(name string) {
	tempdir := path.Join(os.Getenv("ORBIT_HOME"), name)
	err := os.MkdirAll(tempdir, 0700)
	if err != nil {
		log.Error(err)
	}
}

func colorize(input string) string {
	tokens := strings.Split(input, "\n")
	for i, row := range tokens {
		if isBlank(row) {
			continue
		}
		tokens[i] = color.RedString(row)
	}
	return strings.Join(tokens, "\n")
}

func isBlank(input string) bool {
	input = strings.TrimSpace(input)
	if len(input) == 0 {
		return true
	}
	return false
}
