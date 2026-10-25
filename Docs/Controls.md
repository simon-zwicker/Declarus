# Controls

[Docs](README.md) · [State and lifecycle](StateAndLifecycle.md)

Controls inherit the common view modifiers. They start with fixed sizes and a
dark background. Change those when the design needs more room or a different
style. Increasing the font size does not automatically increase the control size.

| Control | Default size | Callback value |
| --- | --- | --- |
| Button | 120 by 28 | Mouse button string |
| TextField | 180 by 28 | New text string |
| Slider | 180 by 20 | Rounded number |
| Toggle | 26 by 26 | Boolean |
| Dropdown | 180 by 28 | Selected option string |

Pass callbacks to the constructor. There are no public onClick/onChange modifier
methods or generic event modifiers yet. Callbacks receive the value described
below, not a native frame as their first argument.

## Button

```lua
local UI = Declarus.UI

local view = UI.Button("Save", function(mouseButton)
    if mouseButton == "RightButton" then
        print("Right click")
    else
        print("Left click")
    end
end)
    :size(180, 34)
    :padding(UI.Edge.Left, 10)
    :padding(UI.Edge.Top, 8)

UI.Mount(view, UIParent)
```

**Result:** A 180 by 34 button with an inset label. Left and right mouse releases
trigger the callback and print their respective messages.

The label must be a string and the callback must be a function. Text and Button
labels render in OVERLAY. The default texture or gradient layer is BORDER, so
normal button artwork stays behind the text.

Hover, pressed, disabled and focus styles are not exposed as Declarus modifiers
yet. A label can be localized with `localize(L)`.

## TextField

```lua
local UI = Declarus.UI

local profileName = "Default"

local field = UI.TextField(profileName, function(value)
    profileName = value
    print("Profile name:", profileName)
end)
    :width(280)
    :fontSize(18)

UI.Mount(field, UIParent)
```

**Result:** A single-line field starting with Default. User input updates the Lua
variable and prints the new text. Empty text is a valid value.

Autofocus is off. Enter and Escape both release focus. Escape does not restore
the previous value, and Enter is not a separate save event.

Only native text-change events marked as user input trigger onChange. Creating
the field or calling native SetText programmatically does not trigger this
Declarus callback. Fixed text insets are 4 left/right and 2 top/bottom.

There are no placeholder, password, numeric-input, maximum-length or validation
modifiers yet. Input stays a string; convert and validate it in your addon.

## Slider

```lua
local UI = Declarus.UI

local volume = 50

local slider = UI.Slider(
    volume,
    0,
    100,
    5,
    function(value)
        volume = value
        print("Volume:", volume)
    end
)
    :width(300)

UI.Mount(slider, UIParent)
```

**Result:** A horizontal slider from 0 to 100. Values round to steps of 5 relative
to the minimum. A reported value of 53 becomes 55 before the callback receives it.

The maximum must be greater than the minimum, the starting value must be inside
the range, and the step must be positive. Step defaults to 1.

The callback is the fifth argument. Use nil for the fourth argument if you want
the default step:

```lua
local UI = Declarus.UI

local slider = UI.Slider(
    5,
    0,
    10,
    nil,
    function(value)
        print(value)
    end
)
```

**Result:** A range of 0 to 10 in whole-number steps. A callback in the fourth
position is not an alternate signature.

Decimal steps work too:

```lua
local UI = Declarus.UI

local slider = UI.Slider(
    0.5,
    0,
    1,
    0.1,
    function(value)
        print(string.format("Opacity: %.1f", value))
    end
)
```

**Result:** Tenths from 0 to 1. Format the display value deliberately because Lua
uses floating-point numbers. Values are clamped to the range after rounding. If
the range is not evenly divisible by the step, that clamp can affect an endpoint.

A Slider does not create min/max labels or a number display. Add Text views if you
want those.

## Toggle

```lua
local UI = Declarus.UI

local enabled = true

local view = UI.HStack({
    UI.Toggle(enabled, function(value)
        enabled = value
        print("Enabled:", enabled)
    end),

    UI.Text("Enable feature"),
})
    :spacing(10)
    :alignment(UI.Alignment.Center)

UI.Mount(view, UIParent)
```

**Result:** A checked checkbox beside a text label. The callback receives true or
false. The text is a separate view and clicking it does not automatically toggle
the checkbox.

## Dropdown

```lua
local UI = Declarus.UI

local selected = "Default"

local dropdown = UI.Dropdown(
    {
        "Default",
        "Raid",
        "Solo"
    },
    selected,
    function(value)
        selected = value
        print("Profile:", selected)
    end
)
    :width(240)

UI.Mount(dropdown, UIParent)
```

**Result:** The trigger shows `Default v`. Clicking it opens the list. Selecting
Raid updates the label and value, then closes the list. Clicking the trigger again
also closes it.

Options must be a non-empty dense list of strings. The initial value must occur
in that list. The constructor copies the options. Labels and values are currently
the same string; there are no separate IDs, icons, groups, search fields, disabled
options or multiple selection.

Menu rows are currently 180 units wide and 28 high. Changing the trigger width
does not resize those rows. The menu opens below the trigger and can be clipped
inside a ScrollView. Scroll the trigger farther up or leave room below it.

Keyboard navigation, Escape handling and closing on an outside click are not
implemented.

## What onChange does and does not do

TextField, Slider, Toggle and Dropdown update their description's value before
calling onChange. Initial setup does not fire it. Repeating the same value does
not fire it again either.

That does not make other views reactive:

```lua
local UI = Declarus.UI

local value = "Before"

local label = UI.Text(value)

local field = UI.TextField(value, function(nextValue)
    value = nextValue
end)
local view = UI.VStack({
    label,
    field
})
    :spacing(8)
```

**Result:** Typing changes the variable, but the label description still says
Before. Update the label's mount explicitly when you want the display to change.
[State and lifecycle](StateAndLifecycle.md) shows how to do this without rebuilding
the input field on every keypress.
