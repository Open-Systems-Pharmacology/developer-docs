# Building website

The [website](https://www.open-systems-pharmacology.org/OSPSuite-R/) for the _ospsuite_ package is built manually using the [pkgdown](https://pkgdown.r-lib.org/) package.

When you wish to update the website, you need to run the following command in the package root directory:

```r
pkgdown::build_site()
```

This will update the `/docs` folder in the package directory. Alternatively, you can also start completely afresh by deleting the existing folder and then running this command so that a new version of the `/docs` folder is created.

The package version displayed on the website will be the same one in the `DESCRIPTION` file.

# Updating only certain pages

If you have already built a website and need to only update certain pages, you can use specific functions from pkgdown. For example,

```r
# to build changelog
pkgdown::build_news()

# to update reference page
pkgdown::build_reference()

# to update vignettes
pkgdown::build_articles()

# to update one vignette
pkgdown::build_article("data-combined-plotting") # specify name of the vignette without the .Rmd
```

# Customize the website

You can customize the structure of the reference page, navigation bar, etc. using `_pkgdown.yml`. For more, read [this](https://pkgdown.r-lib.org/articles/customise.html) article.

# Development version of the website

In case you need to have two different versions of the website: one for the released version of the package, and the other for the development, you can use in `_pkgdown.yml`:

```yaml
development:
  mode: devel
```

Note that you need to do this *after* you have already built the website for the release version. 

If you generate the website now, it will be written to `docs/dev/` folder and the development version of the website (if it exits) can be accessed at [this](https://www.open-systems-pharmacology.org/OSPSuite-R/dev/) URL.

# Publishing the website

The pkgdown websites are hosted using [GitHub Pages](https://pages.github.com/). Therefore, once you commit the `/docs` folder to the required branch, you will need to go to `Settings` page for package repo, and then go to `Pages`, and select the following option (assuming you have the permissions to do and the `/docs` folder located on the `develop` branch is the one that should be used to build the website):

![image](https://user-images.githubusercontent.com/11330453/172597006-57206e68-997b-451c-badb-a981fafb4d93.png)

Make sure to also check the option to enforce the HTTPS protocol:

![image](https://user-images.githubusercontent.com/11330453/172613717-a5647d03-d51a-4875-b4f0-3bc2a37ed606.png)

Don't forget to update the repository "About" section with the package website URL:

![image](https://user-images.githubusercontent.com/11330453/172597588-738d7787-3538-4841-9f6b-e7f0dc3c127b.png)
