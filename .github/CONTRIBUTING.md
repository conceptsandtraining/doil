# Contributing to doil

## Contributor Code of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

## Basic Workflow

* Fork the project
* Add a branch with the number of your issue
* Develop your feature stuff
* Commit to your forked project
* Send a pull request to the develop branch with all the details

Please make sure that you have [set up your user name and email address](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup) for use with Git. Strings such as `silly nick name <root@localhost>` look really stupid in the commit history of a project.

Due to time constraints, you may not always get a quick response. Please do not take delays personally and feel free to remind.

## Workflow Process

### Versioning

Version 1.4.5 of doil will be the last version using the [semantic versioning scheme](https://en.wikipedia.org/wiki/Software_versioning#Semantic_versioning). In future the public version of doil will be named as date of released [as described here](https://en.wikipedia.org/wiki/Software_versioning#Date_of_release) with this schematic: `YYYYMMDD[-PATCH_NUMBER][-RC_NUMBER]`

### Regarding Issues, PRs, Commits

* Every issue will be added with the predefined issue forms such as "Improvment" and "Bug Report"
* Every new issue will be reviewed by the project maintainer. If the issue will be approved it will assigned with certain labels (improvement, bug, ...) and will be added to the [project](https://github.com/conceptsandtraining/doil/projects/7) to the column "Backlog".
* The way every issue follows: Backlog (New) > Todo (Next thing to do) > Doing > Review (done by maintainer) > Done (closed or merged). Usually this will be done automatically but will be overlooked by the maintainer.
* Every commit must be linked to the issue with following pattern: `#${ISSUENUMBER} - ${MESSAGE}`
* Every PR only contains one commit and one reference to a specific issue

## Coding Guidelines

* We want to implement the [google shell styleguide](https://google.github.io/styleguide/shellguide.html) in the long run.
* doil is using an internal unit testing tool called "tstfy" which handles automated tests. Every developer is encouraged to use it.