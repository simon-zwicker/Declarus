-- Exercise the visible demo via its real slash command and rendered event handlers.
---@param root DeclarusMockFrame
---@param predicate fun(frame: DeclarusMockFrame): boolean
---@return DeclarusMockFrame?
local function find(root, predicate)
    if predicate(root) then return root end
    for _, child in ipairs(root.children) do
        local match = find(child, predicate)
        if match then return match end
    end
end

---@param root DeclarusMockFrame
---@param value string
---@return DeclarusMockFrame?
local function findText(root, value)
    return find(root, function(frame)
        for _, label in ipairs(frame.fontStrings) do
            if label.text == value then return true end
        end
        return false
    end)
end

---@param root DeclarusMockFrame
---@param label string
---@param mouse? string
local function click(root, label, mouse)
    local frame = assert(findText(root, label), "Missing control: " .. label)
    assert(frame.scripts.OnClick, "Not clickable: " .. label)(frame, mouse or "LeftButton")
end

---@return DeclarusMockFrame
local function parent()
    local frame = UIParent
    ---@cast frame DeclarusMockFrame
    return frame
end

---@param page string
---@return DeclarusMockFrame
local function open(page)
    SlashCmdList.DECLARUS("hide")
    SlashCmdList.DECLARUS("reset")
    SlashCmdList.DECLARUS("demo")
    local root = parent().children[#parent().children]
    click(root, page)
    return root
end

return {
    TestNavigationAndCoverage = function()
        local expected = {
            {"Uebersicht", "Dieser Client"}, {"Layouts", "VStack Alignment: Stretch"},
            {"Typografie", "Padding: alle Edges"}, {"Darstellung", "Visible: Layout bleibt erhalten"},
            {"Controls", "Dropdown"}, {"Updates", "Lifecycle: Update / Unmount / Mount"},
        }
        for _, entry in ipairs(expected) do
            local root = open(entry[1])
            assert(findText(root, entry[2]), "Missing section: " .. entry[2])
            local scroll = assert(find(root, function(frame) return frame:GetObjectType() == "ScrollFrame" end))
            assert(scroll.scrollChild.height > scroll.height, "Page must exercise scrolling")
            scroll.scripts.OnMouseWheel(scroll, -10000)
            assert(scroll.scroll == scroll.scrollChild.height - scroll.height)
            scroll.scripts.OnMouseWheel(scroll, 10000)
            assert(scroll.scroll == 0)
            assert(not find(root, function(frame) return frame.width < 0 or frame.height < 0 end))
        end
        SlashCmdList.DECLARUS("hide")
    end,
    TestLiveInputsPreservePageAndFocus = function()
        local root = open("Controls")
        local scroll = assert(find(root, function(frame) return frame:GetObjectType() == "ScrollFrame" end))
        scroll:SetVerticalScroll(120)
        local input = assert(find(root, function(frame) return frame:GetObjectType() == "EditBox" end))
        input.focus = true
        input:SetText("Arkan")
        input.scripts.OnTextChanged(input, true)
        assert(findText(root, "Arkan"))
        assert(input.focus and input.parent and not input.hidden)
        assert(find(root, function(frame) return frame == scroll end) and scroll.scroll == 120)
        local slider = assert(find(root, function(frame) return frame.maximum == 100 end))
        slider:SetValue(83)
        assert(slider.value == 85 and findText(root, "Wert: 85 | Dezimal: 0.5"))
        local fraction = assert(find(root, function(frame) return frame.maximum == 1 end))
        fraction:SetValue(0.8)
        assert(findText(root, "Wert: 85 | Dezimal: 0.8"))
        local toggle = assert(find(root, function(frame) return frame:GetObjectType() == "CheckButton" end))
        toggle:SetChecked(false); toggle.scripts.OnClick(toggle)
        assert(findText(root, "Live-Vorschau | Standard | inaktiv"))
        click(root, "Standard v")
        click(root, "Raid")
        assert(findText(root, "Live-Vorschau | Raid | inaktiv"))
        click(root, "Links / Rechts", "RightButton")
        assert(findText(root, "Button: RightButton | Klicks: 1"))
        assert(input.focus and scroll.scroll == 120)
        SlashCmdList.DECLARUS("hide")
    end,
    TestLongUnicodeInput = function()
        local root = open("Controls")
        local input = assert(find(root, function(frame) return frame:GetObjectType() == "EditBox" end))
        input:SetText(string.rep("界", 60))
        input.scripts.OnTextChanged(input, true)
        assert(findText(root, string.rep("界", 18) .. "..."))
        assert(input:GetText() == string.rep("界", 60))
        SlashCmdList.DECLARUS("hide")
    end,
    TestAlignmentSamplesActuallyAlign = function()
        local root = open("Layouts")
        for _, entry in ipairs({{"Top", 0}, {"Center", -25}, {"Bottom", -50}}) do
            local title = assert(findText(root, "HStack Alignment: " .. entry[1]))
            local stack = title.parent.children[2]
            assert(stack.children[1].points[1].y == entry[2])
        end
        local horizontal = assert(findText(root, "HStack Alignment: Stretch")).parent.children[2]
        assert(horizontal.children[1].height == 70 and horizontal.children[2].height == 70)
        local vertical = assert(findText(root, "VStack Alignment: Stretch")).parent.children[2]
        assert(vertical.children[1].width == 340 and vertical.children[2].width == 340)
        SlashCmdList.DECLARUS("hide")
    end,
    TestDynamicChildrenAndReset = function()
        local root = open("Updates")
        click(root, "Eintrag +")
        assert(findText(root, "Dynamischer Eintrag 4"))
        click(root, "Eintrag -")
        assert(not findText(root, "Dynamischer Eintrag 4"))
        for _ = 1, 15 do click(root, "Eintrag -") end
        assert(not findText(root, "Dynamischer Eintrag 1"))
        for _ = 1, 15 do click(root, "Eintrag +") end
        assert(findText(root, "Dynamischer Eintrag 12") and not findText(root, "Dynamischer Eintrag 13"))
        click(root, "Vorschau neu")
        assert(findText(root, "Vorschau unmounted und neu gemountet."))
        click(root, "Reset")
        assert(findText(root, "Dynamischer Eintrag 3") and not findText(root, "Dynamischer Eintrag 4"))
        SlashCmdList.DECLARUS("hide")
    end,
    TestLocalizationAndVisibility = function()
        local locale = GetLocale()
        SetMockLocale("deDE")
        local root = open("Typografie")
        assert(findText(root, "Willkommen bei Declarus!"))
        assert(findText(root, "English fallback: this key has no German translation."))
        assert(findText(root, "MISSING_PLAYGROUND_KEY"))
        click(root, "Lokalisierter Button")
        assert(findText(root, "Lokalisierter Button geklickt."))
        click(root, "Darstellung")
        click(root, "Sichtbarkeit")
        local sample = assert(find(root, function(frame)
            return frame.width == 100 and frame.height == 35 and frame.hidden == true
        end))
        assert(sample.width == 100)
        click(root, "Sichtbarkeit")
        assert(findText(root, "Mittlere Flaeche ist sichtbar."))
        SlashCmdList.DECLARUS("hide")
        SetMockLocale(locale)
    end,
    TestTextureExamples = function()
        local root = open("Darstellung")
        assert(findText(root, "TexCoords: Ausschnitt und Spiegelung"))
        assert(findText(root, "Texturtoenung: nur das Bild"))
        local button = assert(findText(root, "Text bleibt vorn"))
        assert(button.fontStrings[1].layer == "OVERLAY")
        assert(button.textures[2].layer == "BORDER" and button.textures[2].vertexColor[3] == 120 / 255)
        assert(find(root, function(frame)
            for _, texture in ipairs(frame.textures) do
                if texture.texCoords and texture.texCoords[1] == 0.92 and texture.texCoords[2] == 0.08 then return true end
            end
            return false
        end))
        click(root, "Text bleibt vorn")
        assert(findText(root, "Texturierter Button geklickt."))
        click(root, "ARTWORK -2")
        assert(findText(root, "ARTWORK-Button geklickt."))
        SlashCmdList.DECLARUS("hide")
    end,
    TestDemoLifecycle = function()
        SlashCmdList.DECLARUS("hide")
        local before = #parent().children
        SlashCmdList.DECLARUS("info")
        assert(#parent().children == before)
        local root = open("Controls")
        assert(#parent().children == before + 1)
        local input = assert(find(root, function(frame) return frame:GetObjectType() == "EditBox" end))
        click(root, "Layouts")
        assert(input.hidden and input.parent == nil and input.scripts.OnTextChanged == nil)
        for _ = 1, 5 do SlashCmdList.DECLARUS("demo") end
        assert(#parent().children == before + 1)
        click(root, "Schliessen")
        assert(#parent().children == before and root.hidden)
        assert(not find(root, function(frame) return frame.scripts and next(frame.scripts) ~= nil end))
        SlashCmdList.DECLARUS("hide")
    end,
}
