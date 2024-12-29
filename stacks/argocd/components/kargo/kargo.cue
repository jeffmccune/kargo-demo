package holos

import (
	rg "gateway.networking.k8s.io/referencegrant/v1beta1"
	"example.com/holos/pkg/config/kargo"
)

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "kargo"
	Namespace: kargo.config.namespace

	Chart: {
		name:    "oci://ghcr.io/akuity/kargo-charts/kargo"
		version: kargo.config.version
		release: Name
	}
	EnableHooks: true

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

	Values: kargo.config.values
}
