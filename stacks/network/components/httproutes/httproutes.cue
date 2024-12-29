package holos

import "example.com/holos/pkg/config/platform"

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

Component: #Kubernetes & {
	Name: "httproutes"
	Resources: HTTPRoute: {
		for STACK in platform.stacks {
			if STACK.httpRoutes != _|_ {
				STACK.httpRoutes
			}
		}
	}
}
