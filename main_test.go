package main

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/holos-run/holos/cmd"
	"github.com/rogpeppe/go-internal/testscript"
)

func TestMain(m *testing.M) {
	os.Exit(testscript.RunMain(m, map[string]func() int{
		"holos": cmd.MakeMain(),
	}))
}

func TestUnity(t *testing.T) {
	testscript.Run(t, useDemoCodeUsersUse(filepath.Join("tests", "unity")))
}

func useDemoCodeUsersUse(dir string) testscript.Params {
	p := params(dir)
	p.RequireUniqueNames = false
	wd, err := os.Getwd()
	if err != nil {
		panic(err)
	}
	p.WorkdirRoot = wd
	return p
}

func params(dir string) testscript.Params {
	return testscript.Params{
		Dir:                 dir,
		RequireExplicitExec: true,
		RequireUniqueNames:  os.Getenv("HOLOS_WORKDIR_ROOT") == "",
		WorkdirRoot:         os.Getenv("HOLOS_WORKDIR_ROOT"),
		UpdateScripts:       os.Getenv("HOLOS_UPDATE_SCRIPTS") != "",
		Setup: func(env *testscript.Env) error {
			// Just like cmd/cue/cmd.TestScript, set up separate cache and config dirs per test.
			env.Setenv("CUE_CACHE_DIR", filepath.Join(env.WorkDir, "tmp/cachedir"))
			configDir := filepath.Join(env.WorkDir, "tmp/configdir")
			env.Setenv("CUE_CONFIG_DIR", configDir)
			return nil
		},
	}
}
