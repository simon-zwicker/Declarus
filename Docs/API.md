# Öffentliche API-Referenz

[Dokumentationsübersicht](README.md)

`?` markiert optionale Argumente. Methoden auf Views werden mit `:` aufgerufen,
Fabriken und Namespace-Funktionen mit `.`. Modifier verändern das vorhandene
Objekt und geben es für weitere Verkettung zurück.

## Namespaces

| Namespace | Zweck |
| --- | --- |
| `Declarus.UI` | Komponenten, Modifier-Basen, Konstanten und Mount |
| `Declarus.Localization` | Übersetzungsinstanzen und aktive Sprache |
| `Declarus.Client` | Client-Metadaten und Standardschrift |

## Komponenten

| Signatur | Rückgabe | Bedeutung / Default |
| --- | --- | --- |
| `UI.View()` | View | leere Fläche, keine intrinsische Bildgröße |
| `UI.Text(value: string)` | TextView | Text mit intrinsischen Schriftmaßen |
| `UI.HStack(children: View[])` | Stack | horizontale Kinderfolge |
| `UI.VStack(children: View[])` | Stack | vertikale Kinderfolge |
| `UI.Button(label: string, onClick: function)` | Control | 120 × 28, Callback mit Mausbutton |
| `UI.TextField(value: string, onChange?: function)` | Control | 180 × 28, Callback mit neuem String |
| `UI.Slider(value: number, min: number, max: number, step?: number, onChange?: function)` | Control | 180 × 20, Step 1, horizontal |
| `UI.Toggle(value: boolean, onChange?: function)` | Control | 26 × 26, Checkbox, Callback boolean |
| `UI.Dropdown(options: string[], value: string, onChange?: function)` | Control | 180 × 28, String-Liste und ausgewählter String |
| `UI.ScrollView(content: View)` | View | 240 × 180, ein Inhaltsbaum, vertikales Mausrad |

Für Defaults, Validierung und native Besonderheiten siehe [Controls](Controls.md)
und [ScrollView](ScrollView.md). `UI.Image`, `UI.Textfield` und `UI.Textarea` sind
keine vorhandenen Konstruktoren; korrekt sind `UI.View():texture(...)` und
`UI.TextField(...)` mit großem F.

## Gemeinsame Modifier für alle Views

| Signatur | Wirkung |
| --- | --- |
| `:width(value: number|Size)` | Außenbreite |
| `:height(value: number|Size)` | Außenhöhe |
| `:size(width: number|Size, height: number|Size)` | beide Außenmaße |
| `:padding(value: number)` | kumulativer Abstand auf allen Seiten |
| `:padding(edge: Edge, value: number)` | kumulativer Abstand auf gewählten Seiten |
| `:backgroundColor(color: Color)` | eigene BACKGROUND-Fläche |
| `:foregroundColor(color: Color)` | derzeit Text-/Button-Beschriftung |
| `:opacity(value: number)` | natives Frame-Alpha, regulär 0–1 |
| `:visible(value: boolean)` | Frame ein-/ausblenden, Layout bleibt |
| `:gradient(orientation?: GradientOrientation, fromColor?: Color, toColor?: Color)` | zwei Endpunkte, HORIZONTAL/VERTICAL; nil entfernt den Verlauf |
| `:texture(source: string|number)` | Datei-/FileDataID-Textur über die Elementfläche |
| `:texCoords(left: number, right: number, top: number, bottom: number)` | vier UV-Werte 0–1, umgekehrte Seiten spiegeln |
| `:textureTint(color: Color)` | kopierte normalisierte RGB-/RGBA-Tönung der Textur |
| `:textureLayer(layer: DrawLayer, sublevel?: number)` | Standard BORDER/0; Sublevel -8 bis 7 |

Ohne Appearance-Modifier ist eine normale leere View transparent. Controls
konfigurieren einen eigenen dunklen Hintergrund. TexCoords, Tint und Layer sind
wirkungslos, solange weder eine eigene Textur noch ein Gradient gesetzt ist; sie bleiben aber als
Eigenschaften gespeichert.

## TextView-Modifier

Diese Methoden stehen auf Text und den Controls zur Verfügung:

| Signatur | Default | sichtbare Verwendung |
| --- | --- | --- |
| `:font(path: string, flags?: string)` | Client-Schrift, leere Flags | Text, Button, TextField, Dropdown |
| `:fontSize(size: number)` | 16 | dieselben textzeichnenden Komponenten |
| `:localize(localization: Localization)` | keine Übersetzung | Text und Button-Key-Auflösung |

Methodenverfügbarkeit ist nicht identisch mit Rendering-Unterstützung jedes
Control-Werts. Slider/Toggle zeichnen keine Textlabels. Dropdown-Strings und
TextField-Werte werden nicht automatisch lokalisiert.

## Stack-Modifier

