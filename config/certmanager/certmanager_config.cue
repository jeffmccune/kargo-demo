@extern(embed)
package certmanager

import "example.com/platform/schemas/certmanager"

// Unify data from yaml for Kargo integration.
_data: _ @embed(file=cert-manager.yaml)

Config: certmanager.#Config & {
	namespace: "cert-manager"
	// datafile value must align to the embed file directive above for proper
	// configuration of Kargo promotion stages.
	datafile: "./config/certmanager/cert-manager.yaml"
	chart: {
		name:    "cert-manager"
		version: _data.chart.version
		repository: {
			name: "jetstack"
			url:  "https://charts.jetstack.io"
		}
	}
}
