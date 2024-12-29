package istio

import "github.com/holos-run/holos/api/core/v1alpha5:core"

// #Config defines the configuration schema of this package.
#Config: {
	Version: chart.version
	System: Namespace:  string
	Gateway: Namespace: string

	datafile: string
	chart: core.#Chart & {
		version: string
		repository: {
			name: string
			url:  string
		}
	}

	Values: {...}
}
