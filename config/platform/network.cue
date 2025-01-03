package platform

import pkg_istio "holos.example/config/istio"

stacks: network: (#StackBuilder & {
	(#PromoterBuilder & {parameters: {
		name: "istio"
		config: {
			datafile: pkg_istio.config.datafile
			chart: name:       "base"
			chart: repository: pkg_istio.config.chart.repository
		}
	}}).promoter

	stack: namespaces: {
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
			"httproutes": {
				name: "httproutes"
				path: "stacks/network/components/httproutes"
				labels: component: "httproutes"
			}
		}
	}
}).stack
