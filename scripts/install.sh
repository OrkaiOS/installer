#!/usr/bin/env bash
# Install orkai from OrkaiOS/installer (macOS / Linux).
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/OrkaiOS/installer/main/scripts/install.sh | bash
#   ORKAI_VERSION=v1.0.1 curl -fsSL ... | bash
#
# License: installing the binary does not grant a license. Activate after install:
#   orkai activate <KEY>   — keys from https://getorkai.com/pricing
set -euo pipefail

REPO="${ORKAI_GITHUB_REPO:-OrkaiOS/installer}"
REF="${ORKAI_VERSION:-main}"
INSTALL_DIR="${ORKAI_INSTALL_DIR:-}"

info() { printf '==> %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }

detect_asset() {
  local os arch
  os="$(uname -s)"
  arch="$(uname -m)"
  case "${os}:${arch}" in
    Darwin:arm64)              echo "orkai-darwin-arm64" ;;
    Darwin:x86_64)             echo "orkai-darwin-amd64" ;;
    Linux:x86_64|Linux:amd64)  echo "orkai-linux-amd64" ;;
    Linux:aarch64|Linux:arm64) echo "orkai-linux-arm64" ;;
    *)
      die "unsupported platform: ${os} ${arch}. See https://github.com/${REPO} or https://getorkai.com/docs/install"
      ;;
  esac
}

download_url() {
  local asset="$1"
  local release_url="https://github.com/${REPO}/releases/download/${REF}/${asset}"
  if [[ "${REF}" == v* ]] && curl -fsI "${release_url}" 2>/dev/null | head -n1 | grep -qE '200|302'; then
    echo "${release_url}"
    return
  fi
  echo "https://raw.githubusercontent.com/${REPO}/${REF}/${asset}"
}

checksums_url() {
  local release_url="https://github.com/${REPO}/releases/download/${REF}/SHA256SUMS"
  if [[ "${REF}" == v* ]] && curl -fsI "${release_url}" 2>/dev/null | head -n1 | grep -qE '200|302'; then
    echo "${release_url}"
    return
  fi
  echo "https://raw.githubusercontent.com/${REPO}/${REF}/SHA256SUMS"
}

pick_install_dir() {
  if [[ -n "${INSTALL_DIR}" ]]; then
    echo "${INSTALL_DIR}"
    return
  fi
  if [[ -w /usr/local/bin ]]; then
    echo "/usr/local/bin"
    return
  fi
  if command -v sudo >/dev/null 2>&1; then
    echo "/usr/local/bin"
    return
  fi
  local user_bin="${HOME}/.local/bin"
  mkdir -p "${user_bin}"
  warn "installing to ${user_bin} (add it to PATH if needed)"
  echo "${user_bin}"
}

verify_checksum() {
  local asset="$1" tmpdir="$2"
  local sums_url
  sums_url="$(checksums_url)"
  if ! curl -fsSL "${sums_url}" -o "${tmpdir}/SHA256SUMS" 2>/dev/null; then
    warn "SHA256SUMS not found — skipping checksum verification"
    return 0
  fi
  local line
  line="$(grep " ${asset}\$" "${tmpdir}/SHA256SUMS" || true)"
  [[ -n "${line}" ]] || die "checksum entry missing for ${asset}"
  (
    cd "${tmpdir}"
    if command -v sha256sum >/dev/null 2>&1; then
      echo "${line}" | sha256sum -c -
    else
      echo "${line}" | shasum -a 256 -c -
    fi
  )
}

main() {
  local asset url tmpdir dest use_sudo=0
  asset="$(detect_asset)"
  url="$(download_url "${asset}")"
  dest="$(pick_install_dir)"

  info "Installing orkai (${REF}) — ${asset}"
  info "Download: ${url}"
  info "Install to: ${dest}/orkai"

  tmpdir="$(mktemp -d)"
  trap 'rm -rf "${tmpdir}"' EXIT

  curl -fsSL "${url}" -o "${tmpdir}/${asset}"
  verify_checksum "${asset}" "${tmpdir}"
  chmod +x "${tmpdir}/${asset}"

  if [[ "${dest}" == "/usr/local/bin" ]] && [[ ! -w "${dest}" ]]; then
    use_sudo=1
  fi

  if [[ "${use_sudo}" -eq 1 ]]; then
    sudo install -m 755 "${tmpdir}/${asset}" "${dest}/orkai"
  else
    install -m 755 "${tmpdir}/${asset}" "${dest}/orkai"
  fi

  if ! command -v orkai >/dev/null 2>&1; then
    warn "${dest} is not on PATH — add it to your shell profile"
  fi

  info "Installed: $(orkai version 2>/dev/null || "${dest}/orkai" version)"
  cat <<EOF

Next steps:
  1. Get a license (trial or paid): https://getorkai.com/pricing
  2. orkai activate <YOUR_KEY>
  3. orkai serve          # first-run setup, then use orkai start

Indexing, serve, and other write/compute commands require a valid license.
EOF
}

main "$@"
