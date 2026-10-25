# State and lifecycle

[Docs](README.md) · [Controls](Controls.md) · [Recipes](Recipes.md)

## A description is not a live binding

A view stores its kind, properties and children. Mount measures that description,
arranges it and creates native frames. Changing the description later does not
automatically change those frames.

```lua
local UI = Declarus.UI
local view = UI.Text("Hello")
local handle = UI.Mount(view, UIParent)

view:fontSize(24)
-- The mounted text still uses its original size.
handle:Update(view)
-- The new tree now uses size 24.
```

**Result:** Only the explicit update changes what you see. For a UI with several
values, a buildView function that reads your state is usually easier to follow
than changing many properties individually.

## Keep the mount handle

| Member | Purpose |
| --- | --- |
| `handle.frame` | The currently rendered root frame |
| `handle:Update(view)` | Measure and replace this mount's tree |
| `handle:Unmount()` | Hide and clean up this mount |

Mount requires a view and a parent frame. Its internal host is centered in that
parent and sized to the measured root. The parent dimensions are not automatically
passed into root measurement as a Fill constraint.

The frame reference changes on Update. Do not keep an old root frame and expect
it to remain active. Native changes you make manually can also be lost when the
tree is replaced.

## A complete counter

```lua
local UI = Declarus.UI
local count = 0
local handle

local function buildView()
    return UI.VStack({
        UI.Text("Clicks: " .. count):fontSize(20),
        UI.Button("Increase", function()
            count = count + 1
            handle:Update(buildView())
        end):width(160),
    }):spacing(10):padding(14)
end

handle = UI.Mount(buildView(), UIParent)
```

**Result:** The text starts at zero and increases on each click. A callback can
replace the mount that contains its own button. The count survives because it is
stored in a Lua variable outside the rendered tree.

## Keep input and preview separate

Update replaces the whole subtree of that mount. A TextField inside it loses
focus, and a ScrollView loses its offset. Rebuilding the entire form on every
keypress is therefore usually the wrong place to update.

Use a separate mount for the part that needs to change:

```lua
local UI = Declarus.UI
local state = {name = "Default"}

local container = CreateFrame("Frame", nil, UIParent)
container:SetSize(400, 160)
container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local inputRegion = CreateFrame("Frame", nil, container)
inputRegion:SetSize(360, 40)
inputRegion:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -20)

local previewRegion = CreateFrame("Frame", nil, container)
previewRegion:SetSize(360, 40)
previewRegion:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -90)

local preview = UI.Mount(UI.Text("Profile: " .. state.name), previewRegion)
local input = UI.Mount(UI.TextField(state.name, function(value)
    state.name = value
    preview:Update(UI.Text("Profile: " .. value))
end):width(300), inputRegion)

local function closeEditor()
    input:Unmount()
    preview:Unmount()
    container:Hide()
    container:SetParent(nil)
end
```

**Result:** Typing updates the preview while the input mount stays intact and
keeps focus. The manually created regions only provide positions; Declarus draws
the visible content. Call closeEditor when your window closes.

This still creates new preview frames. Separate mounts control what is replaced;
they do not add frame reuse or make frequent updates free.

## Change the children

```lua
local UI = Declarus.UI
local entries = {"Alpha", "Beta"}
local handle

local function buildList()
    local children = {}
    for _, entry in ipairs(entries) do
        children[#children + 1] = UI.Text(entry)
    end
    children[#children + 1] = UI.Button("Add entry", function()
        entries[#entries + 1] = "Entry " .. (#entries + 1)
        handle:Update(buildList())
    end):width(220)
    return UI.VStack(children):spacing(8):padding(12)
end

handle = UI.Mount(buildList(), UIParent)
```

**Result:** Each click adds another row. The new list is measured and arranged
again. Keep arrays dense; use table.remove or rebuild the array when removing
items. There is no keyed diff, observable state or binding API yet.

## Close and reopen

Unmount hides the frames, removes library-installed scripts, unregisters their
frame events and detaches their parent links. Extra resources or scripts managed
outside Declarus remain your addon's responsibility.

Calling Unmount twice is allowed. Calling Update after Unmount is rejected.
Create a new mount when reopening. An old handle can still contain its retired
frame reference; that does not make the handle reusable.

WoW frames cannot be destroyed by this cleanup. There is no frame pool yet, and
repeated updates allocate additional native objects. Do not use this lifecycle as
a per-frame or combat ticker without first adding a suitable reuse strategy.

## Save your own application state

Declarus does not manage SavedVariables, profiles or persistent settings. State
in these examples lasts until the UI reloads. Validation, persistence and
application-specific side effects belong to the addon using the controls.
