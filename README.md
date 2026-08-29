# AL Buddy

[![CI](https://github.com/fvet/albuddy/actions/workflows/ci.yml/badge.svg)](https://github.com/fvet/albuddy/actions/workflows/ci.yml)
[![Visual Studio Marketplace Version](https://img.shields.io/visual-studio-marketplace/v/FredericVercaemst.albuddy)](https://marketplace.visualstudio.com/items?itemName=FredericVercaemst.albuddy)
[![License: MIT](https://img.shields.io/badge/License-MIT-informational.svg)](LICENSE)

A VS Code extension that adds small, practical tools for **AL / Microsoft
Dynamics 365 Business Central** development.

> **Status: MVP.** This first release wires up the build, test, and publish
> pipeline end to end. It ships one placeholder command; real features land on
> top of it.

## What's in this release

| Command | Description |
| --- | --- |
| `AL Buddy: Show Version` | Shows the installed AL Buddy version. A smoke test that the extension activates and registers commands. |

## Requirements

- VS Code `1.95.0` or newer.

AL Buddy is a companion to the official
[AL Language](https://marketplace.visualstudio.com/items?itemName=ms-dynamics-smb.al)
extension; it does not replace it.

## Installation

Install **AL Buddy** from the Extensions view in VS Code, or:

```bash
code --install-extension FredericVercaemst.albuddy
```

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for how to build, run, test, and release the
extension. Issues and pull requests are welcome at
<https://github.com/fvet/albuddy>.

## License

[MIT](LICENSE) © Frédéric Vercaemst
