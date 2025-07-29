# Contributing to Open Password Manager

Thank you for your interest in contributing to Open Password Manager! This document provides guidelines and information for contributors.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Issue Reporting](#issue-reporting)

## Code of Conduct

By participating in this project, you are expected to uphold our Code of Conduct:

- **Be respectful** and inclusive to all participants
- **Be collaborative** and constructive in discussions
- **Focus on what is best** for the community and project
- **Show empathy** towards other community members

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (Latest stable version)
- [Git](https://git-scm.com/)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA recommended)
- A backend provider account for testing (Firebase, Supabase, or Appwrite)

### Setting Up Development Environment

1. **Fork the repository** on GitHub

2. **Clone your fork**:
   ```bash
   git clone https://github.com/your-username/opm.git
   cd opm
   ```

3. **Add upstream remote**:
   ```bash
   git remote add upstream https://github.com/xeladu/opm.git
   ```

4. **Install dependencies**:
   ```bash
   flutter pub get
   ```

5. **Set up your backend** following one of the setup guides:
   - [Firebase Setup](docs/setup-firebase.md)
   - [Supabase Setup](docs/setup-supabase.md)
   - [Appwrite Setup](docs/setup-appwrite.md)

6. **Verify your setup**:
   ```bash
   flutter test
   flutter run -d chrome
   ```

## Development Workflow

### Branching Strategy

- `main` - Stable release branch
- `develop` - Integration branch for features
- `feature/feature-name` - Feature development branches
- `bugfix/bug-description` - Bug fix branches
- `hotfix/critical-fix` - Critical fixes for production

### Working on Features

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Keep your branch updated**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

3. **Make your changes** following the coding standards

4. **Test your changes**:
   ```bash
   flutter test
   flutter analyze
   ```

5. **Commit your changes**:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

## Pull Request Process

### Before Submitting

- [ ] Code follows the project's coding standards
- [ ] All tests pass (`flutter test`)
- [ ] Code analysis passes (`flutter analyze`)
- [ ] Documentation is updated if needed
- [ ] Commits follow conventional commit format

### Conventional Commits

Use the following format for commit messages:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

**Examples:**
```
feat(auth): add biometric authentication support
fix(encryption): resolve cross-platform salt synchronization
docs(readme): update installation instructions
```

### Submitting Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request** on GitHub with:
   - Clear title and description
   - Reference any related issues
   - Screenshots for UI changes
   - Breaking changes documentation

3. **Address review feedback** promptly

4. **Ensure CI checks pass**

## Coding Standards

### Dart/Flutter Guidelines

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `flutter format` for consistent formatting
- Follow the project's existing architecture patterns

### Architecture Principles

- **Domain-Driven Design (DDD)**: Maintain clear separation between domain, infrastructure, and presentation layers
- **Dependency Injection**: Use Riverpod for state management and DI
- **Repository Pattern**: Abstract data sources behind repository interfaces
- **Single Responsibility**: Each class/function should have one clear responsibility

### File Structure

```
lib/
├── features/
│   ├── [feature_name]/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── repositories/
│   │   ├── infrastructure/
│   │   │   └── repositories/
│   │   └── presentation/
│   │       ├── pages/
│   │       ├── widgets/
│   │       └── providers/
└── shared/
    ├── domain/
    ├── infrastructure/
    └── utils/
```

### Code Style

- Use meaningful variable and function names
- Add comments for complex business logic
- Keep functions small and focused
- Use const constructors where possible
- Prefer composition over inheritance

## Testing

### Test Categories

1. **Unit Tests**: Test individual functions and classes
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete user flows

### Writing Tests

- Place tests in `test/` directory mirroring `lib/` structure
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Mock external dependencies

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/features/auth/domain/repositories/auth_repository_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Documentation

### Code Documentation

- Use dartdoc comments for public APIs
- Include code examples in documentation
- Document complex algorithms and business logic

### User Documentation

- Update README.md for user-facing changes
- Update setup guides for backend configuration changes
- Include screenshots for UI changes

### API Documentation

- Document all public methods and classes
- Include parameter descriptions and return types
- Provide usage examples

## Issue Reporting

### Bug Reports

When reporting bugs, include:

- **Environment**: OS, Flutter version, browser (for web)
- **Backend**: Which provider you're using
- **Steps to reproduce**: Detailed steps
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Screenshots**: If applicable
- **Logs**: Console output and error messages

### Feature Requests

When requesting features, include:

- **Problem description**: What problem does this solve?
- **Proposed solution**: How should this work?
- **Alternatives considered**: Other approaches you've thought of
- **Additional context**: Screenshots, mockups, etc.

### Security Issues

**Do not** create public issues for security vulnerabilities. Instead:

1. Email the maintainers directly
2. Provide detailed information about the vulnerability
3. Allow time for the issue to be addressed before public disclosure

## Getting Help

- **GitHub Discussions**: For questions and general discussion
- **GitHub Issues**: For bug reports and feature requests
- **Documentation**: Check the setup guides and README first

## Recognition

Contributors will be recognized in:

- The project's contributor list
- Release notes for significant contributions
- The project's documentation where appropriate

Thank you for contributing to Open Password Manager! 🔐
