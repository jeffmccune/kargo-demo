package holos

// parameters injected from the platform spec.
parameters: {
	project:      string                                   @tag(project)
	stage:        string                                   @tag(stage)
	namespace:    string | *"podinfo-demo"                 @tag(namespace)
	image:        string | *"ghcr.io/stefanprodan/podinfo" @tag(image)
	message:      string | *"Hello World"                  @tag(message)
	version:      string | *"6.7.0"                        @tag(version)
	replicaCount: int | *1                                 @tag(replicaCount, type=int)
}

// BuildPlan for holos to execute.
holos: Component.BuildPlan

// Configure the component from input parameters.
Component: #Helm & {
	Chart: {
		name:    "oci://ghcr.io/stefanprodan/charts/podinfo"
		release: "podinfo"
		version: parameters.version
	}

	// Ensure all resources are located in the provided namespace
	KustomizeConfig: Kustomization: namespace: parameters.namespace

	// The #Values definition is imported from the chart and defined in
	// values_schema.cue
	Values: #Values & {
		replicaCount: parameters.replicaCount
		ui: message: parameters.message
		image: {
			tag:        Chart.version
			repository: parameters.image
		}
	}
}
