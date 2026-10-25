# Farbverläufe

[Dokumentationsübersicht](README.md) · [API-Referenz](API.md) · [Texturen](Textures.md)

`:gradient(orientation, fromColor, toColor)` ist ein gemeinsamer View-Modifier.
Er färbt die eigene Bildfläche des Elements, nicht seine Beschriftung oder seine
Kinder. Ohne explizite Textur erzeugt der Renderer eine weiße Farbfläche, auf der
der Verlauf sichtbar wird. Mit `:texture(...)` wirkt er als Farbfilter auf das Bild.

## Horizontal: links nach rechts

```lua
local UI = Declarus.UI
local view = UI.View():size(320, 60)
    :gradient("HORIZONTAL",
        UI.Color.RGB(30, 100, 200),
        UI.Color.RGB(100, 220, 160))

UI.Mount(view, UIParent)
```

**Ergebnis:** Eine 320 × 60 große Fläche verläuft von Blau links nach Grün rechts.
Der Gradient erzeugt keine intrinsische Größe; Größe explizit angeben oder durch
das Layout bestimmen lassen. Layer und Sublevel entsprechen der eigenen View-
Textur: standardmäßig BORDER/0, optional über `textureLayer` konfigurierbar.

## Vertikal: unten nach oben

```lua
local UI = Declarus.UI
local view = UI.View():size(120, 180)
    :gradient("VERTICAL",
        UI.Color.RGB(240, 100, 50),
        UI.Color.RGB(70, 100, 220))

UI.Mount(view, UIParent)
```

**Ergebnis:** Orange liegt **unten**, Blau **oben**. Die erste Farbe ist bei der
nativen vertikalen WoW-Orientierung die untere Farbe. Für die Gegenrichtung die
Farben vertauschen. Erlaubt sind ausschließlich HORIZONTAL und VERTICAL, keine
Winkel oder diagonalen Verläufe.

## Alpha-Verlauf

```lua
local UI = Declarus.UI
local view = UI.View():size(320, 50)
    :backgroundColor(UI.Color.RGB(20, 25, 35))
    :gradient("HORIZONTAL",
        UI.Color.RGBA(90, 195, 240, 0),
        UI.Color.RGBA(90, 195, 240, 1))

UI.Mount(view, UIParent)
```

**Ergebnis:** Links ist die Gradient-Fläche transparent und der separate dunkle
Hintergrund bleibt sichtbar. Nach rechts wird der hellblaue Verlauf vollständig
deckend. Alpha wirkt hier nur auf die Gradient-Textur. `opacity` auf der View
würde zusätzlich den gesamten Frame einschließlich Text und Kindern beeinflussen.

## Ein Bild ausblenden oder färben

```lua
local UI = Declarus.UI
local icon = UI.View():size(64, 64):texture(134400)
    :texCoords(0.08, 0.92, 0.08, 0.92)
    :gradient("VERTICAL",
        UI.Color.RGBA(255, 255, 255, 0),
        UI.Color.RGB(255, 255, 255))

UI.Mount(icon, UIParent)
```

**Ergebnis:** Das beschnittene Fragezeichen-Icon ist unten transparent und oben
sichtbar. Weiß erhält die RGB-Bildfarben, der Alpha-Unterschied erzeugt den Fade.
Bei farbigen Endpunkten werden die Bildfarben mit dem Verlauf multipliziert;
schwarze Bildteile werden nicht automatisch hell eingefärbt.

TexCoords und Gradient sind unabhängig: Die Koordinaten wählen den Bildausschnitt;
der Gradient färbt die resultierende Fläche. Keine automatische Änderung des
Seitenverhältnisses oder der Elementgröße.

## Button mit lesbarer Beschriftung

```lua
local UI = Declarus.UI
local view = UI.Button("Speichern", function() print("Gespeichert") end)
    :size(220, 40):padding(UI.Edge.Left, 12):padding(UI.Edge.Top, 10)
    :gradient("HORIZONTAL",
        UI.Color.RGB(25, 70, 120),
        UI.Color.RGB(35, 120, 80))
    :foregroundColor(UI.Color.RGB(255, 255, 255))

UI.Mount(view, UIParent)
```

