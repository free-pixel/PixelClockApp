# AGENTS.md - Instructions for AI Agents

This document provides guidelines for AI agents working on the PixelClock codebase.

## Project Overview

PixelClock is a Pomodoro timer app for macOS built with SwiftUI. Features: customizable timer durations, menu bar progress indicator, sound notifications, task completion tracking.

## Build Commands

```bash
# Open in Xcode
open PixelClock.xcodeproj

# Build from command line (using custom project file)
xcodebuild -project PixelClock.xcodeproj -target PixelClock -configuration Debug build

# Build using build script
./scripts/build.sh           # Debug, universal binary
./scripts/build.sh Debug     # Debug build
./scripts/build.sh Release   # Release build
./scripts/build.sh arm64     # Apple Silicon only
./scripts/build.sh universal  # Both architectures (default)

# Run the app after building
open build/Debug/PixelClock.app
```

## CI/CD (GitHub Actions)

The project uses GitHub Actions for continuous integration and automated releases.

### Workflows

- **CI Workflow** (`.github/workflows/ci.yml`): Runs on every push and PR
  - Builds Debug and Release configurations
  - Runs unit tests
  - Verifies binary architecture

- **Release Workflow** (`.github/workflows/release.yml`): Runs on version tags
  - Builds Release universal binary
  - Creates GitHub Release
  - Attaches ZIP artifact to release

### Creating a Release

```bash
# Tag a version
git tag v1.0.0
git push origin v1.0.0
```

GitHub Actions will automatically create a release with the build artifact.

### Local Testing with `act`

```bash
# Install act
brew install act

# Run CI workflow locally
act push --workflow .github/workflows/ci.yml
```

See `.github/workflows/README.md` for detailed documentation.

## Code Style Guidelines

### Swift Conventions

- Follow Apple's Swift API Design Guidelines
- Prefer `let` over `var` for immutability
- Use guard for early returns and optional unwrapping
- Keep functions small and single-purpose

### Naming & Formatting

- PascalCase for types, camelCase for variables/functions
- Use descriptive names: `taskDuration` not `td`
- 4 spaces for indentation, max ~100 characters
- Organize imports alphabetically

### Access Control

- Use `private` by default
- Use `public` only for API that needs external access

### Error Handling

- Use `throw`/`try` for recoverable errors
- Use `guard` for precondition validation
- Print errors with context: `print("Context: error \(error)")`

### SwiftUI Best Practices

- Use `@State` for local view state
- Use `@ObservedObject` or `@StateObject` for external data
- Use `@EnvironmentObject` for app-wide services
- Avoid `@Published` in View structs
- Use `.onChange(of: newValue)` syntax (iOS 17+)

### Property Wrappers

```swift
@State private var timerValue: Double = 25 * 60
@EnvironmentObject var appDelegate: AppDelegate
```

### Documentation

- Document complex logic with comments
- Use /// for public API documentation
- Comment foreign language text in code

## Project Structure

```
PixelClock/
├── PixelClock/          # Main app source
│   ├── PixelClockApp.swift     # App entry point, AppDelegate
│   ├── ContentView.swift       # Main UI
│   ├── WindowAccessor.swift    # Window utilities
│   └── Resources/              # Assets (alert.wav)
├── PixelClockTests/     # Unit tests (Swift Testing framework)
├── scripts/build.sh     # Build script
└── PixelClock.xcodeproj/
```

## Git Conventions

### Commit Message Format

```
<type>: <subject>

Types: feat, fix, refactor, style, docs, test, chore
Examples:
feat: add custom notification sounds
fix: resolve timer pause issue
```

### Branch Naming

- `feat/` for new features
- `fix/` for bug fixes
- `refactor/` for refactoring

## Testing

Use Swift Testing framework with `@Test` attribute and `#expect(...)` for assertions.

```swift
import Testing
@testable import PixelClock

struct PixelClockTests {
    @Test func example() async throws { }
}
```

## Resources

- [Swift Documentation](https://developer.apple.com/documentation/swift)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Swift Testing Framework](https://developer.apple.com/documentation/testing)
- [CONTRIBUTING.md](./CONTRIBUTING.md)
