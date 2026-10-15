
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/UI/Layout/VStackTests
-- Description: Tests vertical stack creation and nesting.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies for vertical stack tests.
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Tests
-- Description: Defines vertical stack test cases.
-- ============================================================================

---Tests vertical stack creation.
local function TestVStackCreation()
    local first = UI._View.New("First")
    local second = UI._View.New("Second")

    local stack = UI.VStack({
        first,
        second,
    })

    assert(stack.kind == "VStack")
    assert(#stack.children == 2)
    assert(stack.children[1] == first)
    assert(stack.children[2] == second)
end

---Tests stack-specific layout modifiers.
local function TestVStackLayoutModifiers()
    local stack = UI.VStack({})
        :size(320, 200)
        :spacing(12)
        :alignment(UI.Alignment.Left)
        :padding(20)

    assert(stack.kind == "VStack")
    assert(stack.properties.width == 320)
    assert(stack.properties.height == 200)
    assert(stack.properties.spacing == 12)
    assert(stack.properties.alignment == UI.Alignment.Left)
    assert(stack.properties.padding.left == 20)
end

---Tests nested horizontal and vertical stacks.
local function TestNestedStacks()
    local view = UI.VStack({
        UI._View.New("Title"),

        UI.HStack({
            UI._View.New("ButtonA"),
            UI._View.New("ButtonB"),
        })
        :padding(8),
    })
    :padding(16)

    assert(view.kind == "VStack")
    assert(#view.children == 2)

    local inner = view.children[2]

    assert(inner.kind == "HStack")
    assert(#inner.children == 2)
    assert(inner.properties.padding.top == 8)
    assert(view.properties.padding.top == 16)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes vertical stack tests.
-- ============================================================================

return {
    TestVStackCreation = TestVStackCreation,
    TestVStackLayoutModifiers = TestVStackLayoutModifiers,
    TestNestedStacks = TestNestedStacks,
}