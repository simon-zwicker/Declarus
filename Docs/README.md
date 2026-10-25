# Declarus – Dokumentation

Declarus beschreibt WoW-Oberflächen als Lua-Objekte und erzeugt daraus native
Frames. Diese Dokumentation beschreibt den **implementierten Stand**, einschließlich
seiner Grenzen. Alle Beispiele sind für Lua 5.1 und aktuelle offizielle
Blizzard-Clients gedacht. Privatserver und historische Original-Clients gehören
nicht zum Projektziel.

## Einstieg und Lesereihenfolge

| Dokument | Inhalt |
| --- | --- |
| [Schnellstart](GettingStarted.md) | Installation, Einbindung, erstes sichtbares UI und erwartetes Ergebnis |
| [Views und Modifier](ViewsAndModifiers.md) | gemeinsame Eigenschaften, Farben, Padding, Sichtbarkeit und Vererbung |
| [Layout](Layout.md) | HStack/VStack, Wrap/Fill, Größenberechnung, Alignment und konkrete Maße |
| [Text und Localization](TextAndLocalization.md) | Fonts, Textmessung, Übersetzungen und Fallbacks |
| [Controls](Controls.md) | Button, TextField, Slider, Toggle und Dropdown mit Callback-Beispielen |
| [Texturen](Textures.md) | FileDataID, Ausschnitt, Spiegelung, Tönung und Zeichenebenen |
| [ScrollView](ScrollView.md) | Viewport, Inhaltsgröße, Padding und Scrollgrenzen |
| [Zustand und Lifecycle](StateAndLifecycle.md) | Mount, Update, Unmount und unabhängige UI-Bereiche |
| [Praxisrezepte](Recipes.md) | vollständige Beispiele für Einstellungen, Listen und Komponentenkombinationen |
| [API-Referenz](API.md) | öffentliche Funktionen, Signaturen, Defaults und Konstanten |
| [Fehlersuche](Troubleshooting.md) | Symptome, Ursachen und passende Korrekturen |
| [Entwicklung und Tests](Development.md) | TOC, Architektur, Tests, LuaLS und Beitragsregeln |
| [Playground](Playground.md) | alle Beispielseiten und deren Bedienung im Client |
| [Client-Kompatibilität](ClientCompatibility.md) | Zielmatrix, Quellen und Stand der Ingame-Abnahme |

## Beispiele lesen

Die Lua-Beispiele laufen **innerhalb eines geladenen WoW-Addons**, nachdem Declarus
geladen wurde. Sie sind keine eigenständigen Programme für den normalen Lua-
Interpreter. `UIParent` und `CreateFrame` stammen aus WoW. Beispiele ohne eigenes
`local UI` setzen diese lokale Abkürzung voraus:

```lua
local UI = Declarus.UI
```

Ein Beispiel, das nur `local view = ...` erzeugt, beschreibt zunächst ein UI.
Sichtbar wird es durch `UI.Mount(view, UIParent)`. Mehrere Beispiele auf einer Seite
sind unabhängig, sofern sie nicht ausdrücklich als Fortsetzung bezeichnet werden.

**Ergebnis** beschreibt das aus dem Code erwartete Verhalten. Exakte Textmaße
hängen von Client-Schrift und Sprache ab. Zahlenbeispiele mit rein geometrischen
Views sind dagegen unabhängig von der Schrift. Eine Beschreibung hier ist keine
Zertifizierung der Darstellung auf jedem Client.

## Wichtige Grundregeln

- Konstruktoren wie `UI.Text(...)` erstellen Beschreibungen, noch keine Frames.
- Modifier geben dasselbe Objekt zurück und verändern dessen Eigenschaften.
- Mount-Updates sind explizit. Eine geänderte Lua-Variable aktualisiert kein UI.
- Texte und Bilder bestimmen keine automatische Zeilenumbruch-/Cover-Logik.
- Stacks ordnen Kinder an; `UI.View()` ist kein frei verwendbarer Kinder-Container.
- Sichtbarkeit entfernt keinen Layoutplatz. Strukturänderungen benötigen einen neuen Baum.
- Die Library speichert Einstellungen nicht selbst dauerhaft.

Für den praktischen Rundgang: `/declarus` öffnen und die sechs Bereiche ausprobieren.
