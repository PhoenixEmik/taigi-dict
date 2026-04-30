# Taigi Dict Native Swift

This directory contains the incremental Swift / SwiftUI rewrite of Taigi Dict.

The first phase intentionally starts as a Swift Package instead of a full Xcode
app target. Core domain models, normalization, conversion, and repository
interfaces can be tested independently, then mounted by an iOS 17+ SwiftUI app
target later.

## Boundaries

- Flutter source remains at the repository root during migration.
- Native Swift source lives under `swift-native/`.
- Dictionary source data is not parsed from `kautian.ods` by the app.
- ODS conversion must happen before runtime and produce JSONL/CSV or SQLite.
- Simplified/traditional conversion must go through SwiftyOpenCC behind
  `ChineseConversionService`.

## Package

```text
swift-native/
  Package.swift
  Sources/TaigiDictCore/
  Tests/TaigiDictCoreTests/
```

The package currently exposes `TaigiDictCore`, which is the shared foundation
for the future SwiftUI app target.
