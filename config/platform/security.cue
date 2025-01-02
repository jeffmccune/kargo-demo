package platform

import (
	"holos.example/config/externalsecrets"
	"holos.example/config/certmanager"
)

stacks: security: (#StackBuilder & {
	stack: namespaces: {
		"cert-manager": metadata: labels: "kargo.akuity.io/project":     "true"
		"external-secrets": metadata: labels: "kargo.akuity.io/project": "true"
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
			}
			"external-secrets": {
				path: "stacks/security/components/external-secrets"
				annotations: description: "external secrets custom resource definitions"
			}
			"external-secrets-promoter": {
				name: "external-secrets-promoter"
				path: "stacks/shared/components/addon-promoter"
				parameters: {
					kargoProject:  "external-secrets"
					kargoStage:    "main"
					kargoDataFile: externalsecrets.config.datafile
					kargoDataKey:  "chart.version"
					gitRepoURL:    organization.repoURL
					chartName:     externalsecrets.config.chart.name
					chartRepoURL:  externalsecrets.config.chart.repository.url
				}
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
			"cert-manager-promoter": {
				path: "stacks/shared/components/addon-promoter"
				annotations: description: "cert-manager kargo promotion stages"
				parameters: {
					kargoProject:  "cert-manager"
					kargoStage:    "main"
					kargoDataFile: certmanager.config.datafile
					kargoDataKey:  "chart.version"
					gitRepoURL:    organization.repoURL
					chartName:     certmanager.config.chart.name
					chartRepoURL:  certmanager.config.chart.repository.url
				}
			}
		}
	}
}).stack
