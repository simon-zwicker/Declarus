# Getting started

[Docs](README.md) · [API reference](API.md)

## Put Declarus in the client

Place the repository in the client's `Interface/AddOns/Declarus` directory. A
symlink to your checkout works too. `Declarus.toc`, `Core`, `UI` and `Debug` must
sit directly inside that directory.

A path such as `Declarus/Declarus/Declarus.toc` has one directory too many.

**Result:** Declarus appears in the client's addon list. Enable it and log in or
reload the UI. The library does not open a window by itself.

With a symlink, changes to the checkout are available on the next UI reload.
Already loaded Lua code is not replaced automatically. New runtime files still
need an entry in the TOC.

## Open the playground

```text
/declarus
/declarus info
/declarus hide
```

**Result:** The first command opens the demo, the second prints client details,
and the third closes it. See [Playground](Playground.md) for the full walkthrough.

## Use Declarus from another addon

Declare the dependency in your addon's TOC. This is an excerpt; add the interface
metadata appropriate for your target client:

```text
## Title: MyAddon
## Dependencies: Declarus
Main.lua
```

Then build your UI in `Main.lua`:

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.Text("My first Declarus UI")
        :fontSize(20)
        :foregroundColor(UI.Color.RGB(90, 195, 240)),

    UI.Text("These elements are stacked vertically."),

    UI.Button("Hello", function(mouseButton)
        print("Clicked with:", mouseButton)
    end)
        :width(180),
})
    :spacing(10)
    :padding(16)
    :backgroundColor(UI.Color.RGB(20, 26, 35))

local handle = UI.Mount(view, UIParent)
```

**Result:** A centered dark panel with a heading, a text line and a button. There
are 10 UI units between the children and 16 units of padding around them. The
widest child determines the content width. Clicking the button prints its mouse
button to chat.

Keep `handle` while this UI is open. You will use it for updates and cleanup.

## Replace the content

This continues the previous example:

```lua
handle:Update(
    UI.Text("The content has been replaced.")
        :fontSize(20)
        :padding(16)
        :backgroundColor(UI.Color.RGB(20, 26, 35))
)
```

**Result:** The stack is replaced by one text view. The mount stays centered in
the same parent and gets its new measured size. Focus and scroll positions inside
the replaced tree are not preserved.

## Close it

Continuing with the same handle:

```lua
handle:Unmount()
```

**Result:** The mounted UI is hidden and its library-managed handlers and parent
links are removed. Calling Unmount again is fine. Updating that handle afterward
is not. Create a new mount to open a new UI.

## Choose a different position

Declarus centers a mount inside its parent. Use a parent region to control where
that center is:

```lua
local UI = Declarus.UI

local region = CreateFrame("Frame", nil, UIParent)
region:SetSize(320, 100)
region:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -30)

local handle = UI.Mount(
    UI.Text("Centered inside my own region")
    :fontSize(16),
    region
)
```

**Result:** The text is centered inside a 320 by 100 region, placed 30 units from
the top and left edges of UIParent.

There is no public position or anchor modifier yet. Your addon owns manually
created parent regions and should hide or release them when it closes the UI.
