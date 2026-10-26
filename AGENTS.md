# Declarus project rules

- This local checkout is the source of truth. Check Git status before changing anything and protect existing work. Stage only your own files or changes explicitly.
- Never push, fetch, pull or run any other remote Git action.
- Support current official Blizzard clients only, including Forever. Do not add private-server or historical original-client support.
- Keep client differences in `Core/Client.lua`. Prefer shared APIs; client identity alone does not prove an API is available.
- Do not change PoisonFlow. Declarus provides general UI basics.
- Preserve Lua 5.1/LuaJIT compatibility and LuaLS annotations on public APIs.
- Keep the fluent API, Measure/Arrange/Render separation and TOC load order.
- Keep shared LuaLS settings in `.luarc.json`. Check local `.vscode/settings.json` too. Do not globally disable the standard libraries.
- Run LuaLS with `--checklevel=Hint` after Lua/type changes; see README for the command.
- Run `luajit Tests/Run.lua` for each completed package and commit it locally. Cover new behavior with meaningful tests.
- Mock tests do not replace an actual WoW test. Clearly mark features that have not been checked in game.

## Original basics roadmap

1. [x] Inspect checkout; initial baseline was 87 passing tests. Leave existing .DS_Store changes out of commits.
2. [x] Shared FontResolver, text padding, font modifiers and textures.
3. [x] Buttons/events, TextField, Slider, Toggle and Dropdown.
4. [x] ScrollView and explicit mount updates with cleanup.
5. [x] API examples and initial local regression pass: 103 tests, production TOC loaded through mocks.
6. [x] Locate and run LuaLS 3.19.2 from the VS Code extension; no diagnostics including hints.
7. [ ] Full in-game acceptance pass.

The order above records the implementation plan. Do not invent unverified
PoisonFlow-specific requirements.

## Client work

- [x] Shared TOC for current official target clients and central diagnostics.
- [x] Client default font shared by measurement and rendering.
- [x] Opt-in playground and matrix run using the production TOC order.
- [ ] Full Retail and available Classic in-game acceptance pass.
- [ ] Forever acceptance pass when the official client can be tested.
- Matrix, limits and sources: `Docs/ClientCompatibility.md`.

## Playground and docs

- [x] Seven playground pages cover the implemented UI API.
- [x] Separate preview/status mounts preserve page input focus and scroll during input changes.
- [x] Tests cover navigation, events, alignment, dynamic children, Unicode and cleanup.
- [x] Texture modifiers and gradients have examples and documentation.
- [ ] Full visual acceptance pass on the available official clients.

## WoW helpers

- [x] Declarus.WoW descriptors and shared tooltip modifiers for text, passive layouts, items, spells and units.
- [x] Owner lifecycle cleanup, cached layout tooltips, LuaLS and six-profile mock tests.
- [x] English guide and dedicated WoW playground page.
- [ ] In-game tooltip placement, native data loading and owner lifecycle acceptance.
