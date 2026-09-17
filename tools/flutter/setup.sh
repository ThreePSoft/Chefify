#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TOOLING_DIR="$REPO_ROOT/.tooling"
CONFIG_FILE="$TOOLING_DIR/flutter-sdk-path.txt"
LOCAL_SDK_ROOT="$REPO_ROOT/.flutter-sdk"
VERSION_FILE="$REPO_ROOT/frontend/.flutter-version"

if [ ! -f "$VERSION_FILE" ]; then
  echo "Pinned Flutter version file was not found at '$VERSION_FILE'." >&2
  exit 1
fi

FLUTTER_VERSION="$(tr -d '\r\n' < "$VERSION_FILE")"
if [[ ! "$FLUTTER_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid Flutter version '$FLUTTER_VERSION' in '$VERSION_FILE'." >&2
  exit 1
fi

log() {
  echo "[setup-flutter] $1"
}

normalize_path() {
  local raw="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY' "$raw"
import os, sys
print(os.path.abspath(sys.argv[1]))
PY
  else
    (cd "$raw" >/dev/null 2>&1 && pwd) || return 1
  fi
}

sdk_candidate_from_root() {
  local root="$1"
  if [ -z "$root" ]; then
    return 1
  fi

  local normalized
  normalized="$(normalize_path "$root" 2>/dev/null || true)"
  if [ -z "$normalized" ]; then
    return 1
  fi

  local flutter_exe="$normalized/bin/flutter"
  if [ -f "$flutter_exe" ]; then
    local sdk_version_file="$normalized/bin/cache/flutter.version.json"
    local sdk_version=""
    if [ -f "$sdk_version_file" ]; then
      sdk_version="$(sed -n 's/.*"flutterVersion"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$sdk_version_file" | head -n 1)"
    fi
    if [ "$sdk_version" != "$FLUTTER_VERSION" ]; then
      return 1
    fi

    echo "$normalized"
    return 0
  fi

  return 1
}

sdk_root_from_flutter_exe() {
  local exe="$1"
  if [ -z "$exe" ]; then
    return 1
  fi

  local resolved="$exe"
  if command -v realpath >/dev/null 2>&1; then
    resolved="$(realpath "$exe")"
  elif command -v readlink >/dev/null 2>&1; then
    resolved="$(readlink -f "$exe" 2>/dev/null || echo "$exe")"
  fi

  local bin_dir
  bin_dir="$(dirname "$resolved")"
  if [ "$(basename "$bin_dir")" != "bin" ]; then
    return 1
  fi

  dirname "$bin_dir"
}

resolve_installed_sdk() {
  local candidate

  if [ -n "${CHEFIFY_FLUTTER_SDK:-}" ]; then
    candidate="$(sdk_candidate_from_root "$CHEFIFY_FLUTTER_SDK" 2>/dev/null || true)"
    if [ -n "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  fi

  if [ -f "$CONFIG_FILE" ]; then
    local saved
    saved="$(head -n 1 "$CONFIG_FILE" | tr -d '\r')"
    candidate="$(sdk_candidate_from_root "$saved" 2>/dev/null || true)"
    if [ -n "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  fi

  candidate="$(sdk_candidate_from_root "$LOCAL_SDK_ROOT" 2>/dev/null || true)"
  if [ -n "$candidate" ]; then
    echo "$candidate"
    return 0
  fi

  if command -v flutter >/dev/null 2>&1; then
    local flutter_cmd sdk_root
    flutter_cmd="$(command -v flutter)"
    sdk_root="$(sdk_root_from_flutter_exe "$flutter_cmd" 2>/dev/null || true)"
    candidate="$(sdk_candidate_from_root "$sdk_root" 2>/dev/null || true)"
    if [ -n "$candidate" ]; then
      echo "$candidate"
      return 0
    fi
  fi

  return 1
}

install_local_flutter() {
  if sdk_candidate_from_root "$LOCAL_SDK_ROOT" >/dev/null 2>&1; then
    log "Local Flutter SDK already exists at '$LOCAL_SDK_ROOT'."
    echo "$LOCAL_SDK_ROOT"
    return 0
  fi

  mkdir -p "$TOOLING_DIR"

  local os_key
  case "$(uname -s)" in
    Linux*) os_key="linux" ;;
    Darwin*) os_key="macos" ;;
    *)
      log "Unsupported OS for automatic install. Please provide SDK path manually."
      return 1
      ;;
  esac

  if ! command -v curl >/dev/null 2>&1; then
    log "curl is required for local install."
    return 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    log "python3 is required for parsing Flutter release metadata."
    return 1
  fi

  local release_json_url="https://storage.googleapis.com/flutter_infra_release/releases/releases_${os_key}.json"
  local release_json_path="$TOOLING_DIR/flutter-releases-${os_key}.json"

  log "Downloading Flutter release metadata for ${os_key}..."
  curl -fsSL "$release_json_url" -o "$release_json_path"

  local release_data
  release_data="$(python3 - "$release_json_path" "$FLUTTER_VERSION" <<'PY'
import json, sys
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    payload = json.load(f)
version = sys.argv[2]
release = next((r for r in payload["releases"] if r.get("version") == version), None)
if not release:
    raise SystemExit(1)
print(release["version"])
print(release["archive"])
print(release["sha256"])
PY
)"

  local version archive_rel expected_sha256
  version="$(echo "$release_data" | sed -n '1p')"
  archive_rel="$(echo "$release_data" | sed -n '2p')"
  expected_sha256="$(echo "$release_data" | sed -n '3p')"

  if [ -z "$version" ] || [ -z "$archive_rel" ] || [ -z "$expected_sha256" ]; then
    log "Failed to parse metadata for pinned Flutter release $FLUTTER_VERSION."
    return 1
  fi

  local archive_url="https://storage.googleapis.com/flutter_infra_release/releases/${archive_rel}"
  local archive_file="$TOOLING_DIR/flutter-${os_key}-${version}.${archive_rel##*.}"

  log "Downloading Flutter SDK $version..."
  if [ -f "$archive_file" ]; then
    if ! python3 - "$archive_file" "$expected_sha256" <<'PY'
