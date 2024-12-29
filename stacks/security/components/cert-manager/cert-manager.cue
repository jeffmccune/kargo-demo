package holos

import "example.com/holos/pkg/config/certmanager"

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "cert-manager"
	Namespace: certmanager.Config.namespace
	Chart:     certmanager.Config.chart

	EnableHooks: true

	Values: #Values & {
		crds: enabled:            true
		startupapicheck: enabled: false
		// https://github.com/cert-manager/cert-manager/issues/6716
		global: leaderElection: namespace: Namespace
	}
}
