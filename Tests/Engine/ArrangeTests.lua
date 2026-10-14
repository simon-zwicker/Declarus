
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Engine/ArrangeTests
-- Description: Tests declarative layout positioning.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: References Declarus UI components.
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Tests
-- Description: Verifies calculated layout positions.
-- ============================================================================

local function TestHStackArrange()
    local view = UI.HStack({
        UI.VStack({}):size(100, 40),
        UI.VStack({}):size(150, 60),
    })
        :spacing(10)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.x == 0)
    assert(result.y == 0)

    assert(result.width == 260)
    assert(result.height == 60)

    assert(result.children[1].x == 0)
    assert(result.children[1].y == 0)

    assert(result.children[2].x == 110)
    assert(result.children[2].y == 0)
end

local function TestVStackArrange()
    local view = UI.VStack({
        UI.HStack({}):size(100, 40),
        UI.HStack({}):size(150, 60),
    })
        :spacing(10)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.width == 150)
    assert(result.height == 110)

    assert(result.children[1].x == 0)
    assert(result.children[1].y == 0)

    assert(result.children[2].x == 0)
    assert(result.children[2].y == 50)
end

local function TestNestedArrange()
    local view = UI.HStack({
        UI.VStack({
            UI.HStack({}):size(80, 30),
            UI.HStack({}):size(80, 40),
        })
            :spacing(5),

        UI.VStack({}):size(100, 50),
    })
        :spacing(10)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured, 20, 30)

    assert(result.x == 20)
    assert(result.y == 30)

    assert(result.children[1].x == 20)
    assert(result.children[1].y == 30)

    assert(result.children[1].children[1].x == 20)
    assert(result.children[1].children[1].y == 30)

    assert(result.children[1].children[2].x == 20)
    assert(result.children[1].children[2].y == 65)

    assert(result.children[2].x == 110)
    assert(result.children[2].y == 30)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes all arrange tests.
-- ============================================================================

return {
    TestHStackArrange = TestHStackArrange,
    TestVStackArrange = TestVStackArrange,
    TestNestedArrange = TestNestedArrange,
}