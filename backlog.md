# Backlog

Ideas for AL Buddy features, mostly things worth learning from or improving on
in other AL extensions. Nothing here is committed scope — it is a shopping list.

When picking something up: open an issue, move the line here to **In progress**,
and add a `CHANGELOG.md` entry when it ships.

## Attribution & licensing

Several ideas below come from **AL Toolbox** by Bart Permentier
(<https://marketplace.visualstudio.com/items?itemName=BartPermentier.al-toolbox>,
source: <https://github.com/StefanMaron/vscode-al-toolbox> / Bart's repos).
**Do not copy code or snippet bodies without checking that project's licence
first.** Prefer reimplementing the behaviour from scratch, or — where the idea
is really a missing compiler analyzer/code action — contributing it upstream to
**AlCops / BusinessCentral.LinterCop** instead of duplicating it here.

---

## 1. Snippets

Reimplement equivalents to these AL Toolbox snippets (names are theirs; ours can
differ). Ship as `snippets/al.json` referenced from `contributes.snippets`.

- [ ] **`rAction`** — TableRelation-style / page action scaffold with the common
      `ApplicationArea`, `Image`, `trigger OnAction` boilerplate.
- [ ] **`rRepeat`** — `repeat … until Rec.Next() = 0;` loop around a
      `if Rec.FindSet() then`.
- [ ] **`rSimplestFunction`** — bare `local procedure Name()` with begin/end.
- [ ] **`rUpgradeFunctionCompany`** — upgrade codeunit `OnUpgradePerCompany`
      procedure with `UpgradeTag` guard (`if UpgradeTag.HasUpgradeTag(...) then exit;`
      … `UpgradeTag.SetUpgradeTag(...)`).
- [ ] **`rUpgradeFunctionDatabase`** — same for `OnUpgradePerDatabase`.

Design notes:
- Match the AL Language extension's own snippet style (prefix, placeholders,
  `$0` final cursor).
- Consider a setting to choose tab vs. 4-space bodies to match `alformatter`.

## 2. Quick fixes (code actions)

- [ ] **Surround with `CopyStr`** — code action on a string-assignment /
      argument that may overflow, wrapping the expression in
      `CopyStr(expr, 1, MaxStrLen(target))`.
      Ref: <https://marketplace.visualstudio.com/items?itemName=BartPermentier.al-toolbox#quickfixes-surround-with-copystr>
      *Upstream option:* propose as an AlCops/LinterCop fix for the overflow rule.
- [ ] **Pragma warning toggle** — code action to wrap the current line/block in
      `#pragma warning disable <id>` / `#pragma warning restore <id>`, id taken
      from the diagnostic under the cursor.
      Ref: <https://marketplace.visualstudio.com/items?itemName=BartPermentier.al-toolbox#pragma-warnings>
      *Upstream option:* this is arguably a plain AL Language feature request.

## 3. Actions / commands

- [ ] **Generate `SetLoadFields`** — command/code action that inspects the
      fields actually read between a `Get`/`FindSet` and the next `Modify`/loop
      end, and inserts a matching `Rec.SetLoadFields(...)` call.
      Ref: <https://marketplace.visualstudio.com/items?itemName=BartPermentier.al-toolbox#action-generate-setloadfields>
      *Upstream option:* contribute to AlCops as a performance analyzer + fix.
      Non-trivial — needs real AL parsing (AST via the AL outline / language
      server, or `al` symbol data), not regex.

## 4. Bigger bets (unsized)

- [ ] Object ID helper / next-free-ID picker (compare: AL Object ID Ninja).
- [ ] "Run this test codeunit / test method" CodeLens.
- [ ] Quick navigation: jump to the matching `.Table.al` / `.Page.al` /
      `PermissionSet` for the current object.
- [ ] Translation helpers around `.xlf` (compare: NAB AL Tools) — only if not
      already well covered.

## 5. Housekeeping / infra

- [ ] Publish to **Open VSX** as well (VSCodium / Cursor / Windsurf). Add
      `ovsx publish` to `release.yml` + `OVSX_PAT` secret. See `DEVELOPMENT.md`.
- [ ] Marketplace listing polish: `galleryBanner`, screenshots/GIFs in README,
      `badges`, categories beyond `Other` once real features exist.
- [ ] Decide on telemetry: none, or opt-in via `@vscode/extension-telemetry`
      with a `PRIVACY.md` (mirror the BC Buddy approach).
- [ ] `CONTRIBUTING.md` + issue/PR templates.
- [ ] Expand the smoke test into real feature tests as features land.
