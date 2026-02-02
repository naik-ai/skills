---
name: github-actions
description: Create CI/CD pipelines with GitHub Actions. Use when user needs "CI/CD pipeline", "GitHub Actions", "automated tests", "deployment workflow", "build pipeline", "continuous integration", or "automated deployment". Creates production-ready workflow files for testing, building, and deploying applications. Outputs `.github/workflows/*.yml` files.
---

# GitHub Actions Skill

Create production-ready CI/CD pipelines using GitHub Actions for testing, building, and deploying applications.

## When to Use

- Setting up continuous integration for a project
- Automating test runs on pull requests
- Creating deployment pipelines
- Automating releases and versioning
- Setting up scheduled tasks

## Workflow

### Phase 1: Requirements Analysis

**Goal**: Understand pipeline needs

**Questions**:
1. What language/framework? (Node, Python, Go, etc.)
2. What needs to run? (lint, test, build, deploy)
3. What environments? (staging, production)
4. What triggers? (push, PR, schedule, manual)

**Output**: Pipeline requirements list

### Phase 2: Workflow Design

**Goal**: Design workflow structure

**Actions**:
1. Define triggers and branches
2. Plan job dependencies
3. Configure caching strategy
4. Set up secrets and variables

**Output**: Workflow architecture

### Phase 3: Implementation

**Goal**: Create workflow files

**Actions**:
1. Create `.github/workflows/` directory
2. Write workflow YAML files
3. Configure branch protection rules
4. Test workflows

**Output**: Production-ready workflow files

## Workflow Patterns

### Basic CI (Test on PR)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Lint
        run: npm run lint

      - name: Type check
        run: npm run type-check

      - name: Test
        run: npm test -- --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
```

### Matrix Testing (Multiple Versions)

```yaml
# .github/workflows/test-matrix.yml
name: Test Matrix

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest, windows-latest]
        node-version: [18, 20, 22]
      fail-fast: false

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'

      - run: npm ci
      - run: npm test
```

### Build and Deploy

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

env:
  NODE_ENV: production

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      version: ${{ steps.version.outputs.version }}

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Upload build artifact
        uses: actions/upload-artifact@v4
        with:
          name: build
          path: dist/
          retention-days: 1

      - name: Get version
        id: version
        run: echo "version=$(node -p "require('./package.json').version")" >> $GITHUB_OUTPUT

  deploy-staging:
    needs: build
    runs-on: ubuntu-latest
    environment: staging

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: build
          path: dist/

      - name: Deploy to staging
        run: |
          # Your deployment command here
          echo "Deploying version ${{ needs.build.outputs.version }} to staging"

  deploy-production:
    needs: [build, deploy-staging]
    runs-on: ubuntu-latest
    environment: production

    steps:
      - name: Download artifact
        uses: actions/download-artifact@v4
        with:
          name: build
          path: dist/

      - name: Deploy to production
        run: |
          echo "Deploying version ${{ needs.build.outputs.version }} to production"
```

### Docker Build and Push

```yaml
# .github/workflows/docker.yml
name: Docker

on:
  push:
    branches: [main]
    tags: ['v*']

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write

    steps:
      - uses: actions/checkout@v4

      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=semver,pattern={{version}}
            type=sha,prefix=

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Release Automation

```yaml
# .github/workflows/release.yml
name: Release

on:
  push:
    tags: ['v*']

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          registry-url: 'https://registry.npmjs.org'

      - name: Install dependencies
        run: npm ci

      - name: Build
        run: npm run build

      - name: Generate changelog
        id: changelog
        run: |
          # Generate changelog from commits
          echo "changelog<<EOF" >> $GITHUB_OUTPUT
          git log $(git describe --tags --abbrev=0 HEAD^)..HEAD --pretty=format:"- %s" >> $GITHUB_OUTPUT
          echo "EOF" >> $GITHUB_OUTPUT

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          body: |
            ## Changes
            ${{ steps.changelog.outputs.changelog }}
          files: |
            dist/*

      - name: Publish to npm
        run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### Scheduled Tasks

```yaml
# .github/workflows/scheduled.yml
name: Scheduled Tasks

on:
  schedule:
    - cron: '0 0 * * *'  # Daily at midnight UTC
  workflow_dispatch:       # Allow manual trigger

jobs:
  cleanup:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Cleanup old artifacts
        uses: actions/github-script@v7
        with:
          script: |
            const days = 30;
            const cutoff = new Date();
            cutoff.setDate(cutoff.getDate() - days);

            const artifacts = await github.rest.actions.listArtifactsForRepo({
              owner: context.repo.owner,
              repo: context.repo.repo,
            });

            for (const artifact of artifacts.data.artifacts) {
              if (new Date(artifact.created_at) < cutoff) {
                await github.rest.actions.deleteArtifact({
                  owner: context.repo.owner,
                  repo: context.repo.repo,
                  artifact_id: artifact.id,
                });
              }
            }

  dependency-update:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Update dependencies
        run: npx npm-check-updates -u

      - name: Create PR
        uses: peter-evans/create-pull-request@v5
        with:
          commit-message: 'chore: update dependencies'
          title: 'chore: update dependencies'
          branch: automated/dependency-updates
```

## Caching Strategies

```yaml
# Node.js
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'  # Built-in caching

# Custom cache
- uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-

# Python
- uses: actions/setup-python@v5
  with:
    python-version: '3.11'
    cache: 'pip'

# Go
- uses: actions/setup-go@v5
  with:
    go-version: '1.21'
    cache: true

# Docker layer caching
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## Secrets and Variables

```yaml
# Using secrets
env:
  API_KEY: ${{ secrets.API_KEY }}
  DATABASE_URL: ${{ secrets.DATABASE_URL }}

# Using variables (non-sensitive)
env:
  APP_ENV: ${{ vars.APP_ENV }}

# Environment-specific secrets
jobs:
  deploy:
    environment: production  # Uses production secrets
    steps:
      - run: echo ${{ secrets.DEPLOY_KEY }}
```

## Conditional Execution

```yaml
jobs:
  deploy:
    # Only on main branch
    if: github.ref == 'refs/heads/main'

    steps:
      # Only when not a fork
      - name: Deploy
        if: github.event.pull_request.head.repo.full_name == github.repository

      # Only on specific file changes
      - name: Build docs
        if: contains(github.event.commits.*.modified, 'docs/')

      # Continue on error
      - name: Optional step
        continue-on-error: true
```

## Reusable Workflows

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: '20'
    secrets:
      npm-token:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm test

# Usage in another workflow
jobs:
  call-tests:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
    secrets:
      npm-token: ${{ secrets.NPM_TOKEN }}
```

## Common Mistakes

| Mistake | Problem | Fix |
|---------|---------|-----|
| No caching | Slow builds | Use built-in caching or actions/cache |
| Hardcoded secrets | Security risk | Use GitHub Secrets |
| No timeout | Stuck jobs | Set `timeout-minutes` |
| No concurrency control | Wasted resources | Use `concurrency` key |
| Running on self-hosted without security | Code execution risk | Use `pull_request_target` carefully |

## Key Principles

1. **Cache aggressively**: Dependencies, build outputs, Docker layers
2. **Fail fast**: Run quick checks (lint) before slow ones (e2e)
3. **Parallelize**: Independent jobs should run concurrently
4. **Secure by default**: Use least privilege, avoid `pull_request_target`
5. **Keep DRY**: Use reusable workflows and composite actions

## References

- `references/workflow-syntax.md` - Complete YAML syntax reference
- `references/action-catalog.md` - Popular actions for common tasks
