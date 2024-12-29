package httpbin

import "example.com/platform/schemas/kargo"

let IMAGE = "quay.io/holos/mccutchen/go-httpbin"

let PROJECT = kargo.#ProjectBuilder & {
	Name: "httpbin"

	// Namespaces are used as a template, the kargo project builder is expected to
	// prefix each namespace with the stage name.
	Namespaces: (Name): metadata: labels: (kargo.#HTTPRouteLabel): Name

	// Stages organized by prod and nonprod so we can easily get a handle on all
	// prod stages, for example in the HTTPRoute below.
	Stages: {
		let NONPROD = {tier: "nonprod"}
		dev: NONPROD & {prior: "direct"}
		test: NONPROD & {prior: "dev"}
		uat: NONPROD & {prior: "test"}
		let PROD = {
			tier:  "prod"
			prior: "uat"
			// We have to stringify all injected tags.  This is a reason to switch to
			// passing the component over standard input as structured data.
			parameters: replicaCount: "2"
			parameters: version:      "v2.14.0"
		}
		"prod-us-east":    PROD
		"prod-us-central": PROD
		"prod-us-west":    PROD
	}

	Components: (Name): {
		name: Name
		path: "projects/\(Name)/components/\(Name)"
		parameters: image: IMAGE
	}

	// Compose the Kargo promotion stages into the holos project components.
	// Project owners are expected to copy the component path into
	// projects/<project name>/components/kargo-stages and customize it as needed
	// to define their promotion process.
	HolosProject: components: "project:\(Name):component:kargo-stages": {
		name: "kargo-stages"
		path: "components/kargo-stages"
		parameters: image:            IMAGE
		parameters: semverConstraint: "^2.0.0"
	}
}

// Configure the project as a Holos Project.
Projects: (PROJECT.Name): PROJECT.HolosProject

// Configure the project as a Kargo Project.
KargoProjects: (PROJECT.Name): PROJECT.Project
