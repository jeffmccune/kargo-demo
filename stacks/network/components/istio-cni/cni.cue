package holos

import "example.com/holos/pkg/config/istio"

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "istio-cni"
	Namespace: istio.config.system.namespace

	Chart: {
		name:    "cni"
		version: istio.config.version
		repository: {
			name: "istio"
			url:  "https://istio-release.storage.googleapis.com/charts"
		}
	}

	Values: istio.config.values
}
