package platform

import "holos.example/types/platform"

// projects represent kargo promotion projects, which are specialized stacks.
projects: #Projects
#Projects: platform.#Projects & {
	[NAME=string]: #Project & {metadata: name: NAME}
}
#Project: platform.#Project & {stack: #Stack}

// Compose each Kargo project into stacks.
for PROJECT in projects {
	stacks: (PROJECT.stack.metadata.name): PROJECT.stack
}

stages: platform.#Stages & {
	let NONPROD = {
		tier: "nonprod"
	}
	dev: NONPROD
	test: NONPROD & {prior: dev.metadata.name}
	uat: NONPROD & {prior: test.metadata.name}

	let PROD = {
		tier:  "prod"
		prior: uat.metadata.name
	}
	"prod-us-east":    PROD
	"prod-us-central": PROD
	"prod-us-west":    PROD
}
