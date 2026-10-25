# Recipes

[Docs](README.md) · [Controls](Controls.md) · [State and lifecycle](StateAndLifecycle.md)

These examples are independent. They use the implemented public API and ordinary
WoW parent frames. State stays in Lua variables unless your addon saves it.

## Reusable cards

```lua
local UI = Declarus.UI

local function card(title, children)
    local content = {
        UI.Text(title):fontSize(20):foregroundColor(UI.Color.RGB(90, 195, 240)),
    }
    for _, child in ipairs(children) do
        content[#content + 1] = child
    end
    return UI.VStack(content):width(UI.Size.Fill):spacing(10):padding(14)
        :backgroundColor(UI.Color.RGB(25, 32, 43))
end

local view = UI.VStack({
    card("General", {UI.Text("A reusable card.")}),
    card("Appearance", {UI.Text("The same spacing and colors.")}),
}):width(400):spacing(12)

UI.Mount(view, UIParent)
```

**Result:** Two equally wide cards in a 400-unit column. There are 12 units
between cards, 14 units of padding inside each card and 10 between its children.
The helper is ordinary Lua. Each call builds new views rather than sharing the
same mutable description between cards.

## A form with an Apply button

```lua
local UI = Declarus.UI
local draft = {name = "Default", enabled = true, scale = 100, mode = "Solo"}
local saved = {name = "Default", enabled = true, scale = 100, mode = "Solo"}
local message = "No changes applied yet."
local handle

local function buildForm()
    return UI.VStack({
        UI.Text("Example settings"):fontSize(22),
        UI.Text("Name"),
        UI.TextField(draft.name, function(value) draft.name = value end):width(300),
        UI.HStack({
            UI.Toggle(draft.enabled, function(value) draft.enabled = value end),
            UI.Text("Enabled"),
        }):spacing(8):alignment(UI.Alignment.Center),
        UI.Text("Scale: 50 to 150, step 5"),
        UI.Slider(draft.scale, 50, 150, 5, function(value) draft.scale = value end):width(300),
        UI.Dropdown({"Solo", "Group", "Raid"}, draft.mode, function(value)
            draft.mode = value
        end),
        UI.View():height(90), -- Leave room for the open menu.
        UI.Button("Apply", function()
            saved.name = draft.name
            saved.enabled = draft.enabled
            saved.scale = draft.scale
            saved.mode = draft.mode
            message = saved.name .. " | " .. saved.mode .. " | " .. saved.scale
            handle:Update(buildForm())
        end):width(180),
        UI.Text(message):fontSize(14),
    }):spacing(10):padding(16):width(400)
        :backgroundColor(UI.Color.RGB(20, 26, 35))
end

handle = UI.Mount(buildForm(), UIParent)
```

**Result:** Editing only changes draft. The form is not rebuilt while typing or
dragging the slider. Apply copies the values to saved and rebuilds the form with
a summary. That explicit rebuild resets focus. Saved is just a local table here,
not a persistent SavedVariable.

For immediate feedback without replacing the form, use the separate-preview
pattern in [State and lifecycle](StateAndLifecycle.md).

## An icon, text and a button

```lua
local UI = Declarus.UI
local view = UI.HStack({
    UI.View():size(48, 48):texture(134400):texCoords(0.08, 0.92, 0.08, 0.92),
    UI.VStack({
        UI.Text("Choose a profile"):fontSize(18),
        UI.Text("An icon beside two text lines."):fontSize(13),
    }):spacing(4):width(UI.Size.Fill),
    UI.Button("Open", function() print("Open requested") end):width(100),
}):width(600):padding(12):spacing(12):alignment(UI.Alignment.Center)
    :backgroundColor(UI.Color.RGB(25, 32, 43))

UI.Mount(view, UIParent)
```

**Result:** A cropped icon on the left, two text lines in the remaining middle
space and a button on the right. The groups are vertically centered. The button
only calls its callback; a real profile screen is up to your addon.

## A gradient button

```lua
local UI = Declarus.UI
local view = UI.Button("Confirm", function() print("Confirmed") end)
    :size(220, 40):padding(UI.Edge.Left, 12):padding(UI.Edge.Top, 10)
    :gradient("HORIZONTAL",
        UI.Color.RGB(25, 70, 120),
        UI.Color.RGB(35, 120, 80))
    :foregroundColor(UI.Color.RGB(255, 255, 255))

UI.Mount(view, UIParent)
```

**Result:** A blue-to-green surface behind a white label. No layer override is
needed. The gradient changes the image region, not the text color.

## Leave optional rows out of the layout

```lua
local UI = Declarus.UI
local rows = {
    {name = "Alpha", visible = true},
    {name = "Beta", visible = false},
    {name = "Gamma", visible = true},
}
local children = {}
for _, row in ipairs(rows) do
    if row.visible then
        children[#children + 1] = UI.Text(row.name):padding(8)
    end
end

local view = UI.ScrollView(
    UI.VStack(children):spacing(4):width(UI.Size.Fill)
):size(320, 160)
UI.Mount(view, UIParent)
```

**Result:** Only Alpha and Gamma exist in the layout. Beta takes no space because
there is no view for it. That differs from hiding an existing view with
visible(false). When the data changes later, rebuild the list and update its mount.
