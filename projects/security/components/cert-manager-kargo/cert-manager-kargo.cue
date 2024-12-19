package holos

holos: Component.BuildPlan

// Manage a Kargo Project and promotion stages for cert-manager.  The use case
// is to watch for new helm chart versions and submit a PR against the main
// branch with the fully rendered manifests.
//
// This integration requires at least holos 0.101.7 to load external data from a
// yaml file.  Kargo will bump the chart version in the yaml file.
Component: #Kubernetes & {
	Resources: {
		// The project is the same as the namespace, we adopt the namespace with the
		// kargo.akuity.io/project: "true" label, configured by the namespaces
		// component.
		Project: (CertManager.namespace): _

		Warehouse: "cert-manager": {
			metadata: name:      "cert-manager"
			metadata: namespace: CertManager.namespace
			spec: {
				// implicit value is Automatic
				freightCreationPolicy: "Automatic"
				// implicit value is 5m0s
				interval: "5m0s"
				subscriptions: [{
					chart: {
						// We leave semverConstraint empty to fetch the latest version
						// because the pipeline submits a pull request that must be manually
						// reviewed and approved.  The purpose is to automate the process of
						// showing the platform engineer what will change.
						name:    CertManager.chart.name
						repoURL: CertManager.chart.repository.url
					}
				}]
			}
		}
	}
}
