
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Components/TextTests
-- Description: Tests declarative text component
-- ============================================================================

local UI = _G.Declarus.UI
local Localization = _G.Declarus.Localization

-- ============================================================================
-- Title:       Tests
-- ============================================================================

local function TestCreateText()
    local view = UI.Text("Hello World")

    assert(view.kind == "Text")
    assert(view.properties.text == "Hello World")
    assert(#view.children == 0)
end

local function TestTextWithLocalization()
    local L = Localization.Create("TextComponentTests")

    local view = UI.Text("TITLE")
        :localize(L)

    assert(view.properties.text == "TITLE")
    assert(view.properties.localization == L)
end

local function TestTextWithModifiers()
    local view = UI.Text("Hello World")
        :width(200)
        :height(30)
        :padding(10)

    assert(view.properties.text == "Hello World")
    assert(view.properties.width == 200)
    assert(view.properties.height == 30)
end

local function TestTextRejectsInvalidValue()
    ---@type any
    local invalidValue = nil

    local success = pcall(function()
        UI.Text(invalidValue)
    end)

    assert(success == false)
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

return {
    TestCreateText = TestCreateText,
    TestTextWithLocalization = TestTextWithLocalization,
    TestTextWithModifiers = TestTextWithModifiers,
    TestTextRejectsInvalidValue = TestTextRejectsInvalidValue,
}