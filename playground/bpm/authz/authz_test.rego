package system.authz

test_auth_denied {
    not allow
}

test_auth_right_identity_allowed {
    allow with input as {"identity":"secret"}
    allow with input as {"identity":"password"}
}

test_auth_right_identity_denied {
    not allow with input as {"identity":"secret2"}
    not allow with input as {"identity":"password4"}
}