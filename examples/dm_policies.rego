package examples

import data.organizations

default allow = false

allow {
    employee_in_org_of_project(input.user, input.project)
}

allow {
    member_of_project(input.user, input.project)
}

allow {
    coordinator_in_org_of_project(input.user, input.project)
}

employee_in_org_of_project(person_id, project_id) {
    person_id = organizations[org_id].employees[_].id
    project_id = organizations[org_id].projects[_].id
}

member_of_project(person_id, project_id) {
    project_id = organizations[org_id].projects[proj_id].id
    person_id = organizations[org_id].projects[proj_id].members[_]
}

coordinator_in_org_of_project(person_id, project_id) {
    project_id = organizations[org_id].projects[proj_id].id
    person_id = organizations[org_id].coordinators[_]
}