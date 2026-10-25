# Offizielle WoW-Clients

Declarus zielt ausschließlich auf aktuelle offizielle Blizzard-Clients. Keine
Privatserver, keine historischen Original-Clients. Classic Era, Hardcore und
saisonale Regeln eines Clients benötigen keine separaten UI-Renderer.

## Gemeinsame Implementierung

Alle Ziele laden dieselbe `Declarus.toc` mit mehreren Interface-Kennungen und
dieselben Lua-Dateien. Keine clientabhängigen Blizzard-Templates, Mixins, Settings-
oder Dropdown-Frameworks sind für die vorhandenen Basics erforderlich. Die
primitiven Frame-, Texture-, FontString-, EditBox-, Slider-, CheckButton- und
ScrollFrame-APIs bilden den gemeinsamen UI-Unterbau.

`Declarus.Client.GetInfo()` liefert `flavor`, `version`, `build`, `interface` und
optional `projectID`. Die Kennung dient der Diagnose, nicht zur Auswahl eines
vermuteten API-Umfangs. Forever wird über seine Interface-Familie getrennt von
Retail erkannt, unabhängig davon, welchen Projektwert eine Beta meldet. Unbekannte
Kennungen werden als `Unknown` berichtet, nicht stillschweigend als Retail.

`Core/Client.lua` ist die zentrale Grenze für nachgewiesene Client-Unterschiede.
Die Standardschrift kommt aus `STANDARD_TEXT_FONT`, damit auch andere Text-Lokalisierungen
die Client-Schrift erhalten. Explizites `:font(...)` hat Vorrang. Messung und
Rendering verwenden denselben Resolver. In einer Umgebung ohne Client-Schrift
bleibt FRIZQT der Fallback. Es werden keine Privatserver-Fallbacks eingeführt.

## Ziel- und Prüfmatrix

Stand: 25. Oktober 2026. Interface-Metadaten sind Patch-abhängig und müssen bei
Blizzard-Updates überprüft werden. Ein TOC-Eintrag ist keine Ingame-Zertifizierung.

| Ziel | Interface in TOC | Automatisierte Prüfung | Ingame-Abnahme |
| --- | --- | --- | --- |
| Retail | 120105, 120100 | gemeinsame Suite + Metadatenprofil | offen, durch Nutzer testbar |
| Forever | 16001 | gemeinsame Suite + Metadatenprofil | offen, aktuell nicht testbar |
| Classic Era / entsprechende Regeln | 11509 | gemeinsame Suite + Metadatenprofil | offen |
| Burning Crusade Classic | 20506 | gemeinsame Suite + Metadatenprofil | offen |
| Mists Classic | 50504 | gemeinsame Suite + Metadatenprofil | offen |
| Titan Reforged, offizieller regionaler Client | 38002 | gemeinsame Suite + Metadatenprofil | offen |

Alte Wrath-/Cataclysm-Classic-Versionen werden nicht vorsorglich als zusätzliche
Ziele aufgenommen. Ein neu angebotener offizieller Client wird anhand seiner
realen API und Interface-Kennung ergänzt.

Die Fixtures verwenden dieselben API-Mocks. Sie prüfen die gemeinsame Ladereihenfolge,
Client-Kennungen, Schriftauflösung, Controls und Lifecycle, emulieren aber keine
sechs echten Clients. Retail-/Classic-Tests ersetzen den Forever-Test nicht.

## Automatisiert prüfen

```sh
luajit Tests/Run.lua
sh Tests/RunClients.sh
```

Der Matrixlauf startet die komplette Suite für jedes Profil in einem separaten
LuaJIT-Prozess. Tests laden die echte TOC statt einer zweiten manuellen Dateiliste.
Nach dem Laden ist nur der interne Mess-Frame vorhanden; es öffnet sich keine Demo.
Zusätzlich LuaLS wie in README beschrieben ausführen, inklusive VS-Code-Konfiguration.

## Auf Retail und Classic prüfen

Denselben Declarus-Ordner in `Interface/AddOns/Declarus` des jeweiligen Clients
bereitstellen. Declarus benötigt für die Standalone-Demo keine anderen Addons.
PoisonFlow ist hierfür nicht erforderlich und wurde nicht verändert.

1. Declarus im Addon-Menü aktivieren und einloggen: kein automatisch geöffnetes UI.
2. `/declarus info` ausführen. Client, Patch, Build, Interface und Sprache notieren.
3. `/declarus` öffnet den gemeinsamen Testdialog.
4. Text-Padding und Schrift prüfen; das Fragezeichen-Icon muss sichtbar sein.
5. TextField bearbeiten und Enter/Escape testen. Slider ziehen: Werte 0–100 in
   Fünferschritten. Toggle und alle Dropdown-Einträge testen; ihre Änderungen
   erscheinen im Chat.
6. Im Inhaltsbereich mit dem Mausrad bis zu beiden Grenzen scrollen.
7. `Update` klicken: Zähler steigt; gewählte Eingabewerte bleiben durch den
   Demo-Zustand erhalten. Der ersetzte UI-Baum verliert Fokus und Scrollposition.
8. `Close` oder `/declarus hide` schließt den Dialog. Wieder öffnen und wiederholen.

Bei Fehlern Client-Ausgabe, konkrete Aktion und vollständigen Lua-Fehler melden.
Erst nach erfolgreichem Ablauf wird die entsprechende Ingame-Abnahme eingetragen.
Die Library verarbeitet hier ausschließlich eigene UI-/Einstellungswerte, keine
geheimen Kampfwerte und keine geschützten Aktionsbuttons.

## Quellen und Evidenz

- [BigWigs TOC](https://raw.githubusercontent.com/BigWigsMods/BigWigs/master/BigWigs.toc):
  Primärquelle eines gepflegten Addons für gemeinsame Multi-Interface-Verteilung
  und die berücksichtigten Interface-Kennungen. Kein Nachweis für Declarus-Ingame-Verhalten.
- [KeyUI TOC](https://raw.githubusercontent.com/1onar/KeyUI/main/KeyUI.toc):
  unabhängiges Beispiel für dieselbe gemeinsame Retail-/Classic-TOC-Verteilung.
- [Blizzard: Forever](https://worldofwarcraft.blizzard.com/en-gb/news/24302093):
  offizieller zusätzlicher Client; Release am 4. November 2026.
- [Blizzard China: Titan Reforged](https://wow.blizzard.cn/trrnews/):
  offizieller regionaler Zweig, kein Privatserver.
- Lokal vorhandene Blizzard-Installationsmetadaten bestätigen Forever 1.60.1,
  Build 70338. Die vorhandene Declarus-TOC verwendete bereits Interface 16001.
  Dies ist keine erfolgreiche Ausführung im Client.
