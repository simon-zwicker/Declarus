# Layout: Stacks, Größen und Ausrichtung

[Übersicht](README.md) · [Views und Modifier](ViewsAndModifiers.md)

## HStack und VStack

`UI.HStack(children)` ordnet Kinder von links nach rechts an.
`UI.VStack(children)` ordnet Kinder von oben nach unten an. Die Kinder werden als
zusammenhängende Lua-Liste übergeben; keine `nil`-Lücken einsetzen.

```lua
local UI = Declarus.UI
local view = UI.VStack({
    UI.View():size(100, 20):backgroundColor(UI.Color.RGB(90, 195, 240)),
    UI.View():size(60, 30):backgroundColor(UI.Color.RGB(100, 210, 140)),
}):spacing(8):padding(10)
```

**Ergebnis:** Außenbreite 120, Außenhöhe 78. Das erste Kind beginnt bei x=10/y=10,
das zweite bei x=10/y=38. Der Stack benötigt die Breite des breitesten Kindes und
die Summe der Kinderhöhen, des Zwischenraums und des Paddings.

Bei HStack werden die Achsen vertauscht: Breiten summieren sich, die größte Höhe
bestimmt die intrinsische Quergröße. Spacing liegt nur **zwischen** den Kindern,
nicht vor dem ersten oder nach dem letzten.

## Fixe Größe, Wrap und Fill

| Wert | Verhalten |
| --- | --- |
| Zahl | feste Außenabmessung |
| nicht gesetzt / `UI.Size.Wrap` | benötigte intrinsische Größe |
| `UI.Size.Fill` | angebotenen Platz auf dieser Achse verwenden |

Eine normale View ohne Text/Kinder hat keine Bild-/Inhaltsgröße. Wrap macht daraus
also nicht automatisch eine sichtbare Fläche. Bei Text werden die Schriftmaße
verwendet, bei Stacks die Kindermaße.

### Verbleibende Breite aufteilen

```lua
local UI = Declarus.UI
local view = UI.HStack({
    UI.View():size(80, 30):backgroundColor(UI.Color.RGB(80, 120, 180)),
    UI.View():size(UI.Size.Fill, 30):backgroundColor(UI.Color.RGB(90, 180, 120)),
    UI.View():size(UI.Size.Fill, 30):backgroundColor(UI.Color.RGB(190, 120, 80)),
}):width(400):spacing(10):padding(10)
```

**Ergebnis:** Außen 400 × 50. Innen stehen 380 Einheiten Breite zur Verfügung.
Nach dem festen Kind (80) und zwei Zwischenräumen (20) bleiben 280. Beide
Fill-Kinder erhalten jeweils 140.

Dasselbe Prinzip gilt vertikal in einer VStack mit bekannter Höhe.
Ein negativer Rest wird bei der Fill-Verteilung auf 0 begrenzt. Zu große fixe
Kinder werden dabei nicht automatisch verkleinert.

### Fill am Wurzelknoten

`UI.Mount` gibt die Größe des Eltern-Frames aktuell **nicht** als verfügbares
Layoutmaß an die Messung weiter. `UI.View():width(UI.Size.Fill)` direkt unter
`UIParent` bedeutet deshalb nicht automatisch Bildschirmbreite.

Für verlässliche Ergebnisse die Wurzelbreite/-höhe explizit setzen und erst deren
Kinder mit Fill ausstatten. Ist der Platz auf der Hauptachse unbekannt, verwendet
die Engine die größte intrinsische bzw. bekannte Geschwistergröße als Fill-Basis.
Das ist kein prozentuales Layout und kein Ersatz für eine feste Layoutgrenze.

Ein nicht gesetztes Hauptachsenmaß kann ein verfügbares Maß des Elternlayouts
für die Fill-Verteilung nutzen. Explizites Wrap fordert dagegen eine intrinsische
Messung auf dieser Achse. Bei Stacks mit Fill-Kindern sind „nicht gesetzt“ und
„explizit Wrap“ daher nicht in jeder Verschachtelung austauschbar.

## Alignment wirkt auf die Querachse

| Stack | Hauptachse | Querachse | erlaubtes Alignment |
| --- | --- | --- | --- |
| HStack | horizontal | vertikal | Top, Center, Bottom, Stretch |
| VStack | vertikal | horizontal | Left, Center, Right, Stretch |

Die Standardausrichtung ist Top bei HStack und Left bei VStack. Ungültige
Kombinationen wie `UI.HStack({}):alignment(UI.Alignment.Left)` werden abgewiesen.
Alignment steuert nicht die Verteilung auf der Hauptachse; es gibt noch kein
`space-between`, `justifyContent` oder Flex-Gewicht.

```lua
local UI = Declarus.UI
local view = UI.HStack({
    UI.View():size(40, 20):backgroundColor(UI.Color.RGB(90, 195, 240)),
    UI.View():size(40, 50):backgroundColor(UI.Color.RGB(100, 210, 140)),
}):height(70):spacing(10):alignment(UI.Alignment.Center)
```

**Ergebnis:** Das 20 hohe Kind erhält oben 25 Einheiten Abstand; das 50 hohe Kind
10. Beide sind in der bekannten Höhe 70 vertikal zentriert. Die Breite beträgt 90.

## Stretch und explizite Maße

```lua
local UI = Declarus.UI
local view = UI.VStack({
    UI.Text("Kurz"),
    UI.Text("Ein längerer Text"),
}):width(300):spacing(8):alignment(UI.Alignment.Stretch)
```

**Ergebnis:** Die Kinder-Frames werden auf der Querachse mindestens auf die
verfügbare Breite 300 gebracht. Das skaliert nicht die Schrift und verteilt nicht
die Buchstaben über diese Breite. Ein explizites `:width(100)` am Kind hat Vorrang
und bleibt 100. Ein schon intrinsisch größeres Kind wird nicht zusammengedrückt.

`UI.Size.Fill` auf der Querachse löst ebenfalls die entsprechende Streckung aus.
Eine HStack ohne eigene Breitenangabe wird innerhalb einer VStack zusätzlich
an deren verfügbare Breite angepasst. Für lesbare, vorhersehbare Beispiele ist
`:width(UI.Size.Fill)` trotzdem oft die deutlichere Absicht.

## Verschachtelte Layouts

```lua
local UI = Declarus.UI
local view = UI.VStack({
    UI.Text("Einstellungen"):fontSize(20),
    UI.HStack({
        UI.Text("Profil"):width(100),
        UI.TextField("Standard"):width(UI.Size.Fill),
    }):width(UI.Size.Fill):spacing(12):alignment(UI.Alignment.Center),
}):width(420):padding(16):spacing(12)
```

**Ergebnis:** Die Zeile liegt unter der Überschrift. Die 420 breite Wurzel hat
innen 388 Einheiten. Die Zeile verwendet diese Breite; nach Label 100 und Spacing
12 bleiben dem TextField 276. Die Kinder der Zeile sind vertikal zentriert.

## Grenzen

Die Engine bietet bisher keine Min-/Max-Größen, Prozentwerte, Flex-Gewichte,
Overlay-/ZStack-Anordnung, automatische Zeilenumbrüche oder automatische
Kollisionsvermeidung. Layoutüberläufe werden außerhalb einer ScrollView nicht
generell abgeschnitten. Texte mit festem `width` erhalten dadurch allein weder
Umbruch noch Ellipse. Inhalte und Größen entsprechend gestalten.
