# Troubleshooting

[Docs](README.md) · [Development](Development.md)

## Declarus is missing from the addon list

Check the client directory and the path
`Interface/AddOns/Declarus/Declarus.toc`. A symlink must resolve to an existing
checkout. Check for an extra nested directory or a different folder name.
A newly added addon may need a client restart before it appears.

The TOC interface metadata must cover the current client. Update it when Blizzard
changes the target build, but do not treat a metadata change as an API test.

## Declarus or Declarus.UI is nil

The library has not loaded yet, or files were loaded out of order. Declare the
Declarus dependency in the consuming addon and run your code afterward. Do not
load library files in an arbitrary order.

For local tests, use the mocks and production TOC as Tests/Run.lua does.

## A view is invisible

A plain View starts empty. Give it a size and a background or texture. If using
Fill, check whether that axis has a known size to fill. A Fill root under UIParent
does not automatically receive the screen dimensions.

```lua
local UI = Declarus.UI
local view = UI.View():size(100, 40):backgroundColor(UI.Color.RGB(255, 0, 0))
UI.Mount(view, UIParent)
```

**Result:** A simple red reference surface. If this appears, add the other
settings one at a time. Also check visibility, opacity, color alpha and the image
source.

## Padding looks wrong

Padding calls add up. Fixed sizes are outer sizes: 100 wide with 10 padding on
each side leaves 80 inside. Native controls also have their own text offsets;
common padding does not replace every native inset.

## A hidden child leaves a gap

That is what visible(false) does. The child still participates in measurement.
Leave it out of the next tree to remove its space. See [Recipes](Recipes.md).

## Stretch does not change the child

A fixed numeric cross-axis size wins. Stretch also does not squeeze an already
larger child. Use intrinsic child sizes and a known cross-axis size on the stack
when testing it. Alignment does not distribute the main-axis space.

## Text extends outside its view or button

Width does not currently enable text wrapping or an ellipsis. Increasing a font
does not enlarge a Button's fixed dimensions. Give it more room or use shorter
text. Check that custom fonts exist in the client and support the language.
An invalid explicit font path is not automatically replaced by the default font.

## The tint does not look like the selected color

Tint multiplies the existing image colors. Black stays black. A white texture is
useful when you want the selected color directly. Use white tint to preserve the
original image. Foreground color is not an image tint.

TexCoords must be between 0 and 1. Reversing two edges mirrors the image.

## A texture covers the label

The default texture layer is BORDER and custom labels use OVERLAY. An explicit
high layer or sublevel can change that order. Try textureLayer with BORDER and
sublevel 0 to isolate the issue.

Draw layers within a frame are different from FrameStrata between frames.

## A vertical gradient seems reversed

VERTICAL starts at the bottom and ends at the top. Swap the endpoint colors for
the opposite direction. An image with dark pixels also stays dark under a color
filter; test the gradient on a plain view first.

If the gradient is transparent, a separate background may still be visible behind
it. Use [Gradients](Gradients.md) to check which region each alpha value affects.

## Input changes a variable but not a label

Lua variables are not reactive bindings. Update the mount that owns the label.
If that mount also contains the input, consider splitting the preview into its
own mount to avoid rebuilding the control.

## The TextField loses focus on every keypress

The callback is probably replacing the whole form. Update only a separate preview
mount instead. The playground already uses this pattern. There is no automatic
focus restoration yet.

## The Slider callback is in the wrong slot

The signature is value, minimum, maximum, step, callback. Pass nil as the fourth
argument to use the default step. The callback receives rounded values, so small
movements within the same step do not each trigger a new change.

## The Dropdown menu is clipped

The menu stays in the control's native parent hierarchy. A ScrollView can clip it.
Scroll the trigger upward or leave space below it. Changing trigger width does not
change the current fixed menu width of 180.

Close it by selecting an option or clicking the trigger again. Outside-click and
keyboard handling are not implemented yet.

## ScrollView does not scroll

If content is no taller than the inner viewport, the maximum offset is zero.
Give content an intrinsic or explicit height rather than vertical Fill. Use the
wheel over the viewport. Horizontal scrolling and a visible scrollbar are not
implemented.

## Update fails after closing

An unmounted handle cannot be updated. Track the open/closed state in your addon
and create a new mount when reopening. Cancel or guard external timers and
callbacks that could still try to use the old handle.

## VS Code reports hundreds of unknown globals

Compare .luarc.json with the local .vscode/settings.json. Do not disable the Lua
basic, math, string and table libraries here. Tests also need io and os.
Do not point the workspace at an extension library that is not installed.

Types/WoW.lua supplies the API subset used by Declarus. LuaLS reads it; the TOC
must not execute it. See [Development](Development.md) for the check command.
A CLI run with different settings can disagree with the editor, so check both.

## Report a client issue

Include the output of `/declarus info`, the full Lua error, the playground page
and the action that caused it. Say whether it happened on load, on open or after
an update. Passing mocks does not replace that client observation, and a working
Classic test does not prove the same behavior on Forever.
