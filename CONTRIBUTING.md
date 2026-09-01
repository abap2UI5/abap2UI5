# Contributing to abap2UI5

Thank you for your interest in contributing to abap2UI5! This guide helps ABAP developers get started with open source contributions, whether you're new to Git or experienced with development workflows.

> **Working with an AI assistant (or as one)?** [AGENTS.md](AGENTS.md) is the
> authoritative briefing for changes to this repository — architecture, coding
> rules, and the validation commands. Where this guide and AGENTS.md differ,
> AGENTS.md wins.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [ABAP Development with abapGit](#abap-development-with-abapgit)
- [Code Quality and Testing](#code-quality-and-testing)
- [Making Your First Contribution](#making-your-first-contribution)
- [Submitting Changes](#submitting-changes)
- [Community Guidelines](#community-guidelines)
- [Advanced Topics](#advanced-topics)
- [Thank You!](#thank-you)

## Getting Started

### What is abap2UI5?

abap2UI5 is a framework for developing UI5 applications purely in ABAP, without JavaScript, OData, or RAP. It supports all ABAP releases from NW 7.02 to ABAP Cloud and works in both cloud and on-premise environments.

### Prerequisites

**Required:**
1. **GitHub Account** - [Create a free account](https://github.com/join)
2. **Git** - [Download and install Git](https://git-scm.com/downloads) (for beginners: [Git Tutorial](https://git-scm.com/docs/gittutorial))

**For ABAP Development:**
3. **abapGit** - [Install abapGit](https://abapgit.org/) in your ABAP system
4. **ABAP Development Environment** - SE80, ADT, or your preferred ABAP editor

**For Node.js Development (Optional):**
5. **Node.js 22 or newer** - [Download Node.js](https://nodejs.org/) (needed for
   transpilation testing and for every `npm run` gate; `package.json` declares
   `"engines": { "node": ">=22" }` and the CI toolchain is pinned to it). The
   gates and the build pipeline are Node scripts on purpose: nothing in them
   assumes a POSIX shell, so `npm run verify` runs on Linux, macOS and Windows
   alike.

### Understanding the Project

The repository structure:
- `src/` - Core ABAP framework classes
- `app/` - the UI5 frontend as a Fiori project (`app/webapp/` plus `ui5.yaml` etc.)
- `tools/` - generators that build artefacts out of `app/webapp/` (embedded ABAP, BSP packaging, delivery branches)
- `frontend/` - the non-generated parts of the delivery branches (ICF/BSP ABAP artefacts, common files)
- `node/` - Node.js transpilation setup
- `docs/` - documentation for contributors and agents (`docs/agents/` maps the directories, the workflows and the test inventory; `docs/removal-plan.md` is what to read before removing any compatibility symbol)
- `backlog/` - findings that belong in ANOTHER repository of the ecosystem (abaplint, the transpiler, the linter). Found a defect that is not ours to fix? It goes here rather than getting lost - see [`backlog/README.md`](backlog/README.md)
- `.claude/skills/` - task-scoped guidance (the ABAP and UI5 problem catalogues a green CI does not catch)
- `.github/` - CI/CD workflows and configurations
- `package.json` - Node.js dependencies and build scripts
- `changelog.txt` - every user-visible change lands here under `unreleased` (the pull-request template asks for it)

## Development Environment Setup

### 1. Fork and Clone the Repository

```bash
# 1. Fork the repository on GitHub (click "Fork" button)
# 2. Clone your fork
git clone https://github.com/YOUR_USERNAME/abap2UI5.git
cd abap2UI5

# 3. Add upstream remote
git remote add upstream https://github.com/abap2UI5/abap2UI5.git
```

### 2. Install Dependencies

Required for everything below: `npx abaplint`, `npm run check`, `npm run verify`
and every `npm run check:*` gate come from these dependencies.

```bash
npm install
```

This installs the abaplint CLI (`@abaplint/cli`) and the other tools
automatically. The first `npm run check` additionally clones three pinned git
dependencies into `node/deps/` (`node/setup/fetch-deps.mjs`), so it needs
network access once; after that the checks run offline.

## ABAP Development with abapGit

### Installation in ABAP System

The framework supports easy installation via abapGit with no extra deployment needed.

1. **Install in Your ABAP System:**
   - Open abapGit in your ABAP system (SE80 → Utilities → abapGit)
   - Click "New Online" repository
   - Enter your fork URL: `https://github.com/YOUR_USERNAME/abap2UI5.git`
   - Choose package name (e.g., `$ZABAP2UI5` or `ZABAP2UI5`)
   - Install the repository

### abapGit Development Workflow

**For ABAP Developers (Recommended Path):**

1. **Make Changes in ABAP:**
   - Use SE80, ADT, or your preferred ABAP editor
   - Modify classes in the installed package (e.g., `z2ui5_cl_*` classes)
   - Test your changes in the ABAP system

2. **Export Changes via abapGit:**
   - Return to abapGit in your ABAP system
   - Select your repository
   - Click "Stage" to see your changes
   - Export changes to update local files in the `src/` directory

3. **Commit and Push:**
   ```bash
   # In your local repository directory
   git add .
   git commit -m "feat: describe your changes"
   git push origin feature/your-feature-name
   ```

## Code Quality and Testing

### Local Code Quality Checks

#### abaplint CLI Usage

The abaplint CLI (`@abaplint/cli`) is automatically installed with `npm install`. Use these commands:

```bash
# Check code quality with main rules
npx abaplint

# Apply automatic formatting fixes
npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix

# Check NetWeaver 7.02 compatibility (check only - see warning below)
npx abaplint .github/abaplint/abap_702.jsonc
```

> **Warning:** never run the 7.02 config with `--fix` (or `npm run auto_downport`)
> on a working tree with uncommitted changes - it rewrites `src/` in place and
> overwrites `abaplint.jsonc`. It is meant for throwaway CI checkouts. Commit
> first and restore afterwards with `git checkout -- src/ abaplint.jsonc`.

#### abaplint Configuration

The project uses multiple configurations:
- `abaplint.jsonc` - Main quality rules (v750 syntax)
- `.github/abaplint/auto_abaplint_fix.jsonc` - Automatic formatting fixes
- `.github/abaplint/abap_702.jsonc` - NetWeaver 7.02 compatibility

For rule customization, see [abaplint documentation](https://abaplint.org/).

### When to Run Local Tests

**For ABAP System Development:**
- ✅ **Always run:** `npm run check` (catches syntax and style issues)
- ⚠️ **Optional:** Transpilation tests (GitHub Actions handles this automatically)
- ✅ **For complex changes:** Run full pipeline to catch issues early

**Quick validation commands:**
```bash
# Recommended for all changes
npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix

# Fast inner loop: abaplint only (seconds)
npm run check

# Full gate before every PR (lint, gates, downport, transpile, unit + JS specs - see AGENTS.md)
# (non-destructive - runs in node/downport/, never touches src/)
npm run verify
```

### Automated Testing

The project uses comprehensive automated testing:
- **abaplint** - Static code analysis
- **Transpilation Tests** - ABAP to JavaScript conversion
- **Unit Tests** - Functionality validation
- **Browser Tests** - End-to-end testing with Playwright

## Making Your First Contribution

### Types of Contributions

1. **Bug Reports** - [Open an issue](https://github.com/abap2UI5/abap2UI5/issues)
2. **Feature Requests** - Discuss in issues first
3. **Documentation** - Improve guides, comments, or examples
4. **Code Contributions** - Bug fixes, new features, improvements
5. **Testing** - Add test cases or improve coverage

### Good First Issues

Look for issues labeled:
- `good first issue`
- `help wanted`
- `documentation`

### Development Workflow

1. **Create a Feature Branch:**
   ```bash
   git checkout main
   git pull upstream main
   git checkout -b feature/your-feature-name
   ```

2. **Make Your Changes:**
   - **ABAP Changes:** Use abapGit workflow (recommended)
   - **Frontend (`app/webapp/`) Changes:** Edit files directly, validate with `npm run check:js` (JS unit specs), then regenerate the embedded frontend in `src/01/03/` with `npm run app2abap` and commit it with your change — `npm run check:app2abap` is the gate that fails otherwise. The delivery trees are NOT committed: `npm run check:frontend` builds them into the git-ignored `tools/out/` to prove the build, and `frontend_deploy` builds and ships them from `main`

     > This repository is the **only** place the frontend is edited.
     > [abap2UI5/frontend](https://github.com/abap2UI5/frontend) publishes the
     > same webapp as installable branches, but it is generated: every branch
     > there is a tree built here from `app/webapp/`, delivered by
     > `frontend_deploy` into `result/<branch>` on its `main` and fanned out
     > from there by its `deliver` workflow, so a change made in that
     > repository is silently discarded on the next delivery. Its `guard`
     > workflow rejects manual pull requests for exactly that reason — see its
     > [CONTRIBUTING.md](https://github.com/abap2UI5/frontend/blob/main/CONTRIBUTING.md).

3. **Test Your Changes:**
   ```bash
   # Always run (catches most issues)
   npm run check

   # Before opening a PR (non-destructive full gate)
   npm run verify
   ```

   > Never validate with `npm run auto_downport` — it rewrites `src/` in place
   > and overwrites `abaplint.jsonc`, destroying uncommitted work. It exists
   > only to produce the `702` branch in CI. `npm run verify` performs the
   > identical downport non-destructively in `node/downport/`.

   Several of the gates are generators, and their failure message names the
   script that fixes them. If you would rather not install the toolchain for
   that, comment **`/fix`** on the pull request: CI runs all of them —
   `npm run app2abap`, `npm run auto_abaplint`, `npm run fmt:chains`,
   `npm run backlog` (the scopes `app2abap`, `abaplint`, `chains`,
   `backlog` in `autofix.yaml`) — and commits the result to your branch. Name a
   subset to skip the rest (`/fix chains backlog`; `app2abap` is three of the
   five minutes). `/fix abaplint` is the formatting pass on its own
   (`npm run auto_abaplint`), which `app2abap` also ends in but only after
   regenerating the whole embedded frontend first. Applying the `autofix`
   label does the same thing as a bare `/fix`.

   > `/fix` cannot push to a fork's branch, so on a pull request from a fork it
   > answers with the command line to run locally instead. And because a commit
   > made by CI does not start a new workflow run, push once more (or reopen the
   > pull request) after it lands, so the checks judge the fixed tree.

4. **Commit Your Changes:**
   ```bash
   git add .
   git commit -m "feat: add new feature for XYZ

   - Detailed description of changes
   - Why the change was needed
   - Any breaking changes"
   ```

#### Commit Message Guidelines
The rule for the whole ecosystem is
[`.github/shared/CONVENTIONS.md` section 7](.github/shared/CONVENTIONS.md#7-commits-and-pull-requests),
and it binds this repository too: a subject in the imperative describing the
**outcome**, not the mechanics. Do not repeat it here — this file used to ask
for conventional commits under 50 characters while AGENTS.md asked for
something else again and CONVENTIONS asked for a third thing, so a
contributor reading two of the three got a rule the reviewer did not hold
them to.

## Submitting Changes

### 1. Push Your Branch
```bash
git push origin feature/your-feature-name
```

### 2. Create a Pull Request
1. Go to your fork on GitHub
2. Click "Compare & pull request"
3. Fill out the PR template:
   - Clear description of changes
   - Why the change is needed
   - How to test the changes
   - Whether changes were made via abapGit

### 3. PR Review Process
1. **Automated Checks** - CI runs all tests automatically
2. **Code Review** - Maintainers review your code
3. **Feedback** - Address any requested changes
4. **Approval** - Once approved, your PR will be merged

### 4. After Merge
```bash
# Update your local repository
git checkout main
git pull upstream main
git branch -d feature/your-feature-name

# Update your abapGit repository
# In abapGit: pull latest changes to your ABAP system
```

## Community Guidelines

### Code of Conduct
Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md).

### Getting Help
- **Issues:** [GitHub Issues](https://github.com/abap2UI5/abap2UI5/issues)
- **Documentation:** [abap2UI5.org](https://abap2UI5.org)
- **Git Help:** [Git Documentation](https://git-scm.com/doc)
- **abapGit Help:** [abapGit Documentation](https://docs.abapgit.org/)

### Recognition
Contributors are recognized in the [GitHub contributors page](https://github.com/abap2UI5/abap2UI5/graphs/contributors) and project documentation.

## Advanced Topics

### Multi-Environment Support
The framework supports multiple ABAP environments:
- ABAP Cloud
- ABAP Standard
- NetWeaver 7.02+

### abapGit Best Practices
- Test changes in your ABAP system before exporting
- Export changes frequently to avoid conflicts
- Keep your local repository and ABAP system synchronized
- Use meaningful commit messages

### Build Pipeline
The project uses sophisticated build automation:
- Automatic downporting for NetWeaver 7.02 compatibility
- ABAP to JavaScript transpilation
- Comprehensive quality checks

## Thank You!

Your contributions help make abap2UI5 better for the entire ABAP community. Whether you're fixing a bug, adding a feature, or improving documentation, every contribution matters!

---

*For more information, visit [abap2UI5.org](https://abap2UI5.org) or explore our [sample applications](https://github.com/abap2UI5/samples).*
