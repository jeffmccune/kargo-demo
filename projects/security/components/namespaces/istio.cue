package holos

import "example.com/platform/config/istio"

_Istio: istio.ProjectBuilder & {organization: Organization}

// Register the istio namespaces.
Namespaces: _Istio.Project.namespaces
