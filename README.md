# Windows juju charm boilerplate

This is a starting template for Windows juju charms.
By starting with this basic structure you will be able to create a Juju charm for Windows, including unit testing.

The following content is included:
* Charm helpers.
* Mocked charm helpers for tests.
* Minimal file structure:
```
my-windows-charm
├── config.yaml
├── hooks
│   ├── main.psm1
│   ├── install.ps1
│   ├── start.ps1
│   ├── stop.ps1
│   ├── config-changed.ps1
│   ├── upgrade-charm.ps1
│   ├── relation-name-relation-broken.ps1
│   ├── relation-name-relation-changed.ps1
│   ├── relation-name-relation-departed.ps1
│   └── relation-name-relation-joined.ps1
├── tests
│   └── main.Tests.ps1
├── icon.svg
├── metadata.yaml
├── get-requirements.ps1
├── run-tests.ps1
└── README.ex

```


#### Usage:
- Create an empty git repo for your charm. 
```
        git init <path>
```
- Set the cloudbase/windows-charms-boilerplate repository as git upstream remote.
```
        git remote set-url upstream https://github.com/cloudbase/windows-charms-boilerplate
```
- Git pull
```
        git pull upstream <tagname>
```
- Make sure your requirements are met. The following script downloads Pester in the Modules folder.
```
        /path/to/boilerplate/get-requirements.ps1
```
- **Code your charm hooks**: Placeholder files for the basic and relation hooks are included. Make sure you change the naming to match your relation names. We recommend writing all the business logic in the main.psm1 and export the functions to be used in every hook.
- Run the provided basic tests:
 - Run helper bundled tests (to make sure env is sane):
```
        /path/to/boilerplate/run-tests.ps1 CharmHelpers
```
 - Run hooks tests.
```
       /path/to/boilerplate/run-tests.ps1 CharmMainModule
```
- **Write your own tests**: Unit tests are written using Pester PowerShell unit testing framework. https://github.com/pester/Pester

#### Charm Helpers:
- By default, Juju adds $env:CHARM_DIR\hooks\Modules and $env:CHARM_DIR\lib\Modules in $env:PSModulePath. So you can simply write a module, bundle it with your charm, and simply do an Import-Module in your hooks.
- The Powershell CharmHelpers Module can be found in this repo:
 - https://github.com/cloudbase/juju-powershell-modules
- The content of the repo should be put in my-windows-charm\hooks\Modules folder for juju version 1.21 or in my-windows-charm\lib\Modules folder for Juju version 1.22 and higher.

#### Supported charm hooks formats:
Windows supports the following ordered executables file formats:
* .ps1
* .cmd
* .bat
* .exe

This means that given several files with the same name and different extensions only one will be executed and the choice made in that precedence order.

#### Upgrades:
- Just do a git pull:
```
        git pull upstream <tagname>
```

### Caveats:
- Since charm installer runs as a service we can only charm software whose installer does not require gui:
Typically you can achieve this by using /quiet or /q and on ocasions /n (which stands for non interactive).
- Installers comes in two ways:
 - MSI installers: Have a pre-defined interface and you use MSIExec (a binary available in all windows versions and flavors) to install.
 - Binary installers (.exe files) implement their own flags, most of them implement the same as flags than (they can be found running `<yourinstaller>.exe /?`)
- To use pester the test runner script will temporarily set an unrestricted execution policy for the duration of its run since pester is not an oficially signed library.
