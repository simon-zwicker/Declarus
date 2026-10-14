
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

local function TestHStackPadding()
    local view = UI.HStack({
        UI.VStack({}):size(100, 40),
        UI.VStack({}):size(80, 40),
    })
        :spacing(10)
        :padding(20)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.width == 230)
    assert(result.height == 80)

    assert(result.children[1].x == 20)
    assert(result.children[1].y == 20)

    assert(result.children[2].x == 130)
    assert(result.children[2].y == 20)
end

local function TestVStackPadding()
    local view = UI.VStack({
        UI.HStack({}):size(100, 40),
        UI.HStack({}):size(80, 30),
    })
        :spacing(10)
        :padding(15)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.width == 130)
    assert(result.height == 110)

    assert(result.children[1].x == 15)
    assert(result.children[1].y == 15)

    assert(result.children[2].x == 15)
    assert(result.children[2].y == 65)
end

local function TestNestedPadding()
    local view = UI.HStack({
        UI.VStack({
            UI.HStack({}):size(80, 30),
        }):padding(10),
    }):padding(20)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured, 50, 100)

    assert(result.children[1].x == 70)
    assert(result.children[1].y == 120)

    assert(result.children[1].children[1].x == 80)
    assert(result.children[1].children[1].y == 130)
end

local function TestHStackCenterAlignment()
    local view = UI.HStack({
        UI.VStack({}):size(100, 30),
        UI.VStack({}):size(80, 50),
    })
        :spacing(10)
        :alignment(UI.Alignment.Center)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.width == 190)
    assert(result.height == 50)

    assert(result.children[1].x == 0)
    assert(result.children[1].y == 10)

    assert(result.children[2].x == 110)
    assert(result.children[2].y == 0)
end

local function TestHStackStretch()
    local view = UI.HStack({
        UI.VStack({}):size(100, 30),
        UI.VStack({}):width(80),
        UI.VStack({}):size(60, 50),
    })
        :alignment(UI.Alignment.Stretch)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.height == 50)

    -- Explicit height must remain unchanged.
    assert(result.children[1].height == 30)

    -- Flexible height stretches to available space.
    assert(result.children[2].height == 50)

    assert(result.children[3].height == 50)

    -- All children start at the same Y position.
    assert(result.children[1].y == 0)
    assert(result.children[2].y == 0)
    assert(result.children[3].y == 0)
end

local function TestVStackStretch()
    local view = UI.VStack({
        UI.HStack({}):size(80, 30),
        UI.HStack({}):height(40),
        UI.HStack({}):size(120, 50),
    })
        :alignment(UI.Alignment.Stretch)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.width == 120)

    -- Explicit width must remain unchanged.
    assert(result.children[1].width == 80)

    -- Flexible width stretches.
    assert(result.children[2].width == 120)

    assert(result.children[3].width == 120)

    assert(result.children[1].x == 0)
    assert(result.children[2].x == 0)
    assert(result.children[3].x == 0)
end

local function TestStretchWithPadding()
    local view = UI.HStack({
        UI.VStack({}):width(80),
        UI.VStack({}):size(100, 60),
    })
        :padding(10)
        :alignment(UI.Alignment.Stretch)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    assert(result.height == 80)

    -- Available height: 80 - 10 - 10 = 60.
    assert(result.children[1].height == 60)

    assert(result.children[1].x == 10)
    assert(result.children[1].y == 10)

    assert(result.children[2].height == 60)
    assert(result.children[2].y == 10)
end

local function TestStretchDoesNotModifyMeasure()
    local view = UI.HStack({
        UI.VStack({}):width(80),
        UI.VStack({}):size(100, 60),
    })
        :alignment(UI.Alignment.Stretch)

    local measured = UI._Measure.Measure(view)

    local originalHeight = measured.children[1].height

    local result = UI._Arrange.Arrange(view, measured)

    assert(result.children[1].height == 60)

    -- Arrange must not mutate Measure results.
    assert(measured.children[1].height == originalHeight)
end

local function TestNestedStretchWithFill()
    local view = UI.HStack({
        UI.VStack({
            UI._View.New("View"):height(UI.Size.Fill),
        }):width(100),

        UI.VStack({}):size(100, 200),
    })
        :alignment(UI.Alignment.Stretch)

    local measured = UI._Measure.Measure(view)
    local result = UI._Arrange.Arrange(view, measured)

    -- Parent dimensions.
    assert(result.width == 200)
    assert(result.height == 200)

    -- First VStack stretches to 200.
    assert(result.children[1].width == 100)
    assert(result.children[1].height == 200)

    -- Fill child must receive the stretched height.
    assert(result.children[1].children[1].height == 200)

    -- Second VStack keeps its explicit dimensions.
    assert(result.children[2].width == 100)
    assert(result.children[2].height == 200)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes all arrange tests.
-- ============================================================================

return {
    TestHStackArrange = TestHStackArrange,
    TestVStackArrange = TestVStackArrange,
    TestNestedArrange = TestNestedArrange,
    TestHStackPadding = TestHStackPadding,
    TestVStackPadding = TestVStackPadding,
    TestNestedPadding = TestNestedPadding,
    TestHStackCenterAlignment = TestHStackCenterAlignment,
    TestHStackStretch = TestHStackStretch,
    TestVStackStretch = TestVStackStretch,
    TestStretchWithPadding = TestStretchWithPadding,
    TestStretchDoesNotModifyMeasure = TestStretchDoesNotModifyMeasure,
    TestNestedStretchWithFill = TestNestedStretchWithFill,
}