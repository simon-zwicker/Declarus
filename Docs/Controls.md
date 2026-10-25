# Controls und Events

[Übersicht](README.md) · [Zustand und Lifecycle](StateAndLifecycle.md)

Alle Controls erben die gemeinsamen View-Modifier und die TextView-Methoden.
Die Konstruktoren setzen feste Standardmaße; eine größere Schrift ändert diese
Maße nicht automatisch. Ein dunkler Hintergrund ist voreingestellt und kann mit
`backgroundColor` überschrieben werden.

| Konstruktor | Standardgröße | Callback |
| --- | --- | --- |
| `UI.Button(label, onClick)` | 120 × 28 | `onClick(mouseButton)` |
| `UI.TextField(value, onChange?)` | 180 × 28 | `onChange(string)` |
| `UI.Slider(value, min, max, step?, onChange?)` | 180 × 20 | `onChange(number)` |
| `UI.Toggle(value, onChange?)` | 26 × 26 | `onChange(boolean)` |
| `UI.Dropdown(options, value, onChange?)` | 180 × 28 | `onChange(string)` |

Callbacks erhalten den hier genannten Wert, **keinen nativen Frame** als erstes
Argument. Es gibt bisher keinen öffentlichen `:onChange(...)`-, `:onClick(...)`-
oder allgemeinen Event-Modifier; Handler werden im Konstruktor angegeben.

## Button

```lua
local UI = Declarus.UI
local view = UI.Button("Speichern", function(mouseButton)
    if mouseButton == "RightButton" then
        print("Rechtsklick")
    else
        print("Linksklick")
    end
end)
    :size(180, 34)
    :padding(UI.Edge.Left, 10)
    :padding(UI.Edge.Top, 8)
    :fontSize(16)

UI.Mount(view, UIParent)
```

**Ergebnis:** Ein 180 × 34 großer Button mit versetzter Beschriftung. Linke und
rechte Maustaste werden beim Loslassen registriert; der entsprechende Text
erscheint im Chat. Label muss ein String und der Callback eine Funktion sein.

Die Beschriftung liegt im OVERLAY-Layer; eine normale View-Textur im BORDER-Layer
bleibt dahinter. Eigene Hover-, Pressed-, Disabled- oder Focus-Stile gibt es noch
nicht als Declarus-API. Ein unsichtbarer Button behält seinen Layoutplatz.

## TextField

```lua
local UI = Declarus.UI
local profileName = "Standard"

local field = UI.TextField(profileName, function(value)
    profileName = value
    print("Neuer Profilname:", profileName)
end):width(280):fontSize(18)

UI.Mount(field, UIParent)
```

**Ergebnis:** Ein einzeiliges Eingabefeld mit „Standard“. Benutzereingaben ändern
`profileName` und werden ausgegeben. Auch ein leerer String ist ein gültiger Wert.
Automatischer Fokus ist aus. Enter und Escape geben den Fokus frei.

Escape stellt den alten Text nicht wieder her; Enter ist kein separater Save-
Callback. Beide führen derzeit nur `ClearFocus()` aus. Es gibt noch keine
Placeholder-, Passwort-, Zahlenmodus-, MaxLength- oder Validierungs-Modifier.

Das Control meldet `OnTextChanged` nur, wenn WoW die Änderung als Benutzereingabe
kennzeichnet. Initialisierung und rein programmatisches `SetText` lösen keinen
Declarus-onChange aus. Der Renderer verwendet feste TextInsets: links/rechts 4,
oben/unten 2. Werte sind Strings, keine automatischen Zahlenkonvertierungen.

Für ein Label daneben HStack verwenden; für ein Label darüber VStack.

## Slider

```lua
local UI = Declarus.UI
local volume = 50
local slider = UI.Slider(volume, 0, 100, 5, function(value)
    volume = value
    print("Lautstärke:", volume)
end):width(300)

UI.Mount(slider, UIParent)
```

**Ergebnis:** Ein horizontaler Slider von 0 bis 100. Werte werden relativ zum
Minimum auf Fünferschritte gerundet. Bei einem gemeldeten Wert 53 wird zum Beispiel
55 übernommen. Der Callback erhält die gerundete, begrenzte Zahl.

