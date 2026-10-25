# Fehlersuche

[Übersicht](README.md) · [Entwicklung und Tests](Development.md)

## Declarus fehlt im Addon-Menü

Prüfen, ob der richtige Client-Ordner verwendet wird und ob
`Interface/AddOns/Declarus/Declarus.toc` tatsächlich existiert. Bei Symlinks muss
das Ziel erreichbar sein. Auf versehentliche doppelte Ordner und abweichende
Schreibweise achten. Nach neu bereitgestellten Addons gegebenenfalls den Client
neu starten.

Eine Interface-Kennung in der TOC muss zu dem aktuellen Client passen. Bei einem
neuen Patch den tatsächlichen Interface-Wert überprüfen und die deklarierte
Zielmatrix pflegen; eine Kennung zu ändern ersetzt keine API-/Ingame-Prüfung.

## `Declarus` oder `Declarus.UI` ist nil

Declarus wurde noch nicht geladen oder die Dateien stehen in falscher Reihenfolge.
Im verwendenden Addon eine Abhängigkeit auf Declarus setzen und den Code erst
nach dem Laden ausführen. Die Bibliothek nicht zusätzlich in zufälliger Reihenfolge
manuell laden. In Lua-Tests zuerst WoW-Mocks und dann die echte TOC laden, wie es
`Tests/Run.lua` bereits macht.

## Eine View ist unsichtbar

`UI.View()` ist zunächst leer. Größe und Farbe oder Textur setzen. Bei `Fill`
prüfen, ob es auf dieser Achse überhaupt bekannten Platz gibt. Ein Fill-Root unter
UIParent übernimmt nicht automatisch die Bildschirmmaße. Auch `visible(false)`,
Opacity 0, transparente Farben und ungültige Texturdateien kontrollieren.

```lua
local UI = Declarus.UI
local view = UI.View():size(100, 40):backgroundColor(UI.Color.RGB(255, 0, 0))
UI.Mount(view, UIParent)
```

**Ergebnis:** Eine einfache rote Referenzfläche. Ist diese sichtbar, anschließend
Textur, Padding und weitere Eigenschaften schrittweise ergänzen.

## Padding scheint die falsche Größe zu haben

Wiederholte Padding-Aufrufe addieren sich. Feste Breite/Höhe sind Außenmaße, nicht
reine Inhaltsmaße. Bei einer fixen 100 breiten View mit links/rechts 10 bleiben
innen 80. Bei nativen Controls gelten außerdem deren eigene Text-Inset-Details.

## Unsichtbares Kind hinterlässt eine Lücke

Das ist das Verhalten von `visible(false)`. Die Messung berücksichtigt dieses
Kind weiterhin. Für kollabierenden Platz das Kind beim Baumaufbau auslassen und
den Mount aktualisieren. Beispiel: [optionale Zeilen](Recipes.md).

## Stretch ändert das Kind nicht

Eine explizite numerische Quergröße am Kind hat Vorrang. Ein bereits größeres
intrinsisches Kind wird außerdem nicht automatisch verkleinert. Zum Beobachten
von Stretch mit intrinsischen Kindergrößen beginnen und eine bekannte Quergröße
am Stack setzen. Alignment betrifft nicht die Hauptachsen-Verteilung.

## Text ragt über den Rahmen oder Button hinaus

Feste Textbreite erzeugt derzeit keinen Umbruch oder keine Ellipse. Button-
Standardmaße wachsen bei größerem Font nicht automatisch mit. Breite/Höhe anpassen,
kürzere Texte verwenden oder mehrere Text-Views bewusst aufteilen. Bei eigenen
Fonts prüfen, ob die Datei im jeweiligen Client existiert und der Font die Sprache
unterstützt. Der Client-Fallback hilft nicht automatisch bei einem ungültigen
explizit gesetzten Fontpfad.

## Texturtönung verändert das Bild anders als erwartet

Tint multipliziert Bildfarben. Ein schwarzer Bildteil wird durch einen roten Tint
nicht rot; eine weiße Textur ist für einfarbige Symbole/Flächen geeignet. Für die
Originalfarben Weiß als Tint verwenden. `foregroundColor` ist kein Textur-Tint.
Koordinatenwerte zwischen 0 und 1 verwenden; vertauschte Seiten spiegeln das Bild.

