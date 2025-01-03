@extern(embed)
package platform

import (
	"holos.example/config/kargo"
	"holos.example/types/platform"
)

stacks: argocd: (#StackBuilder & {
	(#PromoterBuilder & {parameters: {
		name: "kargo"
		config: {
			datafile: kargo.config.datafile
			chart: name: "kargo"
			// We use the chart name because this is an oci:// chart with the image
			// uri as the chart name.
			chart: repository: url: kargo.config.chart.name
		}
	}}).promoter

	stack: {
		namespaces: {
			argocd:          _
			"argo-rollouts": _
		}
	}

	parameters: {
		name: "argocd"
		components: {
			"argocd-crds": {
				path: "stacks/argocd/components/argocd-crds"
				annotations: description: "argocd custom resource definitions"
			}
			"argocd-secrets": {
				path: "stacks/argocd/components/argocd-secrets"
				annotations: description: "argocd secrets needed before pods"
			}
			"argocd": {
				path: "stacks/argocd/components/argocd"
				annotations: description: "argocd controller services"
			}
			"app-projects": {
				path: "stacks/argocd/components/app-projects"
				annotations: description: "argocd AppProject resources for each stack"
			}

			"rollouts-crds": {
				path: "stacks/argocd/components/rollouts-crds"
				annotations: description: "argo rollouts custom resource definitions for kargo"
			}
			"rollouts": {
				path: "stacks/argocd/components/rollouts"
				annotations: description: "argo rollouts controller service"
			}

			"kargo-secrets": {
				path: "stacks/argocd/components/kargo-secrets"
				annotations: description: "kargo github app credentials"
			}
			"kargo": {
				path: "stacks/argocd/components/kargo"
				annotations: description: "kargo controllers and crds"
			}
		}
	}
}).stack