`max` muss größer als `min` sein, der Anfangswert muss innerhalb des Bereichs
liegen und `step` muss positiv sein. Ohne Step wird 1 verwendet. Wenn ein Callback
angegeben wird, ohne einen Step festzulegen, den vierten Parameter als `nil` angeben:

```lua
local UI = Declarus.UI
local slider = UI.Slider(5, 0, 10, nil, function(value)
    print(value)
end)
```

**Ergebnis:** Bereich 0–10 mit Schrittweite 1. Der Callback steht immer an fünfter
Stelle; eine Funktion als vierter Parameter ist keine alternative Signatur.

Dezimalwerte sind möglich:

```lua
local UI = Declarus.UI
local slider = UI.Slider(0.5, 0, 1, 0.1, function(value)
    print(string.format("Deckkraft: %.1f", value))
end)
```

**Ergebnis:** Ein Slider für Zehntelschritte zwischen 0 und 1. Wie bei Lua-
Gleitkommazahlen üblich, für die sichtbare Ausgabe gezielt formatieren. Nach dem
Runden werden Werte auf min/max begrenzt; bei nicht passend teilbarem Bereich kann
die Begrenzung den Endwert beeinflussen. Der Slider zeichnet selbst keine
Min-/Max-Texte und kein Zahlenlabel; solche Labels separat anordnen.

## Toggle

```lua
local UI = Declarus.UI
local enabled = true
local view = UI.HStack({
    UI.Toggle(enabled, function(value)
        enabled = value
        print("Aktiv:", enabled)
    end),
    UI.Text("Funktion aktivieren"),
}):spacing(10):alignment(UI.Alignment.Center)

UI.Mount(view, UIParent)
```

**Ergebnis:** Eine zunächst angehakte Checkbox neben einem Text. Der Callback
liefert `true` oder `false`, keinen String und keinen Zahlenwert. Der Toggle hat
kein eingebautes Label; im Beispiel ist der Text ein separates Element. Der Text
selbst schaltet die Checkbox beim Anklicken nicht automatisch um.

## Dropdown

```lua
local UI = Declarus.UI
local selected = "Standard"
local dropdown = UI.Dropdown({"Standard", "Raid", "Solo"}, selected, function(value)
    selected = value
    print("Profil:", selected)
end):width(240)

UI.Mount(dropdown, UIParent)
```

**Ergebnis:** Der Auslöser zeigt „Standard v“. Ein Klick öffnet eine Liste; die
Auswahl von „Raid“ setzt Label und Wert auf „Raid“ und schließt die Liste.
Ein erneuter Klick auf den Auslöser schließt sie ebenfalls.

Optionen müssen eine nichtleere, zusammenhängende Liste aus Strings sein. Der
Anfangswert muss in dieser Liste vorkommen. Die Liste wird beim Erzeugen kopiert.
Labels und Werte sind derzeit identisch; es gibt keine separaten IDs, Icons,
Gruppen, Mehrfachauswahl, Suche oder deaktivierten Einträge.

Die Menüzeilen sind aktuell 180 breit und 28 hoch. Eine andere Breite des
Auslösers skaliert die Menübreite nicht automatisch mit. Das Menü wird unter dem
Control geöffnet. Bei einer ScrollView kann es am Viewport-Rand abgeschnitten
werden; den Auslöser dann weiter nach oben scrollen. Außenklick und Escape sind
noch keine implementierten Schließmechanismen; Tastaturnavigation fehlt ebenfalls.

## Gemeinsames Verhalten der Änderungs-Callbacks

Bei TextField, Slider, Toggle und Dropdown wird der interne
`view.properties.value` vor dem Callback aktualisiert. Derselbe Wert löst keinen
weiteren onChange aus. Die Initialisierung löst ebenfalls keinen Änderungs-Callback
aus. Das gilt nicht als allgemeine automatische Zustandsbindung an andere Views.

```lua
local UI = Declarus.UI
local value = "Vorher"
local label = UI.Text(value)
local field = UI.TextField(value, function(nextValue)
    value = nextValue
end)
local view = UI.VStack({label, field}):spacing(8)
```

**Ergebnis:** Beim Tippen ändert sich die Variable `value`, aber `label` bleibt
„Vorher“. Für die Änderung der Anzeige ein explizites Mount-Update verwenden.
Wie das ohne Fokusverlust funktioniert, zeigt [Zustand und Lifecycle](StateAndLifecycle.md).