## Eine Textur verdeckt Schrift oder Control-Grafik

Ohne Layer-Override liegt die View-Textur in BORDER; Text-/Button-Beschriftung in
OVERLAY. Ein explizites OVERLAY/HIGHLIGHT oder ein hoher Sublevel kann diese
Reihenfolge bewusst übersteuern. Zum Eingrenzen `:textureLayer("BORDER", 0)`
verwenden. Layer innerhalb eines Frames sind nicht dasselbe wie FrameStrata
zwischen unterschiedlichen Frames.

## Eingaben ändern ein Label nicht

Eine Lua-Variable ist keine reaktive Bindung. Den betroffenen Mount explizit mit
einer neuen View aktualisieren. Ist ein Control im selben Mount, kann dadurch
Fokus verloren gehen: Vorschau und Eingaben in getrennte Mounts legen.

## TextField verliert bei jedem Zeichen den Fokus

Meist wird der Mount des gesamten Formulars aus seinem eigenen onChange ersetzt.
Nur einen anderen, kleinen Vorschau-Mount aktualisieren. Der Playground zeigt
bereits dieses Muster. Eine automatische Fokuswiederherstellung gibt es noch nicht.

## Slider-Callback sitzt am falschen Parameter

Die Signatur lautet `UI.Slider(value, min, max, step, callback)`. Für den Standard-
Step den vierten Parameter als `nil` übergeben. Der Slider liefert gerundete Werte;
kleine Änderungen innerhalb desselben Schritts ergeben nicht jedes Mal onChange.

## Dropdown öffnet sich, ist aber abgeschnitten

Das Menü bleibt in seiner nativen Elternhierarchie. In einer ScrollView kann der
Viewport clippen. Das Control nach oben scrollen oder ausreichend Platz unter dem
Dropdown lassen. Eine andere Breite des Auslösers passt aktuell die feste Menü-
Breite von 180 nicht automatisch an. Schließen per Auswahl oder erneutem Klick.

## ScrollView scrollt nicht

Ist die Inhaltshöhe kleiner/gleich der inneren Viewporthöhe, ist der maximale
Offset 0. Dem Inhalt eine intrinsische oder explizite Höhe geben und nicht einfach
vertikales Fill setzen. Mausrad-Eingaben über dem Scrollbereich testen. Derzeit
gibt es weder eine sichtbare Scrollbar noch horizontales Scrollen.

## Update nach dem Schließen schlägt fehl

Ein unmountetes Handle kann nicht aktualisiert werden. Das aufrufende Addon muss
seine Referenz als geschlossen behandeln und beim Öffnen neu mounten. Laufende
Timer/Callbacks außerhalb von Declarus selbst beenden oder gegen das geschlossene
UI absichern.

## VS Code meldet viele unbekannte Lua-Globals

Die gemeinsame `.luarc.json` und lokale `.vscode/settings.json` vergleichen.
Standardbibliotheken wie basic/math/string/table dürfen hier nicht pauschal
deaktiviert sein; die Tests benötigen zusätzlich io/os. Keine nicht installierte
externe WoW-Typbibliothek voraussetzen. Declarus enthält den verwendeten
API-Ausschnitt in `Types/WoW.lua`. Diese Datei wird von LuaLS gelesen, nicht von der TOC.

[Entwicklung und Tests](Development.md) enthält den reproduzierbaren LuaLS-Aufruf.
Die Diagnosekonfiguration des Editors mitprüfen; ein isolierter CLI-Lauf kann
sonst andere Ergebnisse als VS Code liefern.

## Fehlerbericht für einen Client

Für eine konkrete Fehlersuche helfen die Ausgabe von `/declarus info`, der
vollständige Lua-Fehler, die aktive Playground-Seite und die auslösende Aktion.
Zusätzlich nennen, ob das Problem bei einem UI-Reload, beim Öffnen oder erst nach
einem Update auftritt. Erfolgreiche Mocktests sind kein Ersatz für diese Client-
Beobachtung. Ein auf Classic funktionierender Aufbau garantiert nicht dieselbe
Darstellung auf Forever.
