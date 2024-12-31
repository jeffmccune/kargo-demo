@extern(embed)
package externalsecrets

import (
	es "external-secrets.io/externalsecret/v1beta1"
	ss "external-secrets.io/secretstore/v1beta1"
	pw "generators.external-secrets.io/password/v1alpha1"
	"github.com/holos-run/holos/api/core/v1alpha5:core"
)

// Unify data from yaml for Kargo integration.
_data: _ @embed(file=externalsecrets.yaml)

config: #Config & {
	namespace: "external-secrets"
	datafile:  "./config/externalsecrets/externalsecrets.yaml"

	chart: {
		name:    "external-secrets"
		version: _data.chart.version
		repository: {
			name: "external-secrets"
			url:  "https://charts.external-secrets.io"
		}
	}
}

#Config: {
	namespace: string
	datafile:  string
	chart: core.#Chart & {
		version: =~"^v{0,1}[0-9]+\\.[0-9]+\\.[0-9]+$"
	}
}

#Resources: {
	ExternalSecret?: [_]: es.#ExternalSecret
	Password?: [_]:       pw.#Password
	SecretStore?: [_]:    ss.#SecretStore
}
