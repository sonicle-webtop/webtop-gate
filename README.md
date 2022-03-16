# Building WebTop

This allows to prepare a building environment suitable for building all WebTop's repositories and produce the application war file for deployment.

## Cloning this repository

This repository make use of LFS to store some heavy tools (around ~150MB) packed as archive files (see `files` folder).
If you don't want to clone above archives right away or if you have problems with overquota errors, you need to invoke `git` command with specific variable:

```
GIT_LFS_SKIP_SMUDGE=1 git clone <this-repository-url>
```

LFS clone may already be skipped on system if `git-lfs` was originally installed with `--skip-smudge` option or if smudge configs were set as global.

For backward compatibility, same files are also published [here](https://github.com/sonicle-webtop/webtop-gate-files) in a standard repository with no LFS usage.

## Requirements

- System with minimum 2GB of RAM and enough disk space
- `Git SCM` (>= 2.20) with `Git LFS` support
- `Maven` (>= 3.5.x, < 3.7)
- `Java JDK` (= 1.8.x)
- `NodeJS` (>= 8.x)
- `make`, `awk`, `tar`, `bzip2`, `grep`, `sed`, `wget` commands available on system

You can run this on Windows systems through [Cygwin](https://www.cygwin.com/) but you have make sure to not install `git` commands in Cygwin, so both environments will share same executables under your main Windows OS. Finally, if you have any ssh keys to access sub-modules repositories, remember to copy or link them under your Cygwin's .ssh home, making them available to Cygwin environment also.

## Makefile's targets overview

If you simply issue `make` command, an help section will be shown describing all available targets.

## Preparing your workspace

Target `setup-module` will help you to clone all modules into your workspace.

```
make setup-modules
```

Once finished, you can find them into default `modules` sub-folder.
If you want to keep modules updated, you can periodically use the `checkout` target.

Next, you have to prepare the workspace for Sencha builds and a set of tools to perform them:

```
make setup-senchatools

# If you want do disable GitLFS and download using wget you can use the USE_LFS variable like below
make setup-senchatools USE_LFS=0
```

By default, current tools will be extracted under `sencha` sub-folder.

NB: you can perform a one-time operation using only `setup` target.

## Execute build

### Fix JasperReports mirrors

In order to produce a successful build, you need to override default repository URLs defined in [Jasper-reports-maven-plugin](https://github.com/alexnederlof/Jasper-report-maven-plugin) with more recent ones.
Please add the configuration below to your `settings.xml` file under your `.m2` home.

```
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                          https://maven.apache.org/xsd/settings-1.0.0.xsd">
        <mirrors>
                <!-- Fixes new Jaspersoft repo changes for https://github.com/alexnederlof/Jasper-report-maven-plugin -->
                <!-- This will override default repositories defined in plugin's POM -->
                <mirror>
                        <id>jasperreports-mirror</id>
                        <url>https://jaspersoft.jfrog.io/artifactory/jr-ce-releases/</url>
                        <mirrorOf>jasperreports</mirrorOf>
                </mirror>
                <mirror>
                        <id>jaspersoft-third-party-mirror</id>
                        <url>https://jaspersoft.jfrog.io/artifactory/third-party-ce-artifacts/</url>
                        <mirrorOf>jaspersoft-third-party</mirrorOf>
                </mirror>
                <!-- ********** -->
        </mirrors>
</settings>
```

You can start building component modules by issuing the following command:

```
make components-build
```

Every component module will be built and the artifacts installed in your local repository.

Then you can produce the application war package by running:

```
make webapps-build
```

Finally you can also generate server packages using the following:

```
make servers-build
```

NB: you can perform a one-time operation using only `build` target.

## Build customization examples

*Provide new clone URL*

```
make <desired-target> \
DEFAULT_CLONE_BASEURL=https://git.example.com \
DEFAULT_MVNTOOLS_CLONE_BASEURL=https://git2.example.com
```

*Change default initial branch*

```
make <desired-target> \
DEFAULT_BASE_BRANCH=develop
```

*Add new module, specifying clone URL and module-flags (see comments into Makefile for flags documentation)*

```
make <desired-target> \
COMPONENTS_COM=my-module \
MOD_CLONEBASEURL.my-module=https://git.example.com \
MOD_FLAGS.my-module=git-master
```

NB: not all internal variables can be overridden like above examples, in some situations you need to create and maintain a brand new makefile that includes the original one and provide desired functionalities. Then you can invoke it using make's `-f` option.

# Database initialization

Create a postgres database, configure it following [these instructions](https://www.sonicle.com/docs/webtop5/installation.html#postgresql-database) and initialize it with the following sql files:

[init-config.sql](https://github.com/sonicle-webtop/webtop-core/blob/master/src/main/resources/com/sonicle/webtop/core/meta/db/init-config.sql)  
[init-core.sql](https://github.com/sonicle-webtop/webtop-core/blob/master/src/main/resources/com/sonicle/webtop/core/meta/db/init-core.sql)  
[init-calendar.sql](https://github.com/sonicle-webtop/webtop-calendar/blob/master/src/main/resources/com/sonicle/webtop/calendar/meta/db/init-calendar.sql)  
[init-contacts.sql](https://github.com/sonicle-webtop/webtop-contacts/blob/master/src/main/resources/com/sonicle/webtop/contacts/meta/db/init-contacts.sql)  
[init-mail.sql](https://github.com/sonicle-webtop/webtop-mail/blob/master/src/main/resources/com/sonicle/webtop/mail/meta/db/init-mail.sql)  
[init-tasks.sql](https://github.com/sonicle-webtop/webtop-tasks/blob/master/src/main/resources/com/sonicle/webtop/tasks/meta/db/init-tasks.sql)  
[init-vfs.sql](https://github.com/sonicle-webtop/webtop-vfs/blob/master/src/main/resources/com/sonicle/webtop/vfs/meta/db/init-vfs.sql)  

Then fill it with initial data using the following sql files:

[init-data-core.sql](https://github.com/sonicle-webtop/webtop-core/blob/master/src/main/resources/com/sonicle/webtop/core/meta/db/init-data-core.sql)  
[init-data-mail.sql](https://github.com/sonicle-webtop/webtop-mail/blob/master/src/main/resources/com/sonicle/webtop/mail/meta/db/init-data-mail.sql)  

# Deployment

The application war can be found into `target-wars` folder. Servers are into `target-servers` folder instead.

Please follow installation instructions [here](https://www.sonicle.com/docs/webtop5/installation.html).

# Administration

Once the web application is running, connect to it and you should get the login page.

Enter admin / admin to begin.

You should review the Properties (system) page, to reflect your installation, expecially:
- com.sonicle.webtop.core / home.path = an empty home directory for WebTop, with write permissions for the container user (e.g. tomcat)
- com.sonicle.webtop.core / php.path = point to a valid path for the php binary
- com.sonicle.webtop.core / public.url = how the system is reachable from the internet (used to prepare public urls)
- com.sonicle.webtop.core / smtp.host & smtp.port = the smtp host and port
- com.sonicle.webtop.core / zpush.path = the path pointing to the z-push-webtop component
- com.sonicle.webtop.mail / * = check all the imap settings for your server

Right click the Domains node and create a new domain selecting the authentication method:
- Use WebTop (local) for local users and password, managed by WebTop. Each user must be configured with its imap account.
- Use WebTop (ldap) for a simple ldap management by the WebTop Administrator
- Choose any other method if your imap server infrastructure has its own authentication infrastructure (ldap, active directory)
- In this last case, you can choose to let WebTop create a WebTop user automatically when a user is authenticated the first time.

Once the Domain is created, you can view and manage the list of users by opening the domain tree. Here you can manage groups and roles too.

Go back to the login screen via the top-right menu / exit button, and enter valid user credentials to start using WebTop 5.

