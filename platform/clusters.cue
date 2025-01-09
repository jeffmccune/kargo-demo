package main

import "holos.example/config/platform"

// Register all stack components with the platform spec.
for CLUSTER in platform.clusters {
	for KEY, COMPONENT in CLUSTER.components {
		Platform: Components: "clusters:\(CLUSTER.metadata.name):component:\(KEY)": COMPONENT
	}
}
