package holos

parameters: {
	version: string | *"0.10.7" @tag(version)
}

// Produce a helm chart build plan.
holos: Component.BuildPlan

Component: #Helm & {
	Name:      "external-secrets"
	Namespace: "external-secrets"

	Chart: {
		version: parameters.version
		repository: {
			name: "external-secrets"
			url:  "https://charts.external-secrets.io"
		}
	}

	Values: installCRDs: false
}
