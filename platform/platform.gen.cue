package main

import v1alpha5 "github.com/holos-run/holos/api/author/v1alpha5:author"

Platform: v1alpha5.#Platform & {
	Name: "default"
}

// The holos render platform command processes the Platform resource configured
// by the value of the holos field in the main package.
holos: Platform.Resource
