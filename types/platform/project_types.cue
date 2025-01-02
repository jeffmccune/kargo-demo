package platform

import stage "kargo.akuity.io/stage/v1alpha1"

// Namespaces with this label automatically have HTTPRoute resources built by
// #ProjectBuilder.
#HTTPRouteLabel: "holos.run/httproute.project"

// #Projects defines the structure of a kargo project, useful for kargo
// related components to look up data given a ProjectName.
#Projects: [NAME=string]: #Project & {metadata: name: NAME}

// #Project defines the structure of a project configured for progressive
// rollouts with Kargo.
//
// See the #ProjectBuilder for how concrete values of this schema are built from
// a collection of components and stages.
#Project: {
	metadata: name: #Name

	stages: #Stages

	// stack represents the holos stack associated with the kargo project.
	stack: #Stack

	// promotions maps the promotable component names to pipeline stages.
	promotions: [#Name]: {
		requestedFreight: stage.#StageSpec.requestedFreight
	}
	// TODO(jeff) does this for loop belong in a definition?
	// Automatically promote non-prod stages.
	promotionPolicies: [for STAGE in stages if STAGE.tier == "nonprod" {
		stage:                STAGE.metadata.name
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
	parameters: {
		name: string
		// stages to manage resources within.
		stages: #Stages
		// Components to manage in each Stage.
		components: #Components
	}

	// project represents the built kargo project.
	project: #Project & {
		metadata: name: parameters.name
		stages: parameters.stages

		// stack represents the associated holos stack.
		stack: #Stack & {
			let PROJECT_NAME = project.metadata.name
			metadata: name: PROJECT_NAME

			// Write all artifacts to the project specific directory.
			// NOTE: we use a for loop because using components: [_]: parameters
			// doesn't work as expected in cue 0.11.1
			for KEY, COMPONENT in components {
				components: (KEY): COMPONENT & {
					parameters: {
						stack:         PROJECT_NAME
						outputBaseDir: "projects/\(PROJECT_NAME)"
					}
					// Labels to select specific stacks when rendering.
					labels: "holos.run/stack.name":     PROJECT_NAME
					labels: "holos.run/component.name": COMPONENT.name
					labels: "holos.run/project.name":   PROJECT_NAME
					// Configure how the holos cli displays the rendered ... in ... log lines.
					annotations: "app.holos.run/description": "\(COMPONENT.name) for project \(PROJECT_NAME)"
				}
			}

			// Manage a namespace for the Kargo Project resource itself.  This namespace
			// is a container for the promotion stages.
			namespaces: (PROJECT_NAME): {
				metadata: labels: "kargo.akuity.io/project": "true"
			}

			// Manage the component that manages the Kargo Project resource.
			components: "projects:\(PROJECT_NAME):component:kargo-project": {
				// A static name is OK because OutputBaseDir is scoped to the project.  If
				// it weren't scoped to the project, multiple projects would clobber each
				// other in the deploy directory.
				name: "kargo-project"
				path: "stacks/shared/components/kargo-project"
				parameters: project: PROJECT_NAME
			}

			for STAGE in project.stages {
				namespaces: "\(STAGE.metadata.name)-\(PROJECT_NAME)": {
					// Label the namespace with the stage name and tier so we can select
					// where to route traffic easily.
					metadata: labels: "holos.run/stage.name":        STAGE.metadata.name
					metadata: labels: "holos.run/stage.tier":        STAGE.tier
					metadata: labels: "holos.run/httproute.project": PROJECT_NAME
				}

				for COMPONENT in parameters.components {
					// Unique key to roll the component into the platform spec.
					let COMPONENT_KEY = "project:\(PROJECT_NAME):stage:\(STAGE.metadata.name):component:\(COMPONENT.name)"

					// Generate a new component with the stage specific name and output.
					let STAGE_COMPONENT = {
						name: "\(STAGE.metadata.name)-\(COMPONENT.name)"
						for k, v in COMPONENT if k != "name" {
							(k): v
						}

						// Pass parameters to the component as tags so the component
						// definition can look up project and stage specific values.
						parameters: project:   PROJECT_NAME
						parameters: stage:     STAGE.metadata.name
						parameters: namespace: "\(STAGE.metadata.name)-\(PROJECT_NAME)"
						// Mix in the stage scoped component parameters
						parameters: STAGE.component.parameters
					}
					namespaces: (STAGE_COMPONENT.name): _
					components: (COMPONENT_KEY):        STAGE_COMPONENT
				}
			}
		}

		for STAGE in stages {
			for COMPONENT in parameters.components {
				let PARAMS = {
					Prior: STAGE.prior
					Warehouse: name: COMPONENT.name
				}
				promotions: (STAGE.metadata.name): requestedFreight: (#StageSpecBuilder & PARAMS).spec.requestedFreight
			}
		}
	}
}
