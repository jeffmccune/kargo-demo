@extern(embed)
package istio

import "github.com/holos-run/holos/api/core/v1alpha5:core"

// Unify istio.yaml
_istio_data: _ @embed(file=istio.yaml)

// #Config defines the configuration schema of this package.
#Config: {
	version: chart.version
	system: namespace:  string
	gateway: namespace: string

	datafile: string

	chart: core.#Chart & {
		version: string
		repository: {
			name: string
			url:  string
		}
	}

	values: {...}
}

// config represents concrete configuration values for this package.
config: #Config & {
	system: namespace:  "istio-system"
	gateway: namespace: "istio-ingress"

	datafile: "./config/istio/istio.yaml"
	chart: {
		version: string & _istio_data.chart.version
		repository: {
			name: "istio"
			url:  "https://istio-release.storage.googleapis.com/charts"
		}
	}

	// Constrain Helm values for safer, easier upgrades and consistency across
	// platform components.
	values: global: istioNamespace: system.namespace
	// Configure ambient mode
	values: profile: "ambient"
}
