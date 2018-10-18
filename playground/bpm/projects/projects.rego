package bpm.projects

import data.organizations

default allow = false

organization = data.bpm.dm.organization

# GET / : Swagger UI page
allow {
    input.method = "GET"
    input.path = [""]
}

# GET /projects : List all projects
# IOET employees only
allow { 
    input.method = "GET"
    input.path = ["projects"]
    data.bpm.dm.employee(input.user)
}

# POST /projects : Create a project
# Only employees of an organization
allow {
    input.method = "POST"
    input.path = ["projects"]
    input.user = organizations[org_id].employees[empl_id].id
}

# POST /projects/search : Search projects

# Employees can search projects of their organization
allow {
    input.method = "GET"
    input.path = ["projects", "search"]
    input.user = organizations[org_id].employees[empl_id].id
}

# Coordinators can search projects of their organization
allow {
    input.method = "GET"
    input.path = ["projects", "search"]
    input.user = organizations[org_id].coordinators[_]
}

# Members can search projects of their organization
allow {
    input.method = "GET"
    input.path = ["projects", "search"]
    input.user = organizations[org_id].projects[_].members[_]
}

# DELETE /project/{id} : Delete a project

# Coordinators can delete projects
allow {
    input.method = "DELETE"
    input.path = ["projects", project_id]
    data.bpm.dm.coordinator_in_org_of_project(input.user, project_id)
}

# Employees can delete projects
allow {
    input.method = "DELETE"
    input.path = ["projects", project_id]
    data.bpm.dm.employee_in_org_of_project(input.user, project_id)
}

# PUT /project/{id} : Create or Update a project

# Employees of an organization
allow {
    input.method = "PUT"
    input.path = ["projects", project_id]
    input.user = organizations[org_id].employees[empl_id].id
}

# Coordinators of an organization
allow {
    input.method = "PUT"
    input.path = ["projects", project_id]
    input.user = organizations[org_id].coordinators[_]
}

# GET /project/{id} : Retrieve a project

# Employees, members and coordinators in an organization can read projects
allow {
    input.method = "GET"
    input.path = ["projects", project_id]
    data.bpm.dm.can_read(input.user, project_id)
}

# POST /project/{id} : Updates a project using POST data

# Employees of an organization
allow {
    input.method = "POST"
    input.path = ["projects", project_id]
    input.user = organizations[org_id].employees[empl_id].id
}

# Coordinators of an organization
allow {
    input.method = "POST"
    input.path = ["projects", project_id]
    input.user = organizations[org_id].coordinators[_]
}