package platform

import "github.com/holos-run/holos/api/core/v1alpha5:core"

// #PromoterBuilder builds the configuration to promote automatic updates for
// add-ons.  Pull requests are opened with fully rendered manifests as new
// updates are made available.
//
// The value of the promoter field is intended for composition with a #StackBuilder.
#PromoterBuilder: {
	parameters: {
		name:    string
		repoURL: string
		config: {
			datafile: string
			chart: core.#Chart & {
				version: =~"^v{0,1}[0-9]+\\.[0-9]+\\.[0-9]+$"
			}
		}
	}
	let PARAMS = parameters
	promoter: #StackBuilder & {
		// Manage a namespace for the Kargo Project
		// See: https://docs.kargo.io/how-to-guides/working-with-projects/#namespace-adoption
		stack: namespaces: "\(PARAMS.name)": metadata: labels: "kargo.akuity.io/project": "true"
		// Mix an additional component into the StackBuilder parameters
		parameters: components: {
			"\(PARAMS.name)-promoter": {
				path: "stacks/shared/components/addon-promoter"
				annotations: description: "\(PARAMS.name) kargo promotion stages"
				parameters: {
					kargoProject:  PARAMS.name
					kargoStage:    "main"
					kargoDataFile: PARAMS.config.datafile
					kargoDataKey:  "chart.version"
					gitRepoURL:    PARAMS.repoURL
					chartName:     PARAMS.config.chart.name
					chartRepoURL:  PARAMS.config.chart.repository.url
				}
			}
		}
	}
}
