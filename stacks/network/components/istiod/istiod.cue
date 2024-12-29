package holos

import (
	"encoding/yaml"
	ks "sigs.k8s.io/kustomize/api/types"

	"example.com/holos/pkg/config/istio"
)

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "istiod"
	Namespace: istio.config.system.namespace

	Chart: {
		version: istio.config.version
		repository: {
			name: "istio"
			url:  "https://istio-release.storage.googleapis.com/charts"
		}
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
			name:    "istio-validator-istio-system"
		}
		let Patch = [{
			op:    "replace"
			path:  "/webhooks/0/failurePolicy"
			value: "Fail"
		}]
		patch: yaml.Marshal(Patch)
	}
}
