package holos

import "holos.example/pkg/config/platform"

parameters: {
	project: string @tag(project)
}

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

Component: #Kubernetes & {
	Resources: Project: (parameters.project): {
		spec: promotionPolicies: platform.projects[parameters.project].promotionPolicies
	}
}
