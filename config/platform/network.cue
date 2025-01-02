package platform

import (
	pkg_istio "holos.example/config/istio"
)

stacks: network: (#StackBuilder & {
	stack: namespaces: {
		istio: metadata: labels: "kargo.akuity.io/project": "true"
		(pkg_istio.config.gateway.namespace): _
		(pkg_istio.config.system.namespace):  _
	}
	parameters: {
		name: "network"
		components: {
			"gateway-api": {
				path: "stacks/network/components/gateway-api"
				annotations: description: "gateway api custom resource definitions"
			}

			"istio-base": {
				path: "stacks/network/components/istio-base"
				annotations: description: "istio base resources"
			}
			"istiod": {
				name: "istiod"
				path: "stacks/network/components/istiod"
				annotations: description: "istiod controller service"
			}
			"istio-cni": {
				name: "istio-cni"
				path: "stacks/network/components/istio-cni"
				annotations: description: "istio cni"
			}
			"istio-ztunnel": {
				name: "istio-ztunnel"
				path: "stacks/network/components/istio-ztunnel"
				annotations: description: "istio ztunnel for ambient mode"
			}
			"istio-gateway": {
				name: "istio-gateway"
				path: "stacks/network/components/istio-gateway"
				annotations: description: "istio ingress gateway"
			}
			"istio-promoter": {
				name: "istio-promoter"
				path: "stacks/shared/components/addon-promoter"
				parameters: {
					kargoProject:  "istio"
					kargoStage:    "main"
					kargoDataFile: pkg_istio.config.datafile
					kargoDataKey:  "chart.version"
					gitRepoURL:    organization.repoURL
					chartName:     "base"
					chartRepoURL:  pkg_istio.config.chart.repository.url
				}
			}
			"httproutes": {
				name: "httproutes"
				path: "stacks/network/components/httproutes"
				labels: component: "httproutes"
			}
		}
	}
}).stack
