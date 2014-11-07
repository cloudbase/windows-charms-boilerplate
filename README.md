# Windows juju charm boilerplate

This is the boilerplate for a juju charm for windows.
Departing from this basic structure you will be able to create a juju charm for windows including testing.
The following is provided:
* charm helpers.
* mocked charm helpers for tests.
* basic required file structure:
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
│   └── main.tests.ps1
├── icon.svg
├── metadata.yaml
├── README.ex
└── revision
```


#### Usage:
- Create empty git repo for your charm. 
```
        git init <path>
```
- set the cloubdase/charmelpers repo as upstream.
```
        git remote set-url upstream https://github.com/cloudbase/windows-charm-boilerplate
```
- pull from it
```
        git pull upstream <tagname>
```
- make sure your requirements are met
```
        /path/to/boilerplate/charmRequirements.ps1
```
- **code your charm hooks**: files for the basic hooks are provided as a placeholder for your code and also example files for the relation hooks whose name you will need to change according to your relation names.
- run the provided basic tests:
 - Run helper bundled tests (to make sure env is sane):
```
        /path/to/boilerplate/runTests.ps1 test_bundled
```
 - Run hooks tests.
```
	/path/to/boilerplate/runTests.ps1 test
```
- **code your tests**: To code your own tests we provide a series of mocked functionalities:
 - relation_get: explain
 - relation_set: explain
 - open_port: explain

#### Supported charm hooks formats:
Windows supports the following executables file formats, in order: 
* .ps1
* .cmd
* .bat
* .exe

This means that given several files with the same name and different extensions only one will be executed and the choice made in that precedence order.

#### Upgrades:
- To upgrade to a newer version of the windows charm boilerplate just update your repo from upstream:
```
        git pull upstream <tagname>
```
