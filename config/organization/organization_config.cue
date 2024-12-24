package platform

import "example.com/platform/schemas/platform"

// Override these values with cue build tags.  See organization-jeff.cue for an
// example.
Organization: platform.#Organization & {
	DisplayName: string | *"Kargo Demo"
	Domain:      string | *"holos.localhost"
	RepoURL:     string | *"https://github.com/holos-run/kargo-demo.git"
}
