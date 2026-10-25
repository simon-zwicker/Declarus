# Declarus Playground

Der Playground zeigt die bisher implementierte UI-API in sechs navigierbaren
Bereichen. Er wird mit derselben Library auf den offiziellen Client-Zielen
betrieben. Kein automatisches Oeffnen beim Addon-Start, keine Abhaengigkeit von
PoisonFlow, keine gespeicherten Einstellungen und kein Zugriff auf Kampfwerte.

## Start und Bedienung

- `/declarus` oder `/declarus demo`: oeffnen bzw. die aktive Instanz ersetzen.
- `/declarus info`: Client, Version, Build, Interface und Sprache im Chat ausgeben.
- `/declarus reset`: Demo-Werte zuruecksetzen, ohne den Playground erst oeffnen zu muessen.
- `/declarus hide` oder `Schliessen`: alle aktiven Mounts entfernen.

Der Rahmen ist 860 x 640 UI-Einheiten gross und zentriert. Oben stehen Navigation,
Client-Informationen, Reset und Schliessen. Die mittlere Seite scrollt per Mausrad;
Vorschau und die letzten beiden Ereignisse bleiben darunter sichtbar.

Die Werte bleiben beim Navigieren und Wiedereroeffnen innerhalb derselben
UI-Sitzung erhalten. Reset setzt sie zurueck; ein UI-Reload startet frisch.
Es gibt keine SavedVariables. Das Fenster besitzt noch keine Drag-/Resize-Funktion.

## Bereiche und API-Abdeckung

| Bereich | Beispiele |
| --- | --- |
| Uebersicht | Komponentenverzeichnis, Client-Diagnose, Standardschrift, Grenzen und Bedienhinweise |
| Layouts | verschachtelte HStack/VStack, Spacing, fixe Groessen, Width/Height/Size, Wrap, horizontales und vertikales Fill |
| Layouts | HStack: Top/Center/Bottom/Stretch; VStack: Left/Center/Right/Stretch |
| Typografie | Text, FontSize 12/16/24, expliziter Font mit OUTLINE, ForegroundColor |
| Typografie | Padding All/Horizontal/Vertical/Top/Bottom/Left/Right, kumulatives Padding |
| Typografie | Localization-Namespace, enUS/deDE, aktiver Locale-Wert, englischer Fallback und fehlender Key, lokalisierter Button |
| Darstellung | View-Texture per Dateipfad und numerischer File-ID, gestrecktes Icon, Texture plus BackgroundColor |
| Darstellung | RGB/RGBA, View-Opacity und vererbte Stack-Opacity, Visible true/false mit reserviertem Layoutplatz |
| Controls | Button mit linker/rechter Maustaste, TextField, ganzzahliger und dezimaler Slider, Toggle, Dropdown |
| Updates | explizite Teilbaum-Updates, dynamische Kinder von 0 bis 12, neues Measure/Arrange, gezieltes Unmount/Remount |
| Alle Seiten | ScrollView, getrennte Mounts, Cleanup bei Navigation und Schliessen |

Stretch-Beispiele verwenden intrinsische Querabmessungen, weil explizite fixe
Groessen in der bestehenden Layout-Engine Vorrang vor Stretch haben.

## Live-Vorschau und Ereignisse

Im Bereich Controls beeinflussen Eingaben die unten fixierte Vorschau:

- TextField: Vorschautext; Enter und Escape geben den Fokus frei.
- Erster Slider: Balkenbreite, 0–100 in Fuenferschritten.
- Zweiter Slider: Balken-Opacity, 0–1 in 0.1-Schritten.
- Toggle: Balken-Sichtbarkeit; der reservierte Platz bleibt bestehen.
- Dropdown: Profilname Standard/Raid/Solo.
- Button: Mausbutton und Klickzaehler im Ereignisbereich.

Vorschau und Ereignisse haben eigene Mounts. Ihr Update ersetzt die aktive Seite
nicht; Eingabefokus und Scrollposition bleiben deshalb erhalten. Lange Eingaben
werden nur fuer die Anzeige verkuerzt, ohne UTF-8-Zeichen zu zerschneiden. Das
TextField und der Demo-Zustand behalten den vollstaendigen eingegebenen Text.

Navigation, Reset, dynamische Kinder und die Sichtbarkeits-Schaltflaeche bauen die
jeweilige Seite neu auf; dabei wird deren Scrollposition zurueckgesetzt. Das ist
ein explizites Beispiel fuer das bestehende Mount-Update-Verhalten. `Vorschau neu`
zeigt ein gezieltes Unmount/Remount, ohne Seite oder Eingaben zu ersetzen.

Dropdowns bleiben mausbedient. Falls das Menue am unteren Rand abgeschnitten wird,
den Dropdown in den oberen Bereich des Scrollfensters scrollen. Es gibt aktuell
keine Tastaturnavigation, keinen Aussenklick zum Schliessen und keine Scrollbar.
Die Demo fuegt diese noch nicht implementierten Library-Funktionen nicht hinzu.

## Pruefung und Grenzen

Automatisch geprueft werden alle Seiten und Scrollgrenzen, wirkliche Alignment-
Positionen, Eingaben ohne Seitenersetzung, gerundete Slider-Werte, Dropdown und
Toggle, Unicode-Text, Localization-Fallbacks, dynamische Kinder, Reset und Cleanup.

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
```

Der Matrixlauf verwendet Metadatenprofile und denselben API-Mock. Er ersetzt keine
visuelle Ingame-Abnahme. Auf Retail und Classic bitte alle sechs Bereiche testen;
Forever bleibt bis zu einem echten Client-Test unbestaetigt. Font-Darstellung,
Frame-Ebenen, Menue-Clipping, Checkbox-Klicks, Slider-Dragging und UI-Skalierung
muessen im jeweiligen Client betrachtet werden.
