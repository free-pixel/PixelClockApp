# Contributing to PixelClock

First off, thank you for considering contributing to PixelClock! It's people like you that make PixelClock such a great tool.

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

### Pull Requests

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code follows the existing style.

### Swift Style Guide

- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint rules (configuration file is in the repo)
- Keep functions small and focused
- Use meaningful variable names
- Add comments for complex logic

### Git Commit Messages

- Use the present tense ("Add feature" not "Added feature")
- Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit the first line to 72 characters or less
- Reference issues and pull requests liberally after the first line

Example:
```
feat: add custom notification sounds

- Implement sound selection interface
- Add built-in notification sounds
- Support custom sound file import

Fixes #123
```

### Development Setup

1. Install the latest version of Xcode
2. Clone the repository:
   ```bash
   git clone https://github.com/YourUsername/PixelClock.git
   ```
3. Open `PixelClock.xcodeproj` in Xcode
4. Build and run the project

### Testing

- Write unit tests for new features
- Ensure all tests pass before submitting PR
- Test on different macOS versions if possible
- Test both light and dark mode

## Feature Requests

We love to hear new ideas. Open an issue on GitHub and:

1. Use a clear and descriptive title
2. Provide a detailed description of the suggested feature
3. Explain why this feature would be useful
4. Add mock-ups or sketches if applicable

## Bug Reports

When filing an issue, make sure to answer these questions:

1. What version of macOS are you using?
2. What version of PixelClock are you using?
3. What did you do?
4. What did you expect to see?
5. What did you see instead?

## Documentation

- Keep README.md and README-CN.md in sync
- Update documentation for any user-facing changes
- Add comments for complex code sections

## Community

- Be welcoming to newcomers
- Be respectful of differing viewpoints
- Accept constructive criticism
- Focus on what is best for the community

## License

By contributing, you agree that your contributions will be licensed under the same license that covers the project (see LICENSE file).

## Questions?

Don't hesitate to ask questions by creating an issue or reaching out to the maintainers.

Thank you for contributing! 🎉
