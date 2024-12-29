package certmanager

import "github.com/holos-run/holos/api/core/v1alpha5:core"

#Config: {
	namespace: string
	datafile:  string
	chart: core.#Chart & {
		version: =~"^v{0,1}[0-9]+\\.[0-9]+\\.[0-9]+$"
	}
}
