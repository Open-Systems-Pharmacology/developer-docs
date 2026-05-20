# R Development Collaboration Guide

This guide describes how to contribute to, review, and release OSPS R packages. It is intended for contributors, reviewers, and maintainers of the OSPS R projects.

## Contents

- [Rules](#rules)
- [Prerequisites](#prerequisites)
- [Contributing changes](#contributing-changes)
- [Reviewing a pull request](#reviewing-a-pull-request)
- [Releasing versions](#releasing-versions)

## Rules

The following set of rules should be followed by all contributors and checked by all reviewers of the OSPS R projects.

1. Each change made to the codebase should have a clear purpose and exist in an isolated context.  
  1.1 Each change should be related to an issue created on the project's repository.  
  1.2 Each change should be made in a separate branch.  
  1.3 Each change should be proposed through a pull request.

2. Each change or addition to the code should be documented and controlled.  
  2.1 Each change that affects **user experience or outputs** should be reflected in the documentation. If documentation is not present, then it should be created.  
  2.2 Each change should be tested. If new cases emerge, then they should be tested, even if some tests are already present. If no tests are present, then they should be created.

3. Each change should be easily reviewable, understandable, and traceable.  
  3.1 Each change that affects **user experience or outputs** should have a corresponding entry in the `NEWS.md` file.  
  3.2 Each change should be associated with a pull request whose scope is limited to the change itself.

4. Each change must respect the coding style of the project.  
  4.1 Each change must respect the coding style of the project as defined in the [R Coding Standards](CODING_STANDARDS_R.md).  
  4.2 Each change must be processed by the [`air`](https://posit-dev.github.io/air/) formatter before being proposed.

5. Each change should be reviewed before being merged.  
  5.1 Each change should be reviewed by at least one other contributor through its associated pull request.  
  5.2 Each change should be functional and comply with these rules before its associated pull request is set as "ready for review". If not ready or reviewer inputs are needed, the pull request should be marked as "draft".

## Prerequisites

The workflows in this guide assume that:

- R and RStudio are installed.
- A GitHub account is available and set up to work with RStudio.
- The `{usethis}` package is installed.
- A local clone (from the original repository or from a fork) has been created.

Releasing a version additionally assumes that the current branch is the default branch (usually `main`).

## Contributing changes

Contributions to the OSPS R projects use the [`{usethis}`](https://usethis.r-lib.org) package and its family of [`pr_*()`](https://usethis.r-lib.org/articles/pr-functions.html) functions.

1.  Initialize the branch with `usethis::pr_init("my-branch-name")`.
2.  Apply changes in the codebase and save with commits.
3.  Add or update tests covering the change.
4.  Update `NEWS.md` if the change affects user experience or outputs.
5.  Format edited `.R` files with `air format` (or the `air` RStudio addin).
6.  Run `devtools::check()` locally and resolve any errors, warnings, or notes.
7.  Make a pull request with `usethis::pr_push()`.
8.  Address reviewer feedback with new commits, then run `usethis::pr_push()` again.
9.  Once the pull request is merged, clean up the local branch with `usethis::pr_finish()`.

**Tips:**

-   Get back to the default branch at any moment with `usethis::pr_pause()`.
-   Retrieve an open pull request locally with `usethis::pr_fetch(XX)`, where `XX` is the pull request's numerical identifier.

## Reviewing a pull request

Reviewers should verify the following before approving:

- [ ] The pull request is linked to an issue and its scope is limited to that issue (Rules 1.1, 3.2).
- [ ] CI checks pass.
- [ ] Code follows the [R Coding Standards](CODING_STANDARDS_R.md) and is formatted with `air` (Rules 4.1, 4.2).
- [ ] Tests cover the change and pass locally (Rule 2.2).
- [ ] Documentation (roxygen, vignettes, pkgdown site) reflects user-facing changes (Rule 2.1).
- [ ] `NEWS.md` has an entry when the change affects user experience or outputs (Rule 3.1).
- [ ] The pull request description is clear and the commit history is readable.
- [ ] In the case of an automated AI review of a pull request (e.g., CodeRabbit or GitHub Copilot), all improvements suggested by the AI reviewer must either be fixed or set to "Resolved" with a comment.

## Releasing versions

### Versioning model

OSPS R packages use a two-state versioning model automated by the [`description_manager.yaml`](https://github.com/Open-Systems-Pharmacology/Workflows/blob/main/.github/workflows/description_manager.yaml) reusable GitHub workflow. The workflow runs on each push to the default branch and updates the `DESCRIPTION` file:

- **Release versions** (for example, `0.2.0`) — the version is left untouched, a `v0.2.0` git tag is created, and entries in the `Remotes` field are pinned to `@*release` so the released package depends on released versions of other OSPS packages.
- **Development versions** (for example, `0.2.0.9000`) — the fourth component is auto-incremented on every push to the default branch (`.9000` → `.9001` → ...), no tag is created, and `Remotes` entries remain unpinned.

The `.9000`+ suffix distinguishes in-development builds from released versions; see the [R Packages versioning guide](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number) for background.

Because version bumps are automated, contributors **must not** manually edit the version field in `DESCRIPTION` outside of the release workflow described later in this section.

### Pre-release checklist

Before releasing, verify the following on the default branch:

- [ ] All CI checks pass on the latest commit.
- [ ] `devtools::check()` runs locally with no errors, warnings, or notes.
- [ ] The pkgdown site builds cleanly (`pkgdown::build_site()`).
- [ ] `NEWS.md` is up to date and reflects all user-facing changes since the last release.
- [ ] The chosen version number is consistent with [semantic versioning](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number) and the nature of the changes (major / minor / patch).

### Creating the release

1. Pick the new version number.
   ```r
   new_version <- usethis:::choose_version("What should the new version be?")
   ```

2. Create a dedicated branch.
   ```r
   usethis::pr_init(branch = paste0("release-v", new_version))
   ```

3. Set the release version in `DESCRIPTION`. Follow the interactive prompts to accept and commit the changes.
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

### Publishing the release

1. Wait until all CI/CD actions on the merge commit are validated and completed. The `description_manager.yaml` workflow will:
   - Detect the release version (no `.9000`+ suffix).
   - Pin `Remotes` entries to `@*release`.
   - Create the `v<version>` git tag.
   - Commit the result back to the default branch.

2. Switch to the default branch and pull the latest changes.
   ```r
   usethis::pr_pause()  # if on another branch
   git pull             # from the terminal
   ```

3. Create the release on GitHub.
   ```r
   usethis::use_github_release()
   ```

4. Download the built packages from the GitHub Actions run triggered by the PR merge and attach them to the release. The new version is now fully released.

### Restoring development mode

After the release tag is created, set the next development version. Subsequent pushes to the default branch will be auto-incremented by `description_manager.yaml`.

1. Pick the development version number. Development versions end with `.9000` so that developers and users can easily distinguish them from release versions.
   ```r
   new_version <- usethis:::choose_version(which = "dev")
   ```

2. Create a dedicated branch.
   ```r
   usethis::pr_init(branch = paste0("dev-v", new_version))
   ```

3. Set the development version in `DESCRIPTION`. Follow the interactive prompts to accept and commit the changes.
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

From this point on, `description_manager.yaml` auto-bumps the `.9000`+ suffix on every push to the default branch until the next release.
