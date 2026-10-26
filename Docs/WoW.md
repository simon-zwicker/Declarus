# WoW helpers and tooltips

`Declarus.WoW` holds helpers that use Blizzard's game UI. Start with tooltips:
put either modifier on any Declarus view, including text, icons and stacks.
The tooltip opens when the mouse enters and closes when it leaves.

## A short explanation

```lua
local UI = Declarus.UI

local view = UI.Text("Hover here")
    :tooltip("This setting changes the size of your display.")

local handle = UI.Mount(view, UIParent)
```

**Result:** Hovering the text opens a white, wrapped text tooltip using Blizzard's
GameTooltip. It anchors to the right of the hovered view.

## Your own layout

Pass a Text, View, HStack or VStack when you need formatting. An array of views
becomes a VStack with 4 pixels of spacing. The surrounding tooltip adds 10 pixels
of padding and a dark background. It stays inside the screen.

```lua
local UI = Declarus.UI
local Color = UI.Color

local view = UI.View()
    :size(40, 40)
    :texture(134400)
    :tooltip({
        UI.Text("Display size")
            :fontSize(18)
            :foregroundColor(Color.RGB(100, 220, 160)),

        UI.HStack({
            UI.Text("Current value"),

            UI.Text("40 px")
                :foregroundColor(Color.RGB(240, 190, 80)),
        })
            :spacing(20),
    })
```

**Result:** The icon opens a two-row tooltip. The second row has two columns.
You can pass that same layout directly as `:tooltip(UI.VStack({ ... }))`.
These are passive layouts: controls, ScrollViews and nested tooltips are rejected.
Use intrinsic or explicit sizes; a tooltip has no external Fill size to inherit.
Text does not gain automatic wrapping from a Declarus layout.

## Blizzard's item, spell and unit tooltips

```lua
local UI = Declarus.UI
local WoW = Declarus.WoW

local view = UI.HStack({
    UI.Button("Hearthstone", function() end)
        :infoTooltip(WoW.Item(6948)),

    UI.Button("Attack", function() end)
        :infoTooltip(WoW.Spell(6603)),

    UI.Button("Player", function() end)
        :infoTooltip(WoW.Unit("player")),
})
    :spacing(12)
```

**Result:** Each button opens Blizzard's own tooltip. Declarus does not rebuild
item stats, spell descriptions or unit details. Native item loading and tooltip
refresh belong to the client. An unknown ID may show nothing until data exists.
IDs must exist on the current client; Declarus does not translate IDs between
Retail and Classic.

A unit uses a token such as `"player"`, `"target"` or `"party1"`, not a creature ID
or a GUID. It is resolved on hover. A missing unit shows no tooltip. Changing the
target while already hovering follows the native tooltip's behavior; Declarus
does not add a polling loop.

## Replacing and closing

The last tooltip modifier wins. `:tooltip(nil)` or `:infoTooltip(nil)` removes the
configuration. As with other modifiers, update the mount to apply a change.
Updating, unmounting or hiding the owner closes its tooltip. Formatted layouts
reuse their native frames on repeated hover and release them with the owner. Leaving an old owner
does not close a tooltip that now belongs to another frame or addon.

Only one Declarus tooltip is open at a time. A child with its own tooltip takes
hover ownership when the pointer enters that child. The parent tooltip opens
again on the next mouse entry into the parent. Tooltips enable mouse input on the
owning view, so put the modifier on the smallest useful hover area.

Try all variants on the playground's Controls page. Mock tests cover lifecycle
and dispatch; visual placement and native data still need an in-game test on the
available official clients.
