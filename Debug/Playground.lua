-- Complete opt-in showcase. All component examples use Declarus itself.
local Declarus = _G.Declarus
local UI = Declarus.UI
local C = UI.Color
local accent = C.RGB(90, 195, 240)
local muted = C.RGB(170, 185, 200)
local panel = C.RGB(25, 32, 43)
local pages = {"Uebersicht", "Layouts", "Typografie", "Darstellung", "Controls", "Updates"}
local activePage = 1

---@class DeclarusPlaygroundState
---@field text string
---@field amount number
---@field fraction number
---@field enabled boolean
---@field profile string
---@field clicks number
---@field showSample boolean
---@field items number
---@field gradientEnabled boolean
---@field gradientVertical boolean

---@return DeclarusPlaygroundState
local function initialState()
    return {text = "Declarus", amount = 50, fraction = 0.5, enabled = true,
        profile = "Standard", clicks = 0, showSample = true, items = 3,
        gradientEnabled = false, gradientVertical = false}
end
local state = initialState()
-- Keep UTF-8 characters intact when shortening user-entered preview/status text.
---@param value string
---@param limit number
---@return string
local function shorten(value, limit)
    local characters = {}
    for character in value:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        if #characters == limit then return table.concat(characters) .. "..." end
        characters[#characters + 1] = character
    end
    return table.concat(characters)
end

local events = {"Bereit. Waehle einen Bereich und probiere die Beispiele aus."}
---@type Frame?
local shell
---@type table<string, Frame>
local regions = {}
---@type table<string, DeclarusMountHandle>
local mounts = {}

local L = Declarus.Localization.Create("Declarus.Playground")
L:Register("enUS", {
    WELCOME = "Welcome to Declarus!", ACTION = "Localized button",
    ENGLISH_ONLY = "English fallback: this key has no German translation.",
})
L:Register("deDE", {WELCOME = "Willkommen bei Declarus!", ACTION = "Lokalisierter Button"})

---@param name string
---@param view DeclarusView
local function mountRegion(name, view)
    if mounts[name] then mounts[name]:Update(view)
    else mounts[name] = UI.Mount(view, regions[name]) end
end

---@param value string
---@param size? number
---@return DeclarusTextView
local function text(value, size)
    return UI.Text(value):fontSize(size or 14)
end

---@param title string
---@param children DeclarusView[]
---@return DeclarusStack
local function card(title, children)
    ---@type DeclarusView[]
    local contents = {text(title, 17):foregroundColor(accent)}
    for _, child in ipairs(children) do contents[#contents + 1] = child end
    return UI.VStack(contents):spacing(9):padding(12):width(UI.Size.Fill):backgroundColor(panel)
end

---@param label string
---@param callback fun(button: string)
---@param width? number
---@return DeclarusControl
local function button(label, callback, width)
    local view = UI.Button(label, callback):size(width or 150, 28):padding(UI.Edge.Left, 8):padding(UI.Edge.Top, 6)
    ---@cast view DeclarusControl
    return view
end

local function refreshStatus()
    mountRegion("status", UI.VStack({
        text(events[#events], 13):foregroundColor(accent),
        text(#events > 1 and events[#events - 1] or "/declarus info | /declarus reset | /declarus hide", 12):foregroundColor(muted),
    }):spacing(5):width(820))
end

---@param message string
local function log(message)
    events[#events + 1] = shorten(message, 56)
    if #events > 12 then table.remove(events, 1) end
    refreshStatus()
end

-- This separate mount updates without replacing the controls or their scroll frame.
local function refreshPreview()
    local barWidth = state.amount * 3
    local bar = UI.View():size(barWidth, 8):backgroundColor(accent):opacity(state.fraction):visible(state.enabled)
    if state.gradientEnabled then
        bar:gradient(state.gradientVertical and "VERTICAL" or "HORIZONTAL", C.RGB(30, 100, 200), C.RGB(100, 220, 160))
    end
    mountRegion("preview", UI.VStack({
        text("Live-Vorschau | " .. state.profile .. " | " .. (state.enabled and "aktiv" or "inaktiv"), 14):foregroundColor(accent),
        UI.HStack({
            text(state.text == "" and "(leerer Text)" or shorten(state.text, 18), 18):width(380),
            text(string.format("Wert: %d | Dezimal: %.1f", state.amount, state.fraction), 14),
        }):spacing(12):alignment(UI.Alignment.Center),
        UI.HStack({
            bar,
            UI.View():size(300 - barWidth, 8):backgroundColor(C.RGB(50, 60, 75)),
        }):width(300),
    }):spacing(7):padding(10):width(820):backgroundColor(C.RGB(17, 23, 32)))
end

local function close()
    for name, handle in pairs(mounts) do handle:Unmount(); mounts[name] = nil end
    if shell then shell:Hide(); shell:SetParent(nil) end
end

local function report()
    local info = Declarus.Client.GetInfo()
    print(string.format("Declarus: %s | %s | build %s | Interface %d | %s",
        info.flavor, info.version, info.build, info.interface, GetLocale()))
end

---@type fun()
local refreshPage
---@type fun()
local refreshHeader

---@return DeclarusView[]
local function overview()
    local info = Declarus.Client.GetInfo()
    return {
        card("Alles an einem Ort", {
            text("Sechs Bereiche zeigen die bisher implementierte oeffentliche UI-API."),
            text("Inhalte scrollen mit dem Mausrad. Die Vorschau unten bleibt sichtbar."),
            text("Eingaben aktualisieren nur Vorschau und Ereignisse: Fokus bleibt erhalten."),
            text("Navigation und expliziter Neuaufbau setzen die Seiten-Scrollposition zurueck."),
        }),
        card("Komponenten", {
            text("View / Text / HStack / VStack / Button / TextField"),
            text("Slider / Toggle / Dropdown / ScrollView"),
            text("Modifier: Groesse, Padding, Alignment, Farben, Textur, Sichtbarkeit, Fonts."),
            text("Localization, Client-Informationen und Mount / Update / Unmount."),
        }),
        card("Dieser Client", {
            text(info.flavor .. " | " .. info.version .. " | Build " .. info.build),
            text("Interface " .. info.interface .. " | Sprache " .. GetLocale()),
            text("Standardschrift: " .. Declarus.Client.GetDefaultFont(), 12),
            text("Nur offizielle Blizzard-Clients; keine Privatserver-Unterstuetzung."),
            text("Retail-/Classic-Tests ersetzen keine Forever-Ingame-Abnahme."),
            button("Client ausgeben", function() report(); log("Client-Diagnose im Chat ausgegeben.") end, 190),
        }),
        card("Hinweise zum aktuellen Stand", {
            text("Dropdown: Mausbedienung, schliessen per Auswahl oder erneutem Klick."),
            text("ScrollView: vertikales Mausrad, noch ohne sichtbare Scrollbar."),
            text("Mount-Updates ersetzen ihren Teilbaum; keine implizite Reaktivitaet."),
            text("Groesse und Schrift koennen je nach UI-Skalierung anders wirken."),
        }),
    }
end

---@param width number|DeclarusSize
---@param height number|DeclarusSize
---@param color DeclarusColor
---@return DeclarusView
local function tile(width, height, color)
    return UI.View():size(width, height):backgroundColor(color)
end

---@return DeclarusView[]
local function layouts()
    local result = {
        card("Verschachtelte Stacks / Spacing", {
            UI.HStack({
                UI.VStack({text("VStack"), tile(90, 20, accent), tile(60, 32, C.RGB(105, 210, 150))}):spacing(6),
                UI.VStack({text("HStack"), UI.HStack({tile(40, 40, accent), tile(70, 25, C.RGB(240, 180, 80))}):spacing(10)}):spacing(6),
            }):spacing(30):alignment(UI.Alignment.Top),
        }),
        card("Fixe Groesse / Wrap / Fill", {
            text("120 px fix, intrinsisches Text-Wrap und zwei gleich grosse Fill-Flaechen."),
            UI.HStack({
                tile(120, 32, accent),
                text("Wrap"):width(UI.Size.Wrap):padding(6):backgroundColor(C.RGB(80, 70, 110)),
                tile(UI.Size.Fill, 32, C.RGB(80, 150, 110)),
                tile(UI.Size.Fill, 32, C.RGB(170, 110, 65)),
            }):spacing(8):width(UI.Size.Fill),
            text("Vertikales Fill: zwei Kinder teilen die feste Hoehe von 100 px."),
            UI.VStack({tile(180, UI.Size.Fill, accent), tile(180, UI.Size.Fill, C.RGB(105, 210, 150))}):height(100):spacing(8),
        }),
    }
    for _, entry in ipairs({
        {"Top", UI.Alignment.Top}, {"Center", UI.Alignment.Center},
        {"Bottom", UI.Alignment.Bottom}, {"Stretch", UI.Alignment.Stretch},
    }) do
        local samples = {tile(70, 20, accent), tile(70, 40, C.RGB(105, 210, 150)), tile(70, 58, C.RGB(240, 180, 80))}
        if entry[2] == UI.Alignment.Stretch then
            -- Explicit dimensions take priority, so Stretch needs intrinsic cross sizes.
            samples = {
                UI.VStack({text("A")}):width(70):backgroundColor(accent),
                UI.VStack({text("B"), text("C")}):width(70):backgroundColor(C.RGB(105, 210, 150)),
            }
        end
        result[#result + 1] = card("HStack Alignment: " .. entry[1], {
            UI.HStack(samples):height(70):spacing(12):alignment(entry[2]):backgroundColor(C.RGB(14, 18, 26)),
        })
    end
    for _, entry in ipairs({
        {"Left", UI.Alignment.Left}, {"Center", UI.Alignment.Center},
        {"Right", UI.Alignment.Right}, {"Stretch", UI.Alignment.Stretch},
    }) do
        local samples = {tile(80, 16, accent), tile(150, 16, C.RGB(105, 210, 150)), tile(220, 16, C.RGB(240, 180, 80))}
        if entry[2] == UI.Alignment.Stretch then
            samples = {
                UI.VStack({text("Kurz")}):backgroundColor(accent),
                UI.VStack({text("Laengerer intrinsischer Inhalt")}):backgroundColor(C.RGB(105, 210, 150)),
            }
        end
        result[#result + 1] = card("VStack Alignment: " .. entry[1], {
            UI.VStack(samples):width(340):spacing(6):alignment(entry[2]):backgroundColor(C.RGB(14, 18, 26)),
        })
    end
    return result
end

---@return DeclarusView[]
local function typography()
    local paddingExamples = {}
    for _, entry in ipairs({
        {"All", UI.Edge.All}, {"Horizontal", UI.Edge.Horizontal}, {"Vertical", UI.Edge.Vertical},
        {"Top", UI.Edge.Top}, {"Bottom", UI.Edge.Bottom}, {"Left", UI.Edge.Left}, {"Right", UI.Edge.Right},
    }) do
        paddingExamples[#paddingExamples + 1] = text(entry[1] .. ": 10 px")
            :padding(entry[2], 10):backgroundColor(C.RGB(45, 65, 85))
    end
    paddingExamples[#paddingExamples + 1] = text("Kumulativ: 4 rundum + 16 links")
        :padding(4):padding(UI.Edge.Left, 16):backgroundColor(C.RGB(65, 50, 85))
    return {
        card("Schriftgroessen und Foreground-Farbe", {
            text("12 px: kleine Beschriftung", 12):foregroundColor(muted),
            text("16 px: Standardgroesse", 16),
            text("24 px: Ueberschrift", 24):foregroundColor(accent),
            text("Explizite Client-Schrift mit OUTLINE", 19):font(Declarus.Client.GetDefaultFont(), "OUTLINE"),
            text("Messung und Rendering nutzen denselben FontResolver."),
        }),
        card("Padding: alle Edges", paddingExamples),
        card("Localization / Namespace / Fallback", {
            text("WELCOME", 20):localize(L):foregroundColor(accent),
            text("ENGLISH_ONLY"):localize(L),
            text("MISSING_PLAYGROUND_KEY"):localize(L),
            text("Reihenfolge: Client-Sprache > enUS > urspruenglicher Key."),
            UI.Button("ACTION", function() log("Lokalisierter Button geklickt.") end):localize(L)
                :width(250):padding(UI.Edge.Left, 8):padding(UI.Edge.Top, 6),
        }),
    }
end

---@return DeclarusView[]
local function appearance()
    return {
        card("Texturen auf normalen Views", {
            UI.HStack({
                UI.View():size(48, 48):texture("Interface\\Icons\\INV_Misc_QuestionMark"),
                UI.View():width(96):height(48):texture("Interface\\Icons\\INV_Misc_QuestionMark"),
                UI.View():size(48, 48):texture(134400):backgroundColor(accent),
            }):spacing(16),
            text("Dateipfad / gestreckte Textur / numerische File-ID (134400)."),
            text("Texturen brauchen eine Groesse; Hintergrund und Textur sind kombinierbar."),
        }),
        card("TexCoords: Ausschnitt und Spiegelung", {
            UI.HStack({
                UI.View():size(64, 64):texture(134400),
                UI.View():size(64, 64):texture(134400):texCoords(0.08, 0.92, 0.08, 0.92),
                UI.View():size(64, 64):texture(134400):texCoords(0.92, 0.08, 0.08, 0.92),
            }):spacing(18),
            text("Original / Rand abgeschnitten / horizontal gespiegelt."),
            text("UV-Werte: 0 bis 1. Kein automatischer proportionaler Zuschnitt."),
        }),
        card("Texturtoenung: nur das Bild", {
            UI.HStack({
                UI.View():size(64, 40):texture("Interface\\Buttons\\WHITE8X8"):textureTint(C.RGB(90, 220, 140)),
                UI.View():size(64, 40):texture("Interface\\Buttons\\WHITE8X8"):textureTint(C.RGBA(240, 90, 90, 0.4)),
                UI.View():size(64, 64):texture(134400):textureTint(C.RGB(90, 195, 240)),
            }):spacing(18),
            text("Weisse Textur: gruen / rot mit Alpha 0.4. Icon: blau getoent."),
            text("Toenen multipliziert Bildfarben. Text und Hintergrund bleiben unveraendert."),
        }),
        card("Textur-Layer und lesbare Buttons", {
            UI.HStack({
                button("Text bleibt vorn", function() log("Texturierter Button geklickt.") end, 210)
                    :texture("Interface\\Buttons\\WHITE8X8"):textureTint(C.RGB(30, 85, 120)),
                button("ARTWORK -2", function() log("ARTWORK-Button geklickt.") end, 190)
                    :texture("Interface\\Buttons\\WHITE8X8"):textureTint(C.RGB(75, 45, 100)):textureLayer("ARTWORK", -2),
            }):spacing(16),
            text("Standard: Hintergrund BACKGROUND, Textur BORDER, Beschriftung OVERLAY."),
            text("Expliziter Layer und Sublevel koennen die Zeichenreihenfolge ueberschreiben."),
            text("OVERLAY -1: Text bleibt sichtbar"):size(420, 30):padding(6)
                :texture("Interface\\Buttons\\WHITE8X8"):textureTint(C.RGBA(75, 120, 65, 0.6)):textureLayer("OVERLAY", -1),
        }),
        card("Farbverlaeufe: horizontal und vertikal", {
            UI.HStack({
                UI.View():size(300, 55):gradient("HORIZONTAL", C.RGB(30, 100, 200), C.RGB(100, 220, 160)),
                UI.View():size(120, 100):gradient("VERTICAL", C.RGB(240, 100, 50), C.RGB(70, 100, 220)),
            }):spacing(18):alignment(UI.Alignment.Center),
            text("Horizontal: links nach rechts. Vertikal: unten nach oben."),
            UI.View():size(420, 35):gradient("HORIZONTAL", C.RGBA(90, 195, 240, 0), C.RGBA(90, 195, 240, 1)),
            text("Alpha-Verlauf: transparent nach deckend. Hintergrund bleibt separat."),
        }),
        card("Gradient auf Texturen und Buttons", {
            UI.HStack({
                UI.View():size(64, 64):texture(134400)
                    :gradient("VERTICAL", C.RGBA(255, 255, 255, 0.1), C.RGB(255, 255, 255)),
                button("Gradient-Button", function() log("Gradient-Button geklickt.") end, 220)
                    :gradient("HORIZONTAL", C.RGB(25, 70, 120), C.RGB(35, 120, 80)),
            }):spacing(18):alignment(UI.Alignment.Center),
            UI.View():size(420, 30):gradient("HORIZONTAL", C.RGB(255, 255, 255), C.RGB(80, 160, 255))
                :textureTint(C.RGBA(100, 220, 160, 0.7)),
            text("Texturtint und Gradient werden multipliziert; Schrift bleibt unabhaengig."),
            UI.HStack({
                button("Verlauf an/aus", function()
                    state.gradientEnabled = not state.gradientEnabled
                    refreshPreview()
                    log("Vorschau-Gradient: " .. (state.gradientEnabled and "an" or "aus"))
                end, 190),
                button("Richtung wechseln", function()
                    state.gradientVertical = not state.gradientVertical
                    refreshPreview()
                    log("Vorschau-Richtung: " .. (state.gradientVertical and "VERTICAL" or "HORIZONTAL"))
                end, 210),
            }):spacing(14),
            text("Die Schalter aendern nur den festen Vorschau-Balken unten."),
        }),
        card("RGB / RGBA / Opacity", {
            UI.HStack({
                tile(100, 46, C.RGB(90, 195, 240)),
                tile(100, 46, C.RGBA(90, 195, 240, 0.4)),
                tile(100, 46, C.RGB(90, 195, 240)):opacity(0.4),
                UI.VStack({text("Vererbt"), tile(60, 12, accent)}):opacity(0.4),
            }):spacing(16):alignment(UI.Alignment.Center),
            text("RGB voll / RGBA 0.4 / View-Opacity 0.4 / Opacity auf einem Stack."),
        }),
        card("Visible: Layout bleibt erhalten", {
            UI.HStack({
                tile(100, 35, accent):visible(true),
                tile(100, 35, C.RGB(240, 180, 80)):visible(state.showSample),
                tile(100, 35, C.RGB(105, 210, 150)):visible(true),
            }):spacing(12),
            text(state.showSample and "Mittlere Flaeche ist sichtbar." or "Mittlere Flaeche ist unsichtbar; ihr Platz bleibt frei."),
            button("Sichtbarkeit", function()
                state.showSample = not state.showSample
                refreshPage()
                log("Visible: " .. tostring(state.showSample))
            end),
        }),
    }
end

---@return DeclarusView[]
local function controls()
    local WoW = _G.Declarus.WoW
    return {
        card("WoW / Tooltips", {
            text("Mit der Maus ueber Text, Flaeche und Buttons fahren."),
            text("Einfacher Text-Tooltip")
                :tooltip("Dieser Tooltip nutzt den Blizzard GameTooltip."),
            UI.View()
                :size(180, 30)
                :backgroundColor(accent)
                :tooltip({
                    UI.Text("Declarus Layout"):fontSize(18),
                    UI.HStack({UI.Text("Links"), UI.Text("Rechts")}):spacing(20),
                }),
            UI.HStack({
                UI.Button("Item: Hearthstone", function() end):infoTooltip(WoW.Item(6948)),
                UI.Button("Spell: Attack", function() end):infoTooltip(WoW.Spell(6603)),
                UI.Button("Unit: player", function() end):infoTooltip(WoW.Unit("player")),
            }):spacing(12),
            text("IDs muessen auf dem jeweiligen Client existieren. Unit: player ist dynamisch."),
        }),
        card("Button / Maus-Events", {
            text("Linke und rechte Maustaste werden getrennt im Ereignisbereich angezeigt."),
            button("Links / Rechts", function(mouse)
                state.clicks = state.clicks + 1
                log("Button: " .. mouse .. " | Klicks: " .. state.clicks)
            end, 190),
        }),
        card("TextField", {
            text("Tippen aktualisiert die Vorschau, ohne das TextField neu zu mounten."),
            UI.TextField(state.text, function(value)
                state.text = value
                refreshPreview()
                log("Textfeld: " .. value)
            end):width(420):fontSize(18),
            text("Enter / Escape geben den Fokus frei. Leere Eingaben sind erlaubt."),
        }),
        card("Slider / Toggle", {
            text("Ganzzahlig: 0 bis 100 in Fuenferschritten."),
            UI.Slider(state.amount, 0, 100, 5, function(value)
                state.amount = value; refreshPreview(); log("Slider: " .. value)
            end):width(420),
            text("Dezimal: 0 bis 1 in 0.1-Schritten; steuert die Vorschau-Opacity."),
            UI.Slider(state.fraction, 0, 1, 0.1, function(value)
                state.fraction = value; refreshPreview(); log(string.format("Opacity: %.1f", value))
            end):width(420),
            UI.HStack({
                UI.Toggle(state.enabled, function(value)
                    state.enabled = value; refreshPreview(); log("Toggle: " .. tostring(value))
                end),
                text("Vorschau-Balken sichtbar / unsichtbar"),
            }):spacing(10):alignment(UI.Alignment.Center),
        }),
        card("Dropdown", {
            text("Profil auswaehlen; Auswahl erscheint sofort in der Vorschau."),
            UI.Dropdown({"Standard", "Raid", "Solo"}, state.profile, function(value)
                state.profile = value; refreshPreview(); log("Profil: " .. value)
            end):width(250):fontSize(16),
            -- Leave room for the native menu rows inside the scroll viewport.
            UI.View():height(90),
            text("Auswahl oder erneuter Klick schliesst das Menue."),
        }),
    }
end

---@return DeclarusView[]
local function updates()
    local items = {}
    for index = 1, state.items do
        items[#items + 1] = UI.HStack({tile(12, 12, accent), text("Dynamischer Eintrag " .. index)}):spacing(10)
    end
    return {
        card("Unabhaengige Mounts", {
            text("Navigation, Seite, Vorschau und Ereignisse besitzen getrennte Mounts."),
            text("Controls aktualisieren nur Vorschau und Status: Fokus und Scroll bleiben."),
            text("Die Library braucht explizite Updates; Zustandsverwaltung liegt im Beispiel."),
        }),
        card("Dynamische Kinder / Neu-Layout", {
            UI.HStack({
                button("Eintrag +", function()
                    state.items = math.min(12, state.items + 1); refreshPage(); log("Eintraege: " .. state.items)
                end),
                button("Eintrag -", function()
                    state.items = math.max(0, state.items - 1); refreshPage(); log("Eintraege: " .. state.items)
                end),
            }):spacing(10),
            UI.VStack(items):spacing(8),
            text("0 bis 12 Eintraege. Die Seitenhoehe wird neu gemessen."),
        }),
        card("Lifecycle: Update / Unmount / Mount", {
            button("Vorschau neu", function()
                if mounts.preview then mounts.preview:Unmount(); mounts.preview = nil end
                refreshPreview(); log("Vorschau unmounted und neu gemountet.")
            end, 210),
            text("Nur die Vorschau wird ersetzt; Seite und Eingaben bleiben bestehen."),
            text("Reset setzt alle Werte zurueck; Schliessen entfernt alle aktiven Mounts."),
            text("Wiederholtes Oeffnen erzeugt keinen weiteren aktiven Playground."),
        }),
    }
end

local builders = {overview, layouts, typography, appearance, controls, updates}
refreshPage = function()
    mountRegion("page", UI.ScrollView(UI.VStack(builders[activePage]()):spacing(12):padding(12):width(UI.Size.Fill))
        :size(820, 350):backgroundColor(C.RGB(12, 17, 24)))
end

refreshHeader = function()
    local navigation = {}
    for index, label in ipairs(pages) do
        navigation[#navigation + 1] = button(label, function()
            activePage = index; refreshHeader(); refreshPage(); log("Bereich: " .. label)
        end, 131):backgroundColor(index == activePage and C.RGB(35, 90, 120) or panel)
    end
    local info = Declarus.Client.GetInfo()
    mountRegion("header", UI.VStack({
        UI.HStack({
            text("Declarus Playground", 24):foregroundColor(accent):width(UI.Size.Fill),
            button("Reset", function()
                state = initialState(); refreshPage(); refreshPreview(); log("Alle Werte zurueckgesetzt.")
            end, 90),
            button("Schliessen", close, 110),
        }):width(820):spacing(8):alignment(UI.Alignment.Center),
        text(info.flavor .. " | " .. info.version .. " | Interface " .. info.interface .. " | " .. GetLocale(), 12):foregroundColor(muted),
        UI.HStack(navigation):spacing(6),
    }):spacing(8):width(820))
end

-- Only the host regions use WoW frames; all visible content uses Declarus.
local function open()
    close()
    if not shell then
        shell = CreateFrame("Frame", nil, UIParent)
        shell:SetSize(860, 640)
        shell:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        for _, region in ipairs({
            {"background", 860, 640, 0, 0}, {"header", 820, 100, 20, 12},
            {"page", 820, 350, 20, 118}, {"preview", 820, 92, 20, 477},
            {"status", 820, 52, 20, 580},
        }) do
            local frame = CreateFrame("Frame", nil, shell)
            frame:SetSize(region[2], region[3])
            frame:SetPoint("TOPLEFT", shell, "TOPLEFT", region[4], -region[5])
            regions[region[1]] = frame
        end
    end
    shell:SetParent(UIParent)
    shell:Show()
    mountRegion("background", UI.View():size(860, 640):backgroundColor(C.RGBA(8, 12, 18, 0.98)))
    refreshHeader(); refreshPage(); refreshPreview(); refreshStatus()
end

SLASH_DECLARUS1 = "/declarus"
SlashCmdList.DECLARUS = function(message)
    local command = message:lower():match("^%s*(.-)%s*$")
    if command == "hide" then close()
    elseif command == "info" then report()
    elseif command == "reset" then
        state = initialState()
        if mounts.page then refreshPage(); refreshPreview(); log("Alle Werte zurueckgesetzt.") end
    elseif command == "" or command == "demo" then report(); open()
    else print("Declarus: /declarus [demo|hide|info|reset]") end
end
