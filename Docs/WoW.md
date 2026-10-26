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
reuse their native frames on repeated hover and release them with the owner.
Leaving an old owner
does not close a tooltip that now belongs to another frame or addon.

Only one Declarus tooltip is open at a time. A child with its own tooltip takes
hover ownership when the pointer enters that child. The parent tooltip opens
again on the next mouse entry into the parent. Tooltips enable mouse input on the
owning view, so put the modifier on the smallest useful hover area.

Try all variants on the playground's **WoW** page. Mock tests cover lifecycle
and dispatch; visual placement and native data still need an in-game test on the
available official clients.

## A stack instead of an array

Use an explicit stack when you want control over spacing and alignment:

```lua
local UI = Declarus.UI

local view = UI.Text("Item preview")
    :tooltip(UI.VStack({
        UI.Text("A custom tooltip")
            :fontSize(20),

        UI.HStack({
            UI.View()
                :size(32, 32)
                :texture(134400),

            UI.Text("Icon and description"),
        })
            :spacing(12)
            :alignment(UI.Alignment.Center),
    })
        :spacing(8))
```

**Result:** A title appears above a row containing an icon and description.
The outer stack controls the row spacing. The HStack centers the text beside
the icon. This layout does not query an item; use infoTooltip for native data.

## Changing or removing a tooltip

```lua
local UI = Declarus.UI
local WoW = Declarus.WoW

local handle = UI.Mount(
    UI.Text("Hover me")
        :tooltip("Original explanation"),
    UIParent
)

handle:Update(
    UI.Text("Hover me")
        :infoTooltip(WoW.Item(6948))
)

handle:Update(
    UI.Text("Hover me")
        :tooltip("This explanation is cleared before mounting")
        :tooltip(nil)
)

handle:Unmount()
```

**Result:** The first update replaces text help with native item details. The
second update has no hover tooltip. Each update closes the old owner's tooltip;
unmount removes the final view. The calls run immediately here to show the API.
In an addon, trigger each update from the corresponding application event.

## When nothing appears

- Mount the view first. A description alone does not create a hover target.
- Give an empty View an explicit size. A zero-size view has no useful hover area.
- Check that the item or spell ID exists on the client you are testing.
- For units, start with player. Target and party tokens require an existing unit.
- Move into the hover area again after changing the target or updating the UI.
- Keep tooltip layouts passive. A Button or ScrollView inside one is rejected.

The [playground walkthrough](Playground.md#wow-tooltip-walkthrough) lists the
examples and expected results. Run it on each available official client.
