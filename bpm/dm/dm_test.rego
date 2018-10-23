package bpm.dm

test_allow_allowed {
  allow with input as {"user":"clark", "project":"care"}
  allow with input as {"user":"astrid", "project":"care"}
  allow with input as {"user":"mpineda", "project":"coin"}
}

test_allow_denied {
  not allow with input as {"user":"eliux", "project":"care"}
  not allow with input as {"user":"astrid", "project":"coin"}
  not allow with input as {"user":"mpineda", "project":"care"}
}

test_employee_in_org_of_project_denied {
   not employee_in_org_of_project("eliux","care")
}

test_employee_in_org_of_project_allowed {
   employee_in_org_of_project("clark","care")
   employee_in_org_of_project("bo","coin")
}

test_member_of_project_denied {
  not member_of_project("mpineda", "care")
}

test_member_of_project_allowed {
   member_of_project("mpineda", "coin")
}

test_coordinator_in_org_of_project_denied {
   not coordinator_in_org_of_project("rene", "care")
}

test_coordinator_in_org_of_project_allowed {
   coordinator_in_org_of_project("astrid", "care")
}

test_employee_denied {
  not employee("eliux")
}

test_employee_allowed {
  employee("astrid")
}

test_can_read_allowed {
  can_read("clark", "care")
  can_read("astrid", "care")
  can_read("mpineda", "coin")
}

test_can_read_denied {
  not can_read("eliux", "care")
  not can_read("astrid", "coin")
  not can_read("mpineda", "care")
}

test_organization_of_employees {
  organization["grubhub"] with input as { "user": "clark" }
  organization["midoplay"] with input as { "user": "bo" }
}

test_organization_of_coordinators {
  organization["grubhub"] with input as { "user": "astrid" }
}

test_organization_of_members {
  organization["grubhub"] with input as { "user": "rene" }
  organization["midoplay"] with input as { "user": "mpineda" }
}