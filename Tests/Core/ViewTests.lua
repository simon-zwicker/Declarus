
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Core/ViewTests
-- Description: Tests view creation and layout modifiers
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies for view tests
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Tests
-- Description: Defines test cases for declaritive views
-- ============================================================================

---Tests view initialization
local function TestViewCreation()
    local view = UI._View.New("Test")

    assert(view.kind == "Test")
    assert(view.properties ~= nil)
    assert(view.children ~= nil)
end

---Tests the size modifier
local function TestSize()
    local view = UI._View.New("Test")
        :size(320, 520)

    assert(view.properties.width == 320)
    assert(view.properties.height == 520)
end

---Tests additive padding modifiers
local function TestPadding()
    local view = UI._View.New("Test")
        :padding(16)
        :padding(UI.Edge.Horizontal, 24)
        :padding(UI.Edge.Top, 32)

    local padding = view.properties.padding

    assert(padding ~= nil)
    assert(padding.top == 48)
    assert(padding.bottom == 16)
    assert(padding.left == 40)
    assert(padding.right == 40)
end

---Tests the background color modifier.
local function TestBackgroundColor()
    local color = UI.Color.RGBA(20, 20, 20, 0.9)

    local view = UI._View.New("Test")
        :backgroundColor(color)

    assert(view.properties.backgroundColor == color)
end

---Tests the foreground color modifier.
local function TestForegroundColor()
    local color = UI.Color.RGB(255, 200, 50)

    local view = UI._View.New("Test")
        :foregroundColor(color)

    assert(view.properties.foregroundColor == color)
end

---Tests the opacity modifier.
local function TestOpacity()
    local view = UI._View.New("Test")
        :opacity(0.5)

    assert(view.properties.opacity == 0.5)

    view:opacity(0.8)

    assert(view.properties.opacity == 0.8)
end

---Tests the visibility modifier.
local function TestVisibility()
    local view = UI._View.New("Test")
        :visible(false)

    assert(view.properties.visible == false)

    view:visible(true)

    assert(view.properties.visible == true)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes all view test cases
-- ============================================================================

TestViewCreation()
TestSize()
TestPadding()
TestBackgroundColor()
TestForegroundColor()
TestOpacity()
TestVisibility()

print("Declarus ViewTests: \27[32m✓ passed\27[0m")
