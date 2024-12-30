package holos

import (
	"encoding/yaml"
	ks "sigs.k8s.io/kustomize/api/types"
	"holos.example/pkg/config/istio"
)

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "istio-base"
	Namespace: istio.config.system.namespace

	Chart: {
		name:       "base"
		version:    istio.config.chart.version
		repository: istio.config.chart.repository
	}

	KustomizeConfig: Kustomization: patches: [for x in KustomizePatches {x}]

	Values: istio.config.values
}

#KustomizePatches: [ArbitraryLabel=string]: ks.#Patch
let KustomizePatches = #KustomizePatches & {
	validator: {
		target: {
			group:   "admissionregistration.k8s.io"
			version: "v1"
			kind:    "ValidatingWebhookConfiguration"
			name:    "istiod-default-validator"
		}
		let Patch = [{
			op:    "replace"
			path:  "/webhooks/0/failurePolicy"
			value: "Fail"
		}]
		patch: yaml.Marshal(Patch)
	}
}
