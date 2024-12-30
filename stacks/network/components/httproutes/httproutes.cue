package holos

import (
	"gateway.networking.k8s.io/httproute/v1"
	"holos.example/config/platform"
)

// Produce a kubernetes objects build plan.
holos: Component.BuildPlan

HTTPRoutes: [NAME=string]: v1.#HTTPRoute & {
	metadata: name:      NAME
	metadata: namespace: "istio-ingress"
	metadata: labels: app:                           NAME
	metadata: labels: "argocd.argoproj.io/instance": "network-httproutes"
	spec: {
		hostnames: ["\(NAME).\(platform.organization.domain)"]
		parentRefs: [{
			name:      "default"
			namespace: "istio-ingress"
		}]
	}
}

HTTPRoutes: {
	argocd: {
		spec: rules: [{
			backendRefs: [{
				name:      "argocd-server"
				namespace: "argocd"
				port:      80
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	kargo: {
		spec: rules: [{
			backendRefs: [{
				name:      "kargo-api"
				namespace: "kargo"
				port:      80
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}

	// httpbin project
	"dev-httpbin": {
		spec: rules: [{
			backendRefs: [{
				name:      "httpbin"
				namespace: "dev-httpbin"
				port:      80
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"test-httpbin": {
		spec: rules: [{
			backendRefs: [{
				name:      "httpbin"
				namespace: "test-httpbin"
				port:      80
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"uat-httpbin": {
		spec: rules: [{
			backendRefs: [{
				name:      "httpbin"
				namespace: "uat-httpbin"
				port:      80
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"httpbin": {
		spec: rules: [{
			backendRefs: [{
				name:      "httpbin"
				namespace: "prod-us-east-httpbin"
				port:      80
			}, {
				name:      "httpbin"
				namespace: "prod-us-central-httpbin"
				port:      80
			}, {
				name:      "httpbin"
				namespace: "prod-us-west-httpbin"
				port:      80
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}

	// podinfo project

	"dev-podinfo": {
		spec: rules: [{
			backendRefs: [{
				name:      "podinfo"
				namespace: "dev-podinfo"
				port:      9898
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"test-podinfo": {
		spec: rules: [{
			backendRefs: [{
				name:      "podinfo"
				namespace: "test-podinfo"
				port:      9898
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"uat-podinfo": {
		spec: rules: [{
			backendRefs: [{
				name:      "podinfo"
				namespace: "uat-podinfo"
				port:      9898
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"podinfo": {
		spec: rules: [{
			backendRefs: [{
				name:      "podinfo"
				namespace: "prod-us-east-podinfo"
				port:      9898
			}, {
				name:      "podinfo"
				namespace: "prod-us-central-podinfo"
				port:      9898
			}, {
				name:      "podinfo"
				namespace: "prod-us-west-podinfo"
				port:      9898
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"prod-us-east-podinfo": {
		spec: rules: [{
			backendRefs: [{
				name:      "podinfo"
				namespace: "prod-us-east-podinfo"
				port:      9898
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"prod-us-central-podinfo": {
		spec: rules: [{
			backendRefs: [{
				name:      "podinfo"
				namespace: "prod-us-central-podinfo"
				port:      9898
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
	"prod-us-west-podinfo": {
		spec: rules: [{
			backendRefs: [{
				name:      "podinfo"
				namespace: "prod-us-west-podinfo"
				port:      9898
			}]
			matches: [{path: {type: "PathPrefix", value: "/"}}]
		}]
	}
}

Component: #Kubernetes & {
	Name: "httproutes"
	Resources: HTTPRoute: HTTPRoutes
}
