#!/bin/sh
set -eu

PROJECT_ROOT="${SRCROOT}/.."
BUILD_ROOT="${PROJECT_ROOT}/${FLUTTER_BUILD_DIR:-build}"
HOOKS_ROOT="${PROJECT_ROOT}/.dart_tool/hooks_runner/shared/objective_c/build"
FRAMEWORK_DIR="${BUILD_ROOT}/native_assets/ios/objective_c.framework"
BINARY_PATH="${FRAMEWORK_DIR}/objective_c"
INFO_PLIST_PATH="${FRAMEWORK_DIR}/Info.plist"
IOS_OUTPUT_DIR="${BUILD_ROOT}/ios/${CONFIGURATION}${EFFECTIVE_PLATFORM_NAME}"

if [ ! -d "${HOOKS_ROOT}" ]; then
  exit 0
fi

arm64_binary=""
x86_64_binary=""

for candidate in "${HOOKS_ROOT}"/*/objective_c.dylib; do
  if [ ! -f "${candidate}" ]; then
    continue
  fi

  candidate_info="$(file "${candidate}")"
  case "${candidate_info}" in
    *arm64*)
      arm64_binary="${candidate}"
      ;;
  esac
  case "${candidate_info}" in
    *x86_64*)
      x86_64_binary="${candidate}"
      ;;
  esac
done

if [ -z "${arm64_binary}" ] && [ -z "${x86_64_binary}" ]; then
  exit 0
fi

mkdir -p "${FRAMEWORK_DIR}"

if [ -n "${arm64_binary}" ] && [ -n "${x86_64_binary}" ]; then
  lipo -create "${arm64_binary}" "${x86_64_binary}" -output "${BINARY_PATH}"
elif [ -n "${arm64_binary}" ]; then
  cp "${arm64_binary}" "${BINARY_PATH}"
else
  cp "${x86_64_binary}" "${BINARY_PATH}"
fi

chmod 755 "${BINARY_PATH}"

cat > "${INFO_PLIST_PATH}" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>objective_c</string>
  <key>CFBundleIdentifier</key>
  <string>org.flutter.nativeassets.objectivec</string>
  <key>CFBundleName</key>
  <string>objective_c</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>CFBundleVersion</key>
  <string>1</string>
</dict>
</plist>
EOF

if [ -d "${IOS_OUTPUT_DIR}" ]; then
  xattr -cr "${IOS_OUTPUT_DIR}"
fi
