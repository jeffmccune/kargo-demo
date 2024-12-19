package holos

import "path"

Parameters: {
	KargoProjectName: string @tag(KargoProjectName)
	KargoStageName:   string @tag(KargoStageName)
}

holos: Component.BuildPlan

// Manage a Kargo Project and promotion stages for cert-manager.  The use case
// is to watch for new helm chart versions and submit a PR against the main
// branch with the fully rendered manifests.
//
// This integration requires at least holos 0.101.7 to load external data from a
// yaml file.  Kargo will bump the chart version in the yaml file.
Component: #Kubernetes & {
	Resources: {
		let STAGE = "main"

		// The project is the same as the namespace, we adopt the namespace with the
		// kargo.akuity.io/project: "true" label, configured by the namespaces
		// component.
		Project: (CertManager.namespace): spec: promotionPolicies: [{
			stage: STAGE
		}]

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

		let SRC_PATH = "./src"
		let DATAFILE = path.Join([SRC_PATH, CertManager.datafile])
		let BRANCH = "kargo/\(Parameters.KargoProjectName)/\(Parameters.KargoStageName)"

		Stage: (STAGE): {
			metadata: name:      STAGE
			metadata: namespace: CertManager.namespace
			spec: {
				requestedFreight: [{
					origin: {
						kind: "Warehouse"
						name: Warehouse["cert-manager"].metadata.name
					}
					sources: direct: true
				}]
				promotionTemplate: spec: {
					steps: [
						{
							uses: "git-clone"
							config: {
								repoURL: Organization.RepoURL
								// Unlike the Kargo Quickstart, we aren't promoting into a
								// different branch, we're going to submit a PR to main, so we
								// only need to checkout main.
								checkout: [{
									branch: "main"
									path:   SRC_PATH
								}]
							}
						},
						{
							uses: "yaml-update"
							as:   "update-chart"
							config: {
								path: DATAFILE
								updates: [{
									key: "CertManager.chart.version"
									// https://docs.kargo.io/references/expression-language/#chartfrom
									value: "${{ chartFrom(\"\(CertManager.chart.repository.url)\", warehouse(\"cert-manager\")).Version }}"
								}]
							}
						},
						{
							uses: "git-commit"
							as:   "commit"
							config: {
								path: SRC_PATH
								messageFromSteps: ["update-chart"]
							}
						},
						{
							uses: "git-push"
							config: {
								path:         SRC_PATH
								targetBranch: BRANCH
							}
						},
						{
							uses: "git-open-pr"
							as:   "open-pr"
							config: {
								repoURL:      Organization.RepoURL
								sourceBranch: BRANCH
								targetBranch: "main"
							}
						},
						{
							uses: "git-wait-for-pr"
							as:   "merge-pr"
							config: {
								repoURL:  Organization.RepoURL
								prNumber: "${{ outputs['open-pr'].prNumber }}"
							}
						},
						{
							uses: "argocd-update"
							config: {
								apps: [{
									name: "\(ProjectName)-cert-manager"
									sources: [{
										updateTargetRevision: true
										repoURL:              Organization.RepoURL
										desiredRevision:      "${{ outputs['merge-pr'].commit }}"
									}]
								}]
							}
						},
					]
				}
			}
		}

	}
}
