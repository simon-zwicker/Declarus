# Declarus

Deklarative UI-Library für aktuelle offizielle World-of-Warcraft-Clients.
Lua 5.1 / LuaJIT, gemeinsame View-API und LuaLS-Typannotationen.
Keine externen Laufzeit-Abhängigkeiten. Keine Unterstützung für Privatserver oder
historische Original-Clients.

## Dokumentation

Der zentrale Einstieg ist **[Docs/README.md](Docs/README.md)**. Die Dokumentation
beschreibt Verwendung, Parameter, Defaults, erwartete Ergebnisse und die Grenzen
des aktuell implementierten Stands.

| Einstieg | Thema |
| --- | --- |
| [Schnellstart](Docs/GettingStarted.md) | bereitstellen, einbinden, mounten, aktualisieren und schließen |
| [Views und Modifier](Docs/ViewsAndModifiers.md) | Größe, Padding, Farben, Sichtbarkeit und gemeinsame Eigenschaften |
| [Layout](Docs/Layout.md) | Stacks, Wrap/Fill, Alignment und berechnete Größen |
| [Text und Localization](Docs/TextAndLocalization.md) | Fonts, Übersetzungen und Fallbacks |
| [Controls](Docs/Controls.md) | Button, TextField, Slider, Toggle und Dropdown |
| [Texturen](Docs/Textures.md) | Ausschnitt, Spiegelung, Tönung, Layer und Sublevel |
| [Farbverläufe](Docs/Gradients.md) | horizontale/vertikale Verläufe, Alpha und Bildfilter |
| [ScrollView](Docs/ScrollView.md) | Inhaltsgröße, Viewport und vertikales Scrollen |
| [Zustand und Lifecycle](Docs/StateAndLifecycle.md) | explizite Updates, getrennte Mounts, Fokus und Cleanup |
| [Praxisrezepte](Docs/Recipes.md) | kombinierbare, vollständige Anwendungsbeispiele |
| [API-Referenz](Docs/API.md) | sämtliche öffentlichen Signaturen und Konstanten |
| [Fehlersuche](Docs/Troubleshooting.md) | typische Symptome und passende Lösungen |
| [Entwicklung und Tests](Docs/Development.md) | Architektur, TOC, LuaJIT und LuaLS |
| [Playground](Docs/Playground.md) | vollständige interaktive Demo |
| [Client-Kompatibilität](Docs/ClientCompatibility.md) | Zielmatrix und tatsächlicher Prüfstand |

## Erstes Beispiel

Der Code läuft in einem WoW-Addon, nachdem Declarus geladen wurde:

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.Text("Hallo Declarus"):fontSize(22),
    UI.Text("Text, Layout und Button in einer Beschreibung."),
    UI.Button("Ausprobieren", function(mouseButton)
        print("Declarus:", mouseButton)
    end):width(180),
}):spacing(10):padding(16):backgroundColor(UI.Color.RGB(20, 26, 35))

local handle = UI.Mount(view, UIParent)
```

**Ergebnis:** Ein zentrierter Bereich mit zwei Textzeilen und einem Button.
Die View wird zunächst als Lua-Beschreibung erstellt und erst durch Mount sichtbar.
Den Handle für spätere `handle:Update(view)`- und `handle:Unmount()`-Aufrufe behalten.
Declarus aktualisiert geänderte Lua-Variablen nicht automatisch.

## Playground

- `/declarus`: die sechs Bereiche Übersicht, Layouts, Typografie, Darstellung,
  Controls und Updates öffnen.
- `/declarus info`: Client, Version, Build, Interface und Sprache ausgeben.
- `/declarus reset`: Demo-Zustand zurücksetzen.
- `/declarus hide`: alle aktiven Playground-Mounts schließen.

Eine separate Vorschau und Ereignisanzeige reagieren auf Eingaben, ohne die
aktive Seite zu ersetzen. Beim Addon-Start öffnet sich keine Demo automatisch.

## Aktueller Stand

Der gemeinsame Code zielt auf Retail, Forever und die aktuellen offiziellen
Classic-Zweige einschließlich regionalem Titan Reforged. Der Nutzer hat einen
funktionierenden Classic-Aufbau zurückgemeldet. Eine vollständige Ingame-Abnahme
aller Beispiele je Client ist damit nicht abgeschlossen; Forever bleibt ohne
echten Test unbestätigt.

Updates ersetzen den ganzen Teilbaum eines Mounts und erhalten darin keinen
Fokus oder Scrollzustand. Frames werden noch nicht gepoolt. Automatischer Text-
umbruch, proportionaler Bildzuschnitt, horizontales Scrollen, sichtbare Scrollbars,
Dropdown-Tastaturnavigation und geschützte Aktionsbuttons sind nicht implementiert.

## Prüfung

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
"${LUA_LANGUAGE_SERVER:-lua-language-server}" --check=. --checklevel=Hint --logpath=/tmp/declarus-luals
```

Aktueller automatisierter Stand: **131 Tests pro Metadatenprofil**, sechs Profile;
LuaLS 3.19.2 ohne Diagnosen einschließlich Hint. Die Matrix verwendet gemeinsame
API-Mocks und keine vollständigen Client-Emulationen. LuaLS-Konfiguration aus
`.luarc.json` und lokalen VS-Code-Einstellungen gemeinsam betrachten.

Projektregeln und Roadmap: [AGENTS.md](AGENTS.md). PoisonFlow wird in diesem
Repository-Auftrag nicht verändert; alle Commits bleiben lokal.
