package platform

import (
	// core types
	v1 "gateway.networking.k8s.io/httproute/v1"
	// our types
	"example.com/platform/schemas/platform"
	// our config
	"example.com/platform/config/istio"
)

// HTTPRoutes is where routes are registered.  The httproutes component manages
// routes by composing this struct into a BuildPlan.
HTTPRoutes: platform.#HTTPRoutes & {
	[NAME=string]: {
		metadata: name:      NAME
		metadata: namespace: istio.Config.Gateway.Namespace
		metadata: labels: app: NAME

		let HOST = NAME + "." + Organization.Domain
		spec: hostnames: [HOST]
		spec: parentRefs: [{
			name:      "default"
			namespace: metadata.namespace
		}]

		spec: rules: [
			{
				matches: [{path: {type: "PathPrefix", value: "/"}}]
				backendRefs: [for x in _backendRefs {x}]
			},
		]
	}
}
