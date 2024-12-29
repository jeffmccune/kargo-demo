package holos

holos: Component.BuildPlan

Component: #Kustomize & {
	KustomizeConfig: Kustomization: namespace: "argo-rollouts"
	KustomizeConfig: Files: "rollouts.yaml":   _
}
