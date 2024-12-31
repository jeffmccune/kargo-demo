@if(!NoKargo)
package holos

parameters: {
	kargoProject: string @tag(kargoProject)
	kargoStage:   string @tag(kargoStage)
}

// Configure the ArgoCD Application to allow updates from Kargo.  Configure a
// stub kustomization.yaml artifact in the output directory for Kargo to edit.
Component: {
	_ArgoApplication: {
		metadata: annotations: "kargo.akuity.io/authorized-stage": "\(parameters.kargoProject):\(parameters.kargoStage)"
	}
}
