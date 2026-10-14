-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/Engine/MeasureTests
-- Description: Tests automatic layout size calculations.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: References Declarus UI components.
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Tests
-- Description: Verifies measured sizes of declarative layouts.
-- ============================================================================

local function TestHStackMeasure()
    local view = UI.HStack({
        UI.VStack({})
            :size(100, 80),
        UI.VStack({})
            :size(150, 60),
    })
    :spacing(10)

    local size = UI._Measure.Measure(view)

    assert(size.width == 260)
    assert(size.height == 80)
end

local function TestVStackMeasure()
    local view = UI.VStack({
        UI.HStack({})
            :size(100, 40),
        UI.HStack({})
            :size(150, 60),
    })
    :spacing(10)

    local size = UI._Measure.Measure(view)

    assert(size.width == 150)
    assert(size.height == 110)
end

local function TestPaddingMeasure()
    local view = UI.HStack({
        UI.VStack({})
            :size(100, 50),
    })
    :padding(16)

    local size = UI._Measure.Measure(view)

    assert(size.width == 132)
    assert(size.height == 82)
end

local function TestNestedStackMeasure()
    local view = UI.VStack({
        UI.HStack({
            UI.VStack({})
                :size(100, 40),
            UI.VStack({})
                :size(80, 60),
        })
        :spacing(10),

        UI.HStack({})
            :size(150, 30),
    })
    :spacing(20)

    local size = UI._Measure.Measure(view)

    assert(size.width == 190)
    assert(size.height == 110)
end

local function TestFillWidth()
    local view = UI.HStack({})
        :width(UI.Size.Fill)
        :height(100)

    local size = UI._Measure.Measure(view, {
        width = 500,
        height = 300,
    })

    assert(size.width == 500)
    assert(size.height == 100)
end

local function TestFillHeight()
    local view = UI.VStack({})
        :width(200)
        :height(UI.Size.Fill)

    local size = UI._Measure.Measure(view, {
        width = 500,
        height = 300,
    })

    assert(size.width == 200)
    assert(size.height == 300)
end

local function TestFillSize()
    local view = UI.VStack({})
        :size(UI.Size.Fill, UI.Size.Fill)

    local size = UI._Measure.Measure(view, {
        width = 500,
        height = 300,
    })

    assert(size.width == 500)
    assert(size.height == 300)
end

local function TestHStackFillDistribution()
    local view = UI.HStack({
        UI.VStack({})
            :width(100),
        UI.VStack({})
            :width(UI.Size.Fill),
        UI.VStack({})
            :width(UI.Size.Fill),
    })
    :spacing(10)
    :width(500)

    local result = UI._Measure.Measure(view)

    assert(result.width == 500)
    assert(result.children[1].width == 100)
    assert(result.children[2].width == 190)
    assert(result.children[3].width == 190)
end

local function TestVStackFillDistribution()
    local view = UI.VStack({
        UI.HStack({})
            :height(100),
        UI.HStack({})
            :height(UI.Size.Fill),
        UI.HStack({})
            :height(UI.Size.Fill),
    })
    :spacing(10)
    :height(500)

    local result = UI._Measure.Measure(view)

    assert(result.height == 500)
    assert(result.children[1].height == 100)
    assert(result.children[2].height == 190)
    assert(result.children[3].height == 190)
end

