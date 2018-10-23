package system.authz

default allow = false 

valid_passwords = ["password","secret"]

allow {  
    input.identity = valid_passwords[_]
}