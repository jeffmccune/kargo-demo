package holos

import "example.com/platform/schemas/platform"

// Holos specific integration goes in this file.
Component: Resources: {
	// Grant the HTTPRoute access to route to this namespace.
	ReferenceGrant: (platform.#ReferenceGrantBuilder & {Namespace: Parameters.namespace}).ReferenceGrant
}
