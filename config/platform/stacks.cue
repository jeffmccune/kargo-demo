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
#StackBuilder: platform.#StackBuilder & {stack: #Stack}