import hashlib, sys
with open(sys.argv[1], 'rb') as f:
    actual = hashlib.file_digest(f, 'sha256').hexdigest()
raise SystemExit(0 if actual.lower() == sys.argv[2].lower() else 1)
PY
    then
      rm -f "$archive_file"
    fi
  fi

  if [ ! -f "$archive_file" ]; then
    curl -fL "$archive_url" -o "$archive_file"
  fi

  if ! python3 - "$archive_file" "$expected_sha256" <<'PY'
import hashlib, sys
with open(sys.argv[1], 'rb') as f:
    actual = hashlib.file_digest(f, 'sha256').hexdigest()
raise SystemExit(0 if actual.lower() == sys.argv[2].lower() else 1)
PY
  then
    rm -f "$archive_file"
    log "Flutter archive checksum mismatch for $version."
    return 1
  fi

  log "Verified Flutter SDK archive checksum."

  rm -rf "$TOOLING_DIR/flutter"

  log "Extracting Flutter SDK..."
  if [[ "$archive_rel" == *.zip ]]; then
    if ! command -v unzip >/dev/null 2>&1; then
      log "unzip is required to extract Flutter SDK zip archive."
      return 1
    fi
    unzip -q "$archive_file" -d "$TOOLING_DIR"
  else
    tar -xf "$archive_file" -C "$TOOLING_DIR"
  fi

  if [ ! -d "$TOOLING_DIR/flutter" ]; then
    log "Expected extracted folder '$TOOLING_DIR/flutter' was not found."
    return 1
  fi

  rm -rf "$LOCAL_SDK_ROOT"
  mv "$TOOLING_DIR/flutter" "$LOCAL_SDK_ROOT"

  log "Local Flutter SDK installed to '$LOCAL_SDK_ROOT'."
  echo "$LOCAL_SDK_ROOT"
}

save_sdk_path() {
  local sdk_root="$1"
  mkdir -p "$TOOLING_DIR"
  printf '%s\n' "$sdk_root" > "$CONFIG_FILE"
}

print_usage() {
  echo "Usage: tools/flutter/setup.sh [--print-sdk-path] [--print-flutter-executable] [--non-interactive]"
}

PRINT_SDK_PATH=0
PRINT_FLUTTER_EXE=0
NON_INTERACTIVE=0

for arg in "$@"; do
  case "$arg" in
    --print-sdk-path) PRINT_SDK_PATH=1 ;;
    --print-flutter-executable) PRINT_FLUTTER_EXE=1 ;;
    --non-interactive) NON_INTERACTIVE=1 ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      print_usage
      exit 1
      ;;
  esac
done

SDK_ROOT="$(resolve_installed_sdk 2>/dev/null || true)"

if [ -z "$SDK_ROOT" ]; then
  if [ "$NON_INTERACTIVE" -eq 1 ]; then
    echo "Flutter SDK was not found. Run tools/flutter/setup.sh without --non-interactive to choose manual path or local install." >&2
    exit 1
  fi

  log "Flutter SDK was not found automatically."
  echo "1) Enter Flutter SDK path manually"
  echo "2) Install local SDK into .flutter-sdk"
  echo "3) Exit"
  read -r -p "Choose an option (1/2/3): " choice

  case "$choice" in
    1)
      read -r -p "Enter Flutter SDK root path: " manual_path
      SDK_ROOT="$(sdk_candidate_from_root "$manual_path" 2>/dev/null || true)"
      if [ -z "$SDK_ROOT" ]; then
        echo "Flutter SDK $FLUTTER_VERSION was not found at the provided path. Expected: <path>/bin/flutter" >&2
        exit 1
      fi
      ;;
    2)
      SDK_ROOT="$(install_local_flutter)"
      if [ -z "$SDK_ROOT" ]; then
        echo "Local Flutter SDK install failed." >&2
        exit 1
      fi
      ;;
    *)
      echo "Setup cancelled by user." >&2
      exit 1
      ;;
  esac
fi

save_sdk_path "$SDK_ROOT"
log "Using Flutter SDK: $SDK_ROOT"

if [ "$PRINT_FLUTTER_EXE" -eq 1 ]; then
  echo "$SDK_ROOT/bin/flutter"
elif [ "$PRINT_SDK_PATH" -eq 1 ]; then
  echo "$SDK_ROOT"
fi
