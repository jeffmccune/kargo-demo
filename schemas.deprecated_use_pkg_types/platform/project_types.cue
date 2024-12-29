package platform

import (
	"github.com/holos-run/holos/api/core/v1alpha5:core"
)

// #Project represents a collection of related components.
#Project: {
	name:       string
	components: #Components
	namespaces: #Namespaces
	httpRoutes: #HTTPRoutes
}

// #Projects represents a collection of #Project values organized by name.
#Projects: [NAME=string]: #Project & {name: NAME}

// #ProjectBuilder assembles a Project from dependencies.
#ProjectBuilder: {
	organization: #Organization
	Project:      #Project
}

// #Components represents a collection of core #Component values organized by an
// arbitrary unique label.
#Components: [string]: #Component

#Component: core.#Component & {
	name:  #Name
	#Name: string
}
