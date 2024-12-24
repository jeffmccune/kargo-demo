package holos

import "example.com/platform/config/istio"

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "istio-ztunnel"
	Namespace: istio.Config.System.Namespace

	Chart: {
		name:    "ztunnel"
		version: istio.Config.Version
		repository: {
			name: "istio"
			url:  "https://istio-release.storage.googleapis.com/charts"
		}
	}

	Values: istio.Config.Values
}
