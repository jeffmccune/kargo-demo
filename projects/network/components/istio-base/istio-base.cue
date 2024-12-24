package holos

import (
	"encoding/yaml"
	ks "sigs.k8s.io/kustomize/api/types"
	"example.com/platform/config/istio"
)

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "istio-base"
	Namespace: istio.Config.System.Namespace

	Chart: {
		name:       "base"
		version:    istio.Config.chart.version
		repository: istio.Config.chart.repository
	}

	KustomizeConfig: Kustomization: patches: [for x in KustomizePatches {x}]

	Values: istio.Config.Values
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
