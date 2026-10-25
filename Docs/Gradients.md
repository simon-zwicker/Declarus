# Gradients

[Docs](README.md) · [Textures](Textures.md) · [API reference](API.md)

Use gradient when a surface needs two colors or an image needs a fade. The modifier
is available on every view and control. It colors the element's own image, not its
text or children.

## A horizontal gradient

```lua
local UI = Declarus.UI

local view = UI.View()
    :size(320, 60)
    :gradient(
        "HORIZONTAL",
        UI.Color.RGB(30, 100, 200),
        UI.Color.RGB(100, 220, 160)
    )

UI.Mount(view, UIParent)
```

**Result:** Blue on the left, green on the right. Without an explicit texture,
Declarus creates a white surface for the gradient. Set a size; the gradient does
not give the view an intrinsic image size.

## Vertical means bottom to top

```lua
local UI = Declarus.UI

local view = UI.View()
    :size(120, 180)
    :gradient(
        "VERTICAL",
        UI.Color.RGB(240, 100, 50),
        UI.Color.RGB(70, 100, 220)
    )

UI.Mount(view, UIParent)
```

**Result:** Orange at the bottom and blue at the top. This follows WoW's native
gradient direction. Swap the two colors if you want the reverse.

| Orientation | First color | Second color |
| --- | --- | --- |
| HORIZONTAL | Left | Right |
| VERTICAL | Bottom | Top |

Only these two orientations are supported. There are no arbitrary angles or
radial gradients yet.

## Fade alpha too

```lua
local UI = Declarus.UI

local view = UI.View()
    :size(320, 50)
    :backgroundColor(UI.Color.RGB(20, 25, 35))
    :gradient(
        "HORIZONTAL",
        UI.Color.RGBA(90, 195, 240, 0),
        UI.Color.RGBA(90, 195, 240, 1)
    )

UI.Mount(view, UIParent)
```

**Result:** The gradient starts transparent on the left and becomes solid blue
on the right. The separate dark background remains visible through the transparent
part. This alpha only affects the gradient texture. View opacity affects the
whole frame afterward.

## Apply it to an icon

```lua
local UI = Declarus.UI

local icon = UI.View()
    :size(64, 64)
    :texture(134400)
    :texCoords(0.08, 0.92, 0.08, 0.92)
    :gradient(
        "VERTICAL",
        UI.Color.RGBA(255, 255, 255, 0),
        UI.Color.RGB(255, 255, 255)
    )

UI.Mount(icon, UIParent)
```

**Result:** The cropped icon fades from transparent at the bottom to visible at
the top. White preserves the image's RGB colors; the alpha difference creates
the fade. Colored endpoints multiply the image colors instead.

TexCoords pick the part of the image to show. Gradient colors the resulting
surface. Neither operation automatically preserves the image's aspect ratio.

## Use it on a button

```lua
local UI = Declarus.UI

local view = UI.Button("Save", function()
    print("Saved")
end)
    :size(220, 40)
    :padding(UI.Edge.Left, 12)
    :padding(UI.Edge.Top, 10)
    :gradient(
        "HORIZONTAL",
        UI.Color.RGB(25, 70, 120),
        UI.Color.RGB(35, 120, 80)
    )
    :foregroundColor(UI.Color.RGB(255, 255, 255))

UI.Mount(view, UIParent)
```

**Result:** A blue-to-green button with a white label. The gradient defaults to
BORDER, while the label uses OVERLAY. Native graphics such as a checkbox mark do
not inherit the gradient just because the control has the modifier.

## Combine gradient and tint

If textureTint is set, Declarus multiplies it into both gradient endpoints,
including alpha. The order of those modifiers does not change the result.

For example, endpoint alpha 0.4 combined with tint alpha 0.5 gives alpha 0.2.
View opacity applies afterward. The original color tables are not modified.
The background color and foreground text color remain independent.

## Remove the gradient

```lua
local UI = Declarus.UI

local view = UI.View()
    :size(160, 40)
    :texture(134400)
    :gradient(
        "HORIZONTAL",
        UI.Color.RGB(255, 0, 0),
        UI.Color.RGB(0, 0, 255)
    )
local handle = UI.Mount(view, UIParent)

view
    :gradient(nil)

handle:Update(view)
```

**Result:** The icon stays, but the gradient is removed after the update. A
configured texture tint also stays. If there was no explicit image, removing the
gradient removes the generated white surface. A separate background remains.

Calling `gradient()` also clears it. Do not pass colors when clearing. As with
other modifiers, changing a view description does not refresh an existing mount
until you update that mount.

## Validation and limits

Both colors must be normalized RGB/RGBA tables with finite channels from 0 to 1.
UI.Color.RGB and RGBA create that format. Missing alpha defaults to 1. The modifier
copies both colors. An invalid orientation, missing color or invalid channel is
rejected without replacing the existing gradient.

There are two endpoints. Multiple stops, radial gradients, animation and gradients
on text are not implemented.

The native call goes through Core/Client.lua and uses Texture:SetGradient with
CreateColor objects. We do not add old-client or private-server fallbacks. If the
required API is missing, the call reports a clear error rather than quietly
drawing a solid color.

In the playground, open Appearance (`Darstellung`). The gradient section shows
both directions, alpha, icon fades, buttons, tint multiplication and an interactive
example you can switch off or change direction. Visual results still need an
actual client test; Forever remains unconfirmed in game.

Native color objects follow [Blizzard's CreateColor / ColorMixin](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_SharedXMLBase/Color.lua).
