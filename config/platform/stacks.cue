package platform

import "holos.example/types/platform"

// stacks represents the software stacks managed in the platform.  Useful to
// iterate over all stacks to compose their components into a Platform.spec.
//
// See the *_stack.cue files in this package for specific stack configurations.
stacks: #Stacks

// constrain the platform types
#Stacks: platform.#Stacks & {[_]: #Stack}
#Stack: platform.#Stack

// #StackBuilder builds a #Stack in the stack file from parameters.  Useful to
// build and configure stacks consistently.
#StackBuilder: {
	parameters: {
		name:       platform.#Name
		components: platform.#Components
	}
	stack: #Stack & {
		metadata: name: parameters.name

		for KEY, COMPONENT in parameters.components {
			components: "stacks:\(metadata.name):components:\(KEY)": COMPONENT & {
				name: KEY
				let STACK_NAME = stack.metadata.name
				labels: "holos.run/stack.name":     STACK_NAME
				labels: "holos.run/component.name": name
				// Pass the stack name as a parameter for use with componentconfig.argocd.cue
				parameters: stack: STACK_NAME
			}
		}
	}
}
