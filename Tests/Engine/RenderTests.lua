
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Engine/RenderTests
-- Description: Tests rendering declarative views into WoW frames
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Tests
-- Description: Verifies frame creation, sizing, positioning and backgrounds
-- ============================================================================

---Tests rendering a single view
local function TestRenderView()
    local view = UI.View():size(100, 50)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local frame = UI._Render.Render(view, arranged, UIParent)

    assert(frame ~= nil)
    assert(frame:GetObjectType() == "Frame")
end

---Tests whether the arranged dimensions are applied
local function TestRenderSize()
    local view = UI.View():size(200, 100)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local frame = UI._Render.Render(view, arranged, UIParent)

    ---@cast frame DeclarusMockFrame

    assert(frame.width == 200)
    assert(frame.height == 100)
end

---Tests positioning using WoW coordinates
local function TestRenderPosition()
    local view = UI.View():size(100, 50)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured, 20, 30)

    local frame = UI._Render.Render(view, arranged, UIParent)

    ---@cast frame DeclarusMockFrame

    local point = frame.points[1]

    assert(point.point == "TOPLEFT")
    assert(point.relativeTo == UIParent)
    assert(point.relativePoint == "TOPLEFT")
    assert(point.x == 20)
    assert(point.y == -30)
end

---Tests background color rendering
local function TestRenderBackground()
    local view = UI.View()
        :size(100, 50)
        :backgroundColor(UI.Color.RGBA(255, 0, 0, 0.5))

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local frame = UI._Render.Render(view, arranged, UIParent)

    ---@cast frame DeclarusMockFrame

    assert(#frame.textures == 1)

    local texture = frame.textures[1]

    assert(texture.allPoints == frame)
    assert(texture.color[1] == 1)
    assert(texture.color[2] == 0)
    assert(texture.color[3] == 0)
    assert(texture.color[4] == 0.5)
end

---Tests that views without backgrounds create no textures
local function TestRenderWithoutBackground()
    local view = UI.View():size(100, 50)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local frame = UI._Render.Render(view, arranged, UIParent)

    ---@cast frame DeclarusMockFrame

    assert(#frame.textures == 0)
end

---Tests rendering nested stacks with correct relative positions
local function TestRenderNestedStacks()
    local view = UI.VStack({
        UI.View():size(100, 40),

        UI.HStack({
            UI.View():size(50, 30),
            UI.View():size(70, 30),
        }):spacing(10),
    })
        :spacing(20)
        :padding(10)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local frame = UI._Render.Render(view, arranged, UIParent)

    ---@cast frame DeclarusMockFrame

    -- Root VStack
    assert(frame.width == 150)
    assert(frame.height == 110)

    -- First child
    local first = arranged.children[1]
    assert(first.x == 10)
    assert(first.y == 10)

    -- Nested HStack
    local nested = arranged.children[2]
    assert(nested.x == 10)
    assert(nested.y == 70)

    -- Children inside HStack
    assert(nested.children[1].x == 10)
    assert(nested.children[1].y == 70)

    assert(nested.children[2].x == 70)
    assert(nested.children[2].y == 70)
end

---Tests the actual frame hierarchy and relative positioning.
local function TestRenderNestedFramePositions()
    local view = UI.VStack({
        UI.View():size(100, 40),

        UI.HStack({
            UI.View():size(50, 30),
            UI.View():size(70, 30),
        }):spacing(10),
    })
        :spacing(20)
        :padding(10)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local root = UI._Render.Render(view, arranged, UIParent)

    ---@cast root DeclarusMockFrame

    -- Verify root frame.
    assert(root.width == 150)
    assert(root.height == 110)

    -- Verify child hierarchy.
    assert(#root.children == 2)

    local first = root.children[1]
    local nested = root.children[2]

    assert(first.parent == root)
    assert(nested.parent == root)

    -- Verify first child position.
    assert(first.points[1].x == 10)
    assert(first.points[1].y == -10)

    -- Verify nested HStack position.
    assert(nested.points[1].x == 10)
    assert(nested.points[1].y == -70)

    -- Verify nested children.
    assert(#nested.children == 2)

    local nestedFirst = nested.children[1]
    local nestedSecond = nested.children[2]

    assert(nestedFirst.parent == nested)
    assert(nestedSecond.parent == nested)

    -- Positions must be relative to the HStack.
    assert(nestedFirst.points[1].x == 0)
    assert(nestedFirst.points[1].y == 0)

    assert(nestedSecond.points[1].x == 60)
    assert(nestedSecond.points[1].y == 0)
end

local function TestRenderNestedFillWithinWrapStack()
    local view = UI.VStack({
        UI.View():size(300, 60),

        UI.HStack({
            UI.View()
                :size(UI.Size.Fill, 50)
                :backgroundColor(UI.Color.RGB(0, 150, 255)),

            UI.View()
                :size(UI.Size.Fill, 50)
                :backgroundColor(UI.Color.RGB(0, 150, 255)),
        })
            :spacing(20)
            :padding(UI.Edge.Horizontal, 20)
            :width(UI.Size.Fill),
    })
        :padding(20)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local root = UI._Render.Render(view, arranged, UIParent)

    ---@cast root DeclarusMockFrame

    local hstack = root.children[2]

    assert(hstack.width == 300)

    local first = hstack.children[1]
    local second = hstack.children[2]

    assert(first.width == 120)
    assert(second.width == 120)

    assert(first.height == 50)
    assert(second.height == 50)

    assert(#first.textures == 1)
    assert(#second.textures == 1)
end

local function TestRenderText()
    local view = UI.Text("Hello World")

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local frame = UI._Render.Render(view, arranged, UIParent)

    ---@cast frame DeclarusMockFrame

    assert(#frame.fontStrings == 1)

    local fontString = frame.fontStrings[1]

    assert(fontString.text == "Hello World")
    assert(fontString.fontSize == 16)
    assert(fontString.font == "Fonts\\FRIZQT__.TTF")
end

local function TestRenderLocalizedText()
    SetMockLocale("deDE")

    local L = _G.Declarus.Localization.Create("RenderTextTests")

    L:Register("enUS", {
        TITLE = "Hello World",
    })

    L:Register("deDE", {
        TITLE = "Hallo Welt",
    })

    local view = UI.Text("TITLE")
        :localize(L)

    local measured = UI._Measure.Measure(view)
    local arranged = UI._Arrange.Arrange(view, measured)

    local frame = UI._Render.Render(view, arranged, UIParent)

    ---@cast frame DeclarusMockFrame

    assert(#frame.fontStrings == 1)
    assert(frame.fontStrings[1].text == "Hallo Welt")

    SetMockLocale("enUS")
end

-- ============================================================================
-- Title:       Export
-- Description: Exposes tests to the test runner
-- ============================================================================

return {
    TestRenderView = TestRenderView,
    TestRenderSize = TestRenderSize,
    TestRenderPosition = TestRenderPosition,
    TestRenderBackground = TestRenderBackground,
    TestRenderWithoutBackground = TestRenderWithoutBackground,
    TestRenderNestedStacks = TestRenderNestedStacks,
    TestRenderNestedFramePositions = TestRenderNestedFramePositions,
    TestRenderNestedFillWithinWrapStack = TestRenderNestedFillWithinWrapStack,
    TestRenderText = TestRenderText,
    TestRenderLocalizedText = TestRenderLocalizedText,
}