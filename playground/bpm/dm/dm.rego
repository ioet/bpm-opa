package bpm.dm

import data.organizations
import data.employees

default allow = false

allow = {
    can_read(input.user, input.project)
}

can_read(user, project) {
    employee_in_org_of_project(user, project)
}

can_read(user, project) {
    member_of_project(user, project)
}

can_read(user, project) {
    coordinator_in_org_of_project(user, project)
}

employee_in_org_of_project(person_id, project_id) {
    person_id = organizations[org_idx].employees[_].id
    project_id = organizations[org_idx].projects[_].id
}

member_of_project(person_id, project_id) {
    project_id = organizations[org_id].projects[proj_id].id
    person_id = organizations[org_id].projects[proj_id].members[_]
}

coordinator_in_org_of_project(person_id, project_id) {
    project_id = organizations[org_id].projects[proj_id].id
    person_id = organizations[org_id].coordinators[_]
}

employee(person_id) {
    person_id = employees[_].id
}

# Organization of employees
organization[org_id] {
    input.user = data.organizations[org_idx].employees[_].id
    org_id = data.organizations[org_idx].id
}

# Organization of coordinators
organization[org_id] {
    input.user = data.organizations[org_idx].coordinators[_]
    org_id = data.organizations[org_idx].id
}

# Organization of members of projects
organization[org_id] {
    input.user = data.organizations[org_idx].projects[_].members[_]
    org_id = data.organizations[org_idx].id
}