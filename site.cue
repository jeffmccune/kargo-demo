package holos

import "example.com/platform/schemas/platform"

// Organization represents top level configuration for the platform.  Defined in
// the main package to support mixing in values with build tags, and to inject
// (mix-in) the concrete configuration into other configuration structures, for
// example components.
Organization: platform.#Organization & {
	DisplayName: string | *"Kargo Demo"
	Domain:      string | *"holos.localhost"
	RepoURL:     string | *"https://github.com/holos-run/kargo-demo.git"
}
