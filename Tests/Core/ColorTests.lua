
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Core/ColorTests
-- Description: Tests color creation and normalization
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies for color tests
-- ============================================================================

local Color = _G.Declarus.UI.Color

-- ============================================================================
-- Title:       Tests
-- Description: Defines test cases for color utilities
-- ============================================================================

---Tests RGB color creation and normalization
local function TestRGB()
    local color = Color.RGB(255, 128, 0)

    assert(color[1] == 1)
    assert(color[2] == 128 / 255)
    assert(color[3] == 0)
    assert(color[4] == 1)
end

---Tests RGBA color creation and normalization.
local function TestRGBA()
    local color = Color.RGBA(255, 128, 0, 0.5)

    assert(color[1] == 1)
    assert(color[2] == 128 / 255)
    assert(color[3] == 0)
    assert(color[4] == 0.5)
end

---Tests color channel boundaries.
local function TestColorBoundaries()
    local black = Color.RGB(0, 0, 0)
    local white = Color.RGB(255, 255, 255)

    for i = 1, 3 do
        assert(black[i] == 0)
        assert(white[i] == 1)
    end

    assert(black[4] == 1)
    assert(white[4] == 1)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes all color test cases
-- ============================================================================

return {
    TestRGB = TestRGB,
    TestRGBA = TestRGB,
    TestColorBoundaries = TestColorBoundaries,
}