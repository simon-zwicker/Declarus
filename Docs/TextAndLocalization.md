# Text, Fonts und Localization

[Übersicht](README.md) · [Controls](Controls.md)

## Text anzeigen und messen

```lua
local UI = Declarus.UI
local view = UI.Text("Hallo Azeroth")
    :fontSize(20)
    :padding(8)
    :foregroundColor(UI.Color.RGB(240, 220, 120))
    :backgroundColor(UI.Color.RGB(25, 30, 40))

UI.Mount(view, UIParent)
```

**Ergebnis:** Gelber Text auf dunklem Hintergrund mit 8 Einheiten Innenabstand.
Ohne explizite Größe ergeben Textbreite/-höhe plus Padding die Außenmaße. Exakte
Maße hängen von der Client-Schrift ab. Leere Strings sind erlaubt, andere Werte
als Strings werden von `UI.Text` abgewiesen.

Die Library benutzt für Messung und Rendering denselben FontResolver. Die
Messung verwendet einen wiederverwendeten nativen FontString, die Darstellung
einen eigenen pro Text-View.

## Standardschrift und expliziter Font

```lua
local UI = Declarus.UI
local view = UI.VStack({
    UI.Text("Standard: Client-Schrift, 16"),
    UI.Text("Größer"):fontSize(24),
    UI.Text("Mit Kontur")
        :font(Declarus.Client.GetDefaultFont(), "OUTLINE")
        :fontSize(18),
}):spacing(12)
```

**Ergebnis:** Drei Zeilen mit Standardschrift, größerer Schrift und Kontur.
Standardmäßig wird `STANDARD_TEXT_FONT` des Clients verwendet, damit auch
nichtlateinische Sprachen ihre Client-Schrift erhalten. Fehlt diese globale
Angabe, fällt der Resolver auf `Fonts\\FRIZQT__.TTF` zurück. Die Standardgröße ist
16, die Standard-Flags sind leer.

`:font(path, flags)` setzt Datei und optionale native WoW-Fontflags.
`:fontSize(size)` setzt eine positive Zahl. Bei `:font(path)` werden zuvor gesetzte
Flags zurückgesetzt. Die Datei muss im Zielclient verfügbar sein; für eine
ungültige eigene Fontdatei gibt es keine automatische Reparatur.

Ein eigener Pfad könnte so angegeben werden, wenn die Datei tatsächlich existiert:

```lua
local UI = Declarus.UI
local view = UI.Text("Eigene Schrift")
    :font("Interface\\AddOns\\MyAddon\\Media\\MyFont.ttf")
    :fontSize(18)
```

**Ergebnis:** Der Text soll die mit deinem Addon ausgelieferte Schrift verwenden.
Die Beispiel-Datei gehört nicht zu Declarus und muss selbst bereitgestellt werden.

## Feste Textmaße sind kein Umbruch

```lua
local UI = Declarus.UI
local view = UI.Text("Dieser Text kann breiter als seine View sein.")
    :width(100)
```

**Ergebnis:** Der View-Frame ist 100 breit. Der FontString bekommt derzeit allein
dadurch keine Umbruch-/Kürzungsbreite. Text kann über die Fläche hinausragen.
Automatischer Umbruch, Ellipsen, Textausrichtung und Zeilenabstände sind noch keine
öffentlichen Text-Modifier. Eine größere Schrift vergrößert außerdem nicht
automatisch einen Button mit seinen festen Standardmaßen.

## Übersetzungen registrieren

```lua
local UI = Declarus.UI
local L = Declarus.Localization.Create("MyAddon.Options")

L:Register("enUS", {
    TITLE = "Settings",
    SAVE = "Save",
    ONLY_ENGLISH = "This text is the English fallback.",
})
L:Register("deDE", {
    TITLE = "Einstellungen",
    SAVE = "Speichern",
})

local view = UI.VStack({
    UI.Text("TITLE"):localize(L):fontSize(22),
    UI.Text("ONLY_ENGLISH"):localize(L),
    UI.Text("MISSING_KEY"):localize(L),
    UI.Button("SAVE", function() print("save") end):localize(L),
}):spacing(10)

UI.Mount(view, UIParent)
```

**Ergebnis auf einem deutschen Client:** „Einstellungen“, der englische
Fallback-Satz, der unveränderte Key `MISSING_KEY` und ein Button „Speichern“.
Auf enUS wird „Settings“ und „Save“ verwendet. Für jede andere Sprache ohne
Registrierung wird ebenfalls auf enUS zurückgegriffen.

Die Auflösung läuft bei Textmessung und Rendering nach derselben Reihenfolge:

1. registrierter Wert für `GetLocale()`;
2. registrierter Wert für `enUS`;
3. ursprünglicher Key.

## Namespaces und erneute Registrierung

`Create(namespace)` liefert für denselben Namen dieselbe Localization-Instanz.
Unterschiedliche Namespaces halten ihre Tabellen getrennt. `Register` ergänzt
die vorhandene Tabelle einer Sprache und überschreibt gleichnamige Keys; es
löscht nicht die übrigen Einträge. Namespace und Locale müssen nichtleere Strings
sein. Übersetzungswerte sollen Strings sein.

Direkter Zugriff ist ebenfalls möglich:

```lua
local L = Declarus.Localization.Create("MyAddon.Example")
L:Register("enUS", {TITLE = "Settings"})
print(L:Get("TITLE"))
print(Declarus.Localization.GetActiveLocale())
```

**Ergebnis:** Der aufgelöste Titel und die aktive Sprache werden ausgegeben.
Eine bereits gemountete Ansicht aktualisiert sich durch `Register` nicht von
selbst; dafür ein explizites Mount-Update auslösen.

## Welche Komponenten übersetzen welchen Inhalt?

`UI.Text` und die Button-Beschriftung werden aufgelöst. Der gemeinsame TextView-
Prototyp stellt Fonts und `localize` auch auf Controls bereit; daraus folgt keine
automatische Übersetzung jedes Control-Werts. TextField-Werte, Dropdown-Optionen
und -Auswahl werden aktuell unverändert verwendet. Solche Strings bei Bedarf
vorher über `L:Get(...)` auflösen. Font-Modifier wirken sichtbar bei Text,
Button-Beschriftung, TextField und Dropdown; Slider und Toggle zeichnen kein
zusätzliches Textlabel.
