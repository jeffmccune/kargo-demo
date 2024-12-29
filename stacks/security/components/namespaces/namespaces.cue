package holos

import "example.com/holos/pkg/config/platform"

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

Component: #Kubernetes & {
	for STACK in platform.stacks {
		if STACK.namespaces != _|_ {
			Resources: Namespace: STACK.namespaces
		}
	}
}
