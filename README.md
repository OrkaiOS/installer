# orkai — install

Official **orkai** CLI binaries for **macOS**, **Linux**, and **Windows.

[orkai](https://getorkai.com) is local AI memory for coding agents — a single binary with an embedded dashboard and MCP server for **Cursor**, **Claude Code**, **Windsurf**, and other MCP clients. Everything stays on your machine.

| | |
|---|---|
| **Website** | [getorkai.com](https://getorkai.com) |
| **Pricing & trial** | [getorkai.com/pricing](https://getorkai.com/pricing) |
| **Quick start** | [getorkai.com/docs/quick-start](https://getorkai.com/docs/quick-start) |
| **Install guide** | [getorkai.com/docs/install](https://getorkai.com/docs/install) |
| **Support** | [support@getorkai.com](mailto:support@getorkai.com) |

> **License required.** Installing the binary does **not** include a license. Get a key from [getorkai.com/pricing](https://getorkai.com/pricing) (free 7-day trial or paid), then run `orkai activate <KEY>`. Read-only commands work without activation; `serve`, `index`, and other write/compute paths require a valid license.

---

## Install script (recommended)

### macOS and Linux

```bash
curl -fsSL https://raw.githubusercontent.com/OrkaiOS/installer/main/scripts/install.sh | bash
```

Pin a version (git tag on this repo):

```bash
ORKAI_VERSION=v1.0.1 curl -fsSL https://raw.githubusercontent.com/OrkaiOS/installer/main/scripts/install.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/OrkaiOS/installer/main/scripts/install.ps1 | iex
```

---

## Manual download

Pick the file for your platform from this repository (root directory or [Releases](https://github.com/OrkaiOS/installer/releases)):

| File | Platform |
|------|----------|
| `orkai-darwin-arm64` | macOS Apple Silicon (M1/M2/M3/M4) |
| `orkai-darwin-amd64` | macOS Intel |
| `orkai-linux-amd64` | Linux x86_64 |
| `orkai-linux-arm64` | Linux ARM64 (Graviton, Raspberry Pi 4+) |
| `orkai-windows-amd64.exe` | Windows 64-bit |

**macOS / Linux** — make executable and move onto your PATH:

```bash
chmod +x orkai-darwin-arm64   # use your platform file name
sudo mv orkai-darwin-arm64 /usr/local/bin/orkai
orkai version
```

**Windows** — place `orkai-windows-amd64.exe` on your PATH (e.g. `%LOCALAPPDATA%\Programs\orkai\`) and rename to `orkai.exe`.

Verify checksums when `SHA256SUMS` is present:

```bash
shasum -a 256 -c SHA256SUMS
```

---

## After install

1. **Get a license** — [getorkai.com/pricing](https://getorkai.com/pricing)
2. **Activate** — `orkai activate ORKAI_your_key_here`
3. **First run** — `orkai serve` (interactive setup wizard)
4. **Daily use** — `orkai start` / `orkai stop` / `orkai open`
5. **Connect your editor** — `orkai mcp-config` → paste the section for your client (Cursor, Claude Desktop, …)

Full walkthrough: [getorkai.com/docs/quick-start](https://getorkai.com/docs/quick-start)

---

## What you get

- Embedded SQLite + vector search + full-text search — no Docker required
- MCP server for AI agents (`overview()`, standards, sessions, code search)
- Local web dashboard at `http://localhost:9090`
- `orkai index`, `orkai search`, `orkai review`, and more

Product source and development happen in the main orkai codebase; **this repository publishes installable releases only.**

---

## Version

Current release: **[`VERSION`](VERSION)** (semver, e.g. `0.2.0`).

Maintainers bump in the product monorepo with `make release-installer` (default: minor bump). Pin installs with `ORKAI_VERSION=v0.2.0` on the install script.
