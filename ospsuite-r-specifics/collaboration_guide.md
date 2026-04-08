# R Development Collaboration Guide

## Rules

The following set of rules should be followed by all contributors and checked by
all reviewers of the OSPS R projects.

1. Each change made to the codebase should have a clear purpose and exist in an
isolated context.  
  1.1 Each change should be related to an issue created on the project's repository.  
  1.2 Each change should be made in a separate branch.  
  1.3 Each change should be proposed through a pull request.

2. Each change or addition to the code should be documented and controlled.  
  2.1 Each change that affects **user experience or outputs** should be reflected in the documentation. If 
  documentation is not present, then it should be created.  
  2.2 Each change should be tested. If new cases emerge, then they should be 
  tested, even if some tests are already present. If no tests are present, then
  they should be created.

3. Each change should be easily reviewable, understandable, and traceable.
  3.1 Each change that affects **user experience or outputs** should have a corresponding entry in the `NEWS` file.
  3.2 Each change should be associated with a pull request whose scope is limited to the change itself.

4. Each change must respect the coding style of the project.
  4.1 Each change must respect the coding style of the project as defined in the [R Coding Standards](CODING_STANDARDS_R.md).
  4.2 Each change must be processed by the `{styler}` package before being proposed.

5. Each change should be reviewed before being merged.
  5.1 Each change should be reviewed by at least one other contributor through its associated pull request.
  5.2 Each change should be functional and comply with these rules before its associated pull request is set as "ready for review". If not ready or reviewer inputs are needed, the pull request should be marked as "draft".

## Recommended Workflows

### Changing Code

The recommended workflow for contributing to the OSPS R projects heavily relies on the [`{usethis}`](https://usethis.r-lib.org) package and its family of functions [`pr_*()`](https://usethis.r-lib.org/articles/pr-functions.html).

#### Prerequisites

This workflow implies that:

-   R and RStudio are installed,
-   A GitHub account is available and set up to work with RStudio,
-   The `{usethis}` package is installed,
-   A local clone (from original repository or from a fork) has been created.

#### Workflow

1.  Initialize `usethis::pr_init("my-branch-name")`.
2.  Apply changes in codebase and save with commits
3.  Once changes are implemented, make a pull request with `usethis::pr_push()`.
4.  Review of the pull request may ask for additional changes, proceed with commits then use the `pr_push()` command again.
5.  Finally, the reviewer merges the pull request, the local branch can be cleaned away using `usethis::pr_finish()`

#### Useful tips

-   At any moment you can get back to main branch using `usethis::pr_pause()`
-   If you need to make some changes on a branch that already has a pull request open, you can retrieve it locally with `usethis::pr_fetch(XX)` with `XX` being the pull request's numerical identifier.

### Releasing Versions
  
#### Prerequisites

This workflow implies that:

- R and RStudio are installed,
- A GitHub account is available and set up to work with RStudio,
- The `{usethis}` package is installed,
- A local clone (from original repository or from a fork) has been created.
- The current branch is the default branch (usually `main`).

#### Pre-release checklist

Before starting the release process, verify the following:

- [ ] All CI checks pass on the branch to merge.
- [ ] `NEWS` file is up to date and reflects all user-facing changes since the last release.

#### Workflow

The recommended workflow for releasing relies on the [`{usethis}`](https://usethis.r-lib.org) package.

##### Creating the release

1. Pick the new version number (refer to the [R Packages versioning guide](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number) to make the right choice).
  ```r
  new_version <- usethis:::choose_version("What should the new version be?")
  ```

2. Create a dedicated branch.
  ```r
  usethis::pr_init(branch = paste0("release v", new_version))
  ```

3. Automatically update the version number in the `DESCRIPTION` file. Follow the interactive prompts to accept and commit the changes.
  ```r
  usethis::use_version(which = labels(new_version))
  ```

4. Push the local branch and create the pull request.
  ```r
  usethis::pr_push()
  ```

5. Once the pull request is approved and merged, clean up the local branch.
  ```r
  usethis::pr_finish()
  ```

##### Publishing the release

6. Wait until all CI/CD actions on the merge commit are validated and completed.

7. Switch to the default branch and pull the latest changes.
  ```r
  usethis::pr_pause()  # if on another branch
  git pull              # from the terminal
  ```

8. Create the release on GitHub.
  ```r
  usethis::use_github_release()
  ```

9. Download the built packages from the GitHub Actions run triggered by the PR merge and attach them to the release. The new version is now fully released!

##### Restoring development mode

10. Pick the development version number. Development versions end with `.9000` so that developers and users can easily distinguish them from release versions.
  ```r
  new_version <- usethis:::choose_version(which = "dev")
  ```

11. Create a dedicated branch.
  ```r
  usethis::pr_init(branch = paste0("dev v", new_version))
  ```

12. Update the version number in the `DESCRIPTION` file. Follow the interactive prompts to accept and commit the changes.
  ```r
  usethis::use_version(which = labels(new_version))
  ```

13. Push the local branch and create the pull request.
  ```r
  usethis::pr_push()
  ```

14. Once the pull request is approved and merged, clean up the local branch.
  ```r
  usethis::pr_finish()
  ```
