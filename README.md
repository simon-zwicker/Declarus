# Declarus

Deklarative WoW-UI-Library für Lua 5.1 / LuaJIT. Beschreibungen werden mit
Measure → Arrange → Render in WoW-Frames umgesetzt. Keine externen Laufzeit-Abhängigkeiten.

## Basics

```lua
local UI = Declarus.UI
local view = UI.VStack({
    UI.Text("Einstellungen"):font("Fonts\\FRIZQT__.TTF", "OUTLINE"):fontSize(20):padding(8),
    UI.View():size(32, 32):texture("Interface\\Icons\\INV_Misc_QuestionMark"),
    UI.Button("Speichern", function(button) print(button) end),
    UI.TextField("Profil", function(text) print(text) end),
    UI.Slider(50, 0, 100, 5, function(value) print(value) end),
    UI.Toggle(true, function(enabled) print(enabled) end),
    UI.Dropdown({"Standard", "Raid"}, "Standard", function(profile) print(profile) end),
}):spacing(8):padding(12)

local handle = UI.Mount(UI.ScrollView(view):size(300, 240), UIParent)
-- Neue Beschreibung explizit rendern:
handle:Update(UI.Text("Gespeichert"))
-- Beim Schließen:
handle:Unmount()
```

`Text` und Controls unterstützen `:font(path, flags)` und `:fontSize(size)`.
Textmessung und Rendering verwenden denselben FontResolver (Standard: FRIZQT, 16).
`Text` berücksichtigt Padding und Foreground-Farbe. `:texture(pathOrFileID)` legt
auf jeder View eine gestreckte ARTWORK-Textur über einen optionalen Hintergrund.
Größe explizit setzen; Texturen besitzen keine automatische intrinsische Größe.

Controls haben Standardgrößen und einen dunklen Hintergrund; View-Modifier können
diese überschreiben. Buttons liefern den WoW-Mausbutton an ihren Callback.
TextField meldet Benutzereingaben, bestätigt mit Enter und verliert mit Escape den
Fokus. Slider rundet relativ zum Minimum auf die Schrittweite und begrenzt Werte.
Toggle meldet boolean. Dropdown akzeptiert eine nicht leere String-Liste und einen
darin enthaltenen Anfangswert; sein einfacher aufklappbarer Menübereich lässt
sich per erneutem Klick schließen. Initialisierung löst keine onChange-Callbacks aus.

## Dynamische Updates und Grenzen

Control-Eingaben aktualisieren `view.properties.value` und rufen den Callback auf.
Für abhängige Texte oder Layouts im Callback eine neue Beschreibung erstellen und
`handle:Update(view)` aufrufen. Es gibt keine implizite Reaktivität.

Updates ersetzen den ganzen gerenderten Baum. Fokus und Scrollposition werden
zurückgesetzt. Unmount entfernt Handler, registrierte Events und Elternbeziehungen;
er ist mehrfach aufrufbar. Nach Unmount sind Updates unzulässig. WoW kann Frames
nicht zerstören: häufige Updates erzeugen zusätzliche Frames; diese erste Version
ist für gelegentliche Einstellungsänderungen vorgesehen, nicht für Updates pro Frame.

ScrollView scrollt vertikal per Mausrad und begrenzt den Offset. Seine Größe ist
die Viewport-Größe; Content benötigt intrinsische oder explizite Höhe. Kein sichtbarer
Scrollbar, kein horizontaler Scrollmodus. Dropdown hat weder Tastaturnavigation
noch automatisches Schließen durch Außenklick. Keine geschützten Aktionsbuttons.

## Prüfung

Vom Repository-Verzeichnis: `luajit Tests/Run.lua`.
Die WoW-Mocks prüfen Layout, Rendering, Eingaben und Mount-Lebenszyklus.
LuaLS ist auf Lua 5.1 konfiguriert; öffentliche APIs sind annotiert.
LuaLS kann auch aus einer vorhandenen VS-Code-Lua-Erweiterung gestartet werden.
Für einen vollständigen Lauf einschließlich Hinweisen vom Repository-Verzeichnis:

```sh
"${LUA_LANGUAGE_SERVER:-lua-language-server}" --check=. --checklevel=Hint --logpath=/tmp/declarus-luals
```

Falls das Programm nicht im Suchpfad liegt, `LUA_LANGUAGE_SERVER` auf die ausführbare
Datei setzen. `Types/WoW.lua` beschreibt den von Declarus verwendeten WoW-API-Ausschnitt
nur für den Editor; diese Datei gehört nicht in die TOC und wird nicht ausgeführt.
Mock-spezifische Daten bleiben in den Testtypen. Geprüft mit LuaLS 3.19.2:
keine Diagnosen bei `--checklevel=Hint`, alle 103 LuaJIT-Tests erfolgreich.

Noch nicht im WoW-Client abgenommen: Darstellung der Controls, Font-Dateien und
Flags, EditBox-Fokus, Slider-Dragging, Checkbox-Klicks, Dropdown-Ebenen und Scroll-Clipping.
PoisonFlow wurde nicht verändert; konkrete Integrationsanforderungen bleiben dort
später separat zu prüfen. Lokale Entwicklungsregeln und Roadmap stehen in AGENTS.md.
