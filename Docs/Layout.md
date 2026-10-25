# Layout

[Docs](README.md) · [Views and modifiers](ViewsAndModifiers.md)

## Stacks arrange children

HStack puts children next to each other, left to right. VStack puts them below
each other, top to bottom. Pass a dense Lua array without nil gaps.

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.View()
        :size(100, 20)
        :backgroundColor(UI.Color.RGB(90, 195, 240)),

    UI.View()
        :size(60, 30)
        :backgroundColor(UI.Color.RGB(100, 210, 140)),
})
    :spacing(8)
    :padding(10)
```

**Result:** Outer size is 120 by 78. The first child starts at x=10, y=10. The
second starts at x=10, y=38. Width comes from the widest child plus padding.
Height is both child heights, one gap and the top/bottom padding.

For HStack, swap the axes: widths add up and the tallest child sets the content
height. Spacing is only added between children.

## Fixed size, Wrap and Fill

| Value | Meaning |
| --- | --- |
| A number | Fixed outer size |
| `UI.Size.Wrap` | Use the size needed by the content |
| `UI.Size.Fill` | Use the space offered on that axis |

Without a size modifier, elements generally use their content size. A plain View
has no image content to measure. A Text uses its font measurements, and a stack
uses its children.

### Split the remaining width

```lua
local UI = Declarus.UI

local view = UI.HStack({
    UI.View()
        :size(80, 30)
        :backgroundColor(UI.Color.RGB(80, 120, 180)),

    UI.View()
        :size(UI.Size.Fill, 30)
        :backgroundColor(UI.Color.RGB(90, 180, 120)),

    UI.View()
        :size(UI.Size.Fill, 30)
        :backgroundColor(UI.Color.RGB(190, 120, 80)),
})
    :width(400)
    :spacing(10)
    :padding(10)
```

**Result:** Outer size is 400 by 50. Padding leaves 380 units inside. Subtract the
fixed child at 80 and two gaps at 10 each: 280 remain. Each Fill child gets 140.

The same rule works vertically in a VStack with a known height. If fixed children
already use all the space, remaining Fill space is clamped to zero. Fixed children
are not automatically shrunk to fit.

### Fill needs a useful size constraint

Mount currently does not pass its parent frame's dimensions into measurement.
A Fill root under UIParent therefore does not automatically become screen-wide.
Give the root a fixed size and let its children fill that known area.

If the main-axis space is unknown, the engine uses the largest measured sibling
or intrinsic Fill-child size as its Fill basis. This is a fallback sizing rule,
not a percentage or weighted flex layout.

For stacks, an unset main-axis size can use space offered by the parent when
splitting Fill children. Explicit Wrap asks for intrinsic measurement instead.
These two cases are not interchangeable in every nested layout.

## Alignment works across the stack

| Stack | Children flow along | Alignment acts along | Valid alignment |
| --- | --- | --- | --- |
| HStack | Horizontal axis | Vertical axis | Top, Center, Bottom, Stretch |
| VStack | Vertical axis | Horizontal axis | Left, Center, Right, Stretch |

The defaults are Top for HStack and Left for VStack. A combination such as Left
on a HStack is rejected. Alignment does not distribute children along the main
axis. There is no space-between or flex-weight setting yet.

```lua
local UI = Declarus.UI

local view = UI.HStack({
    UI.View()
        :size(40, 20)
        :backgroundColor(UI.Color.RGB(90, 195, 240)),

    UI.View()
        :size(40, 50)
        :backgroundColor(UI.Color.RGB(100, 210, 140)),
})
    :height(70)
    :spacing(10)
    :alignment(UI.Alignment.Center)
```

**Result:** The first child gets 25 units above it, the second gets 10. Both are
vertically centered inside the height of 70. Total width is 90.

## Stretch respects fixed child sizes

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.Text("Short"),

    UI.Text("A longer line"),
})
    :width(300)
    :spacing(8)
    :alignment(UI.Alignment.Stretch)
```

**Result:** Both child frames stretch to at least the available width of 300.
The font itself is not stretched and letters are not spread across that width.

An explicit numeric width on a child wins over Stretch. A child that is already
intrinsically wider is not squeezed down either. Fill on the cross axis also
requests stretching.

A HStack without an explicit width is additionally stretched to the available
width when placed inside a VStack. Writing `width(UI.Size.Fill)` is often clearer
when that is the behavior you want.

## Nested rows

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.Text("Settings")
        :fontSize(20),

    UI.HStack({
        UI.Text("Profile")
            :width(100),

        UI.TextField("Default")
            :width(UI.Size.Fill),
    })
        :width(UI.Size.Fill)
        :spacing(12)
        :alignment(UI.Alignment.Center),
})
    :width(420)
    :padding(16)
    :spacing(12)
```

**Result:** The row sits below the heading. The root's inner width is 388. After
the label at 100 and the gap at 12, the TextField gets 276. The row's children are
vertically centered.

## Current limits

There are no min/max dimensions, percentages, flex weights, overlay stacks or
automatic collision handling yet. Outside a ScrollView, overflow is not generally
clipped. Giving text a fixed width does not enable wrapping or an ellipsis.
Choose sizes and content with those limits in mind.
