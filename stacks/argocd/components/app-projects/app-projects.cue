package holos

import (
	ap "argoproj.io/appproject/v1alpha1"

	"example.com/holos/pkg/config/platform"
)

holos: Component.BuildPlan

// Manage all app projects.
Component: #Kubernetes & {
	Resources: AppProject: AppProjects
}

// Configure an AppProject for each holos stack in the platform.
AppProjects: #AppProjects & {
	for STACK in platform.stacks {
		(STACK.metadata.name): _
	}
}

// ArgoCD AppProject collection
#AppProjects: [NAME=string]: #AppProject & {
	metadata: name: NAME
}
#AppProject: ap.#AppProject & {
	metadata: name:      string
	metadata: namespace: string | *"argocd"
	spec: description:   string | *"Holos managed AppProject"
	spec: clusterResourceWhitelist: [{group: "*", kind: "*"}]
	spec: destinations: [{namespace: "*", server: "*"}]
	spec: sourceRepos: ["*"]
}
