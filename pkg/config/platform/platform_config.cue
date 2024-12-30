@extern(embed)
package platform

import (
	"holos.example/pkg/types/platform"
	pkg_istio "holos.example/pkg/config/istio"
)

versions: {
	[string]: string

	externalSecrets: "0.10.7"
}

organization: #Organization
#Organization: platform.#Organization & {
	displayName: "Holos Example"
	domain:      "holos.localhost"
	repoURL:     string | *"https://github.com/holos-run/kargo-demo.git"
}

// stacks represents the software stacks managed in the platform.  Useful to
// iterate over all stacks to compose their components into a Platform.spec.
stacks: #Stacks & {
	argocd: (#StackBuilder & {
		stack: {
			namespaces: {
				argocd:          _
				kargo:           _
				"argo-rollouts": _
			}
			httpRoutes: "argocd": {
				metadata: labels: app: metadata.name
				spec: {
					hostnames: ["argocd.\(organization.domain)"]
					parentRefs: [{
						name:      "default"
						namespace: pkg_istio.config.gateway.namespace
					}]
					rules: [{
						backendRefs: [{
							name:      "argocd-server"
							namespace: "argocd"
							port:      80
						}]
						matches: [{path: {
							type:  "PathPrefix"
							value: "/"
						}}]
					}]
				}
			}
		}

		parameters: {
			name: "argocd"
			components: {
				"argocd-crds": {
					path: "stacks/argocd/components/argocd-crds"
					annotations: description: "argocd custom resource definitions"
				}
				"argocd": {
					path: "stacks/argocd/components/argocd"
					annotations: description: "argocd controller services"
				}
				"app-projects": {
					path: "stacks/argocd/components/app-projects"
					annotations: description: "argocd AppProject resources for each stack"
				}

				"rollouts-crds": {
					path: "stacks/argocd/components/rollouts-crds"
					annotations: description: "argo rollouts custom resource definitions for kargo"
				}
				"rollouts": {
					path: "stacks/argocd/components/rollouts"
					annotations: description: "argo rollouts controller service"
				}

				"kargo-secrets": {
					path: "stacks/argocd/components/kargo-secrets"
					annotations: description: "kargo github app credentials"
				}
				"kargo": {
					path: "stacks/argocd/components/kargo"
					annotations: description: "kargo controllers and crds"
				}
			}
		}
	}).stack

	network: (#StackBuilder & {
		stack: namespaces: {
			istio: metadata: labels: "kargo.akuity.io/project": "true"
			(pkg_istio.config.gateway.namespace): _
			(pkg_istio.config.system.namespace):  _
		}
		parameters: {
			name: "network"
			components: {
				"gateway-api": {
					path: "stacks/network/components/gateway-api"
					annotations: description: "gateway api custom resource definitions"
				}

				"istio-base": {
					path: "stacks/network/components/istio-base"
					annotations: description: "istio base resources"
				}
				"istiod": {
					name: "istiod"
					path: "stacks/network/components/istiod"
					annotations: description: "istiod controller service"
				}
				"istio-cni": {
					name: "istio-cni"
					path: "stacks/network/components/istio-cni"
					annotations: description: "istio cni"
				}
				"istio-ztunnel": {
					name: "istio-ztunnel"
					path: "stacks/network/components/istio-ztunnel"
					annotations: description: "istio ztunnel for ambient mode"
				}
				"istio-gateway": {
					name: "istio-gateway"
					path: "stacks/network/components/istio-gateway"
					annotations: description: "istio ingress gateway"
				}
				"istio-promoter": {
					name: "istio-promoter"
					path: "stacks/shared/components/addon-promoter"
					parameters: {
						kargoProject:  "istio"
						kargoStage:    "main"
						kargoDataFile: pkg_istio.config.datafile
						kargoDataKey:  "chart.version"
						gitRepoURL:    organization.repoURL
						chartName:     "base"
						chartRepoURL:  pkg_istio.config.chart.repository.url
					}
				}
				"httproutes": {
					name: "httproutes"
					path: "stacks/network/components/httproutes"
					labels: component: "httproutes"
				}
			}
		}
	}).stack

	security: (#StackBuilder & {
		stack: namespaces: {
			"cert-manager": metadata: labels: "kargo.akuity.io/project": "true"
			"external-secrets": _
		}
		parameters: {
			name: "security"
			components: {
				namespaces: {
					path: "stacks/security/components/namespaces"
					annotations: description: "configures namespaces for all stacks"
				}
				"external-secrets-crds": {
					path: "stacks/security/components/external-secrets-crds"
					annotations: description: "external secrets custom resource definitions"
					parameters: version:      versions.externalSecrets
				}
				"external-secrets": {
					path: "stacks/security/components/external-secrets"
					annotations: description: "external secrets custom resource definitions"
					parameters: version:      versions.externalSecrets
				}
				"cert-manager": {
					path: "stacks/security/components/cert-manager"
					annotations: description: "cert-manager operator and custom resource definitions"
					parameters: {
						kargoProject: "cert-manager"
						kargoStage:   "main"
					}
				}
				"local-ca": {
					path: "stacks/security/components/local-ca"
					annotations: description: "localhost mkcert certificate authority"
				}
				"cert-manager-kargo": {
					// TODO(jeff) refactor to use stacks/shared/components/addon-promoter
					path: "stacks/security/components/cert-manager-kargo"
					annotations: description: "cert-manager kargo promotion stages"
					parameters: {
						project: "cert-manager"
						stage:   "main"
					}
				}
			}
		}
	}).stack
}

