package holos

import (
	rg "gateway.networking.k8s.io/referencegrant/v1beta1"
	"holos.example/config/kargo"
)

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "kargo"
	Namespace: kargo.config.namespace

	Chart: {
		release: Name
		name:    kargo.config.chart.name
		version: kargo.config.chart.version
	}
	EnableHooks: true
	Values:      kargo.config.values

	// Mix-in resources.
	Resources: [_]: [_]: metadata: namespace: Namespace
	// Grant the Gateway namespace the ability to refer to the backend service
	// from HTTPRoute resources.
	Resources: ReferenceGrant: "istio-ingress": rg.#ReferenceGrant & {
		metadata: name: "istio-ingress"
		spec: from: [{
			group:     "gateway.networking.k8s.io"
			kind:      "HTTPRoute"
			namespace: "istio-ingress"
		}]
		spec: to: [{
			group: ""
			kind:  "Service"
		}]
	}
}
