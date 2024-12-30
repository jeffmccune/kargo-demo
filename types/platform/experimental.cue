package platform

import (
	"list"
	"strings"

	rg "gateway.networking.k8s.io/referencegrant/v1beta1"
)

// #ReferenceGrantBuilder builds a ReferenceGrant.  Useful from within a
// component definition to grant the HTTPRoute access to the namespace the
// component is managed in.
#ReferenceGrantBuilder: {
	parameters: {
		namespace:        string
		gatewayNamespace: #GatewayNamespace
	}

	referenceGrant: (parameters.gatewayNamespace): rg.#ReferenceGrant & {
		metadata: name:      parameters.gatewayNamespace
		metadata: namespace: parameters.namespace
		spec: from: [{
			group:     "gateway.networking.k8s.io"
			kind:      "HTTPRoute"
			namespace: parameters.gatewayNamespace
		}]
		spec: to: [{
			group: ""
			kind:  "Service"
		}]
	}
}

// BackendRefs useful to configure a HTTPRoute backendRefs list using a struct.  T
#BackendRefs: [HTTPRouteName=string]: [NAMESPACE=string]: #BackendRef & {
	name:      HTTPRouteName
	namespace: NAMESPACE
	port:      number | *80
}

// BackendRef copied from
// gateway.networking.k8s.io/httproute/v1.#HTTPRouteSpec.rules.backendRefs
#BackendRef: {
	name: strings.MaxRunes(253) & strings.MinRunes(1)
	namespace?: strings.MaxRunes(63) & strings.MinRunes(1) & {
		=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
	}
	port?:   uint16 & >=1
	weight?: int & <=1000000 & >=0 | *1
	group?:  strings.MaxRunes(253) & =~"^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$" | *""
	kind?:   strings.MaxRunes(63) & strings.MinRunes(1) & =~"^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$" | *"Service"
	filters?: list.MaxItems(16) & [...{
		extensionRef?: {
			group: strings.MaxRunes(253) & {
				=~"^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"
			}
			kind: strings.MaxRunes(63) & strings.MinRunes(1) & {
				=~"^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$"
			}
			name: strings.MaxRunes(253) & strings.MinRunes(1)
		}
		requestHeaderModifier?: {
			add?: list.MaxItems(16) & [...{
				name: strings.MaxRunes(256) & strings.MinRunes(1) & {
					=~"^[A-Za-z0-9!#$%&'*+\\-.^_\\x60|~]+$"
				}
				value: strings.MaxRunes(4096) & strings.MinRunes(1)
			}]
			remove?: list.MaxItems(16) & [...string]
			set?: list.MaxItems(16) & [...{
				name: strings.MaxRunes(256) & strings.MinRunes(1) & {
					=~"^[A-Za-z0-9!#$%&'*+\\-.^_\\x60|~]+$"
				}
				value: strings.MaxRunes(4096) & strings.MinRunes(1)
			}]
		}
		requestMirror?: {
			backendRef: {
				group?: strings.MaxRunes(253) & =~"^$|^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$" | *""
				kind?:  strings.MaxRunes(63) & strings.MinRunes(1) & =~"^[a-zA-Z]([-a-zA-Z0-9]*[a-zA-Z0-9])?$" | *"Service"
				name:   strings.MaxRunes(253) & strings.MinRunes(1)
				namespace?: strings.MaxRunes(63) & strings.MinRunes(1) & {
					=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?$"
				}
				port?: uint16 & >=1
			}
		}
		requestRedirect?: {
			hostname?: strings.MaxRunes(253) & strings.MinRunes(1) & {
				=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"
			}
			path?: {
				replaceFullPath?:    strings.MaxRunes(1024)
				replacePrefixMatch?: strings.MaxRunes(1024)
				type:                "ReplaceFullPath" | "ReplacePrefixMatch"
			}
			port?:       uint16 & >=1
			scheme?:     "http" | "https"
			statusCode?: (301 | 302) & int | *302
		}
		responseHeaderModifier?: {
			add?: list.MaxItems(16) & [...{
				name: strings.MaxRunes(256) & strings.MinRunes(1) & {
					=~"^[A-Za-z0-9!#$%&'*+\\-.^_\\x60|~]+$"
				}
				value: strings.MaxRunes(4096) & strings.MinRunes(1)
			}]
			remove?: list.MaxItems(16) & [...string]
			set?: list.MaxItems(16) & [...{
				name: strings.MaxRunes(256) & strings.MinRunes(1) & {
					=~"^[A-Za-z0-9!#$%&'*+\\-.^_\\x60|~]+$"
				}
				value: strings.MaxRunes(4096) & strings.MinRunes(1)
			}]
		}
		type: "RequestHeaderModifier" | "ResponseHeaderModifier" | "RequestMirror" | "RequestRedirect" | "URLRewrite" | "ExtensionRef"
		urlRewrite?: {
			hostname?: strings.MaxRunes(253) & strings.MinRunes(1) & {
				=~"^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$"
			}
			path?: {
				replaceFullPath?:    strings.MaxRunes(1024)
				replacePrefixMatch?: strings.MaxRunes(1024)
				type:                "ReplaceFullPath" | "ReplacePrefixMatch"
			}
		}
	}]
}
