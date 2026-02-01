# GitHub Actions Workflow Syntax Reference

## Triggers (on)

### Push/Pull Request
```yaml
on:
  push:
    branches: [main, develop]
    branches-ignore: [feature/*]
    paths: ['src/**', 'package.json']
    paths-ignore: ['docs/**']
    tags: ['v*']

  pull_request:
    branches: [main]
    types: [opened, synchronize, reopened]
```

### Manual/Scheduled
```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        default: 'staging'
        type: choice
        options: [staging, production]

  schedule:
    - cron: '0 0 * * *'    # Daily at midnight
    - cron: '0 */6 * * *'  # Every 6 hours
```

### Other Events
```yaml
on:
  release:
    types: [published]

  workflow_call:  # Reusable workflow

  repository_dispatch:
    types: [deploy]
```

## Jobs

### Basic Structure
```yaml
jobs:
  job-id:
    name: Display Name
    runs-on: ubuntu-latest
    timeout-minutes: 30

    steps:
      - name: Step name
        run: echo "Hello"
```

### Job Dependencies
```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps: [...]

  test:
    needs: build
    runs-on: ubuntu-latest

  deploy:
    needs: [build, test]  # Multiple dependencies
```

### Matrix Strategy
```yaml
jobs:
  test:
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
        node: [18, 20]
        include:
          - os: ubuntu-latest
            node: 22
        exclude:
          - os: windows-latest
            node: 18
      fail-fast: false
      max-parallel: 4
```

### Outputs
```yaml
jobs:
  build:
    outputs:
      version: ${{ steps.version.outputs.version }}
    steps:
      - id: version
        run: echo "version=1.0.0" >> $GITHUB_OUTPUT

  deploy:
    needs: build
    steps:
      - run: echo "Deploying ${{ needs.build.outputs.version }}"
```

## Steps

### Run Commands
```yaml
steps:
  - run: npm install

  - name: Multi-line script
    run: |
      npm install
      npm build
      npm test

  - name: With environment
    run: echo $MY_VAR
    env:
      MY_VAR: value

  - name: With working directory
    run: npm install
    working-directory: ./app

  - name: With shell
    run: Get-Process
    shell: pwsh
```

### Use Actions
```yaml
steps:
  - uses: actions/checkout@v4
    with:
      fetch-depth: 0
      token: ${{ secrets.PAT }}

  - uses: ./local/action  # Local action
  - uses: owner/repo/path@ref  # GitHub action
```

## Expressions

### Context Variables
```yaml
${{ github.repository }}      # owner/repo
${{ github.ref }}             # refs/heads/main
${{ github.sha }}             # commit SHA
${{ github.actor }}           # username
${{ github.event_name }}      # push, pull_request
${{ github.run_number }}      # sequential number
${{ github.workspace }}       # workspace path

${{ secrets.MY_SECRET }}      # secret value
${{ vars.MY_VAR }}            # variable value
${{ env.MY_ENV }}             # environment variable

${{ runner.os }}              # Linux, Windows, macOS
${{ runner.temp }}            # temp directory
```

### Functions
```yaml
# String functions
${{ contains(github.event.head_commit.message, '[skip ci]') }}
${{ startsWith(github.ref, 'refs/tags/') }}
${{ endsWith(github.repository, '-api') }}
${{ format('Hello {0}', github.actor) }}

# JSON functions
${{ toJSON(github.event) }}
${{ fromJSON(needs.build.outputs.matrix) }}

# Hash functions
${{ hashFiles('**/package-lock.json') }}
${{ hashFiles('**/*.go', 'go.sum') }}

# Status functions (in if:)
${{ success() }}
${{ failure() }}
${{ cancelled() }}
${{ always() }}
```

### Conditionals
```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'

steps:
  - if: ${{ success() }}
  - if: ${{ failure() }}
  - if: ${{ always() }}
  - if: ${{ github.event_name == 'push' }}
  - if: ${{ contains(github.event.pull_request.labels.*.name, 'deploy') }}
```

## Concurrency

```yaml
# Cancel in-progress runs
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

# Per-environment
concurrency:
  group: deploy-${{ github.event.inputs.environment }}
  cancel-in-progress: false
```

## Permissions

```yaml
permissions:
  contents: read
  packages: write
  pull-requests: write
  issues: write
  id-token: write  # For OIDC

# Minimal permissions
permissions: read-all

# No permissions
permissions: {}
```

## Environments

```yaml
jobs:
  deploy:
    environment:
      name: production
      url: https://example.com
    steps:
      - run: echo ${{ secrets.PROD_API_KEY }}  # Environment secret
```

## Services (Sidecar Containers)

```yaml
jobs:
  test:
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis
        ports:
          - 6379:6379
```

## Artifacts

```yaml
# Upload
- uses: actions/upload-artifact@v4
  with:
    name: my-artifact
    path: |
      dist/
      !dist/**/*.map
    retention-days: 5
    if-no-files-found: error  # warn, ignore

# Download
- uses: actions/download-artifact@v4
  with:
    name: my-artifact
    path: ./downloaded
```

## Common Patterns

### Skip CI
```yaml
jobs:
  build:
    if: "!contains(github.event.head_commit.message, '[skip ci]')"
```

### Path Filtering
```yaml
on:
  push:
    paths:
      - 'src/**'
      - 'package.json'
      - '.github/workflows/ci.yml'
```

### Approval Gates
```yaml
jobs:
  deploy:
    environment:
      name: production  # Configure required reviewers in repo settings
```
