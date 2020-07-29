# Pester Github Action

## Basic Usage

Create a GitHub Workflow

```yaml
on:
  push:
    branches:
      - master
    pull_request:
      branches:
        - master
defaults:
  run:
    shell: pwsh
jobs:
  test_Pester_Action:
    runs-on: ubuntu-latest
    name: A job to run Pester on ${{ matrix.os }}
    steps:
    - name: checkout
      uses: actions/checkout@v2
    - name: Run pester tests
      id: pesterTests
      uses: PowerShell/GitHub-Actions/PesterActionV1@master
      with:
        script: './tests'
    - name: Upload pester results
      uses: actions/upload-artifact@v2
      with:
        name: pester-results-${{ matrix.os }}
        path: ${{ steps.pesterTests.outputs.logPath }}
```
## Other Inputs

### Version

- What version of Pester to use.
  This defaults to the latest tested with the action.

Example:

```yaml
    - name: Upload pester results
      uses: actions/upload-artifact@v2
      with:
        name: pester-results-${{ matrix.os }}
        path: ${{ steps.pesterTests.outputs.logPath }
        version: 4.9
```

### logFormat

- What format of the xml log file to use.
  This defaults to `NUnitXml`.
  The other option is `JUnitXml`.

Example:

```yaml
    - name: Upload pester results
      uses: actions/upload-artifact@v2
      with:
        name: pester-results-${{ matrix.os }}
        path: ${{ steps.pesterTests.outputs.logPath }
        logFormat: JUnitXml
```

### tags

- What tags to run.
  This defaults to all tags.

Example which runs only `myTag` and `myTag2`:

```yaml
    - name: Upload pester results
      uses: actions/upload-artifact@v2
      with:
        name: pester-results-${{ matrix.os }}
        path: ${{ steps.pesterTests.outputs.logPath }
        tags: myTag, myTag2
```