| Signatur | Default | Wirkung |
| --- | --- | --- |
| `:spacing(value: number)` | 0 | Abstand zwischen Kindern |
| `:alignment(value: Alignment)` | HStack Top, VStack Left | Querachsen-Ausrichtung |

Die Fabriken HStack/VStack und die Modifier `width`, `height`, `padding` usw.
sind kombinierbar. Feste Kind-Maße haben Vorrang vor Stretch.

## Konstanten und Farbwerte

| Gruppe | Werte |
| --- | --- |
| `UI.Size` | `Wrap`, `Fill` |
| `UI.Edge` | `All`, `Horizontal`, `Vertical`, `Top`, `Bottom`, `Left`, `Right` |
| `UI.Alignment` | `Top`, `Bottom`, `Left`, `Right`, `Center`, `Stretch` |
| GradientOrientation-Strings | `"HORIZONTAL"`, `"VERTICAL"` |
| DrawLayer-Strings | `"BACKGROUND"`, `"BORDER"`, `"ARTWORK"`, `"OVERLAY"`, `"HIGHLIGHT"` |

Alignment-Kombinationen sind auf die jeweilige Stack-Querachse beschränkt.
Größen, Edges und Alignments bevorzugt über die Konstanten referenzieren statt
entsprechende Rohstrings selbst zu schreiben.

`UI.Color.RGB(red, green, blue)` und
`UI.Color.RGBA(red, green, blue, alpha)` geben `{r/255, g/255, b/255, a}` zurück.
Bei RGB ist Alpha 1. Beispiel: `UI.Color.RGBA(255, 128, 0, 0.5)` ergibt intern
Rot 1, Grün 128/255, Blau 0 und Alpha 0.5.

## Mount und Handle

| Aufruf / Feld | Rückgabe / Wirkung |
| --- | --- |
| `UI.Mount(view: View, parent: Frame)` | MountHandle; im Parent zentriert |
| `handle.frame` | aktuell gerenderter Wurzel-Frame |
| `handle:Update(view: View)` | ersetzt und vermisst den Baum dieses Mounts |
| `handle:Unmount()` | entfernt den aktiven Mount; mehrfach erlaubt |

Update nach Unmount ist unzulässig. Weder Update noch Unmount liefern einen
neuen Handle als verkettbaren Rückgabewert. Beim Ersetzen gehen Fokus und
Scrollposition im ersetzten Baum verloren. Details: [Lifecycle](StateAndLifecycle.md).

## Localization

| Aufruf | Rückgabe / Wirkung |
| --- | --- |
| `Declarus.Localization.Create(namespace: string)` | neue oder bestehende Instanz für denselben Namen |
| `Declarus.Localization.GetActiveLocale()` | `GetLocale()` oder `"enUS"` als Fallback |
| `L:Register(locale: string, translations: table<string, string>)` | ergänzt/überschreibt Übersetzungen dieser Sprache |
| `L:Get(key: string)` | aktive Sprache → enUS → Key |

Die Instanz besitzt außerdem `namespace` und `translations`. Anwendungscode sollte
Registrierung und Auflösung bevorzugt über die Methoden durchführen.

## Client

`Declarus.Client.GetInfo()` liefert eine Tabelle:

| Feld | Typ | Bedeutung |
| --- | --- | --- |
| `flavor` | string | erkannter Client-Zweig oder `"Unknown"` |
| `version` | string | Client-Version aus GetBuildInfo |
| `build` | string | Build-Kennung |
| `interface` | number | Interface-Kennung |
| `projectID` | number oder nil | vorhandenes WOW_PROJECT_ID |

`Declarus.Client.GetDefaultFont()` liefert `STANDARD_TEXT_FONT` oder die feste
FRIZQT-Fallback-Datei. Client-Identität ist Diagnose, keine Zusicherung einer
verfügbaren API oder abgeschlossenen Ingame-Abnahme.

## Playground-Befehle

| Befehl | Wirkung |
| --- | --- |
| `/declarus` / `/declarus demo` | Playground öffnen/ersetzen |
| `/declarus info` | Client-Diagnose ausgeben |
| `/declarus reset` | Demo-Zustand zurücksetzen |
| `/declarus hide` | aktive Playground-Mounts schließen |

## Interne Schnittstellen

Mit `_` beginnende UI-Felder sind Implementierungsdetails:
`_View`, `_TextView`, `_Stack`, `_Measure`, `_Arrange`, `_Render`, `_ControlRender`,
`_LocalizationResolver`, `_FontResolver`, `_TextMeasure`. Auch
`Declarus.Client._ApplyGradient` ist eine interne native Übergabe, kein
Anwendungs-Modifier.
Diese Dokumentation empfiehlt sie nicht als Integrations-API. Tests greifen
bewusst darauf zu. Eigenen Anwendungscode auf die öffentlichen Funktionen stützen.