local function TestMeasuredChildren()
    local view = UI.HStack({
        UI.VStack({})
            :size(100, 80),

        UI.VStack({
            UI.HStack({})
                :size(50, 20),
        })
        :size(150, 60),
    })
    :spacing(10)

    local result = UI._Measure.Measure(view)

    assert(result.width == 260)
    assert(result.height == 80)

    assert(#result.children == 2)

    assert(result.children[1].width == 100)
    assert(result.children[1].height == 80)

    assert(result.children[2].width == 150)
    assert(result.children[2].height == 60)

    assert(#result.children[2].children == 1)

    assert(result.children[2].children[1].width == 50)
    assert(result.children[2].children[1].height == 20)
end

local function TestNestedFillDistribution()
    local view = UI.HStack({
        UI.VStack({
            UI.HStack({})
                :height(40),

            UI.HStack({})
                :height(UI.Size.Fill),
        })
        :width(200)
        :height(UI.Size.Fill),
    })
    :size(500, 300)

    local result = UI._Measure.Measure(view)

    -- Root HStack
    assert(result.width == 500)
    assert(result.height == 300)

    local vStack = result.children[1]

    assert(vStack.width == 200)
    assert(vStack.height == 300)

    -- Nested HStacks
    assert(vStack.children[1].height == 40)
    assert(vStack.children[2].height == 260)
end

local function TestFillMatchesSiblingWithoutAvailableSize()
    local view = UI.HStack({
        UI.VStack({})
            :width(100),

        UI.VStack({})
            :width(UI.Size.Fill),
    })
        :spacing(10)
        :width(UI.Size.Wrap)

    local result = UI._Measure.Measure(view)

    assert(result.width == 210)
    assert(result.children[1].width == 100)
    assert(result.children[2].width == 100)
end

local function TestFillWithIntrinsicSize()
    local view = UI.HStack({
        UI.VStack({})
            :width(100),

        UI.VStack({
            UI.HStack({})
                :width(50),
        })
            :width(UI.Size.Fill),
    })
        :spacing(10)
        :width(UI.Size.Wrap)

    local result = UI._Measure.Measure(view)

    assert(result.width == 210)
    assert(result.children[1].width == 100)
    assert(result.children[2].width == 100)

    -- Intrinsic child size remains unchanged.
    assert(result.children[2].children[1].width == 50)
end

local function TestWrapWithAvailableSize()
    local view = UI.HStack({
        UI.VStack({})
            :width(100),
        UI.VStack({})
            :width(50),
    })
    :spacing(10)
    :width(UI.Size.Wrap)

    local result = UI._Measure.Measure(view, {
        width = 500,
        height = 300,
    })

    assert(result.width == 160)
end

local function TestHStackWrapFillMatchesLargestSibling()
    local view = UI.HStack({
        UI.VStack({}):width(100),
        UI.VStack({}):width(UI.Size.Fill),
        UI.VStack({}):width(UI.Size.Fill),
        UI.VStack({}):width(250),
    })
        :spacing(10)
        :width(UI.Size.Wrap)

    local result = UI._Measure.Measure(view)

    assert(result.width == 880)
    assert(result.children[1].width == 100)
    assert(result.children[2].width == 250)
    assert(result.children[3].width == 250)
    assert(result.children[4].width == 250)
end

local function TestVStackWrapFillMatchesLargestSibling()
    local view = UI.VStack({
        UI.HStack({}):height(40),
        UI.HStack({}):height(UI.Size.Fill),
        UI.HStack({}):height(UI.Size.Fill),
        UI.HStack({}):height(120),
    })
        :spacing(10)
        :height(UI.Size.Wrap)

    local result = UI._Measure.Measure(view)

    assert(result.height == 430)
    assert(result.children[1].height == 40)
    assert(result.children[2].height == 120)
    assert(result.children[3].height == 120)
    assert(result.children[4].height == 120)
end

local function TestFillMatchesLargestIntrinsicSibling()
    local view = UI.HStack({
        UI.VStack({
            UI.HStack({}):width(80),
        })
        :width(UI.Size.Fill),

        UI.VStack({
            UI.HStack({}):width(150),
        })
        :width(UI.Size.Fill),

        UI.VStack({})
            :width(100),
    })
    :spacing(10)
    :width(UI.Size.Wrap)

    local result = UI._Measure.Measure(view)

    assert(result.children[1].width == 150)
    assert(result.children[1].children[1].width == 80)

    assert(result.children[2].width == 150)
    assert(result.children[2].children[1].width == 150)

    assert(result.children[3].width == 100)
    assert(result.width == 420)
end

local function TestNestedFillWithUnknownCrossAxis()
    local view = UI.HStack({
        UI.VStack({
            UI.HStack({})
                :size(80, 40),

            UI.HStack({})
                :width(UI.Size.Fill)
                :height(30),
        })
        :width(UI.Size.Fill),
    })
    :width(300)

    local result = UI._Measure.Measure(view)

    assert(result.width == 300)
    assert(result.height == 70)

    local vStack = result.children[1]

    assert(vStack.width == 300)
    assert(vStack.height == 70)

    assert(vStack.children[1].width == 80)
    assert(vStack.children[1].height == 40)

    assert(vStack.children[2].width == 300)
    assert(vStack.children[2].height == 30)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes all measurement tests.
-- ============================================================================

return {
    TestHStackMeasure = TestHStackMeasure,
    TestVStackMeasure = TestVStackMeasure,
    TestPaddingMeasure = TestPaddingMeasure,
    TestNestedStackMeasure = TestNestedStackMeasure,
    TestFillWidth = TestFillWidth,
    TestFillHeight = TestFillHeight,
    TestFillSize = TestFillSize,
    TestHStackFillDistribution = TestHStackFillDistribution,
    TestVStackFillDistribution = TestVStackFillDistribution,
    TestMeasuredChildren = TestMeasuredChildren,
    TestNestedFillDistribution = TestNestedFillDistribution,
    TestFillMatchesSiblingWithoutAvailableSize = TestFillMatchesSiblingWithoutAvailableSize,
    TestFillWithIntrinsicSize = TestFillWithIntrinsicSize,
    TestWrapWithAvailableSize = TestWrapWithAvailableSize,
    TestHStackWrapFillMatchesLargestSibling = TestHStackWrapFillMatchesLargestSibling,
    TestVStackWrapFillMatchesLargestSibling = TestVStackWrapFillMatchesLargestSibling,
    TestFillMatchesLargestIntrinsicSibling = TestFillMatchesLargestIntrinsicSibling,
    TestNestedFillWithUnknownCrossAxis = TestNestedFillWithUnknownCrossAxis,
}