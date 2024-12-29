package holos

import "example.com/holos/pkg/types/platform"

let PARAMETERS = parameters

// Holos specific integration goes in this file.
Component: Resources: {
	// Grant the HTTPRoute access to route to this namespace.
	ReferenceGrant: (platform.#ReferenceGrantBuilder & {
		parameters: namespace: PARAMETERS.namespace
	}).referenceGrant
}
