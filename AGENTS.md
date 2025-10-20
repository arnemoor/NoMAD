# Repository Guidelines

## Project Structure & Module Organization
Core sources sit in `NoMAD/`, with Swift feature files (for example `LoginWindow.swift`, `ShareMounter.swift`) beside small Objective-C shims such as `DNSResolver.m`. The Xcode definition in `NoMAD.xcodeproj` drives targets and signing. Assets and localizations live in `NoMAD/Assets.xcassets` and the language-specific `*.lproj` folders; edit nibs and strings together to avoid mismatches. Platform utilities cluster by role (`KerbUtil.*`, `LDAPUtil.swift`, `RouteTableManager/`), so extend the existing module rather than duplicating logic. Unit tests are isolated in `NoMADTests/`.

## Build, Test, and Development Commands
- `xcodebuild -project NoMAD.xcodeproj -scheme NoMAD -configuration Release`: Build a distributable app bundle.
- `xcodebuild test -project NoMAD.xcodeproj -scheme NoMAD -destination 'platform=macOS'`: Execute XCTest targets.
- `xcodebuild -project NoMAD.xcodeproj -list`: Confirm schemes before introducing a new one.
Match the macOS SDK recorded in the project settings and keep signing managed locally; shared provisioning files are not versioned.

## Coding Style & Naming Conventions
Adhere to standard Swift convention—`UpperCamelCase` types, `lowerCamelCase` members, 4-space indentation, and trailing commas for multi-line collections. Prefer `guard` and extensions for clarity, and keep shared helpers in `Extensions.swift`. Objective-C utilities follow Apple-style naming without prefixes; align with existing headers to ease review. Use Xcode’s formatting (`Editor ▸ Structure ▸ Re-Indent`) on touched files and keep import blocks alphabetized. Avoid introducing formatters or lint tools unless approved for the full repo.

## Testing Guidelines
Write or update XCTests inside `NoMADTests/NoMADTests.swift`, adding files as suites grow. Name methods `testScenario_expectation` to mirror the current style. Async paths must use expectations with explicit timeouts. Exercise both success and failure flows for authentication, Kerberos renewals, and password sync to protect regressions. Run `xcodebuild test` before opening a PR and record the macOS version in the description.

## Commit & Pull Request Guidelines
Recent history uses short, imperative commit subjects (“Fix UI freezing during authentication”). Keep summaries under 80 characters, elaborate in the body when multiple files move, and squash fixups before pushing. Pull requests should include a brief objective, testing evidence (command output or UI screenshots), and links to relevant issues. Flag localization, entitlement, or plist changes so reviewers can check deployment impact.

## Security & Configuration Tips
Update `NoMAD.entitlements` and `DefaultPreferences.plist` cautiously; capability changes affect distribution and managed deployments. Never commit real certificates, directory credentials, or site-specific secrets. When adding preference keys, supply benign sample values and document behavior in the PR notes.
