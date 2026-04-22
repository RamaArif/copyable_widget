# Contributing to copyable_widget

Thank you for your interest in contributing to `copyable_widget`! We welcome issues, feature requests, and pull requests.

## How to Contribute

### 1. Issues and Feature Requests
- Check existing issues before opening a new one.
- Use clear and descriptive titles.
- Provide a minimal reproducible example when reporting bugs.
- For feature requests, explain the use case and why the feature benefits the broader community.

### 2. Pull Requests
- Fork the repository and create your branch from `main`.
- Add tests for any new functionality or bug fixes.
- Ensure all tests pass by running `flutter test --coverage`.
- Run static analysis and fix any warnings or errors: `flutter analyze --fatal-infos`.
- Update the `README.md` and `CHANGELOG.md` if your changes affect usage or release notes.
- Write clear and meaningful commit messages.

## Code Guidelines

- **Null Safety**: The project uses strict null safety.
- **Documentation**: All public APIs must be fully documented using dartdoc comments (`///`).
- **Modifiers**: Use `sealed`, `final`, or `interface` class modifiers where appropriate to explicitly define API contracts.

## Development Setup

```sh
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run static analysis
flutter analyze
```

Thanks again for contributing!
