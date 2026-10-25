# Zustand, Updates und Lifecycle

[Übersicht](README.md) · [Controls](Controls.md) · [Praxisrezepte](Recipes.md)

## Beschreibungen und native Frames trennen

Die View-Objekte enthalten `kind`, `properties` und `children`. Ein Konstruktor
baut zunächst nur eine Beschreibung. Beim Mounten folgen Messung, Anordnung und
Erzeugung nativer Frames. Eine danach veränderte Beschreibung ist nicht von selbst
mit ihren Frames synchronisiert.

```lua
local UI = Declarus.UI
local view = UI.Text("Hallo")
local handle = UI.Mount(view, UIParent)

view:fontSize(24)
-- Bisher sichtbar: weiterhin die ursprüngliche Schriftgröße.
handle:Update(view)
-- Jetzt sichtbar: 24.
```

**Ergebnis:** Erst das explizite Update erzeugt die neue Darstellung.
Für komplexere Zustände ist eine Funktion, die aus Lua-Daten einen frischen Baum
baut, meist übersichtlicher als viele direkte Eigenschaftsänderungen.

## MountHandle

| Mitglied | Verwendung |
| --- | --- |
| `handle.frame` | aktuell gerenderter Wurzel-Frame des Mounts |
| `handle:Update(view)` | denselben Mount mit einer neuen Beschreibung darstellen |
| `handle:Unmount()` | Mount ausblenden und aufräumen |

`UI.Mount(view, parent)` braucht beide Argumente. Der interne Host wird im Eltern-
Frame zentriert; seine Größe folgt der gemessenen Wurzel. Die Elterngröße ist
aktuell keine automatische Fill-Vorgabe für die Wurzel.

`handle.frame` wird bei Updates ersetzt. Einen alten Frame-Verweis deshalb nicht
als dauerhafte Referenz auf ein weiterhin aktives Element behandeln. Direkte
manuelle Änderungen an Frames können durch das nächste Update verloren gehen.

## Vollständiges Zähler-Beispiel

```lua
local UI = Declarus.UI
local count = 0
local handle

local function buildView()
    return UI.VStack({
        UI.Text("Klicks: " .. count):fontSize(20),
        UI.Button("Erhöhen", function()
            count = count + 1
            handle:Update(buildView())
        end):width(160),
    }):spacing(10):padding(14)
end

handle = UI.Mount(buildView(), UIParent)
```

**Ergebnis:** Der Text startet bei 0 und steigt bei jedem Klick. Der Callback kann
diesen Mount ersetzen, obwohl er aus einem Button des bisherigen Baums aufgerufen
wurde. Die Lua-Variable `count` lebt außerhalb des gerenderten Baums weiter.

## Fokus und Scrollposition

Ein Update ersetzt den gesamten Baum **dieses Mounts**, nicht nur geänderte
Eigenschaften. Das ist für gelegentliche Einstellungsänderungen geeignet.
Ein TextField oder eine ScrollView darin werden dabei neu erstellt und verlieren
Fokus bzw. Scrollposition. Jeden Tastendruck durch ein Update des gesamten
Formulars zu behandeln, ist daher meist ungeeignet.

Eine praktikable Lösung sind getrennte Mounts für Eingaben und Vorschau:

```lua
local UI = Declarus.UI
local state = {name = "Standard"}

local container = CreateFrame("Frame", nil, UIParent)
container:SetSize(400, 160)
container:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

local inputRegion = CreateFrame("Frame", nil, container)
inputRegion:SetSize(360, 40)
inputRegion:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -20)

local previewRegion = CreateFrame("Frame", nil, container)
previewRegion:SetSize(360, 40)
previewRegion:SetPoint("TOPLEFT", container, "TOPLEFT", 20, -90)

local preview = UI.Mount(UI.Text("Profil: " .. state.name), previewRegion)
local input = UI.Mount(UI.TextField(state.name, function(value)
    state.name = value
    preview:Update(UI.Text("Profil: " .. value))
end):width(300), inputRegion)

local function closeEditor()
    input:Unmount()
    preview:Unmount()
    container:Hide()
    container:SetParent(nil)
end
```

**Ergebnis:** Tippen verändert die Vorschau, aber der Eingabe-Mount bleibt
unverändert. Sein Fokus bleibt erhalten. Die nativen Elternbereiche definieren
hier lediglich die Platzierung; alle sichtbaren Inhalte erzeugt Declarus.
Beim Schließen des eigenen Fensters `closeEditor()` aufrufen.

Auch dieses Muster erzeugt bei jeder Vorschauänderung neue Frames. Es zeigt
gezielte Updates, aber noch keine Wiederverwendung oder auf hohe Frequenzen
optimierte Reconciliation.

## Dynamische Kinder

```lua
local UI = Declarus.UI
local entries = {"Alpha", "Beta"}
local handle

local function buildList()
    local children = {}
    for _, entry in ipairs(entries) do
        children[#children + 1] = UI.Text(entry)
    end
    children[#children + 1] = UI.Button("Eintrag hinzufügen", function()
        entries[#entries + 1] = "Eintrag " .. (#entries + 1)
        handle:Update(buildList())
    end):width(220)
    return UI.VStack(children):spacing(8):padding(12)
end

handle = UI.Mount(buildList(), UIParent)
```

**Ergebnis:** Der Button ergänzt einen weiteren Text. Anzahl, Höhe und Positionen
werden neu berechnet. Die Liste verwendet dichte Lua-Arrays; entfernte Elemente
mit `table.remove` bzw. durch eine neu aufgebaute Liste behandeln.
Es gibt noch keine Key-/Diff-/Observable-/Binding-API.

## Unmount und Wiederöffnen

`Unmount()` versteckt die gerenderten Frames, entfernt die von Declarus
installierten Event-Scripts, meldet deren Frame-Events ab und löst die Eltern-
beziehungen. Manuell zusätzliche Scripts oder andere Ressourcen außerhalb des
Declarus-Lifecycles bleiben Verantwortung des aufrufenden Addons.

Mehrfaches Unmount ist erlaubt; Update nach Unmount wird abgewiesen. Erneutes
Öffnen erfolgt mit `UI.Mount(...)`, nicht durch Wiederbeleben des alten Handles.
Das gilt auch dann, wenn `handle.frame` noch einen alten Frame-Verweis enthält.

WoW-Frames werden durch diesen Vorgang nicht zerstört. Häufige Updates erzeugen
weitere native Objekte. Es gibt noch keinen Frame-Pool. Keine pro-Frame- oder
Kampf-Ticker-Updates auf diesem Muster aufbauen; zuerst eine passende
Wiederverwendungsstrategie implementieren.

## Dauerhafter Zustand

Die Library verändert keine SavedVariables und bietet keine Profilverwaltung.
In den Beispielen bleibt Zustand nur in Lua-Variablen bis zum UI-Reload erhalten.
Persistenz, Validierung und anwendungsbezogene Seiteneffekte gehören zum
verwendenden Addon. Controls melden Werte; sie speichern sie nicht selbst dauerhaft.
