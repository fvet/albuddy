# Development & maintenance

Guide for anyone building, testing, or releasing AL Buddy.

## Layout

| Path | What it is |
| --- | --- |
| `src/extension.ts` | Extension entry point (`activate` / `deactivate`). |
| `src/test/` | Integration tests, run inside a real VS Code instance. |
| `esbuild.js` | Bundles `src/extension.ts` into `dist/extension.js`. |
| `.vscode-test.mjs` | Test runner config for `@vscode/test-cli`. |
| `icons/logo.svg` | Source of the brand mark. `build-icons.ps1` rasterises it. |
| `.github/workflows/ci.yml` | Lint, type-check, test, and package on every push and PR. |
| `.github/workflows/release.yml` | Publishes to the Marketplace on a `v*` tag. |

## Prerequisites

- Node.js 22.x and npm.
- VS Code.
- For `npm run build-icons` only: Chrome or Edge, on Windows (PowerShell).

## Everyday commands

```bash
npm install           # install dependencies
npm run watch          # rebuild dist/ on change (use with F5 "Run Extension")
npm run compile        # type-check + lint + one-off bundle
npm run lint           # ESLint only
npm run check-types    # tsc --noEmit only
npm test               # full test build + run (see Testing below)
```

Press <kbd>F5</kbd> in VS Code to launch the Extension Development Host with the
extension loaded. Run **AL Buddy: Show Version** from the Command Palette to
confirm it activates.

---

## Testing

### What the tests are

`src/test/*.test.ts` are **integration tests**: `@vscode/test-cli` downloads a
throwaway VS Code build, installs this extension into it, and runs the suite
with the real `vscode` API available. The current suite is a smoke test — the
extension is present, activates, and registers its command.

### Run them locally

```bash
npm test
```

That runs, in order (via the `pretest` hook):

1. `npm run compile-tests` — `tsc` compiles `src/` to `out/`.
2. `npm run compile` — type-check, lint, and esbuild bundle to `dist/`.
3. `npm run lint`.

Then `vscode-test` launches VS Code and runs `out/test/**/*.test.js`.

- The **first run downloads VS Code** (~150 MB) into `.vscode-test/`; later runs
  reuse it. `.vscode-test/` is git-ignored.
- On Windows and macOS it just works. On Linux it needs a display —
  `xvfb-run -a npm test`.
- To iterate quickly, run `npm run watch-tests` in one terminal and use the
  **Extension Test Runner** VS Code extension (recommended in
  `.vscode/extensions.json`) to run individual tests from the editor.

### Add a test

Create `src/test/<name>.test.ts` using the TDD-style `suite()` / `test()` API
(configured in `.vscode-test.mjs`). Anything under `src/test/` matching
`*.test.ts` is picked up automatically.

### What CI runs

`.github/workflows/ci.yml` runs on every push to `main`, every PR, and manual
dispatch. Matrix: **ubuntu-latest** (tests under `xvfb`) and **windows-latest**.
Steps: `npm ci` -> `lint` -> `check-types` -> `compile-tests` -> `test` ->
`vsce package`. The Linux job uploads the built `.vsix` as a workflow artifact
so you can install a PR build by hand.

---

## Publishing

The extension is published to the **Visual Studio Marketplace** as
`FredericVercaemst.albuddy`. The Marketplace version always equals the Git tag.

### One-time setup (maintainer)

1. **Create the publisher.** Go to <https://marketplace.visualstudio.com/manage>,
   sign in with the Microsoft account that should own the extension, and create a
   publisher with ID **`FredericVercaemst`** (must match `publisher` in
   `package.json`).
