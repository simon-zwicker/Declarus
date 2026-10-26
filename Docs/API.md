# API reference

[Docs](README.md)

Use a dot for factories and namespace functions, and a colon for view methods.
A question mark in the signatures below marks an optional argument. Modifier
methods change the same view object and return it for chaining.

## Namespaces

| Namespace | Purpose |
| --- | --- |
| `Declarus.UI` | Components, constants, colors and mounting |
| `Declarus.Localization` | Translation instances and locale lookup |
| `Declarus.Client` | Client details and the default font |

## Constructors

```text
UI.View()
UI.Text(value)
UI.HStack(children)
UI.VStack(children)
UI.Button(label, onClick)
UI.TextField(value, onChange?)
UI.Slider(value, minimum, maximum, step?, onChange?)
UI.Toggle(value, onChange?)
UI.Dropdown(options, value, onChange?)
UI.ScrollView(content)
```

| Constructor | Input | Result and defaults |
| --- | --- | --- |
| View | No arguments | Plain view with no intrinsic image size |
| Text | String | Text view measured using its font |
| HStack | Dense list of views | Children arranged horizontally |
| VStack | Dense list of views | Children arranged vertically |
| Button | String label and callback | 120 by 28; callback receives the mouse button |
| TextField | String and optional callback | 180 by 28; callback receives new text |
| Slider | Numbers for value/range, optional step/callback | 180 by 20; horizontal; step defaults to 1 |
| Toggle | Boolean and optional callback | 26 by 26; callback receives a boolean |
| Dropdown | Dense string list, selected string, optional callback | 180 by 28; callback receives the selected string |
| ScrollView | One content view | Viewport defaults to 240 by 180 |

The Slider callback is always argument five. Use nil for argument four to keep
the default step. See [Controls](Controls.md) for validation and behavior.

There is no UI.Image constructor; use a View with a texture. The input control is
spelled `UI.TextField`, with a capital F. There is no Textarea constructor yet.

## Common view modifiers

These methods are available on every component:

| Method | Arguments | Effect |
| --- | --- | --- |
| `:width(value)` | Number or UI.Size constant | Set outer width |
| `:height(value)` | Number or UI.Size constant | Set outer height |
| `:size(width, height)` | Two numbers or UI.Size constants | Set both dimensions |
| `:padding(value)` | Number | Add padding on all sides |
| `:padding(edge, value)` | UI.Edge constant and number | Add padding on selected sides |
| `:backgroundColor(color)` | Normalized color table | Draw a BACKGROUND surface |
| `:foregroundColor(color)` | Normalized color table | Color Text and custom Button labels |
| `:opacity(value)` | Number, normally 0 to 1 | Set native frame alpha |
| `:visible(value)` | Boolean | Show or hide without changing layout space |
| `:texture(source)` | File path or numeric FileDataID | Stretch an image over the element |
| `:texCoords(left, right, top, bottom)` | Four numbers from 0 to 1 | Crop or mirror the image |
| `:textureTint(color)` | Normalized RGB/RGBA table | Multiply the image colors |
| `:textureLayer(layer, sublevel?)` | Layer string and optional integer | Default BORDER/0; sublevel range -8 to 7 |
| `:gradient(orientation, fromColor, toColor)` | Orientation string and two color tables | Color or fade the image between two endpoints |
| `:gradient(nil)` | Nil, with no colors | Remove the gradient |

Calling gradient without arguments also removes it. Horizontal runs left to
right; vertical runs bottom to top. See [Gradients](Gradients.md).

TexCoords, tint and layer are stored even if no image is set. They affect drawing
when the view has an explicit texture or a generated gradient surface.
A plain View starts transparent; controls configure their own dark backgrounds.

## TextView modifiers

```text
:font(path, flags?)
:fontSize(size)
:localize(localization)
```

| Method | Default | Where it is rendered |
| --- | --- | --- |
| Font | Client font and empty flags | Text, Button, TextField, Dropdown |
| Font size | 16 | Components that draw text |
| Localization | None | Text and Button translation keys |

Slider and Toggle inherit these methods but do not create text labels.
TextField values and Dropdown strings are not automatically localized.
Font size must be positive and font path must be a non-empty string.

## Stack modifiers

