# Views und gemeinsame Modifier

[Übersicht](README.md) · [Layout](Layout.md) · [Texturen](Textures.md)

## View als einfache Fläche

```lua
local UI = Declarus.UI
local view = UI.View()
    :size(160, 48)
    :backgroundColor(UI.Color.RGB(30, 100, 150))

UI.Mount(view, UIParent)
```

**Ergebnis:** Eine zentrierte blaue Fläche mit 160 × 48 UI-Einheiten.
Eine leere View hat ohne Größe und ohne Padding keine intrinsische Ausdehnung.
`UI.View()` akzeptiert öffentlich keine Kinder; für Gruppen HStack/VStack verwenden.

## Fluent-API und Objektidentität

```lua
local UI = Declarus.UI
local view = UI.View()
local sameView = view:width(100):height(40)
assert(sameView == view)
```

**Ergebnis:** Beide Variablen zeigen auf dieselbe Beschreibung. Modifier erzeugen
keine unabhängigen Kopien. Für zwei unabhängige Elemente zwei Konstruktoraufrufe
verwenden. Nach dem Mounten ist die Beschreibung kein automatisch gebundenes UI.

## Größe

| Modifier | Bedeutung |
| --- | --- |
| `:width(value)` | nur Breite konfigurieren |
| `:height(value)` | nur Höhe konfigurieren |
| `:size(width, height)` | Breite und Höhe konfigurieren |

Erlaubte Größenwerte sind Zahlen, `UI.Size.Wrap` und `UI.Size.Fill`. Zahlen geben
UI-Einheiten an, deren sichtbare Pixelgröße von WoWs UI-Skalierung abhängt.
Die Details zu bekannten und unbekannten Platzangeboten stehen unter [Layout](Layout.md).

Explizite Zahlen sind **Außenmaße einschließlich Padding**. Padding vergrößert eine
fest auf 100 gesetzte Breite nicht auf 120, sondern reduziert den inneren Platz.
Bei intrinsischer Größe wird Padding dagegen zur Inhaltsgröße addiert.

## Padding und Edges

```lua
local UI = Declarus.UI
local view = UI.Text("Abstand zum Rand")
    :padding(8)
    :padding(UI.Edge.Left, 12)
    :backgroundColor(UI.Color.RGB(30, 45, 65))
```

**Ergebnis:** Der Text hat links 20, rechts 8, oben 8 und unten 8 Einheiten Abstand.
Padding ist **kumulativ**. Wiederholtes `:padding(8)` addiert nochmals 8 pro Seite.
Anders als bei Padding überschreibt ein zweiter `:width(...)` den ersten Wert.

| Edge | Betroffene Seiten |
| --- | --- |
| `UI.Edge.All` | links, rechts, oben, unten |
| `UI.Edge.Horizontal` | links und rechts |
| `UI.Edge.Vertical` | oben und unten |
| `UI.Edge.Left` / `Right` | einzelne horizontale Seite |
| `UI.Edge.Top` / `Bottom` | einzelne vertikale Seite |

`:padding(8)` ist die Kurzform von `:padding(UI.Edge.All, 8)`.
Es gibt aktuell keinen öffentlichen Padding-Reset-Modifier. Für einen frischen
Ausgangszustand eine neue View bauen.

Padding wirkt auf Stack-Anordnung und Text-/Button-Beschriftung. Native Controls
haben zusätzlich eigene Details: Das TextField verwendet derzeit feste TextInsets
von 4/4/2/2; ein Dropdown-Label einen linken Offset von 4. Gemeinsames Padding ist
kein universeller Innenabstand für jede native Control-Grafik.

## Farben

```lua
local UI = Declarus.UI
local background = UI.Color.RGBA(20, 50, 80, 0.6)
local foreground = UI.Color.RGB(240, 245, 250)

local view = UI.Text("Heller Text auf transparentem Blau")
    :padding(10)
    :backgroundColor(background)
    :foregroundColor(foreground)
```

