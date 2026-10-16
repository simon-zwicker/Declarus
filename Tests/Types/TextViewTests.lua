
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Core/TextViewTests
-- Description: Tests shared text-based view functionality
-- ============================================================================

local UI = _G.Declarus.UI
local Localization = _G.Declarus.Localization
local TextView = UI._TextView

-- ============================================================================
-- Title:       Tests
-- ============================================================================

local function TestCreateTextView()
    local view = TextView.New("Text")

    assert(view.kind == "Text")
    assert(view.properties ~= nil)
    assert(view.children ~= nil)
end

local function TestInheritsViewModifiers()
    local view = TextView.New("Text")
        :width(200)
        :height(50)
        :padding(10)

    assert(view.properties.width == 200)
    assert(view.properties.height == 50)
    assert(view.properties.padding ~= nil)
end

local function TestLocalizationModifier()
    local L = Localization.Create("TestModifier")

    local view = UI._TextView.New("Text")
        :localize(L)

    assert(view.properties.localization == L)
end

local function TestLocalizationModifierChaining()
    local L = Localization.Create("TestModifierChaining")

    local view = UI._TextView.New("Text")
        :width(200)
        :localize(L)
        :height(50)

    assert(view.properties.localization == L)
    assert(view.properties.width == 200)
    assert(view.properties.height == 50)
end

local function TestViewHasNoLocalization()
    local view = UI.View()
    local modifier = view["localize"]

    assert(modifier == nil)
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

return {
    TestCreateTextView = TestCreateTextView,
    TestInheritsViewModifiers = TestInheritsViewModifiers,
    TestLocalizationModifier = TestLocalizationModifier,
    TestLocalizationModifierChaining = TestLocalizationModifierChaining,
    TestViewHasNoLocalization = TestViewHasNoLocalization,
}