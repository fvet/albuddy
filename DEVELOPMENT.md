# Development

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

## Common tasks

```bash
npm install          # install dependencies
npm run watch         # rebuild dist/ on change (use with F5 "Run Extension")
npm run compile       # type-check + lint + one-off bundle
npm test              # compile tests + bundle + lint, then run in VS Code
npm run lint          # ESLint only
```

Press <kbd>F5</kbd> in VS Code to launch the Extension Development Host with the
extension loaded. Run **AL Buddy: Show Version** from the Command Palette to
confirm it activates.

## The icon

`package.json` points `icon` at `icons/icon128.png`. That PNG is generated from
`icons/logo.svg`:

```bash
npm run build-icons
```

The script renders the SVG with headless Chrome so Segoe UI Semibold is baked
into the pixels and the result does not depend on the font being installed
elsewhere. Commit the regenerated `icon128.png` / `icon256.png` alongside any
`logo.svg` change.

## Tests

Tests live in `src/test/*.test.ts`, are compiled to `out/` by `tsc`, and run
through `@vscode/test-cli`, which downloads a throwaway VS Code build and loads
the extension into it. The first run downloads VS Code; later runs are cached.

CI runs the same suite on Linux (under `xvfb`) and Windows.

## Releasing

The Marketplace version is driven by the Git tag.

1. Move the `## Unreleased` notes in `CHANGELOG.md` under a new
   `## x.y.z - YYYY-MM-DD` heading, and open a fresh empty `## Unreleased`.
2. Bump the version: `npm version x.y.z` (this commits and creates the `vx.y.z`
   tag).
3. `git push && git push --tags`.

The `Release` workflow then lints, type-checks, tests, packages the `.vsix`,
verifies the tag matches `package.json`, runs `vsce publish`, and attaches the
`.vsix` to a generated GitHub release.

Use **Actions -> Release -> Run workflow** with **dry-run** checked to build and
package without publishing.

### One-time setup

- Create a publisher named **FredericVercaemst** at
  <https://marketplace.visualstudio.com/manage>.
- Create an Azure DevOps Personal Access Token with **Marketplace -> Manage**
  scope (all accessible organizations).
- Add it to the repo as the **`VSCE_PAT`** Actions secret
  (Settings -> Secrets and variables -> Actions).
