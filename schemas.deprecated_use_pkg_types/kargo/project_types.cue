package kargo

import (
	"example.com/platform/schemas/platform"
	stage "kargo.akuity.io/stage/v1alpha1"
)

// Namespaces with this label automatically have HTTPRoute resources built by
// #ProjectBuilder.
#HTTPRouteLabel: "holos.run/httproute.project"

// #Projects defines the structure of a kargo project, useful for kargo
// related components to look up data given a ProjectName.
#Projects: [NAME=string]: #Project & {name: NAME}

// #Project defines the structure of a project configured for progressive
// rollouts with Kargo.
//
// See the #ProjectBuilder for how concrete values of this schema are built from
// a collection of components and stages.
#Project: {
	name:  #Name
	#Name: string

	stages: platform.#Stages

	// promotions maps the promotable component names to pipeline stages.
	promotions: [platform.#Component.#Name]: {
		requestedFreight: stage.#StageSpec.requestedFreight
	}

	// Automatically promote non-prod stages.
	promotionPolicies: [for STAGE in stages if STAGE.tier == "nonprod" {
		stage:                STAGE.name
		autoPromotionEnabled: true
	}]
}

// ProjectBuilder expands components out across the provided stages.  The
// builder configures both a Kargo Project and a Holos Project.  The kargo
// project manages the promotion process across stages for the components in the
// project.
//
// We define an abstraction over both kinds of projects, holos and kargo,
// because the two are closely related but not the same.
//
// The Holos Project is used to associate multiple related components together
// and isn't concerned with Kargo.
//
// The Kargo Project is used to define a progressive rollout promotion pipeline
// across multiple stages.  For example, Kargo handles the business use case:
// automatically promote from dev to test to uat, then submit a pull request to
// promote to production.  On merge, roll out to production across regions from
// east to west, verifying each deployment is healthy before proceeding to the
// next.
#ProjectBuilder: {
	Name: string | *"default"
	// Stages to manage resources within.
	Stages: platform.#Stages
	// Namespaces to manage in each Stage.
	Namespaces: [NAME=string]: {
		name: NAME
		metadata: labels: [string]: string
	}
	// Components to manage in each Stage.
	Components: platform.#Components

	// Project represents the built kargo project.
	Project: #Project & {
		name:   Name
		stages: Stages

		for STAGE in stages {
			for COMPONENT in Components {
				let PARAMS = {
					Prior: STAGE.prior
					Warehouse: name: COMPONENT.name
				}
				promotions: (STAGE.name): requestedFreight: (#StageSpecBuilder & PARAMS).spec.requestedFreight
			}
		}
	}

	// HolosProject represents the associated holos project.
	HolosProject: platform.#Project & {
		name: Name

		// Write all artifacts to the project specific directory.
		for KEY, COMPONENT in components {
			components: (KEY): parameters: outputBaseDir: "projects/\(Name)"
		}

		// Manage a namespace for the Kargo Project resource itself.  This namespace
		// is a container for the promotion stages.
		namespaces: (Name): {
			metadata: labels: "kargo.akuity.io/project": "true"
		}

		// Manage the component that manages the Kargo Project resource.
		components: "project:\(Name):component:kargo-project": {
			// A static name is OK because OutputBaseDir is scoped to the project.  If
			// it weren't scoped to the project, multiple projects would clobber each
			// other in the deploy directory.
			name: "kargo-project"
			path: "components/kargo-project"
			parameters: ProjectName: Name
		}

		for STAGE in Stages {
			for NAMESPACE in Namespaces {
				namespaces: "\(STAGE.name)-\(NAMESPACE.name)": {
					// Compose labels provided to make it easy to select the namespaces
					// this builder builds.
					metadata: labels: NAMESPACE.metadata.labels
					// Label the namespace with the stage name and tier so we can select
					// where to route traffic easily.
					metadata: labels: "holos.run/stage.name": STAGE.name
					metadata: labels: "holos.run/stage.tier": STAGE.tier
				}
			}

			for COMPONENT in Components {
				// Unique key to roll the component into the platform spec.
				let COMPONENT_KEY = "project:\(Name):stage:\(STAGE.name):component:\(COMPONENT.name)"

				// Generate a new component with the stage specific name and output.
				let STAGE_COMPONENT = {
					name: "\(STAGE.name)-\(COMPONENT.name)"
					for k, v in COMPONENT if k != "name" {
						(k): v
					}

					// Pass parameters to the component as tags so the component
					// definition can look up project and stage specific values.
					parameters: ProjectName:   Name
					parameters: StageName:     STAGE.name
					parameters: NamespaceName: name
					// Mix in the stage parameters
					parameters: STAGE.parameters
				}
				namespaces: (STAGE_COMPONENT.name): _
				components: (COMPONENT_KEY):        STAGE_COMPONENT
			}
		}

		// Mix HTTPRoute resources into the holos project.
		httpRoutes: {
			[string]: {
				_backendRefs: [string]: platform.#BackendRef

				spec: rules: [{
					matches: [{path: {type: "PathPrefix", value: "/"}}]
					backendRefs: [for x in _backendRefs {x}]
				}]
			}
		}

		let PROJECT_NAME = name

		// Compose stage specific httproutes with the platform selecting namespaces.
		for NS in namespaces {
			for K, V in NS.metadata.labels {
				if K == #HTTPRouteLabel && V == PROJECT_NAME {
					// Note we assume the backend service name is the project name.  Consider
					// adding a service name field to the project to let the differ.
					httpRoutes: (NS.metadata.name): _backendRefs: (NS.metadata.name): {
						name:      PROJECT_NAME
						namespace: NS.metadata.name
					}
				}

				// Manage a backend ref for all prod tier stages.
				if K == "holos.run/stage.tier" && V == "prod" {
					// Note we assume the backend service name is the project name.  Consider
					// adding a service name field to the project to let the differ.
					httpRoutes: (PROJECT_NAME): _backendRefs: (NS.metadata.name): {
						name:      PROJECT_NAME
						namespace: NS.metadata.name
					}
				}
			}
		}
	}
}
