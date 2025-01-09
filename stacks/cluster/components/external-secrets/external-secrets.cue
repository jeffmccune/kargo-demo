package holos

// Produce a helm chart build plan.
holos: Component.BuildPlan

parameters: {
	version: string @tag(version) // 0.10.7
}

Component: #Helm & {
	Name:      "external-secrets"
	Namespace: "external-secrets"
	Chart: {
		name:    "external-secrets"
		version: parameters.version
		repository: {
			name: "external-secrets"
			url:  "https://charts.external-secrets.io"
		}
	}
	Values: installCRDs: false
}
