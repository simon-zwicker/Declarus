# Client compatibility

[Docs](README.md) · [API reference](API.md) · [Playground](Playground.md)

We target current official Blizzard clients only. No private servers and no
historical original clients. Different rulesets on the same Classic client do
not need separate UI renderers just because the game rules differ.

## One codebase

All targets use the same Declarus.toc and Lua files. The current basic components
use native frames, textures, FontStrings, EditBoxes, Sliders, CheckButtons and
ScrollFrames without depending on client-specific control templates or settings
frameworks.

Client differences belong in Core/Client.lua. GetInfo reports the client identity;
it is not used to assume an API exists. Forever is recognized by its interface
family independently of the project ID reported by a particular beta. Unknown
families report Unknown instead of being silently called Retail.

The default font comes from STANDARD_TEXT_FONT so client languages get the
appropriate font. An explicit font wins. Native gradient colors are also passed
through this central boundary.

## Targets and test status

This is the TOC snapshot used by the project as of October 25, 2026. Interface
numbers change with patches. A TOC entry makes a build eligible to load; it does
not prove that our UI has passed an in-game test there.

| Target | TOC interface | Automated check | Full in-game pass |
| --- | --- | --- | --- |
| Retail | 120105, 120100 | Shared suite and metadata profile | Pending |
| Forever | 16001 | Shared suite and metadata profile | Pending; not currently available for testing |
| Classic Era and its rulesets | 11509 | Shared suite and metadata profile | Pending |
| Burning Crusade Classic | 20506 | Shared suite and metadata profile | Pending |
| Mists Classic | 50504 | Shared suite and metadata profile | Pending |
| Titan Reforged, official regional client | 38002 | Shared suite and metadata profile | Pending |

The playground has been reported working on Classic. We have not recorded a
complete pass of every later example with a specific build, locale and UI scale.
That is why the full-pass column is still pending.

Old Wrath/Cataclysm Classic builds are not added just in case. When another
official client becomes a target, check its actual interface and API first.

## What the matrix checks

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
```

Each profile runs the full suite in a separate LuaJIT process. Tests use the real
TOC load order, then check identity, fonts, layout, controls and lifecycle. Loading
the library creates its internal measurement frame but does not mount the demo.

The profiles use the same native API mocks. They are not six client emulators.
Passing Retail or Classic checks does not replace a Forever test. The same applies
to new features such as gradients.

## In-game walkthrough

1. Put the same Declarus directory in the chosen client's addon directory.
2. Enable it and log in. No demo should open automatically.
3. Run `/declarus info` and record client, build, interface and locale.
4. Open `/declarus` and visit all seven pages described in [Playground](Playground.md).
5. Check fonts, padding, textures, draw order, alpha and both gradient directions.
6. Try TextField, both Sliders, Toggle, Dropdown and left/right mouse clicks.
7. Check that the fixed preview updates without losing input focus or page scroll.
8. Toggle the preview gradient, change direction and check both scroll limits.
9. Add/remove dynamic children, reset, close and reopen several times.

For a failure, keep the full Lua error and the action that triggered it. Record a
full pass only after completing the steps on that client. The demo uses its own
UI/settings values; it does not implement protected action buttons or combat-data
processing.

## Sources behind the target setup

- [BigWigs TOC](https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/BigWigs.toc)
  demonstrates shared multi-interface packaging and the relevant interface values.
- [KeyUI TOC](https://raw.githubusercontent.com/1onar/KeyUI/main/KeyUI.toc) is another
  maintained addon using shared Retail/Classic packaging.
- [Blizzard's Forever announcement](https://worldofwarcraft.blizzard.com/en-gb/news/24302093)
  identifies the additional official client.
- [Blizzard China's Titan Reforged page](https://wow.blizzard.cn/trrnews/) identifies
  the official regional branch.
- Local Blizzard installation metadata identified Forever 1.60.1 build 70338.
  The original Declarus TOC already used interface 16001. Neither observation is
  an in-game execution test.
