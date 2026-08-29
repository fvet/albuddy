# CLAUDE.md

## What this is

A VS Code extension (`FredericVercaemst.albuddy`, "AL Buddy") that adds helper
tools for AL / Business Central development. Published to the Visual Studio
Marketplace only. Companion project to BC Buddy, and it borrows BC Buddy's icon
build (`icons/build-icons.ps1`) and brand construction.

## Language

All development is in English: source, comments, commit messages, build-script
output, docs. There are no localised strings yet.

## Conventions

- **TypeScript + esbuild.** `src/extension.ts` bundles to `dist/extension.js`.
  Do not add a compile step that emits the extension via `tsc` - `tsc` is
  type-check only (`npm run check-types`) plus the test build (`npm run
  compile-tests` -> `out/`).
- **Every user-visible change gets a `CHANGELOG.md` entry** under `## Unreleased`,
  in the same commit, written for users. Build/CI/dependency work does not.
- **`README.md` and `DEVELOPMENT.md` split by reader**: README is for users of
  the extension, DEVELOPMENT is for contributors. A behaviour change usually
  touches README + CHANGELOG; a workflow/tooling change touches DEVELOPMENT.
- **Icon**: edit `icons/logo.svg`, then `npm run build-icons`, then commit the
  regenerated PNGs. `package.json` ships `icon128.png`.
- **Versioning**: the Marketplace version follows the Git tag. Release steps are
  in DEVELOPMENT.md; `release.yml` fails if the `v*` tag and `package.json`
  disagree.
- New commands: declare in `package.json` `contributes.commands` with the
  `AL Buddy` category, register in `activate`, document in the README table.

## Checks before a commit

`npm run lint && npm run check-types && npm test` - the same gates CI runs.
