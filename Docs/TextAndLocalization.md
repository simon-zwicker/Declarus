# Text and localization

[Docs](README.md) · [Controls](Controls.md)

## Display text

```lua
local UI = Declarus.UI
local view = UI.Text("Hello Azeroth")
    :fontSize(20)
    :padding(8)
    :foregroundColor(UI.Color.RGB(240, 220, 120))
    :backgroundColor(UI.Color.RGB(25, 30, 40))

UI.Mount(view, UIParent)
```

**Result:** Yellow text on a dark background with 8 units of padding. Without a
fixed size, the outer dimensions are the measured text size plus padding.

Text takes a string. An empty string is fine; passing a number is not. Exact text
dimensions depend on the font and client language. Measurement and rendering use
the same font configuration.

## Choose a font and size

```lua
local UI = Declarus.UI
local view = UI.VStack({
    UI.Text("Client font at 16"),
    UI.Text("Larger text"):fontSize(24),
    UI.Text("Outlined text")
        :font(Declarus.Client.GetDefaultFont(), "OUTLINE")
        :fontSize(18),
}):spacing(12)
```

**Result:** Three lines using the client font, a larger size and an outlined
variant. Default size is 16 and default flags are empty.

The default font comes from the client's `STANDARD_TEXT_FONT`. This also respects
client fonts for non-Latin languages. If that global is missing, the resolver uses
`Fonts\FRIZQT__.TTF`.

`font(path, flags)` sets the file and optional native WoW font flags. Calling it
without flags clears previously selected flags. `fontSize(size)` needs a positive
number. Changing the font size does not automatically enlarge a Button's fixed
standard dimensions.

## Use a font shipped with your addon

```lua
local UI = Declarus.UI
local view = UI.Text("My addon font")
    :font("Interface\\AddOns\\MyAddon\\Media\\MyFont.ttf")
    :fontSize(18)
```

**Result:** This description uses your font file, provided that file actually
exists in the target client. The example file is not included with Declarus.
An invalid explicit font path is not automatically repaired by the default-font
fallback.

## Width is not wrapping

```lua
local UI = Declarus.UI
local view = UI.Text("This line can be wider than its view."):width(100)
```

**Result:** The view frame is 100 units wide. The FontString does not get an
automatic wrapping or truncation width, so the line can extend beyond it.

Wrapping, ellipses, text alignment and line-spacing modifiers are not implemented
yet. Use shorter lines, more room or deliberately separate text views.

## Register translations

```lua
local UI = Declarus.UI
local L = Declarus.Localization.Create("MyAddon.Options")

L:Register("enUS", {
    TITLE = "Settings",
    SAVE = "Save",
    ENGLISH_ONLY = "This line is the English fallback.",
})
L:Register("deDE", {
    TITLE = "Einstellungen",
    SAVE = "Speichern",
})

local view = UI.VStack({
    UI.Text("TITLE"):localize(L):fontSize(22),
    UI.Text("ENGLISH_ONLY"):localize(L),
    UI.Text("MISSING_KEY"):localize(L),
    UI.Button("SAVE", function() print("Save requested") end):localize(L),
}):spacing(10)

UI.Mount(view, UIParent)
```

**Result:** On a German client, the heading is `Einstellungen` and the button says
`Speichern`. The second line stays English because no German translation exists.
The third line stays `MISSING_KEY` because neither language defines it.

The German strings here are translation data, included to show the fallback
behavior. On an English client, the heading and button use Settings and Save.
Other unregistered languages also fall back to enUS.

Resolution order is:

1. The current client locale from GetLocale.
2. The enUS entry.
3. The original key.

The same resolution runs during measurement and rendering, so a translated title
is measured using the text that will actually appear.

## Namespaces and repeated registration

`Create(namespace)` returns the same instance when called with the same name.
Different names keep separate translation tables. `Register` merges into the
chosen locale and overwrites matching keys; it does not clear the other keys.
Use non-empty strings for namespace and locale names, and string translation
values.

```lua
local L = Declarus.Localization.Create("MyAddon.Example")
L:Register("enUS", {TITLE = "Settings"})
print(L:Get("TITLE"))
print(Declarus.Localization.GetActiveLocale())
```

**Result:** Chat receives the resolved title and the active locale. Registering a
new translation does not refresh an already mounted UI. Update that mount if you
want it to use the changed translations.

## Which content gets localized?

Text and the custom Button label resolve translation keys. TextField values and
Dropdown options are used as supplied. Resolve those yourself with `L:Get(...)`
if you want translated strings there.

Controls inherit the TextView methods, but that does not mean every control value
is localized or every control has a label. Font modifiers are visible on Text,
Button, TextField and Dropdown. Slider and Toggle do not create additional text
labels.
