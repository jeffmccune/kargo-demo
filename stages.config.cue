package holos

import "example.com/platform/schemas/platform"

// Injected from Platform.spec.components.parameters.StageName
StageName: string | *"dev" @tag(StageName)

Stages: platform.#Stages & {
	let NONPROD = {
		tier: "nonprod"
	}
	dev: NONPROD
	test: NONPROD & {prior: dev.name}
	uat: NONPROD & {prior: test.name}

	let PROD = {
		tier:  "prod"
		prior: uat.name
	}
	"prod-us-east":    PROD
	"prod-us-central": PROD
	"prod-us-west":    PROD
}
