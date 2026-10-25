# Declarus – verbindliche Projektregeln

- Dieser lokale Checkout ist Source of Truth. Vor Änderungen Git-Status prüfen und fremde Änderungen schützen. Nur eigene Dateien explizit stagen.
- Niemals push, fetch, pull oder andere Remote-Git-Aktionen ausführen.
- Ausschließlich aktuelle offizielle Blizzard-Clients unterstützen, einschließlich Forever. Keine Privatserver und keine historischen Original-Clients.
- Client-Unterschiede zentral in `Core/Client.lua` behandeln. Gemeinsame APIs bevorzugen; Client-Kennung ist kein Beweis für verfügbare Fähigkeiten.
- PoisonFlow nicht verändern. Declarus stellt allgemeine UI-Basics bereit.
- Lua 5.1 / LuaJIT beibehalten; öffentliche APIs mit LuaLS annotieren.
- Bestehende Fluent-API, Measure/Arrange/Render-Trennung und TOC-Ladereihenfolge wahren.
- LuaLS-Konfiguration in `.luarc.json` halten; lokale `.vscode/settings.json` bei der Prüfung mitberücksichtigen. Standardbibliotheken nicht pauschal deaktivieren.
- Bei Lua-/Typänderungen auch LuaLS mit `--checklevel=Hint` ausführen (Aufruf siehe README).
- Pro abgeschlossenem Paket `luajit Tests/Run.lua` ausführen und lokal committen. Neue Verhaltensweisen mit aussagekräftigen Tests absichern.
- Mocktests ersetzen keinen WoW-Test. Nicht ingame geprüfte Funktionalität ausdrücklich kennzeichnen.

## Roadmap

1. [x] Checkout inspizieren; Basis: 87 erfolgreiche Tests. Vorhandene .DS_Store-Änderungen nicht übernehmen.
2. [x] Gemeinsamer FontResolver, Text-Padding, Font-Modifier und Texturen.
3. [x] Buttons und Events; TextField, Slider, Toggle, Dropdown.
4. [x] ScrollView und explizite dynamische Mount-Updates mit Cleanup.
5. [x] API-Beispiele, Regressionstests und lokale Abschlussprüfung: 103 Tests; TOC vollständig mit Mocks geladen.
6. [x] LuaLS 3.19.2 über VS-Code-Erweiterung gefunden und ausgeführt: keine Diagnosen einschließlich Hint.
7. [ ] Ingame-Abnahme durch Nutzer.

Die Reihenfolge ist ein Implementierungsplan. Nicht belegte PoisonFlow-Sonderanforderungen werden nicht erfunden.