| Method | Default | Effect |
| --- | --- | --- |
| `:spacing(value)` | 0 | Space between children |
| `:alignment(value)` | HStack Top; VStack Left | Cross-axis alignment |

Stacks also support the common view modifiers. Fixed numeric cross-axis sizes
on children take priority over Stretch.

## Constants

| Group | Values |
| --- | --- |
| `UI.Size` | Wrap, Fill |
| `UI.Edge` | All, Horizontal, Vertical, Top, Bottom, Left, Right |
| `UI.Alignment` | Top, Bottom, Left, Right, Center, Stretch |
| Texture layer strings | BACKGROUND, BORDER, ARTWORK, OVERLAY, HIGHLIGHT |
| Gradient orientation strings | HORIZONTAL, VERTICAL |

Use UI constants for sizes, edges and alignment. Texture layers and gradient
orientations are uppercase strings. Alignment values must match the stack's cross
axis, as described in [Layout](Layout.md).

## Colors

```text
UI.Color.RGB(red, green, blue)
UI.Color.RGBA(red, green, blue, alpha)
```

RGB channels use 0 to 255. Alpha uses 0 to 1 and defaults to 1 in RGB. The result
is a normalized array of red, green, blue and alpha values.

For example, RGBA(255, 128, 0, 0.5) produces red 1, green 128/255, blue 0 and
alpha 0.5. The color factories themselves do not clamp invalid inputs.

## Mount and handle

```text
UI.Mount(view, parent)
handle:Update(view)
handle:Unmount()
```

Mount returns a handle and centers its content in the parent frame.
`handle.frame` is its currently rendered root frame. Update replaces that tree
and returns no new handle. Unmount cleans up the active tree and may be called
more than once. Update after Unmount is rejected.

See [State and lifecycle](StateAndLifecycle.md) for focus, scroll state and frame
allocation behavior.

## Localization

```text
Declarus.Localization.Create(namespace)
Declarus.Localization.GetActiveLocale()
L:Register(locale, translations)
L:Get(key)
```

Create returns the same instance for the same non-empty namespace string.
GetActiveLocale returns the client locale, or enUS if unavailable. Register merges
a locale's string translations. Get resolves current locale, then enUS, then the
original key. Register does not return a chainable localization object.

The instance also stores namespace and translations. Prefer its methods over
directly editing those tables.

## Client information

```text
Declarus.Client.GetInfo()
Declarus.Client.GetDefaultFont()
```

| GetInfo field | Type | Meaning |
| --- | --- | --- |
| flavor | String | Recognized client family or Unknown |
| version | String | Version returned by GetBuildInfo |
| build | String | Client build |
| interface | Number | Interface version |
| projectID | Number or nil | WOW_PROJECT_ID when available |

GetDefaultFont returns STANDARD_TEXT_FONT or the FRIZQT fallback file. Client
identity is diagnostic information, not a guarantee that a particular API exists
or an in-game test has passed.

## Playground commands

| Command | Effect |
| --- | --- |
| `/declarus` or `/declarus demo` | Open or replace the playground |
| `/declarus info` | Print client details |
| `/declarus reset` | Reset the demo values |
| `/declarus hide` | Close the active playground |

## Internal APIs

Names beginning with an underscore are implementation details. This includes
UI._View, _TextView, _Stack, _Measure, _Arrange, _Render, _ControlRender,
_LocalizationResolver, _FontResolver and _TextMeasure, plus
Declarus.Client._ApplyGradient.

Tests use these deliberately. Application examples should use the public API.

## WoW tooltips

```text
Declarus.WoW.Item(itemID: number) -> DeclarusInfoTooltip
Declarus.WoW.Spell(spellID: number) -> DeclarusInfoTooltip
Declarus.WoW.Unit(unitToken: string) -> DeclarusInfoTooltip
view:tooltip(content?: string | DeclarusView | DeclarusView[]) -> self
view:infoTooltip(source?: DeclarusInfoTooltip) -> self
```

The last tooltip modifier wins. Nil clears it. Text uses GameTooltip; passive
layouts use a Declarus tooltip frame. Info descriptors request Blizzard's native
data. See [WoW helpers](WoW.md) for examples, hover behavior and limits.
