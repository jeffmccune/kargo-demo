package holos

import (
	"encoding/yaml"
	ks "sigs.k8s.io/kustomize/api/types"
)

parameters: {
	version: string | *"0.10.7" @tag(version)
}

// Produce a kustomize build plan
holos: Component.BuildPlan

Component: #Kustomize & {
	Name: "external-secrets-crds"

	KustomizeConfig: {
		// Resources: "https://raw.githubusercontent.com/external-secrets/external-secrets/v\(ExternalSecrets.Version)/deploy/crds/bundle.yaml": _
		Files: "bundle.\(parameters.version).yaml": _
		Kustomization: patches: [for x in KustomizePatches {x}]
	}
}

#KustomizePatches: [ArbitraryLabel=string]: ks.#Patch

let KustomizePatches = #KustomizePatches & {
	let Patch = [{
		op:    "replace"
		path:  "/spec/conversion/webhook/clientConfig/service/name"
		value: "external-secrets-webhook"
	}, {
		op:    "replace"
		path:  "/spec/conversion/webhook/clientConfig/service/namespace"
		value: "external-secrets"
	}]

	clustersecretstores: {
		target: {
			group:   "apiextensions.k8s.io"
			version: "v1"
			kind:    "CustomResourceDefinition"
			name:    "clustersecretstores.external-secrets.io"
		}
		patch: yaml.Marshal(Patch)
	}
	externalsecrets: {
		target: {
			group:   "apiextensions.k8s.io"
			version: "v1"
			kind:    "CustomResourceDefinition"
			name:    "externalsecrets.external-secrets.io"
		}
		patch: yaml.Marshal(Patch)
	}
	secretstores: {
		target: {
			group:   "apiextensions.k8s.io"
			version: "v1"
			kind:    "CustomResourceDefinition"
			name:    "secretstores.external-secrets.io"
		}
		patch: yaml.Marshal(Patch)
	}
}
