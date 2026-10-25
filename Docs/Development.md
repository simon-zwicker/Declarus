# Development

[Docs](README.md) · [Client compatibility](ClientCompatibility.md)

## Working rules

The rules are in [AGENTS.md](../AGENTS.md). Protect existing changes, stage only
your work and commit completed packages locally. Do not push, fetch, pull or run
other remote Git actions. Do not change PoisonFlow as part of the library work.

Keep Lua 5.1/LuaJIT compatibility, LuaLS annotations and the separation between
measurement, arrangement and rendering. We target current official Blizzard
clients, not private servers or historical original clients.

## Where things live

| Path | Responsibility |
| --- | --- |
| Core/Init.lua | Global Declarus namespace |
| Core/Client.lua | Client details and native compatibility boundary |
| Core/Localization.lua | Translation instances and resolution |
| UI/Types | Colors, sizes, edges and alignment constants |
| UI/Core | Shared View/TextView prototypes and modifiers |
| UI/Components | Public component constructors |
| UI/Layout | Stack implementation and factories |
| UI/Typography | Font resolution and intrinsic text measurement |
| UI/Engine | Measurement, arrangement and native rendering |
| UI/Mount.lua | Public mount lifecycle |
| Debug/Playground.lua | Optional in-game feature showcase |
| Types/WoW.lua | Editor-only native API declarations |
| Tests | Mocks, runner and behavior checks |
| Docs | Usage guides, reference and examples |

## The flow

```text
Application state
    -> your buildView function
    -> view description with properties and children
    -> Measure: sizes
    -> Arrange: positions
    -> Render: native frames and handlers
    -> mount handle
    -> Update or Unmount
```

Storing a new property is only the first part of a modifier. Add its type,
consume it in the relevant engine step and test the behavior it is supposed to
produce. Keep measured dimensions separate from native drawing concerns.

## The TOC is the load order

Declarus.toc is the production file list. Add new runtime files in the correct
place. Tests/Run.lua loads that same list rather than maintaining another copy.

Do not put Types/WoW.lua into the TOC. It contains editor declarations that would
overwrite native globals if executed. The playground registers its command on
load but does not open a window until requested.

## Run the tests

From the repository directory:

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
```

**Result:** The first command runs the full suite. The second runs it in separate
LuaJIT processes for six client metadata profiles. The current suite has 132 tests
per profile.

These profiles vary client identity, not the entire native implementation. They
are not six real client emulators. The mock also uses simplified font measurement,
so do not use its text widths as exact in-game measurements.

## Run LuaLS

```sh
"${LUA_LANGUAGE_SERVER:-lua-language-server}" --check=. --checklevel=Hint --logpath=/tmp/declarus-luals
```

**Result:** Diagnostics for the whole project, including hints. If the executable
is not on PATH, set LUA_LANGUAGE_SERVER to its location. An installed VS Code Lua
extension can contain it, but that extension path is version-dependent and should
not be hardcoded into the library.

Use .luarc.json as the shared configuration and check local VS Code settings
when the results differ. Keep standard libraries enabled. Add new native API
signatures to Types/WoW.lua as needed. Mock-only fields belong to mock types.
Fix the types rather than globally suppressing diagnostics.

## Stay compatible with Lua 5.1

Do not depend on newer syntax or standard functions without a supported approach.
Examples are goto, integer division using two slashes, or an unconditional call
to table.unpack. The existing code uses Lua 5.1's unpack. Client extensions need
verified availability and handling at the central boundary where appropriate.

## Check the Markdown too

Keep code examples outside tables. Table cells can contain short inline method
names, but avoid unescaped pipe characters in type descriptions. They are column
separators in GFM even when placed inside backticks.

Validate the rendered table structure, local links and executable examples after
changing the guides. Document the actual implementation, including its current
limits, rather than an API we plan to add later.

## What still needs the actual client

Fonts, languages, alpha, gradients, draw layers, checkbox input, Slider dragging,
Dropdown clipping, focus, UI scale and repeated open/close behavior need in-game
checks. The Classic feedback is useful but does not cover every current example.

Use the [client matrix](ClientCompatibility.md) to separate target metadata,
automated checks and actual in-game testing. Forever remains unconfirmed until
we can run that client.
