@extern(embed)
package platform

import "example.com/holos/pkg/types/platform"

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
		stack: namespaces: {
			argocd:          _
			kargo:           _
			"argo-rollouts": _
		}

		parameters: {
			name: "argocd"
			components: {
				"argocd-crds": {
					path: "stacks/argocd/components/argocd-crds"
					annotations: description: "argocd custom resource definitions"
				}
				"rollouts-crds": {
					path: "stacks/argocd/components/rollouts-crds"
					annotations: description: "argo rollouts custom resource definitions for kargo"
				}
			}
		}
	}).stack

	network: (#StackBuilder & {
		stack: namespaces: {
			istio: metadata: labels: "kargo.akuity.io/project": "true"
			"istio-ingress": _
			"istio-system":  _
		}
		parameters: {
			name: "network"
			components: {
				"gateway-api": {
					path: "stacks/network/components/gateway-api"
					annotations: description: "gateway api custom resource definitions"
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
			}
		}
	}).stack
}

// constrain the platform types
#Stacks: platform.#Stacks & {[_]: #Stack}
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

				// configure output manifests to stacks/foo/components/bar/bar.gen.yaml
				// for component bar.
				// TODO(jeff): uncomment to desired per-stack location after domain
				// model refactor completes.
				// parameters: outputBaseDir: "stacks/\(metadata.name)"
			}
		}
	}
}
