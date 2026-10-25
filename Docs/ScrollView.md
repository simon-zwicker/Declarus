# ScrollView

[Docs](README.md) · [Layout](Layout.md)

ScrollView takes one content view. Wrap multiple elements in a stack first.
Its default size is 240 by 180. That is the visible viewport, not the full content
size.

## A vertical list

```lua
local UI = Declarus.UI

local rows = {}

for index = 1, 20 do
    rows[#rows + 1] = UI.Text("Entry " .. index)
end

local content = UI.VStack(rows)
    :spacing(8)
    :padding(12)
    :width(UI.Size.Fill)
local view = UI.ScrollView(content)
    :size(320, 200)

UI.Mount(view, UIParent)
```

**Result:** A 320 by 200 viewport with a taller list inside it. Use the mouse wheel
over the viewport to move the content. Each reported wheel unit moves 30 UI units.
The offset is clamped between zero and content height minus viewport height.

Give content an intrinsic or explicit height. Vertical Fill is not a useful way
to express a taller scrolling list; scroll content is measured without a finite
vertical Fill target.

## Viewport padding and content padding

```lua
local UI = Declarus.UI

local view = UI.ScrollView(
    UI.View()
        :size(180, 400)
        :backgroundColor(UI.Color.RGB(90, 195, 240))
)
    :size(200, 120)
    :padding(10)
```

**Result:** Outer size is 200 by 120. Padding leaves a viewport of 180 by 100,
starting 10 units inside the outer frame. The 400-high content can scroll by at
most 300 units.

Padding on ScrollView reduces its viewport. Padding on the content stack belongs
to the scrolling content and moves with it. You can use both when that is what
the layout needs.

## Short content does not scroll

```lua
local UI = Declarus.UI

local view = UI.ScrollView(
    UI.View()
        :size(100, 40)
        :backgroundColor(UI.Color.RGB(90, 195, 240))
)
    :size(100, 100)
```

**Result:** The content is shorter than the viewport, so the offset stays at zero
even when you use the wheel.

## Updates and controls inside a viewport

Replacing a ScrollView through a mount update resets its scroll position. Keep
an independent preview in a separate mount if it needs to update without replacing
the scrolling page. The playground uses that approach.

There is no public Declarus scroll-offset getter/setter yet. Dropdown menus also
remain inside their native parent hierarchy and can be clipped at the viewport
edge. There is no popup portal to move them outside that hierarchy.

Nested ScrollViews are not a tested general solution for scroll chaining or input
routing. Visible scrollbars, horizontal scrolling, list virtualization and
scroll-to-item are not implemented. Each rendered item still creates frames.
