package holos

import "path"

parameters: {
	kargoProject: string           @tag(kargoProject)
	kargoStage:   string | *"main" @tag(kargoStage)
	// The datafile where the version is stored
	kargoDataFile: string @tag(kargoDataFile)
	// The key in the data file where the version is stored
	kargoDataKey: string @tag(kargoDataKey)
	gitRepoURL:   string @tag(gitRepoURL)
	chartName:    string @tag(chartName)
	chartRepoURL: string @tag(chartRepoURL)
}

holos: Component.BuildPlan

// Manage a Kargo Project and promotion stages for a cluster add-on.  The use
// case is to watch for new helm chart versions and submit a PR against the main
// branch with the fully rendered manifests.
//
// This integration requires at least holos 0.101.7 to load external data from a
// yaml file.  Kargo will bump the chart version in the yaml file.
Component: #Kubernetes & {

	let PROJECT = parameters.kargoProject
	let STAGE = parameters.kargoStage

	Resources: {
		// The project is the same as the namespace, we adopt the namespace with the
		// kargo.akuity.io/project: "true" label, configured by the namespaces
		// component.
		Project: (PROJECT): {
			metadata: annotations: "link.argocd.argoproj.io/external-link": "https://kargo.holos.localhost/project/\(PROJECT)"
			spec: promotionPolicies: [{
				stage:                STAGE
				autoPromotionEnabled: true
			}]
		}

		Warehouse: (PROJECT): {
			metadata: name:      PROJECT
			metadata: namespace: PROJECT
			metadata: annotations: "link.argocd.argoproj.io/external-link": "https://kargo.holos.localhost/project/\(PROJECT)/warehouse/\(PROJECT)"
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
						repoURL: parameters.chartRepoURL
						if repoURL !~ "^oci://" {
							name: parameters.chartName
						}
					}
				}]
			}
		}

		let SRC_PATH = "./src"
		let DATAFILE = path.Join([SRC_PATH, parameters.kargoDataFile], path.Unix)

		// Change how use use expressions if we're using an oci chart or not.
		let EXPRESSIONS = {
			// https://docs.kargo.io/references/expression-language/#chartfrom
			if parameters.chartRepoURL !~ "^oci://" {
				chartFrom: "chartFrom('\(parameters.chartRepoURL)', '\(parameters.chartName)', warehouse('\(PROJECT)'))"
			}
			if parameters.chartRepoURL =~ "^oci://" {
				chartFrom: "chartFrom('\(parameters.chartRepoURL)', warehouse('\(PROJECT)'))"
			}
		}

		Stage: (STAGE): {
			metadata: name:      STAGE
			metadata: namespace: PROJECT
			metadata: annotations: "link.argocd.argoproj.io/external-link": "https://kargo.holos.localhost/project/\(PROJECT)/stage/\(STAGE)"
			spec: {
				requestedFreight: [{
					origin: {
						kind: "Warehouse"
						name: Warehouse[PROJECT].metadata.name
					}
					sources: direct: true
				}]
				promotionTemplate: spec: {
					steps: [
						{
							uses: "git-clone"
							config: {
								repoURL: parameters.gitRepoURL
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
							as:   "update"
							config: {
								path: DATAFILE
								updates: [{
									key: parameters.kargoDataKey
									// https://docs.kargo.io/references/expression-language/#chartfrom
									value: "${{ \(EXPRESSIONS.chartFrom).Version }}"
								}]
							}
						},
						{
							// https://docs.kargo.io/references/promotion-steps#git-commit
							uses: "git-commit"
							as:   "commit"
							config: {
								path:    SRC_PATH
								message: "\(PROJECT): update to ${{ \(EXPRESSIONS.chartFrom).Version }}"
							}
						},
						{
							// https://docs.kargo.io/references/promotion-steps#git-push
							uses: "git-push"
							as:   "push"
							config: {
								path:                 SRC_PATH
								generateTargetBranch: true
							}
						},
						{
							// https://docs.kargo.io/references/promotion-steps#git-open-pr
							uses: "git-open-pr"
							as:   "pull"
							config: {
								repoURL:      parameters.gitRepoURL
								sourceBranch: "${{ outputs.push.branch }}"
								targetBranch: "main"
							}
						},
					]
				}
			}
		}

	}

	_ArgoApplication: {
		metadata: annotations: "link.argocd.argoproj.io/external-link": "https://kargo.holos.localhost/project/\(PROJECT)"
		spec: info: [{
			name:  "Kargo Project"
			value: "https://kargo.holos.localhost/project/\(PROJECT)"
		}]
	}
}
