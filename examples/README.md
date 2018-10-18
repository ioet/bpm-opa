BPM 
====
In the official [BPM documentation](https://docs.google.com/document/d/1xyiHfktEbanPXMa71K_6a1zzTZGbVe7urMlEqV1lvqo/edit?ts=5bc61b2e#heading=h.i31whztravs3) 
some examples of policies where given to illustrate how policies work and specifically are meant to work in BPM. Here you will find the equivalent 
OPA (REGO and json) to model those hypothetic scenarios so you can understand better how you might work with OPA in BPM.

Example scenario
================

## Facts

Lets checkout the following facts that reflects the state of the domain that we want to shape up.

| Facts                        | Descriptions                                 |
|------------------------------|----------------------------------------------|
| employee(midoplay,bo).       | Bo is an employee of MidoPlay.               |
| project(midoplay,coin).      | Coin is a project of MidoPlay.               |
| coordinator(grubhub,astrid). | Astrid is a project coordinator for GrubHub. |
| member(coin,mpineda).        | Maria Pineda is a member of the Coin project.|

Based on the previous examples you might probable infer the meaning of all the following facts we are gonna have
in count:

```prolog
employee(grubhub,clark).
project(grubhub,care).
project(grubhub,wda).
member(care,rene).
employee(midoplay,bo).
project(midoplay,coin).
coordinator(grubhub,astrid).
member(coin,mpineda).
```

Note: Remember these are facts not policies

## Policies

```prolog
can_read(Person,Project) :- employee(Org,Person), project(Org,Project).
can_read(Person,Project) :- member(Project,Person).
can_read(Person,Project) :- coordinator(Org,Person), project(Org,Project).
```

Those 2 policies explains how you can define that a Person (AKA User) can be able to read, in general,
content from a project.

* The first policy can be read as **employees can_read Project if Person is member of an organization who owns that project**:
* The second reads **Person can_read Project if Person is a member of the Project**.


## Solution

So as in the facts we detect:
* identities as persons (Bo, Astrid)
 Persons belong to projects
* Objects: 
   - projects (Coin)
   - organizations (MidoPlay, Grubhub) 
Projects belong to organizations

So to solve this with rego we are going to create the facts basically in the `data.json` and the policies in 
the `policies.rego`.

The `can_read` policy can be read as

* The organization must have employeed Person and must have the project Project: We infeer 
that organization must have a property for a list of employees and another one for a list of projects.
* Person must be a member of Project: So each project must have a list of members.
* Person must be coordinator of an organization: Each organization should have a list of coordinators 
(only the ids because the full data is contained in employees)

To use TDD for `dm_policies.rego` we create `dm_policies_test.rego`. This and all test files requires to be in the same package of the file its going to test, e.g. `examples` or import it. The structure of each test must be:

`name_of_the_test` {
    {not?} <function_evaluated_on_params>
}

## Run the tests

To run all the tests in a package like `example` just go to that folder and run the tests in verbose mode:

```
cd example
opa test . -v
```