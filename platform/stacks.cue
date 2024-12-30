package main

import "holos.example/pkg/config/platform"

// Register all stack components with the platform spec.
for STACK in platform.stacks {
	Platform: Components: STACK.components
}