**Ergebnis:** Blau-grüner Button mit weißer Beschriftung. Der Gradient liegt im
BORDER-Layer, der Text in OVERLAY. Der voreingestellte dunkle Control-Hintergrund
bleibt separat vorhanden. Dass ein Control den Modifier erbt, bedeutet nicht,
dass seine nativen Grafiken wie Checkbox-Haken ebenfalls einen Verlauf erhalten.

## Mit Texturtönung kombinieren

Sind `gradient` und `textureTint` gesetzt, multipliziert Declarus die Tönung in
**beide Endpunktfarben einschließlich Alpha** hinein. Die Setter überschreiben
sich nicht gegenseitig. Die Reihenfolge dieser Modifier spielt daher keine Rolle.
Ein Gradient-Endpunkt mit Alpha 0.4 und ein Tint mit Alpha 0.5 ergeben an diesem
Ende Alpha 0.2; eine View-Opacity wirkt anschließend zusätzlich.

Der Verlauf hat Vorrang als Farbfeld gegenüber der einfachen nativen Vertex-
Tönung; die gespeicherten ursprünglichen Farbtabellen werden dabei nicht verändert.
Eine separat gesetzte `backgroundColor` und die Textfarbe bleiben unabhängig.

## Entfernen und aktualisieren

```lua
local UI = Declarus.UI
local view = UI.View():size(160, 40):texture(134400)
    :gradient("HORIZONTAL", UI.Color.RGB(255, 0, 0), UI.Color.RGB(0, 0, 255))
local handle = UI.Mount(view, UIParent)

view:gradient(nil)
handle:Update(view)
```

**Ergebnis:** Nach dem Update bleibt das Icon erhalten, aber sein Gradient ist
entfernt. Eine vorhandene Texturtönung bleibt ebenfalls erhalten. Ohne Bildquelle
und ohne Gradient entfällt die automatisch erzeugte weiße Fläche; eine separate
Hintergrundfarbe bleibt bestehen. Wie alle Modifier aktualisiert auch `gradient`
einen bestehenden Mount erst durch einen expliziten Update-Aufruf.

## Validierung und Grenzen

Farben sind normalisierte RGB-/RGBA-Tabellen, wie sie `UI.Color.RGB/RGBA` liefern.
Alle Kanäle müssen endlich und im Bereich 0–1 sein. Ein fehlendes Alpha wird 1.
Farben werden beim Setzen kopiert. Ungültige Orientierung, fehlende Farben und
ungültige Kanäle werden abgewiesen, ohne einen bestehenden Verlauf zu ersetzen.
`gradient(nil)` bzw. `gradient()` entfernt den Verlauf; dabei keine Farben mitgeben.

Es gibt genau zwei Endpunkte. Mehrere Farbstopps, radiale Verläufe, Animationen
und Verläufe auf Schrift sind noch nicht implementiert.

Die native Übergabe an `Texture:SetGradient` mit durch `CreateColor` erzeugten
Farben liegt zentral in `Core/Client.lua`. Es gibt keine Privatserver-/Original-
Client-Fallbacks. Wenn die benötigte API fehlt, wird ein klarer Fehler ausgelöst;
der Verlauf wird nicht stillschweigend als einfarbige Fläche dargestellt.

`/declarus` → Darstellung zeigt die Beispiele. Der Matrixlauf mit Mocks prüft
API-Nutzung, Farben, Alpha, Tönung und Lifecycle; visuelle Richtung und Darstellung
bleiben auf den jeweiligen offiziellen Clients zu prüfen. Forever bleibt ohne
Ingame-Test unbestätigt.

Die verwendeten nativen Farbobjekte entsprechen
[Blizzards ColorMixin/CreateColor](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_SharedXMLBase/Color.lua).
