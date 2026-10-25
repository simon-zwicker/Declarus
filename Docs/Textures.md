# Textures

[Docs](README.md) · [Gradients](Gradients.md) · [API reference](API.md)

Every view and control can have its own texture. There is no separate Image
constructor yet; use a normal view with a size and texture.

```lua
local UI = Declarus.UI

local icon = UI.View()
    :size(48, 48)
    :texture(134400)
    :texCoords(0.08, 0.92, 0.08, 0.92)
    :textureTint(UI.Color.RGBA(90, 195, 240, 0.8))

UI.Mount(icon, UIParent)
```

**Result:** A 48 by 48 question-mark icon with its edge cropped, a blue tint and
80% texture alpha.

## Source and size

Texture accepts a file path or a numeric WoW FileDataID:

```lua
local UI = Declarus.UI

local fromPath = UI.View()
    :size(48, 48)
    :texture("Interface\\Icons\\INV_Misc_QuestionMark")
local fromID = UI.View()
    :size(48, 48)
    :texture(134400)
```

**Result:** Both descriptions refer to the question-mark image. A numeric ID is a
file identifier, not a color or a coordinate.

The texture stretches across the whole view, including padding. It does not
supply an intrinsic size. Set a size or let the layout assign one.

Changing the source preserves that view's configured coordinates, tint, gradient
and layer. Those modifiers can be set before or after the source.

## Crop or mirror with TexCoords

The argument order is left, right, top, bottom. Values are normalized from 0 to 1.

```lua
local UI = Declarus.UI

local cropped = UI.View()
    :size(64, 64)
    :texture(134400)
    :texCoords(0.08, 0.92, 0.08, 0.92)
local mirrored = UI.View()
    :size(64, 64)
    :texture(134400)
    :texCoords(1, 0, 0, 1)
```

**Result:** The first icon loses its outer edge. The second is mirrored
horizontally. Reversing top and bottom mirrors vertically.

Use `(0, 1, 0, 1)` for the whole image. The selected part still stretches to the
view's dimensions. There is no automatic proportional crop, cover/contain mode
or eight-coordinate API yet.

## Tint only the image

```lua
local UI = Declarus.UI

local view = UI.View()
    :size(120, 40)
    :texture("Interface\\Buttons\\WHITE8X8")
    :textureTint(UI.Color.RGB(90, 220, 140))
```

**Result:** A green surface. Tint multiplies the image channels: white parts take
the selected color, while black stays black. Tinting an already colored icon can
produce a different result from tinting a white symbol.

Use RGB or RGBA from UI.Color. The modifier expects normalized color tables and
copies them when set. Missing alpha defaults to 1. White tint restores the image's
original colors. Tint alpha affects only the image; view opacity applies on top.
Text color and background color stay independent.

## Keep the label in front

The default order inside a frame is:

1. Background color in BACKGROUND.
2. The view's texture or gradient in BORDER at sublevel 0.
3. Text and custom Button labels in OVERLAY.

A normal textured button therefore needs no layer override:

```lua
local UI = Declarus.UI

local view = UI.Button("Save", function()
    print("Saved")
end)
    :texture("Interface\\Buttons\\WHITE8X8")
    :textureTint(UI.Color.RGB(30, 85, 120))
```

**Result:** A blue button surface behind its readable label.

Use `textureLayer(layer, sublevel)` when you deliberately need a different draw
order. Layers are BACKGROUND, BORDER, ARTWORK, OVERLAY and HIGHLIGHT. Sublevel is
an integer from -8 to 7 and defaults to 0. Higher sublevels draw later inside the
same layer.

An explicit high layer can cover text or native control graphics. HIGHLIGHT also
follows WoW's highlight behavior for the frame type. Layers order regions inside
a frame; they do not control arbitrary other frames or their FrameStrata.

## Add a gradient

[Gradients](Gradients.md) can color or fade the same texture between two endpoints.
When tint and gradient are both present, Declarus multiplies the tint into both
endpoint colors. Neither setter silently erases the other.

The Appearance page in `/declarus` shows sources, cropping, mirroring, tint,
layers, gradients and textured buttons. The rendering tests check the configured
API calls. The final appearance still needs checking in the actual client.

Native APIs used here:
[SetTexCoord](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua)
and [SetVertexColor / SetDrawLayer](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleRegionAPIDocumentation.lua).
