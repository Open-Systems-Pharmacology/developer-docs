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

Releasing a version needs no local setup. It is done with GitHub Actions workflows, so it additionally assumes permission to run workflows and merge pull requests in the package repository.

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

OSPS R packages use a two-state versioning model. The state is given by the `Version` field of the `DESCRIPTION` file on the default branch, and it also decides where the package takes its OSPS dependencies from:

- **Development versions** (for example, `0.2.0.9000`) — the fourth component is incremented on every push to the default branch (`.9000` → `.9001` → ...). OSPS dependencies are listed in the `Remotes` field and are installed from their development versions on GitHub.
- **Release versions** (for example, `0.2.0`) — the version is left untouched by pushes. `DESCRIPTION` has no `Remotes` field: OSPS dependencies are installed as their latest releases from the [OSP R-universe](https://open-systems-pharmacology.r-universe.dev), which is listed in `Additional_repositories`.

The `.9000`+ suffix distinguishes in-development builds from released versions; see the [R Packages versioning guide](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number) for background.

The version is managed by reusable GitHub workflows from the [Workflows repository](https://github.com/Open-Systems-Pharmacology/Workflows#osp-r-package-ci). Each package repository calls them from its own `.github/workflows/` folder:

| Reusable workflow | Started by | What it does |
| --- | --- | --- |
| [`bump-dev-version.yaml`](https://github.com/Open-Systems-Pharmacology/Workflows/blob/main/.github/workflows/bump-dev-version.yaml) | Every push to the default branch | Increments the `.9000`+ suffix of a development version. Does nothing on a release version. |
| [`release-pr.yaml`](https://github.com/Open-Systems-Pharmacology/Workflows/blob/main/.github/workflows/release-pr.yaml) | A maintainer, manually | Sets the release version, switches the OSPS dependencies to the R-universe, and opens the release pull request. |
| [`publish-release.yaml`](https://github.com/Open-Systems-Pharmacology/Workflows/blob/main/.github/workflows/publish-release.yaml) | A maintainer, manually, after the release pull request is merged | Creates the `v<version>` git tag and the GitHub Release, with the built packages attached. |
| [`dev-pr.yaml`](https://github.com/Open-Systems-Pharmacology/Workflows/blob/main/.github/workflows/dev-pr.yaml) | A maintainer, manually, after the release is published | Sets the next development version, restores the `Remotes` field, and opens the "back to development" pull request. |

Nothing is tagged or published automatically: merging a release version to the default branch does not create a tag or a GitHub Release.

Because the version is managed by these workflows, contributors **must not** manually edit the version field in `DESCRIPTION`. A maintainer who changes the version by hand (for example, with `usethis::use_version()`) must also switch the dependency fields; see the [dependency model](https://github.com/Open-Systems-Pharmacology/Workflows#dependency-model) in the Workflows repository.

The steps in the rest of this section refer to the workflows by the names used in the [caller templates](https://github.com/Open-Systems-Pharmacology/Workflows#setting-up-a-consuming-repository) of the Workflows repository. A repository that names its caller workflows differently shows them under those names in its **Actions** tab.

### Pre-release checklist

Before releasing, verify the following on the default branch:

- [ ] All CI checks pass on the latest commit.
- [ ] `devtools::check()` runs locally with no errors, warnings, or notes.
- [ ] The pkgdown site builds cleanly (`pkgdown::build_site()`).
- [ ] `NEWS.md` is up to date and reflects all user-facing changes since the last release. The entries are under the `(development version)` heading, which the release workflow renames to the release version.
- [ ] The OSPS packages that the package depends on have been released, and the [R-universe](https://open-systems-pharmacology.r-universe.dev/builds) has built those releases. A release version installs its OSPS dependencies from there.
- [ ] The chosen release type (major / minor / patch) is consistent with [semantic versioning](https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number) and the nature of the changes.

### Creating the release

1. In the package repository on GitHub, open the **Actions** tab and select the **Release PR** workflow (`release-pr.yaml`).

2. Click **Run workflow**, keep the default branch selected, and choose which version component to bump: `patch`, `minor`, or `major`. From the development version `0.2.0.9005`, these give `0.2.1`, `0.3.0`, and `1.0.0`.

3. Wait for the workflow to open a pull request named `Release <version>` from the branch `release-pr-<version>`. The pull request:
   - Sets the release version in `DESCRIPTION` with `usethis::use_version()`.
   - Renames the `(development version)` heading of `NEWS.md` to the release version.
   - Removes the `Remotes` field and adds the R-universe to `Additional_repositories`. The development remotes are kept in the `Config/osp/dev-remotes` field.
   - Updates `renv.lock`, if the package has one.

4. Review the pull request. Its CI checks install the released OSPS dependencies, so they validate the package as users will install it.

5. Merge the pull request once it is approved and all checks pass.

### Publishing the release

1. In the **Actions** tab, select the **Publish Release Workflow** (`publish.yaml`), click **Run workflow**, and keep the default branch selected. Do this before anything else is merged, because the tag is placed on the latest commit of the default branch.

2. Wait for the workflow to complete. It will:
   - Run `R CMD check` and build the packages for each operating system.
   - Stop without tagging if `DESCRIPTION` still has a `Remotes` field.
   - Create the `v<version>` git tag.
   - Create the GitHub Release `v<version>`, with release notes taken from the `NEWS.md` section of that version and the built packages attached.

3. Open the release on GitHub and check its notes and attached packages. The new version is now fully released.

If something is wrong, fix it on the default branch and run the workflow again: it moves the tag to the latest commit and updates the existing release. The workflow does nothing when the default branch is on a development version.

### Restoring development mode

Restore development mode right after the release is published, so that the default branch does not stay on the release version.

1. In the **Actions** tab, select the **Dev PR** workflow (`dev-pr.yaml`) and click **Run workflow**. Some repositories start this workflow automatically when a release is published; in that case the pull request of the next step already exists.

2. Wait for the workflow to open a pull request named `Restore development mode (<version>)` from the branch `dev-pr-<version>`. The pull request:
   - Sets the development version in `DESCRIPTION` with `usethis::use_dev_version()` (for example, `0.2.0` becomes `0.2.0.9000`). Development versions end with `.9000`+ so that developers and users can easily distinguish them from release versions.
   - Adds a new `(development version)` heading to `NEWS.md`.
   - Restores the `Remotes` field and removes the R-universe from `Additional_repositories`.
   - Updates `renv.lock`, if the package has one.

3. Review the pull request and merge it once it is approved.

From this point on, `bump-dev-version.yaml` increments the `.9000`+ suffix on every push to the default branch until the next release.
