# 05: Preview Environments

This instruction tells you, how to create a preview environment for a new feature, before you release it to a real new version.
This procedure is a bit different from the other four ways, as you don't release a new docker image version by yourself, but
you only create a PR for new features.


### Developing a new feature
* Make a small visible change in for example `app/server.js` in a new branch and push it
* Open a PR for the feature branch to the main branch, and add the label `preview` to the PR

### Creating preview environment
* Preview environments are created by the Pull Request Generator of Argo CD Application Sets
* The Pull Request Generator scans for all PRs with the label `preview`
* For each of these PRs, it interpolates the information like branch name or PR number into the Argo CD application it creates
* After the Argo CD application is created by the Application Set, you can see it in the Argo CD UI
* Preview Env Apps are accessible on [`http://localhost:8080/preview-<BRANCH_NAME>-<PR_NUMBER>`](http://localhost:8080/preview-<BRANCH_NAME>-<PR_NUMBER>)

### Destroying preview environment
* When you merge the PR or reject and close it, the preview environment is destroyed
* Delete the old branch for cleanup on the PR