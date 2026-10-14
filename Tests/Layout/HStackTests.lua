-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Tests/UI/Layout/HStackTests
-- Description: Tests horizontal stack creation and nesting.
-- ============================================================================

-- ============================================================================
-- Title:       Locals
-- Description: Defines dependencies for horizontal stack tests.
-- ============================================================================

local UI = _G.Declarus.UI

-- ============================================================================
-- Title:       Tests
-- Description: Defines horizontal stack test cases.
-- ============================================================================

---Tests horizontal stack creation.
local function TestHStackCreation()
    local first = UI._View.New("First")
    local second = UI._View.New("Second")

    local stack = UI.HStack({
        first,
        second,
    })

    assert(stack.kind == "HStack")
    assert(#stack.children == 2)
    assert(stack.children[1] == first)
    assert(stack.children[2] == second)
end

---Tests stack-specific layout modifiers
local function TestHStackLayoutModifiers()
    local stack = UI.HStack({})
        :size(320, 100)
        :spacing(8)
        :alignment(UI.Alignment.Center)
        :padding(16)

    assert(stack.kind == "HStack")
    assert(stack.properties.width == 320)
    assert(stack.properties.height == 100)
    assert(stack.properties.spacing == 8)
    assert(stack.properties.alignment == UI.Alignment.Center)
    assert(stack.properties.padding.top == 16)
end

---Tests inherited view modifiers.
local function TestHStackModifiers()
    local stack = UI.HStack({})
        :size(320, 100)
        :padding(16)

    assert(stack.properties.width == 320)
    assert(stack.properties.height == 100)

    local padding = stack.properties.padding

    assert(padding ~= nil)
    assert(padding.top == 16)
    assert(padding.bottom == 16)
    assert(padding.left == 16)
    assert(padding.right == 16)
end

---Tests independent child modifiers.
local function TestHStackChildrenModifiers()
    local first = UI._View.New("First")

    local stack = UI.HStack({
        first
            :padding(20)
            :padding(UI.Edge.Bottom, 10)
            :visible(false),
    })
        :padding(25)

    assert(stack.children[1] == first)

    local stackPadding = stack.properties.padding
    local childPadding = first.properties.padding

    assert(stackPadding ~= nil)
    assert(childPadding ~= nil)

    assert(stackPadding.top == 25)
    assert(stackPadding.bottom == 25)

    assert(childPadding.top == 20)
    assert(childPadding.bottom == 30)
    assert(childPadding.left == 20)
    assert(childPadding.right == 20)

    assert(first.properties.visible == false)
end

---Tests nested horizontal and vertical stacks.
local function TestNestedStacks()
    local view = UI.HStack({
        UI._View.New("Button"),

        UI.VStack({
            UI._View.New("Title"),
            UI._View.New("Description"),
        })
        :padding(8),
    })
    :padding(16)

    assert(view.kind == "HStack")
    assert(#view.children == 2)

    local inner = view.children[2]

    assert(inner.kind == "VStack")
    assert(#inner.children == 2)

    local outerPadding = view.properties.padding
    local innerPadding = inner.properties.padding

    assert(outerPadding ~= nil)
    assert(innerPadding ~= nil)

    assert(outerPadding.top == 16)
    assert(innerPadding.top == 8)
end

-- ============================================================================
-- Title:       Test Execution
-- Description: Executes horizontal stack tests.
-- ============================================================================

TestHStackCreation()
TestHStackLayoutModifiers()
TestHStackModifiers()
TestHStackChildrenModifiers()
TestNestedStacks()

print("Declarus HStackTests: \27[32m✓ passed\27[0m")