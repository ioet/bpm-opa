package bpm.projects 

test_get_swagger_page_allowed {
    allow with input as { "method": "GET", "path": [] }
}

test_get_resource_files_allowed {
    allow with input as { "method": "GET", "path": ["path", "resource.js"] }
    allow with input as { "method": "GET", "path": ["path", "resource.css"] }
    allow with input as { "method": "GET", "path": ["path", "resource.png"] }
    allow with input as { "method": "GET", "path": ["another", "path", "resource.json"] } 
    allow with input as { "method": "GET", "path": ["fav.ico"] }
}

test_get_resource_files_denied {
    not allow with input as { "method": "GET", "path": ["resource.txt"] }
    not allow with input as { "method": "GET", "path": ["path", "resource.exe"] }
    not allow with input as { "method": "GET", "path": ["path", "long", "resource.sh"] }
    not allow with input as { "method": "GET", "path": ["path", "long", "longer", "resource.dmg"] }
}

test_get_login_allowed {
    allow with input as { "method": "GET", "path": ["login"] }
    allow with input as { "method": "GET", "path": ["login"], "user": "invaliduser" }
}

test_get_logout_allowed {
    allow with input as { "method": "GET", "path": ["logout"] }
    allow with input as { "method": "GET", "path": ["logout"], "user": "invaliduser" }
}

test_post_swagger_page_denied {
    not allow with input as { "method": "POST", "path": [""] }
}

test_get_all_projects_granted {
    allow with input as { "method": "GET", "path": ["projects"], "user": "rene" }
}

test_get_all_projects_denied {
    not allow with input as { "method": "GET", "path": ["projects"], "user": "eliux" }
}

test_create_project_allowed {
    allow with input as { "method": "POST", "path": ["projects"], "user": "clark" }
    allow with input as { "method": "POST", "path": ["projects"], "user": "bo" }
}

test_create_project_only_for_specific_organizations {
    organization["grubhub"] with input as { "method": "POST", "path": ["projects"], "user": "clark" }
    organization["midoplay"] with input as { "method": "POST", "path": ["projects"], "user": "bo" }
}

test_create_project_denied {
    not allow with input as { "method": "POST", "path": ["projects"], "user": "rene" }
    not allow with input as { "method": "POST", "path": ["projects"], "user": "mpineda" }
}

test_organization_with_data {
    organization["grubhub"] with input as {"user":"clark"}
    organization["midoplay"] with input as {"user":"bo"}
}

test_employees_can_search_projects_of_their_organization { 
    request1 = { "method": "GET", "path": ["projects", "search"], "user": "clark" }
    allow with input as request1
    organization["grubhub"] with input as request1
    request2 = { "method": "GET", "path": ["projects", "search"], "user": "bo" }
    allow with input as request2
    organization["midoplay"] with input as request2
}

test_employees_can_search_projects_of_other_organizations {  
    not organization["midoplay"] with input as { "method": "GET", "path": ["projects", "search"], "user": "clark" }
    not organization["grubhub"] with input as { "method": "GET", "path": ["projects", "search"], "user": "bo" }
}

test_coordinators_can_search_projects_of_their_organization {
    request = { "method": "GET", "path": ["projects", "search"], "user": "astrid" }
    allow with input as request
    organization["grubhub"] with input as request
}

test_members_can_search_projects_of_its_organization {
    request1 = { "method": "GET", "path": ["projects", "search"], "user": "rene" }
    allow with input as request1
    organization["grubhub"] with input as request1
    request2 = { "method": "GET", "path": ["projects", "search"], "user": "mpineda" }
    allow with input as request2
    organization["midoplay"] with input as request2
}

test_coordinator_delete_project_allowed {
    allow with input as { "method": "DELETE", "path": ["projects", "care"], "user": "astrid" }
}

test_members_delete_project_denied {
    not allow with input as { "method": "DELETE", "path": ["projects", "care"], "user": "rene" } 
    not allow with input as { "method": "DELETE", "path": ["projects", "coin"], "user": "mpineda" } 
}

test_employees_delete_project_allowed {
    allow with input as { "method": "DELETE", "path": ["projects", "care"], "user": "clark" } 
    allow with input as { "method": "DELETE", "path": ["projects", "coin"], "user": "bo" } 
}

test_employees_create_or_update_project_allowed {
    request1 = { "method": "PUT", "path": ["projects", "newproject"], "user": "clark" } 
    allow with input as request1
    organization["grubhub"] with input as request1

    request2 = { "method": "PUT", "path": ["projects", "newproject2"], "user": "bo" } 
    allow with input as request2
    organization["midoplay"] with input as request2
}

test_coordinators_can_create_or_update_project_allowed {
    request = { "method": "PUT", "path": ["projects", "newproject"], "user": "astrid" } 
    allow with input as request
    organization["grubhub"] with input as request
}

test_employees_get_project_allowed {
    allow with input as { "method": "GET", "path": ["projects", "care"], "user": "clark" } 
    allow with input as { "method": "GET", "path": ["projects", "coin"], "user": "bo" } 
}

test_members_get_project_allowed {
    allow with input as { "method": "GET", "path": ["projects", "care"], "user": "rene" } 
    allow with input as { "method": "GET", "path": ["projects", "coin"], "user": "mpineda" } 
}

test_coordinators_get_project_allowed {
    allow with input as { "method": "GET", "path": ["projects", "care"], "user": "astrid" } 
}

test_just_global_employees_get_project_denied {
    not allow with input as { "method": "GET", "path": ["projects", "coin"], "user": "astrid" } 
    not allow with input as { "method": "GET", "path": ["projects", "coin"], "user": "rene" } 
    not allow with input as { "method": "GET", "path": ["projects", "grubhub"], "user": "mpineda" } 
}

test_employees_update_project_allowed {
    allow with input as { "method": "POST", "path": ["projects", "care"], "user": "clark" } 
    allow with input as { "method": "POST", "path": ["projects", "coin"], "user": "bo" } 
}

test_coordinators_update_project_allowed {
    allow with input as { "method": "POST", "path": ["projects", "care"], "user": "astrid" } 
}

test_members_update_project_denied {
    not allow with input as { "method": "POST", "path": ["projects", "care"], "user": "rene" } 
    not allow with input as { "method": "POST", "path": ["projects", "coin"], "user": "mpineda" } 
}