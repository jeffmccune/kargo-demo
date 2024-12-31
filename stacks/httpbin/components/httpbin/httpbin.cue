package holos

// parameters injected from the platform spec.
parameters: {
	namespace:    string | *"httpbin-demo"                       @tag(namespace)
	image:        string | *"quay.io/holos/mccutchen/go-httpbin" @tag(image)
	version:      string | *"v2.14.1"                            @tag(version)
	replicaCount: int | *1                                       @tag(replicaCount, type=int)
}

// Not used, but part of the project builder interface.
parameters: {
	project: string @tag(project)
	stage:   string @tag(stage)
}

// BuildPlan for holos to execute.
holos: Component.BuildPlan

// Configure the component from input parameters.
Component: #Kubernetes & {
	// Configure all resources in the desired namespace
	Resources: [_]: [_]: metadata: namespace: parameters.namespace

	Resources: {
		Deployment: httpbin: {
			metadata: name:      "httpbin"
			metadata: namespace: parameters.namespace
			spec: {
				replicas: parameters.replicaCount
				selector: matchLabels: "app.kubernetes.io/name": "httpbin"
				template: {
					metadata: labels: selector.matchLabels
					spec: {
						containers: [{
							name:  "httpbin"
							image: parameters.image
							ports: [{
								name:          "http"
								containerPort: 8080
								protocol:      "TCP"
							}]
							livenessProbe: httpGet: {
								path: "/status/200"
								port: "http"
							}
							readinessProbe: livenessProbe
							resources: {}
						}]
					}
				}
			}

		}

		Service: httpbin: {
			metadata: name:      "httpbin"
			metadata: namespace: parameters.namespace
			spec: {
				selector: Deployment.httpbin.spec.selector.matchLabels
				ports: [{
					port:        80
					targetPort:  "http"
					protocol:    "TCP"
					name:        "http"
					appProtocol: "http"
				}]
			}
		}
	}
}