2. **Create a Personal Access Token (PAT).** In Azure DevOps
   (<https://dev.azure.com>, same Microsoft account):
   - User settings -> **Personal access tokens** -> **New Token**.
   - **Organization:** *All accessible organizations* (required — a single-org
     token is rejected by `vsce`).
   - **Expiration:** up to 1 year. Set a calendar reminder to rotate it.
   - **Scopes:** *Show all scopes* -> **Marketplace** -> **Manage**.
   - Copy the token now; it is shown only once.
3. **Store the PAT as a GitHub Actions secret** named **`VSCE_PAT`**:
   - `gh secret set VSCE_PAT --repo fvet/albuddy` (paste when prompted), or
   - repo **Settings -> Secrets and variables -> Actions -> New repository
     secret**.
4. (Optional) Keep the PAT in your own credential store too, for local
   `vsce publish` as a fallback.

### Cutting a release

1. **Update the changelog.** Move everything under `## Unreleased` in
   `CHANGELOG.md` to a new `## x.y.z - YYYY-MM-DD` section and leave a fresh
   empty `## Unreleased`.
2. **Bump + tag** in one step:
   ```bash
   npm version <patch|minor|major>   # edits package.json, commits, tags vX.Y.Z
   ```
3. **Push with the tag:**
   ```bash
   git push --follow-tags
   ```
4. The **Release** workflow (`.github/workflows/release.yml`) then:
   - runs lint / type-check / tests,
   - asserts the tag matches `package.json` (`vX.Y.Z` -> `X.Y.Z`),
   - `vsce package` -> `albuddy-vX.Y.Z.vsix`,
   - `vsce publish` to the Marketplace using `VSCE_PAT`,
   - creates a GitHub Release with generated notes and the `.vsix` attached.
5. Confirm it went live:
   <https://marketplace.visualstudio.com/items?itemName=FredericVercaemst.albuddy>
   (listing can take a few minutes to refresh).

### Dry run (no publish)

**Actions -> Release -> Run workflow**, tick **dry-run**. It builds, tests, and
packages, uploads the `.vsix` artifact, and skips `vsce publish` and the GitHub
Release. Use it to sanity-check the pipeline without shipping.

### Manual publish (fallback)

If Actions is unavailable:

```bash
npm ci
npm test
npx vsce login FredericVercaemst      # paste the PAT once
npx vsce publish                       # uses package.json version
# or publish a prebuilt package:
npx vsce package
npx vsce publish --packagePath albuddy-<version>.vsix
```

### Verifying a package before it ships

```bash
npx vsce package
npx vsce ls        # list exactly what goes in the .vsix
```

Only these should be included: `package.json`, `README.md`, `CHANGELOG.md`,
`LICENSE`, `dist/extension.js`, `icons/icon128.png`. `.vscodeignore` controls
this — update it if you add shipped assets.

### Troubleshooting

| Symptom | Fix |
| --- | --- |
| `ERROR Failed request: (401)` on publish | `VSCE_PAT` is missing, expired, wrong scope, or not *all accessible organizations*. Recreate the PAT and update the secret. |
| `ERROR The Personal Access Token verification has failed` | Same as above; also check the publisher ID matches `package.json`. |
| Release workflow fails at "Check tag matches package.json version" | You tagged without running `npm version`, or edited the version separately. Delete the tag, fix `package.json`, re-tag. |
| `vsce package` warns about missing `repository` / activation | Keep `repository`, `license`, and an `icon` in `package.json`. |
| Tests fail only on the Linux CI job | Almost always the missing display — the job already wraps `npm test` in `xvfb-run`; check for a real assertion failure in the log. |

### Open VSX (not enabled)

AL Buddy currently ships to the VS Marketplace only. To also reach VSCodium /
Cursor / Windsurf users, add an `ovsx publish` step to `release.yml` with an
`OVSX_PAT` secret from <https://open-vsx.org>. Tracked in `backlog.md`.

---

## The icon

`package.json` points `icon` at `icons/icon128.png`, generated from
`icons/logo.svg`:

```bash
npm run build-icons
```

The script renders the SVG with headless Chrome so Segoe UI Semibold is baked
into the pixels and the result does not depend on the font being installed
elsewhere. Commit the regenerated `icon128.png` / `icon256.png` alongside any
`logo.svg` change.
