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

Based on the previous examples you might probable infer the meaning of all the following facts we are gonna have in count:

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

Those 3 policies explains how you can define that a Person (AKA User) can be able to read, in general,
content from a project. The way it operates is with some sort of [pattern  matching](https://en.wikipedia.org/wiki/Pattern_matching) where it evalutes all the `can_read` cases until it finds a truthy one or it will return false or underfined if some data was missing.

* The first match of `can_read` can be read  as *a Person can_read a Project if Person is employee of an Organization who owns that project*:
* The second can be read as *Person can_read Project if Person is a member of the Project*.
* The third can be read as *Person can read Project if Person is a coordinator of an Organization who owns the Project*


## Solution
So as in the facts we detect:
* identities as persons, e.g.: bo, astrid, rene, mpineda
 Persons belong to projects
* Objects: 
   - projects, e.g.: coin, care, wda.
   - organizations, e.g. midoplay, grubhub.
* The fact that projects belong to organizations.

So to solve this with rego we are going to create the facts basically in the **data.json** and the policies in the **rego** files.

If we go deeper analyzing `can_read` then we realise that

* 1st match: Each organization must have a property for a list of employees and another one for a list of projects.
* 2nd match: Each project must have a list of members.
* 3rd match: Each organization should have a list of the id of the coordinators, which reference employees in the global context.

To use TDD for each `<package>.rego` we create a `<package>_test.rego` in that same folder and belong to the same <package> (declared at the begining of each rego file. The structure of each test must be:

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

## Playground to try policies on the bpm domain model
You will see that all sample files are contained in a folder called `playground`. Inside that folder you have bpm which is basically where our *OPA* namespace really starts.

As we are going to use `bpm-projects-api` as a sample project, we will try to modelate on the `bpm.projects` package the `allow` rules to grant or pass a request. For now lets just focus in the one related to retrieve a project.

```rego
allow {
    input.method = "GET"
    input.path = ["projects", project_id]
    data.bpm.dm.can_read(input.user, project_id)
}
```

This policy will allow employees, members and coordinators in an organization to read projects. As you can figure it checks if the method is `GET` and it calls `/projects/<project_id>` in the url. To finally decide
if the user passed as input can access to the project identified by `project_id`. To do so it call to the function `can_read` located in the package `bpm.dm`, which contains:

```rego
can_read(user, project) {
    employee_in_org_of_project(user, project)
}

can_read(user, project) {
    member_of_project(user, project)
}

can_read(user, project) {
    coordinator_in_org_of_project(user, project)
}
```
We will skip the implementation of all the references properties, but by just readying this function you can see an straighforward analogy with aforementioned *prolog* code.

## Run the tests
To run all the tests on the `bpm` folder giving details (verbose mode), just run:

```bash
opa test bpm -v
```

If you want to run code coverage do it with

```bash
opa test --coverage bpm -v
```
It will run the tests as well but wont show details about them. Thats why you should run first the tests with `-v` and then the coverage. If the response of the coverage was successful you will get json content giving you details about all the covered and not covered rego code. When a line is not covered it indicates one of two things:

* If the line refers to the head of a rule, the body of the rule was never true.
* If the line refers to an expression in a rule, the expression was never evaluated.

## Run the OPA files from a bundle
You can run opa getting and sending information to a service server:
```bash
opa run -c config.yml
```
Check the config.yml file and the [bundle documentation](https://www.openpolicyagent.org/docs/bundles.html) to see how it works. As such server probably wont be running for the moment you will get an error:

```txt
ERRO[0000] Bundle download failed, server replied with not found.  name=http/dm plugin=bundle
```

Luckly we can try this using a local bundle file, which you can create with the following command:

```bash
tar --exclude='*test.rego' -zcvf bpm.tar.gz bpm
```

You can check it has the wanted structure (we dont include the test files):

```bash
tar tzf bpm.tar.gz
```

Now you can run the bundle:

```bash
opa run -s bpm.tar.gz
```

* `-s` Runs it in server mode instead of REPL

Its pretty much the same as running

```bash
opa run -s bpm
```

Then using POSTMAN or a curl test a simple policy using REST:

```bash
curl -X POST \
  http://localhost:8181/v1/data/bpm/projects/allow \
  -H 'Postman-Token: 8b101567-8c92-4de1-b8af-2e8f0f05c78f' \
  -H 'cache-control: no-cache' \
  -d '{"input": {"method": "GET", "path": ["projects","care"], "user": "rene"}}'
```
It will return `true` because `rene` should be able to access the project `care`.

and

```bash
curl -X POST \
  http://localhost:8181/v1/data/bpm/projects/allow \
  -H 'Postman-Token: 0662fb7c-96ff-4030-b98d-0b098500fe82' \
  -H 'cache-control: no-cache' \
  -d '{"input": {"method": "GET", "path": ["projects","coin"], "user": "rene"}}'
```
It will return `false` because `rene` should not be able to access the project `coin`.

To see more cases check `projects_test.rego`. Its also highly recommended you create policies 
for your own application and install an OPA compatible library for you to enforce security with it.
Take `bpm.projects` as a reference. Demo your results to others members of your team. to get some feedback.