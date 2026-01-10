# AGENTS.md - Instructions for AI Agents

This document provides guidelines for AI agents working on the PixelClock codebase.

## Project Overview

PixelClock is a Pomodoro timer app for macOS built with SwiftUI. Features: customizable timer durations, menu bar progress indicator, sound notifications, task completion tracking.

## Build Commands

```bash
# Open in Xcode
open PixelClock.xcodeproj

# Build from command line
xcodebuild -project PixelClock.xcodeproj -scheme PixelClock -configuration Debug build

# Build using script
./scripts/build.sh           # Debug, universal binary
./scripts/build.sh Debug     # Debug build
./scripts/build.sh Release   # Release build

# Run the app
open build/Debug/PixelClock.app
```

## Testing Commands

```bash
# Run all tests
xcodebuild -project PixelClock.xcodeproj -scheme PixelClock -configuration Debug test

# Run a single test class
xcodebuild -project PixelClock.xcodeproj -scheme PixelClock -configuration Debug test -only-testing:PixelClockTests/PixelClockTests

# Run a single test method
xcodebuild -project PixelClock.xcodeproj -scheme PixelClock -configuration Debug test -only-testing:PixelClockTests/PixelClockTests/example

# Run tests in Release configuration
xcodebuild -project PixelClock.xcodeproj -scheme PixelClock -configuration Release test
```

## Lint & Pre-commit

```bash
# Run pre-commit hooks manually
pre-commit run --all-files

# Run specific hook
pre-commit run trailing-whitespace --all-files

# Check for secrets with TruffleHog
trufflehog filesystem .
```

## Code Style Guidelines

### Swift Conventions

- Follow Apple's [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Prefer `let` over `var` for immutability
- Use `guard` for early returns and optional unwrapping
- Keep functions small and single-purpose (target: <30 lines)
- Use trailing closure syntax when closure is last parameter

### Naming

| Type | Convention | Example |
|------|------------|---------|
| Types | PascalCase | `TimerViewModel`, `TimerState` |
| Variables/Constants | camelCase | `taskDuration`, `timerValue` |
| Functions | camelCase | `switchTo(_:)`, `startPauseTimer()` |
| Private/Internal | prefix `_` | `_privateProperty` |

### Imports

- Organize imports alphabetically
- Group by framework, then project imports
- Example:

```swift
import Foundation
import SwiftUI

@testable import PixelClock
```

### Formatting

- 4 spaces for indentation (no tabs)
- Max ~100 characters per line
- Use implicit returns for single-expression functions
- No trailing whitespace
- Empty line between import groups and code

### Access Control

```swift
// Order: private, fileprivate, internal, public, open
private let constant = 42
internal var sharedState: String?
public func accessibleMethod() { }
```

### Error Handling

```swift
// Preferred: throw/try for recoverable errors
func loadConfiguration() throws -> Config {
    guard FileManager.default.fileExists(atPath: path) else {
        throw ConfigurationError.notFound
    }
    // ...
}

// Use guard for precondition validation
guard !items.isEmpty else { return }
```

### SwiftUI Best Practices

```swift
// Local state in View
@State private var isExpanded: Bool = false

// Shared state (ObservableObject)
@StateObject private var viewModel = TimerViewModel()

// App-wide services
@EnvironmentObject var appDelegate: AppDelegate

// Avoid @Published in View structs
// Correct: @StateObject + @ObservedObject
// Avoid: @Published directly in View
```

### Documentation

```swift
/// Starts the timer with specified duration.
///
/// - Parameter duration: Time in seconds for the timer
/// - Throws: TimerError if timer already running
func startTimer(duration: TimeInterval) throws
```

## Project Structure

```
PixelClock/
├── PixelClock/              # Main app
│   ├── PixelClockApp.swift  # App entry, AppDelegate, MenuBarController
│   ├── ContentView.swift    # Main UI with TimerViewModel
│   ├── TimerViewModel.swift # Timer state management
│   └── Resources/           # alert.wav
├── PixelClockTests/         # Unit tests (Swift Testing)
└── scripts/build.sh         # Build script
```

## Git Conventions

```
<type>: <subject>

Types: feat, fix, refactor, style, docs, test, chore

feat: add custom notification sounds
fix: resolve timer pause issue
```

Branches: `feat/` | `fix/` | `refactor/`

## Security

- Never commit secrets, keys, or credentials
- Use `.env` files, exclude from git
- Report any suspected secret leaks immediately
- Follow OWASP AI Agent Security guidelines

## Resources

- [Swift Documentation](https://developer.apple.com/documentation/swift)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Swift Testing Framework](https://developer.apple.com/documentation/testing)
- [CONTRIBUTING.md](./CONTRIBUTING.md)
