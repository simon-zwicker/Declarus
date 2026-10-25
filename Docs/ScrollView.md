# ScrollView

[Übersicht](README.md) · [Layout](Layout.md)

`UI.ScrollView(content)` nimmt genau eine Inhalts-View entgegen. Mehrere Kinder
vorher in einer VStack oder HStack zusammenfassen. Die Standardgröße ist 240 × 180;
Breite und Höhe beschreiben den Viewport, nicht den gesamten Inhalt.

## Vertikale Liste

```lua
local UI = Declarus.UI
local rows = {}
for index = 1, 20 do
    rows[#rows + 1] = UI.Text("Eintrag " .. index)
end

local content = UI.VStack(rows)
    :spacing(8)
    :padding(12)
    :width(UI.Size.Fill)

local view = UI.ScrollView(content):size(320, 200)
UI.Mount(view, UIParent)
```

**Ergebnis:** Eine 320 × 200 große vertikale Ansicht. Die 20 Zeilen erzeugen einen
höheren Inhalt. Mit dem Mausrad über der ScrollView wird nach oben/unten gescrollt.
Der Renderer bewegt pro gemeldeter Mausrad-Einheit 30 UI-Einheiten und begrenzt
den Offset auf 0 bis `max(0, Inhaltshöhe - Viewporthöhe)`.

Inhalte müssen eine intrinsische oder explizite Höhe haben. Für eine vertikale
Liste deshalb nicht `:height(UI.Size.Fill)` am Inhalt verwenden: Die Messung der
Scroll-Inhalte erhält auf der Höhenachse kein endliches Scroll-Limit als Fill-Ziel.

## Viewport-Padding und Inhalts-Padding

```lua
local UI = Declarus.UI
local view = UI.ScrollView(
    UI.View():size(180, 400):backgroundColor(UI.Color.RGB(90, 195, 240))
):size(200, 120):padding(10)
```

**Ergebnis:** Die Außenfläche ist 200 × 120. Der innere Viewport ist 180 × 100
und beginnt 10 Einheiten von den Außenrändern entfernt. Der 400 hohe Inhalt
kann um maximal 300 Einheiten gescrollt werden.

Padding **an der ScrollView** verkleinert den Viewport. Padding **am Inhalts-Stack**
gehört dagegen zur scrollbaren Inhaltsfläche und scrollt mit. Es ist möglich,
beide bewusst zu kombinieren.

## Nicht scrollender Inhalt

```lua
local UI = Declarus.UI
local view = UI.ScrollView(UI.View():size(100, 40))
    :size(100, 100)
```

**Ergebnis:** Der Inhalt ist niedriger als der Viewport. Der Scroll-Offset bleibt
auch bei Mausrad-Eingaben 0. Eine normale View ist ohne Farbe/Textur unsichtbar;
das Beispiel zeigt nur das Größenverhältnis.

## Updates und verschachtelte Controls

Ein Mount-Update, das die ScrollView ersetzt, setzt ihre Scrollposition zurück.
Um neben einer scrollenden Seite eine Live-Vorschau zu ändern, getrennte Mounts
verwenden. Der Playground zeigt dieses Muster. Der vorhandene Scroll-Offset hat
noch keinen öffentlichen Declarus-Getter/Setter und wird nicht automatisch
wiederhergestellt.

Dropdown-Menüs und andere Kinder bleiben Teil ihrer nativen Frame-Hierarchie.
Die Library enthält noch kein Popup-Portal, das solche Menüs aus dem Viewport
heraushebt. Auch verschachtelte ScrollViews sind keine getestete allgemeine
Event-Routing-/Scroll-Verkettungslösung.

Es gibt aktuell keine sichtbare Scrollbar, kein horizontales Scrollen, keine
Virtualisierung großer Listen und keine Scroll-to-item-API. Für umfangreiche
Datenmengen geeignete Teilmengen rendern; jedes gerenderte Kind erzeugt Frames.
