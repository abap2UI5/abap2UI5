# Contributing to abap2UI5

Thank you for your interest in contributing to abap2UI5! This guide helps ABAP developers get started with open source contributions, whether you're new to Git or experienced with development workflows.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [ABAP Development with abapGit](#abap-development-with-abapgit)
- [Code Quality and Testing](#code-quality-and-testing)
- [Making Your First Contribution](#making-your-first-contribution)
- [Submitting Changes](#submitting-changes)
- [Community Guidelines](#community-guidelines)

## Getting Started

### What is abap2UI5?

abap2UI5 is a framework for developing UI5 applications purely in ABAP, without JavaScript, OData, or RAP. [1](#4-0)  It supports all ABAP releases from NW 7.02 to ABAP Cloud and works in both cloud and on-premise environments. [2](#4-1) 

### Prerequisites

**Required:**
1. **GitHub Account** - [Create a free account](https://github.com/join)
2. **Git** - [Download and install Git](https://git-scm.com/downloads) (for beginners: [Git Tutorial](https://git-scm.com/docs/gittutorial))

**For ABAP Development:**
3. **abapGit** - [Install abapGit](https://abapgit.org/) in your ABAP system
4. **ABAP Development Environment** - SE80, ADT, or your preferred ABAP editor

**For Node.js Development (Optional):**
5. **Node.js** - [Download Node.js](https://nodejs.org/) (only needed for transpilation testing)

### Understanding the Project

The repository structure: [3](#4-2) 
- `src/` - Core ABAP framework classes
- `node/` - Node.js transpilation setup
- `.github/` - CI/CD workflows and configurations
- `package.json` - Node.js dependencies and build scripts

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

### 2. Install Dependencies (Optional)

Only needed if you plan to run transpilation tests locally:

```bash
npm install
```

This installs abaplint-cli and other tools automatically. [4](#4-3) 

## ABAP Development with abapGit

### Installation in ABAP System

The framework supports easy installation via abapGit with no extra deployment needed. [5](#4-4) 

1. **Install in Your ABAP System:**
   - Open abapGit in your ABAP system (SE80 → Utilities → abapGit)
   - Click "New Online" repository
   - Enter your fork URL: `https://github.com/YOUR_USERNAME/abap2UI5.git`
   - Choose package name (e.g., `$ZABAP2UI5` or `ZABAP2UI5`)
   - Install the repository

### Development Workflow

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

#### abaplint-cli Usage

abaplint-cli is automatically installed with `npm install`. [4](#4-3)  Use these commands:

```bash
# Check code quality with main rules
npx abaplint

# Apply automatic formatting fixes
npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix

# Check NetWeaver 7.02 compatibility
npx abaplint .github/abaplint/abap_702.jsonc --fix
```

#### abaplint Configuration

The project uses multiple configurations: [6](#4-5) 
- `abaplint.jsonc` - Main quality rules (v750 syntax)
- `.github/abaplint/auto_abaplint_fix.jsonc` - Automatic formatting fixes [7](#4-6) 
- `.github/abaplint/abap_702.jsonc` - NetWeaver 7.02 compatibility [8](#4-7) 

For rule customization, see [abaplint documentation](https://abaplint.org/).

### When to Run Local Tests

**For ABAP System Development:**
- ✅ **Always run:** `npx abaplint` (catches syntax and style issues)
- ⚠️ **Optional:** Transpilation tests (GitHub Actions handles this automatically)
- ✅ **For complex changes:** Run full pipeline to catch issues early

**Quick validation commands:**
```bash
# Recommended for all changes
npx abaplint .github/abaplint/auto_abaplint_fix.jsonc --fix

# Optional - only for complex changes or debugging
npm run auto_downport
npm run auto_transpile
npm run unit
```

### Automated Testing

The project uses comprehensive automated testing: [9](#4-8) 
- **abaplint** - Static code analysis
- **Transpilation Tests** - ABAP to JavaScript conversion
- **Unit Tests** - Functionality validation
- **Browser Tests** - End-to-end testing with Playwright

## Making Your First Contribution

### Types of Contributions

1. **Bug Reports** - [Open an issue](https://github.com/abap2UI5/abap2UI5/issues) [10](#4-9) 
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
   - **Node.js Changes:** Edit files directly and test with `npm run auto_transpile`

3. **Test Your Changes:**
   ```bash
   # Always run (catches most issues)
   npx abaplint

   # Optional (GitHub Actions will run these)
   npm run auto_downport
   npm run auto_transpile
   ```

4. **Commit Your Changes:**
   ```bash
   git add .
   git commit -m "feat: add new feature for XYZ

   - Detailed description of changes
   - Why the change was needed
   - Any breaking changes"
   ```

#### Commit Message Guidelines
- Use [conventional commits](https://www.conventionalcommits.org/): `type: description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep first line under 50 characters
- Add detailed description for complex changes

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
- **Documentation:** [abap2UI5.org](http://abap2UI5.org) [11](#4-10) 
- **Git Help:** [Git Documentation](https://git-scm.com/doc)
- **abapGit Help:** [abapGit Documentation](https://docs.abapgit.org/)

### Recognition
Contributors are recognized in the [GitHub contributors page](https://github.com/abap2UI5/abap2UI5/graphs/contributors) and project documentation. [12](#4-11) 

## Advanced Topics

### Multi-Environment Support
The framework supports multiple ABAP environments: [2](#4-1) 
- ABAP Cloud
- ABAP Standard
- NetWeaver 7.02+

### abapGit Best Practices
- Test changes in your ABAP system before exporting
- Export changes frequently to avoid conflicts
- Keep your local repository and ABAP system synchronized
- Use meaningful commit messages

### Build Pipeline
The project uses sophisticated build automation: [13](#4-12) 
- Automatic downporting for NetWeaver 7.02 compatibility
- ABAP to JavaScript transpilation
- Comprehensive quality checks

## Thank You!

Your contributions help make abap2UI5 better for the entire ABAP community. Whether you're fixing a bug, adding a feature, or improving documentation, every contribution matters!

---

*For more information, visit [abap2UI5.org](http://abap2UI5.org) or explore our [sample applications](https://github.com/abap2UI5/abap2UI5-samples).*
