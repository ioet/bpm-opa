# bpm-opa
OPA related code and info to use as example and at runtime for the BPM project.

## How to release
The project uses Travis CI for testing the OPA policies and deploy the bundle `bpm.gz.tar` to GitHub as a 
release. To do so create and push a new tag:
```bash
git tag -a v0.1 -m "Baseline and projects policies"
```

In case of accident, i.e. you previously tagged your commit incorrectly, you can delete it with

```bash
git tag --delete v0.1
```

When you push your changes those tags wont be pushed as well. Its that way by default, probably because it has deployment purposes and if the CI failed in a push you might want to correct those changes so when they pass then you commit the tags indicating the CI system to do probably a deployment, which is what happens in our case. You can push a particular tag with

```bash
git push origin v0.1
```
or all of them with

```bash
git push origin --tags
```