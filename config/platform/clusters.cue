@extern(embed)
package platform

import "holos.example/types/platform"

// #Cluster defines the schema of a clusters/*.yaml config file.
#Cluster: platform.#Cluster

// #Clusters defines a collection of clusters organized by name.
#Clusters: platform.#Clusters & {[_]: #Cluster}

// clusters represents all clusters in the platform.
clusters: #Clusters

// clustersByTier represents clusters organized by prod or non-prod.  The
// clusters/*.yaml config files are loaded into this structure for use by the
// rest of the platform configuration.
clustersByTier: #ClustersByTier

// #ClustersByTier organizes collections of clusters by their tier.
#ClustersByTier: {
	prod: platform.#Clusters & {
		[_]: {
			metadata: name: =~"^prod-"
			tier: "prod"
		}
	}
	nonprod: platform.#Clusters & {
		[_]: tier: "nonprod"
	}
}

// Load the cluster configuration data files and unify them into the platform
// configuration.
_clusters: _ @embed(glob=clusters/*.yaml)
_clusters: _ @embed(glob=clusters/*.yml)
_clusters: _ @embed(glob=clusters/*.json)

for CL in _clusters {
	let CLUSTER = CL & #ClusterComponents
	clusters: (CLUSTER.metadata.name): CLUSTER
	clustersByTier: (CLUSTER.tier): (CLUSTER.metadata.name): CLUSTER
}

// #ClusterComponents defines the platform components to manage on every cluster.
#ClusterComponents: #Cluster & {
	metadata: name: string
	let CLUSTER_NAME = metadata.name

	components: [NAME=string]: {
		name: string | *NAME
		path: string | *"stacks/cluster/components/\(name)"
		parameters: stack:         "cluster"
		parameters: outputBaseDir: "clusters/\(CLUSTER_NAME)"
		labels: {
			cluster:   CLUSTER_NAME
			component: name
		}
		annotations: "app.holos.run/description": "\(name) for cluster \(CLUSTER_NAME)"
	}

	// versions represents the default software version of each platform
	// component.
	versions: {
		"external-secrets": string | *"0.10.7"
	}

	// components represents the platform components to manage on each cluster.
	components: {
		// Keep these two components in lock step.
		"external-secrets": parameters: version:      versions["external-secrets"]
		"external-secrets-crds": parameters: version: versions["external-secrets"]
	}
}
