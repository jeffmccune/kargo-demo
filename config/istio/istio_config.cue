@extern(embed)
package istio

import (
	"example.com/platform/schemas/istio"
	"example.com/platform/schemas/platform"
)

// Unify istio.yaml
_istio_data: _ @embed(file=istio.yaml)

// Config represents concrete configuration values for this package.
Config: istio.#Config & {
	System: Namespace:  "istio-system"
	Gateway: Namespace: "istio-ingress"

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
	Values: global: istioNamespace: System.Namespace
	// Configure ambient mode
	Values: profile: "ambient"
}

// Project represents how istio integrates with the platform.  Dependencies are
// injected as fields, the Project field contains the value assembled from the
// dependencies.
ProjectBuilder: platform.#ProjectBuilder & {
	organization: _

	Project: {
		namespaces: (Config.System.Namespace):  _
		namespaces: (Config.Gateway.Namespace): _
		namespaces: istio: metadata: labels: "kargo.akuity.io/project": "true"

		components: {
			"istio-base": {
				name: "istio-base"
				path: "projects/network/components/istio-base"
			}
			"istiod": {
				name: "istiod"
				path: "projects/network/components/istiod"
			}
			"istio-cni": {
				name: "istio-cni"
				path: "projects/network/components/istio-cni"
			}
			"istio-ztunnel": {
				name: "istio-ztunnel"
				path: "projects/network/components/istio-ztunnel"
			}
			"istio-gateway": {
				name: "istio-gateway"
				path: "projects/network/components/istio-gateway"
			}
			"istio-kargo": {
				name: "istio-promoter"
				path: "components/addon-promoter"
				parameters: {
					KargoProjectName: "istio"
					KargoStageName:   "main"
					KargoDataFile:    Config.datafile
					KargoDataKey:     "chart.version"
					GitRepoURL:       organization.RepoURL
					ChartName:        "base"
					ChartRepoURL:     Config.chart.repository.url
				}
			}
			"httproutes": {
				name: "httproutes"
				path: "projects/network/components/httproutes"
				labels: component: "httproutes"
			}
		}
	}
}
