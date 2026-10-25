# Entwicklung und Tests

[Übersicht](README.md) · [Client-Kompatibilität](ClientCompatibility.md)

## Verbindliche Regeln

[AGENTS.md](../AGENTS.md) enthält die Projektregeln. Insbesondere: bestehende
Änderungen schützen, nur eigene Änderungen explizit stagen, Lua 5.1/LuaJIT und
LuaLS-Annotationen beibehalten, PoisonFlow nicht verändern und abgeschlossene
Pakete lokal committen. Keine Remote-Git-Aktionen, insbesondere kein Push,
Fetch oder Pull. Unterstützungsziel sind ausschließlich aktuelle offizielle
Blizzard-Clients, keine Privatserver oder historischen Original-Clients.

## Dateistruktur und Zuständigkeiten

| Bereich | Aufgabe |
| --- | --- |
| `Core/Init.lua` | globaler Declarus-Namespace |
| `Core/Client.lua` | Diagnose und gemeinsame Client-Grenze |
| `Core/Localization.lua` | Übersetzungsinstanzen und Fallbacks |
| `UI/Types/` | Color, Size, Edge, Alignment |
| `UI/Core/` | View- und TextView-Prototypen, gemeinsame Modifier |
| `UI/Components/` | öffentliche Konstruktoren für Views/Text/Controls |
| `UI/Layout/` | Stack-Prototyp und HStack/VStack |
| `UI/Typography/` | FontResolver und intrinsische Textmessung |
| `UI/Engine/` | Localization-Auflösung, Measure, Arrange, Render und native Controls |
| `UI/Mount.lua` | öffentlicher Mount-Lifecycle |
| `Debug/Playground.lua` | optionaler gemeinsamer Ingame-Playground |
| `Types/WoW.lua` | Editor-Metadaten für den verwendeten WoW-API-Ausschnitt |
| `Tests/` | Runner, Mock-Umgebung und Verhaltensprüfungen |
| `Docs/` | Verwendung, Referenz und überprüfbare Beispiele |

## Datenfluss

```text
Lua-Anwendungszustand
        ↓ eigene buildView()-Funktion
View-Beschreibung mit properties und children
        ↓ Measure: Breite/Höhe der Elemente und Kinder
        ↓ Arrange: Positionen, Spacing, Padding, Alignment
        ↓ Render: native WoW-Frames und Control-Handler
MountHandle
        ↓ Update(view) oder Unmount()
```

Measure/Arrange/Render getrennt halten. Ein neuer Modifier braucht bei Bedarf
eine Eigenschaft/Annotation, einen Renderer-Verbrauch und einen aussagekräftigen
Test. Eine Eigenschaft nur an der View zu speichern macht sie noch nicht sichtbar.

## TOC als Ladereihenfolge

`Declarus.toc` ist die gemeinsame Produktions-Dateiliste. Neue Laufzeitdateien
müssen dort an der richtigen Stelle stehen. `Tests/Run.lua` lädt dieselbe TOC statt
einer manuell duplizierten Liste. Editor-Dateien wie `Types/WoW.lua` gehören nicht
in die TOC; sonst würden die Metadaten globale Client-Funktionen überschreiben.

Der Playground wird beim Laden registriert, aber erst durch `/declarus` geöffnet.
Neue Module sollen beim Laden ebenfalls keine ungefragten Demo-Fenster erzeugen.

## LuaJIT-Suite

Vom Repository-Verzeichnis:

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
```

**Ergebnis:** Der erste Aufruf führt alle Suiten aus. Der zweite startet dieselbe
Suite in separaten LuaJIT-Prozessen mit sechs Client-Metadatenprofilen. Stand dieser
Dokumentation: 131 erfolgreiche Tests pro Profil, keine Fehler.

Die Profile variieren Kennungen/Metadaten. Sie emulieren keine echten Clients
und belegen keine vollständige Gleichheit ihrer nativen APIs oder Darstellung.
Client-Textmaße werden im Mock vereinfacht nachgebildet; auf exakte echte
Schriftbreiten deshalb nicht aus Mock-Ergebnissen schließen.

## LuaLS

```sh
"${LUA_LANGUAGE_SERVER:-lua-language-server}" --check=. --checklevel=Hint --logpath=/tmp/declarus-luals
```

**Ergebnis:** Vollständige Diagnose einschließlich Hinweisen. Liegt der Server
nicht im Suchpfad, `LUA_LANGUAGE_SERVER` auf die ausführbare Datei setzen. Auf dem
Entwicklungs-Mac ist er unter anderem in der installierten VS-Code-Lua-Erweiterung
vorhanden; der konkrete Erweiterungspfad ist versionsabhängig und gehört nicht
fest in den Projektcode.

Die Konfiguration liegt in `.luarc.json`. `.vscode/settings.json` bei Abweichungen
mitprüfen. Die Standardbibliotheken bleiben aktiviert. `Types/WoW.lua` beschreibt
nur den verwendeten API-Umfang; bei neuen nativen Aufrufen die Typdefinitionen
gezielt ergänzen. Mock-spezifische Felder gehören in die Mocktypen und nicht in
die Produktions-Frame-Typen. Warnungen nicht pauschal abschalten, um einen grünen
Lauf zu erreichen.

## Lua-5.1-Verträglichkeit

Keine neuere Lua-Syntax oder ausschließlich in späteren Lua-Versionen vorhandene
Standardfunktionen als Laufzeitvoraussetzung einführen. Beispiele sind `goto`,
Integer-Division mit `//` oder ein unbedingtes `table.unpack`. Der vorhandene Code
benutzt unter anderem das Lua-5.1-`unpack`. Client-spezifische Erweiterungen nur
nach belegter Verfügbarkeit und mit passender zentraler Behandlung einsetzen.

## Was Ingame geprüft werden muss

Darstellung und native Eingabe bleiben reale Client-Aufgaben: Fonts und Sprachen,
Textur-Layer, Alpha, Checkbox-Klicks, Slider-Dragging, Dropdown-Menüs, Clipping,
Fokus, UI-Skalierung und wiederholtes Öffnen/Schließen. Der Nutzer hat einen
funktionierenden Classic-Aufbau zurückgemeldet; eine detaillierte Abnahme aller
aktuellen Beispiele auf jedem Zielclient ist damit nicht abgeschlossen.

Die [Prüfmatrix](ClientCompatibility.md) trennt Zielmetadaten, automatisierte
Prüfung und echte Ingame-Abnahme. Forever bleibt bis zu einem tatsächlichen Test
im offiziellen Client unbestätigt. Keine Aussage „auf allen Clients getestet“ aus
einem erfolgreichen Matrixlauf ableiten.
