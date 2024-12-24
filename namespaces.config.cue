package holos

import "example.com/platform/schemas/platform"

// Namespaces represents all managed namespaces across the platform.  Mix
// namespaces into this structure to manage them automatically from the
// namespaces component.
Namespaces: platform.#Namespaces

for PROJECT in Projects {
	Namespaces: PROJECT.namespaces
}