**Ergebnis:** Der Hintergrund ist zu 60 % deckend; der Text bleibt voll deckend.
`RGB` nimmt drei Kanalwerte von 0–255 und setzt Alpha auf 1. `RGBA` nimmt zusätzlich
Alpha von 0–1. Beide liefern intern normalisierte Farbtabellen. Die Fabriken
begrenzen falsche Eingaben nicht automatisch; gültige Werte selbst übergeben.

`backgroundColor` erstellt eine eigene BACKGROUND-Textur auf dem Frame.
`foregroundColor` wird derzeit bei `UI.Text` und der von Declarus gezeichneten
Button-Beschriftung angewendet. Eine Farbe auf dem Stack wird nicht automatisch
zur Textfarbe seiner Kinder. Native EditBox-/Dropdown-Texte werden durch diesen
Modifier aktuell nicht eingefärbt. Texturtönung hat einen separaten Modifier.

## Farbverläufe

`:gradient("HORIZONTAL", fromColor, toColor)` färbt die eigene Bildfläche von
links nach rechts; VERTICAL von unten nach oben. Ohne Bildquelle wird eine weiße
Fläche für den Verlauf erzeugt. Alpha und `textureTint` sind kombinierbar, Text
und Kinder werden nicht mitgefärbt. `:gradient(nil)` entfernt ihn. Beispiele und
erwartete Ergebnisse stehen unter [Farbverläufe](Gradients.md).

## Opacity

```lua
local UI = Declarus.UI
local view = UI.VStack({
    UI.Text("Auch dieser Text wird transparenter."),
    UI.View():size(100, 20):backgroundColor(UI.Color.RGB(0, 180, 100)),
}):spacing(8):opacity(0.5)
```

**Ergebnis:** Der Stack-Frame ist halbtransparent. Durch WoWs Frame-Hierarchie
betrifft das auch seine Kinder. Eigene Alpha-Werte der Kinder wirken zusätzlich.
Das unterscheidet `opacity` von einer RGBA-Hintergrundfarbe, die nur den Hintergrund
betrifft. Für `opacity` selbst Werte von 0–1 verwenden.

## Sichtbarkeit

```lua
local UI = Declarus.UI
local view = UI.HStack({
    UI.View():size(40, 40):backgroundColor(UI.Color.RGB(255, 0, 0)),
    UI.View():size(40, 40):backgroundColor(UI.Color.RGB(0, 255, 0)):visible(false),
    UI.View():size(40, 40):backgroundColor(UI.Color.RGB(0, 0, 255)),
}):spacing(10)
```

**Ergebnis:** Rot und Blau sind sichtbar. In der Mitte bleiben 40 Einheiten
reserviert, obwohl Grün unsichtbar ist. Die Gesamtbreite bleibt 140.
Soll der Platz entfallen, das betreffende Kind beim nächsten Baumaufbau weglassen.

`visible(false)` blendet den Frame aus. `opacity(0)` macht ihn transparent,
beendet aber nicht grundsätzlich seine mögliche Mausinteraktion.

## Was wird geerbt?

Alle Komponenten erben die gemeinsamen Modifier als Methoden. Das ist von
**Wertvererbung** zu unterscheiden:

| Eigenschaft eines Eltern-Stacks | Wirkung auf Kinder |
| --- | --- |
| Padding/Spacing/Alignment | beeinflusst die Anordnung |
| Opacity | wirkt über die native Frame-Hierarchie zusätzlich auf Kinder |
| Visible false | versteckt auch die Darstellung seiner Kinder |
| BackgroundColor/Texture | zeichnet auf dem Eltern-Frame; kopiert keine Kind-Eigenschaften |
| ForegroundColor | wird nicht als Textstil an Kinder weitergereicht |

Für wiederkehrende Gestaltung eigene Lua-Funktionen bauen, die die gewünschten
Modifier auf jedes erzeugte Element anwenden. Ein Beispiel steht in [Praxisrezepte](Recipes.md).
