# Praxisrezepte

[Übersicht](README.md) · [Controls](Controls.md) · [Lifecycle](StateAndLifecycle.md)

Die folgenden Beispiele sind unabhängig. Sie verwenden nur die bisherige
öffentliche Declarus-API und übliche WoW-Elternframes. Zustand bleibt jeweils in
Lua-Variablen; dauerhafte Speicherung ist nicht Teil des Beispiels.

## Einheitlich gestaltete Karten

```lua
local UI = Declarus.UI

local function card(title, children)
    local content = {
        UI.Text(title):fontSize(20):foregroundColor(UI.Color.RGB(90, 195, 240)),
    }
    for _, child in ipairs(children) do
        content[#content + 1] = child
    end
    return UI.VStack(content)
        :width(UI.Size.Fill)
        :spacing(10)
        :padding(14)
        :backgroundColor(UI.Color.RGB(25, 32, 43))
end

local view = UI.VStack({
    card("Allgemein", {UI.Text("Eine wiederverwendbare Karte.")}),
    card("Darstellung", {UI.Text("Gleiche Abstände und Farben.")}),
}):width(400):spacing(12)

UI.Mount(view, UIParent)
```

**Ergebnis:** Zwei gleich breite Karten in einer 400 breiten Spalte. Der Abstand
zwischen den Karten ist 12; in jeder Karte gelten 14 Padding und 10 Spacing.
Die Hilfsfunktion ist normales Lua und keine zusätzliche Declarus-Komponente.
Jeder Aufruf baut neue View-Objekte, damit sich Änderungen nicht unbeabsichtigt
auf mehrere Karten auswirken.

## Formular mit explizitem Übernehmen

```lua
local UI = Declarus.UI
local draft = {name = "Standard", enabled = true, scale = 100, mode = "Solo"}
local saved = {name = "Standard", enabled = true, scale = 100, mode = "Solo"}
local handle
local message = "Noch keine Änderungen übernommen."

local function buildForm()
    return UI.VStack({
        UI.Text("Beispiel-Einstellungen"):fontSize(22),
        UI.Text("Name"),
        UI.TextField(draft.name, function(value) draft.name = value end):width(300),
        UI.HStack({
            UI.Toggle(draft.enabled, function(value) draft.enabled = value end),
            UI.Text("Aktiv"),
        }):spacing(8):alignment(UI.Alignment.Center),
        UI.Text("Skalierung: 50 bis 150, Schrittweite 5"),
        UI.Slider(draft.scale, 50, 150, 5, function(value) draft.scale = value end):width(300),
        UI.Dropdown({"Solo", "Gruppe", "Raid"}, draft.mode, function(value)
            draft.mode = value
        end),
        UI.View():height(90), -- Platz für das aufgeklappte Menü
        UI.Button("Übernehmen", function()
            saved.name = draft.name
            saved.enabled = draft.enabled
            saved.scale = draft.scale
            saved.mode = draft.mode
            message = saved.name .. " | " .. saved.mode .. " | " .. saved.scale
            handle:Update(buildForm())
        end):width(180),
        UI.Text(message):fontSize(14),
    }):spacing(10):padding(16):width(400)
        :backgroundColor(UI.Color.RGB(20, 26, 35))
end

handle = UI.Mount(buildForm(), UIParent)
```

**Ergebnis:** Eingaben verändern zunächst nur `draft`. Tippen und Slider-Änderungen
bauen das Formular nicht neu auf. Erst „Übernehmen“ kopiert die Werte nach `saved`
und zeigt eine neue Zusammenfassung. Dabei wird das Formular absichtlich ersetzt
und verliert seinen bisherigen Fokus. `saved` ist hier eine normale Tabelle,
keine automatisch persistierte SavedVariable.

Für sofortige Vorschau ohne Seitenersetzung das Muster mit getrennten Mounts
unter [Lifecycle](StateAndLifecycle.md) verwenden.

## Bild, Text und Button in einer Zeile

```lua
local UI = Declarus.UI
local view = UI.HStack({
    UI.View():size(48, 48)
        :texture(134400)
        :texCoords(0.08, 0.92, 0.08, 0.92),
    UI.VStack({
        UI.Text("Profil auswählen"):fontSize(18),
        UI.Text("Ein Icon neben zwei Textzeilen."):fontSize(13),
    }):spacing(4):width(UI.Size.Fill),
    UI.Button("Öffnen", function() print("Öffnen") end):width(100),
}):width(600):padding(12):spacing(12):alignment(UI.Alignment.Center)
    :backgroundColor(UI.Color.RGB(25, 32, 43))

UI.Mount(view, UIParent)
```

**Ergebnis:** Links ein beschnittenes Icon, in der Mitte zwei Textzeilen und rechts
ein Button. Die mittlere Spalte nimmt den restlichen Platz ein. Alle drei Gruppen
sind vertikal zentriert. Der Button startet nur den Callback; eine konkrete
Profilansicht muss das aufrufende Addon implementieren.

## Transparenter, texturierter Button

```lua
local UI = Declarus.UI
local view = UI.Button("Bestätigen", function() print("Bestätigt") end)
    :size(220, 40)
    :padding(UI.Edge.Left, 12)
    :padding(UI.Edge.Top, 10)
    :texture("Interface\\Buttons\\WHITE8X8")
    :textureTint(UI.Color.RGBA(30, 100, 150, 0.8))
    :foregroundColor(UI.Color.RGB(255, 255, 255))

UI.Mount(view, UIParent)
```

**Ergebnis:** Ein blauer, zu 80 % deckender Textur-Hintergrund mit weißer
Beschriftung. Das Alpha der Texturtönung macht nicht automatisch den Text
transparent. Ein Layer-Override ist nicht nötig: BORDER liegt hinter OVERLAY.
Der voreingestellte dunkle Button-Hintergrund bleibt zusätzlich vorhanden.

## Datenliste mit optionalen Zeilen

```lua
local UI = Declarus.UI
local rows = {
    {name = "Alpha", visible = true},
    {name = "Beta", visible = false},
    {name = "Gamma", visible = true},
}

local children = {}
for _, row in ipairs(rows) do
    if row.visible then
        children[#children + 1] = UI.Text(row.name):padding(8)
    end
end

local view = UI.ScrollView(
    UI.VStack(children):spacing(4):width(UI.Size.Fill)
):size(320, 160)
UI.Mount(view, UIParent)
```

**Ergebnis:** Nur Alpha und Gamma sind Teil des Layouts. Beta belegt keinen Platz,
weil keine View dafür erzeugt wurde. Das unterscheidet dieses Muster von
`:visible(false)`, bei dem eine vorhandene View weiter Platz beansprucht.
Bei späteren Datenänderungen die Liste neu bauen und ihren Mount aktualisieren.
