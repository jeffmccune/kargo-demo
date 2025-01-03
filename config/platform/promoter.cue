package platform

import "holos.example/types/platform"

// PromoterBuilder represents promotion steps for an add-on component to mix
// into a #StackBuilder.
#PromoterBuilder: platform.#PromoterBuilder & {
	parameters: repoURL: organization.repoURL
}
