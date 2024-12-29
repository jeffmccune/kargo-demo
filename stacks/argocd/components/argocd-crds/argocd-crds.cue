package holos

holos: Component.BuildPlan

_version: string | *"2.13.2" @tag(version)

Component: #Kustomize & {
	KustomizeConfig: {
		Files: "argocd-crds.\(_version).yaml": _
		// Resources: {
		// 	"https://raw.githubusercontent.com/argoproj/argo-cd/v\(ArgoCD.Version)/manifests/crds/application-crd.yaml":    _
		// 	"https://raw.githubusercontent.com/argoproj/argo-cd/v\(ArgoCD.Version)/manifests/crds/applicationset-crd.yaml": _
		// 	"https://raw.githubusercontent.com/argoproj/argo-cd/v\(ArgoCD.Version)/manifests/crds/appproject-crd.yaml":     _
		// }
	}
}
