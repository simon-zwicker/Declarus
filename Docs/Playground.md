# Playground

[Docs](README.md) · [API reference](API.md)

The playground is where we try the implemented API in one place. It uses the same
library and shared code on the target clients. It does not depend on PoisonFlow,
save settings or process combat data. Native unit tooltips show Blizzard's own unit details.

The current demo UI uses German labels. The page names below match those labels
so you can find the examples while reading this English guide.

## Commands

| Command | Action |
| --- | --- |
| `/declarus` or `/declarus demo` | Open the playground or replace its active instance |
| `/declarus info` | Print client, version, build, interface and locale |
| `/declarus reset` | Reset the demo values, even while closed |
| `/declarus hide` | Close all active playground mounts |

The centered host is 860 by 640 UI units. Navigation is at the top. The middle
page scrolls with the mouse wheel. The preview and the last two events remain
visible below it.

Values survive navigation and reopening during the same UI session. Reset clears
them; a UI reload starts fresh. There are no SavedVariables, dragging or resizing
controls for this window yet.

## Pages and examples

| Page label | What to try |
| --- | --- |
| Uebersicht | Component list, client details, default font and current limits |
| Layouts | Nested stacks, spacing, fixed sizes, Wrap and horizontal/vertical Fill |
| Layouts | All valid HStack and VStack alignments, including actual Stretch cases |
| Typografie | Font sizes, explicit font with OUTLINE, foreground color and every padding edge |
| Typografie | Localization namespace, current locale, English fallback and missing key |
| Darstellung | Path/FileDataID images, stretching, cropping, mirroring and tint |
| Darstellung | Texture layers, sublevels and textured buttons with readable labels |
| Darstellung | Horizontal/vertical gradients, alpha fade, icon filter and gradient button |
| Darstellung | Gradient/tint combination and interactive preview gradient controls |
| Darstellung | RGB/RGBA, parent opacity and visibility with retained layout space |
| Controls | Mouse buttons, TextField, integer/decimal Slider, Toggle and Dropdown |
| WoW | Text, array and stack tooltips; native items, spells and units; replacement and cleanup |
| Updates | Dynamic child lists, explicit subtree updates and preview Unmount/Remount |
| All pages | Scroll limits, independent mounts, navigation and cleanup |

Stretch examples use intrinsic cross-axis sizes because fixed numeric dimensions
take priority in the current engine.

## The fixed preview

Controls update the bottom preview without replacing the page:

- TextField changes the displayed text. Enter and Escape release its focus.
- The first Slider sets bar width, from 0 to 100 in steps of 5.
- The second sets opacity, from 0 to 1 in steps of 0.1.
- Toggle shows or hides the bar while retaining its layout space.
- Dropdown changes the profile name.
- The mouse-button example logs the button and click count.

On Appearance, `Verlauf an/aus` toggles the gradient on the fixed preview bar.
`Richtung wechseln` switches its orientation between HORIZONTAL and VERTICAL.
The page and its scroll offset stay intact. The static gradient examples remain
visible when you scroll back to them. If the bar was hidden through Toggle, turn
that Toggle back on to see the preview changes.

Preview and event output have their own mounts. Their updates keep the controls
and page scroll frame intact. Long user text is shortened only for display,
without splitting UTF-8 characters. The TextField keeps the full input.

## Actions that rebuild a page

Navigation, Reset, dynamic child changes and the visibility example rebuild the
page. Its scroll position resets. This deliberately demonstrates the existing
mount behavior rather than a hidden reactive update system.

`Vorschau neu` unmounts and remounts only the preview. The page and input controls
stay in place. Closing removes all active mounts. Reopening reuses the outer
playground shell instead of leaving another active window behind.

## Current UI limits

The Dropdown is mouse-driven. If its menu is clipped at the bottom, scroll its
trigger farther up. There is no outside-click close, keyboard navigation or
visible scrollbar yet. The playground does not add features that the library
itself does not implement.

## Checks

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
```

The tests cover navigation, scroll limits, alignment positions, input without
page replacement, rounded values, localization, Unicode, dynamic children,
gradient preview controls and cleanup. Metadata profiles still use the same
mock implementation.

Run through all pages on Retail and the available Classic client too. Fonts,
layers, gradient direction, clipping, native input and UI scale need that visual
check. Forever remains unconfirmed until an actual client test is possible.

Related guides: [Textures](Textures.md), [Gradients](Gradients.md),
[State and lifecycle](StateAndLifecycle.md).

## WoW tooltip walkthrough

Open `/declarus` and choose **WoW**. Scroll through these sections:

| Section | Try this | Expected result |
| --- | --- | --- |
| Text-Tooltips | Hover Text mit Tooltip | A wrapped Blizzard text tooltip appears |
| Text-Tooltips | Hover and click Button mit Tooltip | Tooltip appears; clicking still logs an event |
| Formatierte Tooltips | Hover Array-Tooltip | Colored title and description appear as two rows |
| Formatierte Tooltips | Hover Stack-Tooltip | A title sits above an icon and text row |
| Blizzard: Item und Spell | Hover the Hearthstone and Attack buttons | Blizzard supplies the item or spell details |
| Blizzard: Units | Hover player, target and party1 | Existing units show details; missing units show nothing |
| Ersetzen, Entfernen und Cleanup | Hover Letzter Modifier gewinnt | Item details replace the earlier text tooltip |
| Ersetzen, Entfernen und Cleanup | Hover Tooltip explizit entfernt | Nothing opens |
| Ersetzen, Entfernen und Cleanup | Hover Cleanup testen, then run reset or hide | The formatted tooltip disappears with its owner |

Move the pointer between examples, leave the window, and reopen a formatted
tooltip several times. Only the active owner's tooltip should remain visible.
Navigate away from WoW and back; old tooltip layouts must not remain on screen.
For a target test, select a unit before hovering target. For party1, join a group.

Check placement near screen edges and with your normal UI scale. Formatted
layouts clamp to the screen; plain text and info tooltips use Blizzard's anchor.
Native item loading, live unit details and visual placement still require these
in-game checks. Passing mocks alone does not confirm them.

See [WoW helpers and tooltips](WoW.md) for the actual API and copyable examples.
