package holos

import "holos.example/config/istio"

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "istio-ztunnel"
	Namespace: istio.config.system.namespace

	Chart: {
		name:    "ztunnel"
		version: istio.config.version
		repository: {
			name: "istio"
			url:  "https://istio-release.storage.googleapis.com/charts"
		}
	}

	Values: istio.config.values
}
