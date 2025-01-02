package platform

import "holos.example/types/platform"

organization: #Organization

#Organization: platform.#Organization & {
	displayName: "Holos Example"
	domain:      "holos.localhost"
	repoURL:     string | *"https://github.com/holos-run/kargo-demo.git"
}
