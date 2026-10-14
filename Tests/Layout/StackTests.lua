
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/UI/Layout/StackTests
-- Description: Tests shared stack functionality and inherited modifiers.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies for stack tests.
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Tests
-- Description: Defines test cases for stack functionality.
-- ============================================================================

---Tests stack creation.
local function TestStackCreation()
    local first = UI._View.New("First")
    local second = UI._View.New("Second")

    local stack = UI._Stack.New("HStack", {
        first,
        second,
    })

    assert(stack.kind == "HStack")
    assert(#stack.children == 2)
    assert(stack.children[1] == first)
    assert(stack.children[2] == second)
end

---Tests stack-specific modifiers.
local function TestStackModifiers()
    local stack = UI._Stack.New("HStack")
        :spacing(8)
        :alignment(UI.Alignment.Center)

    assert(stack.properties.spacing == 8)
    assert(stack.properties.alignment == UI.Alignment.Center)
end

---Tests inherited view modifiers and method chaining.
local function TestInheritedModifiers()
    local stack = UI._Stack.New("HStack")
        :size(320, 100)
        :padding(16)
        :spacing(8)
        :alignment(UI.Alignment.Center)
        :visible(false)

    assert(stack.properties.width == 320)
    assert(stack.properties.height == 100)
    assert(stack.properties.padding.top == 16)
    assert(stack.properties.spacing == 8)
    assert(stack.properties.alignment == UI.Alignment.Center)
    assert(stack.properties.visible == false)
end

---Tests modifier chaining in different orders.
local function TestModifierChaining()
    local stack = UI._Stack.New("VStack")
        :spacing(8)
        :padding(16)
        :alignment(UI.Alignment.Start)
        :width(UI.Size.Fill)
        :spacing(12)

    assert(stack.properties.spacing == 12)
    assert(stack.properties.padding.left == 16)
    assert(stack.properties.alignment == UI.Alignment.Start)
    assert(stack.properties.width == UI.Size.Fill)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes all stack test cases.
-- ============================================================================

return {
    TestStackCreation = TestStackCreation,
    TestStackModifiers = TestStackModifiers,
    TestInheritedModifiers = TestInheritedModifiers,
    TestModifierChaining = TestModifierChaining,
}