package examples

test_employee_in_org_of_project_denied {
   not employee_in_org_of_project("eliux","care")
}

test_employee_in_org_of_project_granted {
   employee_in_org_of_project("clark","care")
}

test_member_of_project_denied {
  not member_of_project("mpineda", "care")
}

test_member_of_project_granted {
   member_of_project("mpineda", "coin")
}

test_coordinator_in_org_of_project_denied {
   not coordinator_in_org_of_project("rene", "care")
}

test_coordinator_in_org_of_project_granted {
   coordinator_in_org_of_project("astrid", "care")
}

test_allow_granted {
   allow with input as {"user":"clark","project":"care"}
   allow with input as {"user":"astrid","project":"care"}
   allow with input as {"user":"mpineda","project":"coin"}
}

test_allow_denied {
   not allow with input as {"user":"eliux","project":"care"}
   not allow with input as {"user":"astrid","project":"coin"}
   not allow with input as {"user":"mpineda","project":"care"}
}