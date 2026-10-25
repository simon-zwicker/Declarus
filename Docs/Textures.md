# Texturen und Modifier

[Dokumentationsübersicht](README.md) · [API-Referenz](API.md)

Alle Views, Texte, Stacks und Controls erben die Textur-Modifier. Sie beeinflussen
ausschliesslich die eigene Textur des Elements, nicht seine Kinder, sein Padding,
seine intrinsische Groesse, die Textfarbe oder die Hintergrundfarbe.

```lua
local UI = Declarus.UI
local icon = UI.View()
    :size(48, 48)
    :texture(134400)
    :texCoords(0.08, 0.92, 0.08, 0.92)
    :textureTint(UI.Color.RGBA(90, 195, 240, 0.8))
    :textureLayer("ARTWORK", 0)
```

## Quelle und Groesse

`:texture(pathOrFileID)` akzeptiert einen WoW-Dateipfad oder eine numerische
FileDataID. Die Textur fuellt die gesamte Elementflaeche, inklusive Padding.
Eine Groesse explizit setzen bzw. aus dem Layout beziehen; die Bilddatei bestimmt
keine intrinsische Groesse. Beim Wechsel der Quelle bleiben die konfigurierten
TexCoords, Tint und Layer dieses View-Objekts erhalten. Die Modifier koennen vor
oder nach `:texture(...)` gesetzt werden.

## Ausschnitt und Spiegelung

`:texCoords(left, right, top, bottom)` akzeptiert vier endliche Werte von 0 bis 1.
Die Reihenfolge entspricht WoWs vierteiliger `SetTexCoord`-Variante. Ohne Modifier
wird die volle Textur verwendet. `(0, 1, 0, 1)` setzt den vollen Ausschnitt explizit.

- `(0.08, 0.92, 0.08, 0.92)` schneidet den aeusseren Rand ab.
- `(1, 0, 0, 1)` spiegelt horizontal, `(0, 1, 1, 0)` vertikal.

Der gewaehlte Ausschnitt wird weiterhin auf die Elementflaeche gestreckt.
Automatische Seitenverhaeltnis-Anpassung, Cover-/Contain-Modi und die achtteilige
Koordinatenvariante sind nicht Bestandteil dieses Pakets.

## Toenen

`:textureTint(UI.Color.RGB(...))` bzw. `RGBA(...)` multipliziert die Bildkanaele
mit der Farbe. Weiss `(255, 255, 255)` erhaelt das Bild; weisse Bildteile nehmen
die Tönung an, schwarze bleiben schwarz. Alpha wirkt nur auf die Textur, zusaetzlich
zu einer moeglichen View-/Eltern-Opacity. Die Farbe wird beim Setzen kopiert.

Der Modifier erwartet wie die anderen Farb-Modifier normalisierte Farbtabellen;
`UI.Color.RGB/RGBA` erzeugt diese aus den bekannten 0–255-RGB-Werten. Ein fehlender
Alpha-Kanal wird als 1 behandelt. Um die Toenung zurueckzusetzen, Weiss verwenden.
Text-/Foreground- und Hintergrundfarbe bleiben unabhaengig.

## Zeichenreihenfolge

Der sichere Standard innerhalb des eigenen Frames ist:

1. `backgroundColor`: BACKGROUND.
2. `texture`: BORDER, Sublevel 0.
3. Text-/Button-Beschriftung: OVERLAY.

Damit liegt eine normale Button-Textur hinter der Beschriftung. Zuvor nutzten
sowohl Textur als auch Text ARTWORK; diese uneindeutige Reihenfolge wurde ersetzt.
Native Control-Grafiken wie Checkbox-Haken und Slider-Thumb werden nicht umgestaltet.

`:textureLayer(layer, sublevel)` erlaubt BACKGROUND, BORDER, ARTWORK, OVERLAY und
HIGHLIGHT. Der Sublevel ist eine ganze Zahl von -8 bis 7, Standard 0. Ein hoeherer
Sublevel liegt innerhalb desselben Layers weiter vorne. Ein explizit hoher Layer
kann absichtlich die Beschriftung oder native Control-Grafiken ueberdecken;
HIGHLIGHT folgt ausserdem WoWs Highlight-Verhalten des jeweiligen Frame-Typs.
Layer ordnen Regionen innerhalb eines Frames, nicht beliebige andere Frames
oder deren FrameStrata. Fuer einen normalen texturierten Button ist kein Override
noetig:

```lua
UI.Button("Speichern", function() print("Gespeichert") end)
    :texture("Interface\\Buttons\\WHITE8X8")
    :textureTint(UI.Color.RGB(30, 85, 120))
```

## Playground und Pruefung

`/declarus` > Darstellung zeigt Original/Ausschnitt/Spiegelung, RGB-/RGBA-Tint,
texturierte Buttons und explizite Layer/Sublevel. Automatische Tests pruefen alle
View-Typen, Validierung, Unabhaengigkeit von Text-/Hintergrundfarbe und das
Zuruecksetzen beim Ersetzen eines Mount-Teilbaums. Visuelle Darstellung und
native Control-Layer muessen weiterhin im jeweiligen offiziellen Client geprueft
werden.

Verwendete gemeinsame WoW-APIs:
[SetTexCoord](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua),
[SetVertexColor und SetDrawLayer](https://raw.githubusercontent.com/Gethe/wow-ui-source/live/Interface/AddOns/Blizzard_APIDocumentationGenerated/SimpleRegionAPIDocumentation.lua).
