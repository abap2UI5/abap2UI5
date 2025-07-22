# Contributing to abap2UI5

Thank you for your interest in contributing to abap2UI5! This guide will help you get started with contributing to our project, whether you're new to open source or git.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Making Your First Contribution](#making-your-first-contribution)
- [Development Workflow](#development-workflow)
- [Code Quality and Testing](#code-quality-and-testing)
- [Submitting Changes](#submitting-changes)
- [Community Guidelines](#community-guidelines)

## Getting Started

### What is abap2UI5?

abap2UI5 is a framework for developing UI5 applications purely in ABAP, without JavaScript, OData, or RAP. [4](#0-3)  It supports both cloud and on-premise environments and works with all ABAP releases from NW 7.02 to ABAP Cloud. [5](#0-4) 

### Prerequisites

Before contributing, you'll need:

1. **Git** - [Download and install Git](https://git-scm.com/downloads)
2. **GitHub Account** - [Create a free account](https://github.com/join)
3. **Node.js** (for transpilation features) - [Download Node.js](https://nodejs.org/)
4. **ABAP Development Environment** (optional, for testing)

### Understanding the Project Structure

The repository contains:
- `src/` - Core ABAP framework classes [6](#0-5) 
- `node/` - Node.js transpilation setup and output
- `.github/` - CI/CD workflows and configurations
- `package.json` - Node.js dependencies and scripts [7](#0-6) 

## Development Environment Setup

### 1. Fork the Repository

1. Go to [https://github.com/abap2UI5/abap2UI5](https://github.com/abap2UI5/abap2UI5)
2. Click the "Fork" button in the top-right corner
3. This creates your own copy of the repository

### 2. Clone Your Fork

```bash
# Clone your fork to your local machine
git clone https://github.com/YOUR_USERNAME/abap2UI5.git

# Navigate to the project directory
cd abap2UI5

# Add the original repository as upstream
git remote add upstream https://github.com/abap2UI5/abap2UI5.git
```

### 3. Install Dependencies

```bash
# Install Node.js dependencies
npm install
```

### 4. Verify Your Setup

```bash
# Check that all npm scripts work
npm run auto_downport
npm run auto_transpile
npm run express &
curl -s http://localhost:3000
npm run unit
```

These commands test the transpilation pipeline that converts ABAP code to JavaScript. [8](#0-7) 

## Making Your First Contribution

### Types of Contributions Welcome

1. **Bug Reports** - Found an issue? [Open an issue](https://github.com/abap2UI5/abap2UI5/issues) [9](#0-8) 
2. **Feature Requests** - Have an idea? Discuss it in issues first
3. **Documentation** - Improve README, wiki, or code comments
4. **Code Contributions** - Bug fixes, new features, or improvements
5. **Testing** - Add test cases or improve existing ones

### Good First Issues

Look for issues labeled:
- `good first issue`
- `help wanted`
- `documentation`

## Development Workflow

### 1. Create a Feature Branch

```bash
# Make sure you're on main and up to date
git checkout main
git pull upstream main

# Create a new branch for your feature
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

#### For ABAP Code Changes:
- Follow the existing code style and patterns
- Ensure compatibility with ABAP 7.02+ [10](#0-9) 
- Add appropriate documentation

#### For Node.js/Transpilation Changes:
- Test your changes with `npm run auto_transpile`
- Ensure the Express server starts correctly with `npm run express`

### 3. Test Your Changes

```bash
# Run the full test suite
npm run auto_downport
npm run auto_transpile
npm run unit

# Test the web server
npm run express &
# Test in browser at http://localhost:3000
```

### 4. Commit Your Changes

```bash
# Stage your changes
git add .

# Commit with a descriptive message
git commit -m "feat: add new feature for XYZ

- Detailed description of what was added
- Why it was needed
- Any breaking changes"
```

#### Commit Message Guidelines:
- Use conventional commits format: `type: description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep the first line under 50 characters
- Add detailed description if needed

## Code Quality and Testing

### Automated Checks

The project uses several automated tools: [11](#0-10) 

1. **abaplint** - Static code analysis for ABAP [12](#0-11) 
2. **Transpilation Tests** - Ensures ABAP code converts to JavaScript
3. **Unit Tests** - Validates functionality
4. **Browser Tests** - End-to-end testing with Playwright [13](#0-12) 

### Running Quality Checks Locally

```bash
# Run abaplint checks
npx abaplint

# Run transpilation
npm run auto_transpile

# Run unit tests
npm run unit

# Run all checks (what CI does)
npm run auto_downport && npm run auto_transpile && npm run unit
```

### Code Style Guidelines

- Follow existing ABAP naming conventions
- Use meaningful variable and method names
- Add comments for complex logic
- Ensure ABAP Cloud compatibility where possible [14](#0-13) 

## Submitting Changes

### 1. Push Your Branch

```bash
# Push your feature branch to your fork
git push origin feature/your-feature-name
```

### 2. Create a Pull Request

1. Go to your fork on GitHub
2. Click "Compare & pull request"
3. Fill out the PR template with:
   - Clear description of changes
   - Why the change is needed
   - How to test the changes
   - Any breaking changes

### 3. PR Review Process

1. **Automated Checks** - CI will run all tests automatically
2. **Code Review** - Maintainers will review your code
3. **Feedback** - Address any requested changes
4. **Approval** - Once approved, your PR will be merged

### 4. After Your PR is Merged

```bash
# Switch back to main
git checkout main

# Pull the latest changes
git pull upstream main

# Delete your feature branch
git branch -d feature/your-feature-name
git push origin --delete feature/your-feature-name
```

## Community Guidelines

### Code of Conduct

Please read and follow our [Code of Conduct](CODE_OF_CONDUCT.md). [3](#0-2) 

### Getting Help

- **Issues**: [GitHub Issues](https://github.com/abap2UI5/abap2UI5/issues) [9](#0-8) 
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: [www.abap2UI5.org](http://www.abap2UI5.org) [15](#0-14) 

### Recognition

Contributors are recognized in:
- GitHub contributors page [16](#0-15) 
- Project documentation
- Release notes for significant contributions

## Advanced Topics

### Working with the Transpilation System

The project includes a sophisticated transpilation system that converts ABAP to JavaScript: [17](#0-16) 

```bash
# Understanding the transpilation pipeline
npm run auto_downport    # Ensures ABAP 7.02 compatibility
npm run auto_transpile   # Converts ABAP to JavaScript
npm run express         # Runs the Node.js server
```

### Testing in Different Environments

The project supports multiple ABAP environments:
- ABAP Cloud
- ABAP Standard  
- ABAP 7.02+ [5](#0-4) 

### Release Process

Releases follow semantic versioning and include:
- Feature additions
- Bug fixes
- Compatibility improvements [18](#0-17) 

## Thank You!

Your contributions help make abap2UI5 better for everyone. Whether you're fixing a typo, adding a feature, or helping with documentation, every contribution matters! [19](#0-18) 

---

*For more information, visit [www.abap2UI5.org](http://www.abap2UI5.org) or check out our [sample applications](https://github.com/abap2UI5/abap2UI5-samples).* [20](#0-19) 
```

## Notes

This contributing guide is tailored specifically for the abap2UI5 project based on its unique characteristics as an ABAP framework with Node.js transpilation capabilities. The guide incorporates the project's existing tooling, CI/CD workflows, and community resources while providing comprehensive guidance for newcomers to both open source and git workflows.

Wiki pages you might want to explore:
- [Node.js Transpilation (abap2UI5/abap2UI5)](/wiki/abap2UI5/abap2UI5#4.2)