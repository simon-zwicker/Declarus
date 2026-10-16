
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Typography/TextMeasureTests
-- Description: Tests intrinsic text measurement
-- ============================================================================

local UI = _G.Declarus.UI
local TextMeasure = UI._TextMeasure
local Localization = _G.Declarus.Localization

-- ============================================================================
-- Title:       Tests
-- ============================================================================

local function TestMeasureText()
    local view = UI.Text("Hello")

    local size = TextMeasure.Measure(view)

    assert(size.width == 40)
    assert(size.height == 16)
end

local function TestMeasureLocalizedText()
    SetMockLocale("deDE")

    local L = Localization.Create("TextMeasureTests")

    L:Register("enUS", {
        TITLE = "Hello",
    })

    L:Register("deDE", {
        TITLE = "Hallo Welt",
    })

    local view = UI.Text("TITLE")
        :localize(L)

    local size = TextMeasure.Measure(view)

    assert(size.width == 80)
    assert(size.height == 16)

    SetMockLocale("enUS")
end

local function TestMeasureEmptyText()
    local view = UI.Text("")

    local size = TextMeasure.Measure(view)

    assert(size.width == 0)
end

-- ============================================================================
-- Title:       Registration
-- ============================================================================

return {
    TestMeasureText = TestMeasureText,
    TestMeasureLocalizedText = TestMeasureLocalizedText,
    TestMeasureEmptyText = TestMeasureEmptyText,
}