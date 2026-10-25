# Schnellstart

[Dokumentationsübersicht](README.md) · [API-Referenz](API.md)

## 1. Declarus verfügbar machen

Den Repository-Ordner als `Declarus` im `Interface/AddOns`-Ordner des jeweiligen
offiziellen Clients bereitstellen. Das geht als Kopie oder als Symlink auf den
Checkout. Im Ordner müssen `Declarus.toc`, `Core/`, `UI/` und `Debug/` direkt liegen.
Eine zusätzliche Verschachtelung `Declarus/Declarus/Declarus.toc` wäre falsch.

**Ergebnis:** Declarus erscheint im Addon-Menü. Aktivieren und das UI neu laden
bzw. einloggen. Beim Laden öffnet die Library selbst kein Fenster.

Bei einem Symlink sind Codeänderungen im Checkout nach dem nächsten UI-Reload
auch im Client verfügbar; ein bereits geladener Lua-Code wird nicht automatisch
ersetzt. Ein Symlink führt außerdem nicht dazu, dass neue Dateien ohne Eintrag in
der TOC geladen werden.

## 2. Playground starten

Im Chat:

```text
/declarus
/declarus info
/declarus hide
```

**Ergebnis:** Der erste Befehl öffnet die vollständige Demo. Der zweite gibt Client,
Version, Build, Interface und Sprache aus. Der dritte schließt die Demo. Die
[Playground-Anleitung](Playground.md) beschreibt sämtliche Bereiche.

## 3. Aus einem eigenen Addon verwenden

Ein eigenständiges Addon kann Declarus als Abhängigkeit eintragen. Schematischer
Ausschnitt aus dessen TOC; die Interface-Kennung muss zum Zielclient passen:

```text
## Title: MyAddon
## Dependencies: Declarus
Main.lua
```

In `Main.lua`:

```lua
local UI = Declarus.UI

local view = UI.VStack({
    UI.Text("Mein erstes Declarus-UI")
        :fontSize(20)
        :foregroundColor(UI.Color.RGB(90, 195, 240)),

    UI.Text("Diese Elemente stehen untereinander."),

    UI.Button("Hallo", function(mouseButton)
        print("Geklickt mit:", mouseButton)
    end):width(180),
})
    :spacing(10)
    :padding(16)
    :backgroundColor(UI.Color.RGB(20, 26, 35))

local handle = UI.Mount(view, UIParent)
```

**Ergebnis:** Ein zentrierter dunkler Bereich mit Überschrift, Erklärung und Button.
Zwischen den Kindern liegen jeweils 10 UI-Einheiten; außen sind 16 Einheiten
Padding. Der Button schreibt seinen Mausbutton in den Chat. Die Breite des
Bereichs richtet sich nach dem breitesten Kind plus Padding.

`handle` aufbewahren, solange das UI lebt. Es wird für Änderungen und Cleanup
benötigt. Der gezeigte Code verändert kein bestehendes PoisonFlow-Addon.

## 4. Den sichtbaren Inhalt ersetzen

Fortsetzung des vorherigen Beispiels:

```lua
handle:Update(
    UI.Text("Der Inhalt wurde ersetzt.")
        :fontSize(20)
        :padding(16)
        :backgroundColor(UI.Color.RGB(20, 26, 35))
)
```

**Ergebnis:** Der ursprüngliche Stack verschwindet und wird durch einen Text
ersetzt. Der Mount bleibt im selben Elternbereich zentriert und erhält eine neue
Größe. Der gesamte Baum dieses Mounts wird ersetzt; Fokus und Scrollpositionen
darin werden nicht übernommen.

## 5. Aufräumen

Fortsetzung:

```lua
handle:Unmount()
```

**Ergebnis:** Der Inhalt wird ausgeblendet, die von Declarus verwalteten Handler
werden entfernt und die Frame-Elternbeziehungen gelöst. Ein zweiter Unmount-Aufruf
ist erlaubt. Ein Update auf demselben Handle ist danach nicht mehr erlaubt.
Zum erneuten Öffnen einen neuen Mount erstellen.

## Position durch einen eigenen Elternbereich festlegen

```lua
local UI = Declarus.UI
local region = CreateFrame("Frame", nil, UIParent)
region:SetSize(320, 100)
region:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 30, -30)

local handle = UI.Mount(
    UI.Text("Oben links im eigenen Bereich"):fontSize(16),
    region
)
```

**Ergebnis:** Declarus zentriert den Text im 320 × 100 großen Elternbereich,
der 30 Einheiten vom oberen und linken Bildschirmrand entfernt liegt.
Declarus bietet aktuell keinen eigenen Anchor-/Position-Modifier an.
Den manuell erstellten Elternbereich verwaltet das aufrufende Addon selbst.
