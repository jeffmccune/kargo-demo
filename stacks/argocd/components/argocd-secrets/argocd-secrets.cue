package holos

// Produce a helm chart build plan.
holos: Component.BuildPlan

// Create the redis secret prior to configuring ArgoCD so we avoid 401 NOAUTH
// errors in the web ui.  ArgoCD does not eventually converge, races with the
// redis auth credentials.

Component: #Kubernetes & {
	Resources: [_]: [_]: metadata: namespace: "argocd"

	Resources: {
		ExternalSecret: "argocd-redis": {
			metadata: name: "argocd-redis"
			spec: {
				target: {
					creationPolicy: "Owner"
					deletionPolicy: "Delete"
					template: {
						type:          "Opaque"
						mergePolicy:   "Replace"
						engineVersion: "v2"
						data: auth: "{{ .password }}"
					}
				}
				dataFrom: [{
					// Specify the top level key for the generated value.  This key is
					// used in the ExternalSecret.spec.target.template.data templates.
					rewrite: [{transform: template: "password"}]
					sourceRef: {
						generatorRef: {
							apiVersion: "generators.external-secrets.io/v1alpha1"
							kind:       "Password"
							name:       Password.redis.metadata.name
						}
					}
				}]
			}
		}

		Password: redis: {
			metadata: name: "argocd-redis"
			spec: SPEC
		}

		let SPEC = {
			length:      16
			digits:      4
			symbols:     0
			allowRepeat: true
			noUpper:     false
		}
	}
}
