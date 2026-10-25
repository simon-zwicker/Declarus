# Views and modifiers

[Docs](README.md) · [Layout](Layout.md) · [Textures](Textures.md)

## A plain view

```lua
local UI = Declarus.UI

local view = UI.View()
    :size(160, 48)
    :backgroundColor(UI.Color.RGB(30, 100, 150))

UI.Mount(view, UIParent)
```

**Result:** A centered blue surface, 160 by 48 UI units.

A plain view has no image size or children to measure. Without size or padding,
it has no intrinsic area. `UI.View()` does not accept a public children argument.
Use HStack or VStack to group elements.

## Chaining changes the same object

```lua
local UI = Declarus.UI

local view = UI.View()
local sameView = view
    :width(100)
    :height(40)
assert(sameView == view)
```

**Result:** Both variables refer to the same description. Build a new view when
you need an independent element. Changing a description after mounting it does
not update its frames until you call `handle:Update(...)`.

## Size

Use `width` for one axis, `height` for the other, or `size` for both:

```lua
local UI = Declarus.UI

local view = UI.View()
    :width(100)
    :height(40)
local anotherView = UI.View()
    :size(100, 40)
```

**Result:** Both descriptions have the same outer size. Values can be numbers,
`UI.Size.Wrap` or `UI.Size.Fill`. See [Layout](Layout.md) for how space is assigned.

Numbers are UI units. Their physical pixel size depends on WoW's UI scale.
A fixed size includes padding. Adding padding to a fixed width of 100 leaves less
room inside; it does not make the outer width larger.

## Padding adds up

```lua
local UI = Declarus.UI

local view = UI.Text("Space around the text")
    :padding(8)
    :padding(UI.Edge.Left, 12)
    :backgroundColor(UI.Color.RGB(30, 45, 65))
```

**Result:** Padding is 20 on the left and 8 on the other three sides. The second
call adds to the first one. Calling `padding(8)` twice gives 16 on each side.

| Edge | Sides affected |
| --- | --- |
| `UI.Edge.All` | All four sides |
| `UI.Edge.Horizontal` | Left and right |
| `UI.Edge.Vertical` | Top and bottom |
| `UI.Edge.Left` | Left only |
| `UI.Edge.Right` | Right only |
| `UI.Edge.Top` | Top only |
| `UI.Edge.Bottom` | Bottom only |

`padding(8)` is the short form of `padding(UI.Edge.All, 8)`. There is no padding
reset method yet. Build a fresh view if you need a fresh starting point.

Padding affects layout and the custom Text/Button labels. Native controls also
have their own offsets: TextField uses fixed text insets of 4 left/right and 2
top/bottom. The Dropdown label starts 4 units from its left edge. Common padding
does not replace those native offsets.

## Background and text colors

```lua
local UI = Declarus.UI

local view = UI.Text("Bright text on a transparent background")
    :padding(10)
    :backgroundColor(UI.Color.RGBA(20, 50, 80, 0.6))
    :foregroundColor(UI.Color.RGB(240, 245, 250))
```

**Result:** The background is 60% opaque. The text stays fully opaque.

`RGB` takes channels from 0 to 255 and adds alpha 1. `RGBA` also takes alpha from
0 to 1. The factories return normalized color tables. They do not clamp invalid
input, so pass values in the expected ranges.

`backgroundColor` draws a BACKGROUND texture. `foregroundColor` currently colors
Text and the custom Button label. It does not set a text style for every child of
a stack, or recolor the native TextField and Dropdown labels.

Use [textureTint](Textures.md) to color an image and [gradient](Gradients.md) for
a transition between two colors. Neither changes the foreground text color.

## Opacity affects the whole frame

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.Text("This text becomes transparent too."),

    UI.View()
        :size(100, 20)
        :backgroundColor(UI.Color.RGB(0, 180, 100)),
})
    :spacing(8)
    :opacity(0.5)
```

**Result:** The stack and its children are half opaque. Child alpha values apply
on top of the parent's alpha. Use values from 0 to 1.

That is different from setting alpha on a background color or a texture tint,
which affects only that drawn region.

## Visibility keeps the layout space

```lua
local UI = Declarus.UI

local view = UI.HStack({
    UI.View()
        :size(40, 40)
        :backgroundColor(UI.Color.RGB(255, 0, 0)),

    UI.View()
        :size(40, 40)
        :backgroundColor(UI.Color.RGB(0, 255, 0))
        :visible(false),

    UI.View()
        :size(40, 40)
        :backgroundColor(UI.Color.RGB(0, 0, 255)),
})
    :spacing(10)
```

**Result:** Red and blue remain visible. The hidden green view still takes up 40
units in the middle. Total width stays 140.

To remove that gap, leave the child out when building the next tree. Setting
`opacity(0)` is also different from hiding: a transparent frame can still receive
mouse input.

## What carries over to children?

All components inherit the modifier methods. Their property values are not all
inherited by their children.

| Parent setting | Effect on children |
| --- | --- |
| Padding, spacing, alignment | Changes their arrangement |
| Opacity | Native parent alpha also affects their appearance |
| Hidden parent | Hides their appearance with the parent |
| Background, texture, gradient | Draws on the parent; does not copy styles into children |
| Foreground color | Does not become a shared child text color |

For repeated styling, use a Lua helper that builds and styles each element.
[Recipes](Recipes.md) shows a simple card helper.
