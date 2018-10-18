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

To use TDD for `dm_policies.rego` we create `dm_policies_test.rego`. This and all test files requires to be in the same package of the file its going to test, e.g. `dm` or import it. The structure of each test must be:

```
`name_of_the_test` {
    {not?} <function>(<testparams>)
}
```

or

```
`name_of_the_test` { 
    {not?} allow with input as <input_json>
}
```

## Sample API usage
As we are going to use bpm-projects-api as sample projects we will try to modelate on the `bpm.projects` package the allow rules
to grant or pass a request.

* GET / : Allowed to anyone to see
* GET /projects: Allowed just for the employees of the company (IOET), so we must create an `employees` section in the base documents and a corresponding function to evaluate if some user is an employee of the domain. Only employees of IOET are going to see this entries

## Run the tests

To run all the tests in a package like `example` just go to that folder and run the tests in verbose mode:

```bash
cd bpm/dm
opa test . -v
```
It use to fail in the vscode plugin because it doesnt run it in the right folder. So its better for you to do it in the console instead.

If you want to run code coverage do it with

```bash
opa test --coverage . -v
```
As the coverage is an option of the tests it combines the previous action as well, only that the verbose information wont be given; if you want
it you must run first the tests with `-v` and then the coverage.

If the response of the coverage was successful you will get a json giving you details about all the covered and not covered lines.
When a line is not covered it indicates one of two things:

* If the line refers to the head of a rule, the body of the rule was never true.
* If the line refers to an expression in a rule, the expression was never evaluated.

## Run it as a bundle
By the time the opa control server be ready to use you may be able to run your OPA configuration:
```bash
cd playground
opa run -c config.yml
```

As the server probably wont be running you will get a response like

```txt
ERRO[0000] Bundle download failed, server replied with not found.  name=http/dm plugin=bundle
```
So the best to do a simulation of how to work a bundle would be like better create a bundle with the following command:
```bash
cd playground
tar --exclude='*test.rego' -zcvf bpm.tar.gz bpm
```
You can check it has the wanted structure:

```bash
tar tzf bpm.tar.gz
```

Now you can run the bundle:

```bash
opa run bpm.tar.gz
```