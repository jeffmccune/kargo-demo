package holos

import "holos.example/config/externalsecrets"

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "external-secrets"
	Namespace: externalsecrets.config.namespace
	Chart:     externalsecrets.config.chart
	Values: installCRDs: false
}
