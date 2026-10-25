# Declarus

A declarative UI library for current official World of Warcraft clients.
Build your UI with Lua objects, then mount it into a WoW frame.

The library stays compatible with Lua 5.1 and LuaJIT. It includes LuaLS annotations
and has no external runtime dependencies. We target official Blizzard clients.
We do not build for private servers or old original clients.

## Start here

The full documentation starts at [Docs/README.md](Docs/README.md).

| Guide | What it covers |
| --- | --- |
| [Getting started](Docs/GettingStarted.md) | Installation, first UI, updates and cleanup |
| [Views and modifiers](Docs/ViewsAndModifiers.md) | Size, padding, colors, opacity and visibility |
| [Layout](Docs/Layout.md) | Stacks, spacing, Wrap, Fill and alignment |
| [Text and localization](Docs/TextAndLocalization.md) | Fonts, translation keys and fallbacks |
| [Controls](Docs/Controls.md) | Buttons, text fields, sliders, toggles and dropdowns |
| [Textures](Docs/Textures.md) | Image sources, cropping, tint and layers |
| [Gradients](Docs/Gradients.md) | Horizontal and vertical gradients, including alpha |
| [ScrollView](Docs/ScrollView.md) | Viewports, content size and scrolling |
| [State and lifecycle](Docs/StateAndLifecycle.md) | Mount, Update, Unmount and separate UI regions |
| [Recipes](Docs/Recipes.md) | Complete examples you can build on |
| [API reference](Docs/API.md) | Public functions, modifiers and defaults |
| [Troubleshooting](Docs/Troubleshooting.md) | What to check when something behaves differently |
| [Development](Docs/Development.md) | Load order, architecture, tests and LuaLS |
| [Playground](Docs/Playground.md) | Try every implemented feature in the client |
| [Client compatibility](Docs/ClientCompatibility.md) | Target clients and what has actually been tested |

## First example

Run this inside a WoW addon after Declarus has loaded:

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.Text("Hello Declarus")
        :fontSize(22),

    UI.Text("Text, layout and a button in one description."),

    UI.Button("Try it", function(mouseButton)
        print("Clicked:", mouseButton)
    end)
        :width(180),
})
    :spacing(10)
    :padding(16)
    :backgroundColor(UI.Color.RGB(20, 26, 35))

local handle = UI.Mount(view, UIParent)
```

**Result:** A centered panel with two text lines and a button. Clicking the button
prints the mouse button to chat. Keep the handle if you want to update or close
this UI later.

## Try the playground

Use `/declarus` to open it. The six pages cover layout, typography, appearance,
controls and updates. Gradients are on the Appearance page, labelled `Darstellung`
in the current playground UI.

`/declarus info` prints client details. `/declarus reset` resets the demo values.
`/declarus hide` closes the playground. Nothing opens automatically when the addon
loads.

## Current limits

Updates replace the whole subtree of a mount. Focus and scroll position inside
that subtree are reset. Frames are not pooled yet, so this is intended for
occasional UI changes rather than per-frame updates.

Text wrapping, automatic proportional image cropping, horizontal scrolling,
visible scrollbars, dropdown keyboard navigation and protected action buttons
are not implemented. Each guide explains the relevant limits where you use them.

The playground has been reported working on Classic. That is useful feedback,
but it is not a complete test of every feature on every client. Forever still
needs an actual in-game test.

## Checks

Run these from the repository directory:

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
"${LUA_LANGUAGE_SERVER:-lua-language-server}" --check=. --checklevel=Hint --logpath=/tmp/declarus-luals
```

The current suite has 132 tests per client metadata profile. The matrix runs six
profiles using the same API mocks. It does not emulate six actual clients.
LuaLS 3.19.2 passes without diagnostics, including hints.

Project rules are in [AGENTS.md](AGENTS.md). Keep commits local. Do not change
PoisonFlow as part of this library work.
