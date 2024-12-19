@if(!NoKargo)
package holos

Parameters: {
	KargoProjectName: string @tag(KargoProjectName)
	KargoStageName:   string @tag(KargoStageName)
}

// Configure the ArgoCD Application to allow updates from Kargo.  Configure a
// stub kustomization.yaml artifact in the output directory for Kargo to edit.
Component: {
	Name:          _
	OutputBaseDir: _
	_OutPath:      "\(OutputBaseDir)/components/\(Name)"

	_ArgoApplication: {
		metadata: annotations: "kargo.akuity.io/authorized-stage": "\(Parameters.KargoProjectName):\(Parameters.KargoStageName)"
		spec: source: {
			path:           "./"
			targetRevision: "project/\(ProjectName)/component/\(Name)"
		}
	}
}