// constrain the platform types
#Stacks: platform.#Stacks & {
	[_]: #Stack & {
		httpRoutes: [_]: {
			metadata: namespace: pkg_istio.config.gateway.namespace
		}
	}
}
#Stack: platform.#Stack

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

// projects represent kargo promotion projects, which are specialized stacks.
projects: #Projects & {
	httpbin: (platform.#ProjectBuilder & {
		let IMAGE = "quay.io/holos/mccutchen/go-httpbin"
		let PROJECT_NAME = parameters.name
		parameters: {
			name: "httpbin"

			// components to manage in each stage
			components: httpbin: {
				name: "httpbin"
				path: "stacks/httpbin/components/httpbin"
				parameters: image: IMAGE
			}

			// Stages organized by prod and nonprod so we can easily get a handle on all
			// prod stages, for example in the HTTPRoute below.
			stages: STAGES & {
				let NONPROD = {tier: "nonprod"}
				dev: NONPROD & {prior: "direct"}
				test: NONPROD & {prior: "dev"}
				uat: NONPROD & {prior: "test"}
				let PROD = {
					tier:  "prod"
					prior: "uat"
					// We have to stringify all injected tags.  This is a reason to switch to
					// passing the component over standard input as structured data.
					component: parameters: replicaCount: "2"
					component: parameters: version:      "v2.14.0"
				}
				"prod-us-east":    PROD
				"prod-us-central": PROD
				"prod-us-west":    PROD
			}
		}
		project: stack: components: {
			// Compose the Kargo promotion stages into the holos project components.
			// Project owners are expected to copy the component path into
			// projects/<project name>/components/kargo-stages and customize it as needed
			// to define their promotion process.
			"project:\(PROJECT_NAME):component:kargo-stages": {
				name: "kargo-stages"
				path: "stacks/shared/components/kargo-stages"
				parameters: image:            IMAGE
				parameters: project:          PROJECT_NAME
				parameters: semverConstraint: "^2.0.0"
			}
		}
	}).project

	podinfo: (platform.#ProjectBuilder & {
		let IMAGE = "quay.io/holos/stefanprodan/podinfo"
		let PROJECT_NAME = parameters.name
		parameters: {
			name: "podinfo"
			// Stages organized by prod and nonprod so we can easily get a handle on all
			// prod stages, for example in the HTTPRoute below.
			stages: STAGES & {
				let PARAMS = {
					metadata: name: string
					component: parameters: message: "Hello! Stage: \(metadata.name)"
				}
				let NONPROD = PARAMS & {
					tier: "nonprod"
					component: parameters: version: "6.7.0"
				}
				dev: NONPROD & {prior: "direct"}
				test: NONPROD & {prior: "dev"}
				uat: NONPROD & {prior: "test"}
				let PROD = PARAMS & {
					tier:  "prod"
					prior: "uat"
					// We have to stringify all injected tags.  This is a reason to switch to
					// passing the component over standard input as structured data.
					component: parameters: replicaCount: "2"
				}
				"prod-us-east": PROD & {
					component: parameters: version: "6.6.1"
				}
				"prod-us-central": PROD & {
					component: parameters: version: "6.6.2"
				}
				"prod-us-west": PROD & {
					component: parameters: version: "6.7.0"
				}
			}
			components: "podinfo": {
				name: "podinfo"
				path: "stacks/podinfo/components/podinfo"
				parameters: image: IMAGE
			}
		}
		project: stack: components: {
			// Compose the Kargo promotion stages into the holos project components.
			// Project owners are expected to copy the component path into
			// projects/<project name>/components/kargo-stages and customize it as needed
			// to define their promotion process.
			"project:\(PROJECT_NAME):component:kargo-stages": {
				name: "kargo-stages"
				path: "stacks/shared/components/kargo-stages"
				parameters: image:            IMAGE
				parameters: project:          PROJECT_NAME
				parameters: semverConstraint: "^6.0.0"
			}
		}
	}).project
}
#Projects: platform.#Projects & {
	[NAME=string]: #Project & {metadata: name: NAME}
}
#Project: platform.#Project & {stack: #Stack}

// Compose each Kargo project into stacks.
for PROJECT in projects {
	stacks: (PROJECT.stack.metadata.name): PROJECT.stack
}

// stages represents stages to manage.
let STAGES = stages

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
