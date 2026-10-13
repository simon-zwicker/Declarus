
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Layout/Stack
-- Description: Defines shared layout behavior for stack components.
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines stack properties and types.
-- ============================================================================

---@class DeclarusStackProperties: DeclarusViewProperties
---@field spacing? number
---@field alignment? DeclarusAlignment

---@class DeclarusStack: DeclarusView
---@field properties DeclarusStackProperties
---@field spacing fun(self: DeclarusStack, value: number): DeclarusStack
---@field alignment fun(self: DeclarusStack, value: DeclarusAlignment): DeclarusStack

---@class DeclarusStackClass
---@field New fun(kind: string, children?: DeclarusView[]): DeclarusStack

-- ============================================================================
-- Title:       Locals
-- Description: Defines local dependencies and the stack prototype.
-- ============================================================================

local UI = _G.Declarus.UI
local View = UI._View

local Stack = {}
Stack.__index = Stack

setmetatable(Stack, { __index = View })

-- ============================================================================
-- Title:       Implementation
-- Description: Implements stack creation and layout modifiers.
-- ============================================================================

---Creates a new stack view.
---@param kind string
---@param children? DeclarusView[]
---@return DeclarusStack
function Stack.New(kind, children)
    local instance = View.New(kind, children)

    setmetatable(instance, Stack)

    ---@cast instance DeclarusStack
    return instance
end

-- ============================================================================
-- Title:       Layout Modifiers
-- Description: Configures spacing and alignment for stacks.
-- ============================================================================

---Sets the spacing between stack children.
---@param self DeclarusStack
---@param value number
---@return DeclarusStack
function Stack:spacing(value)
    self.properties.spacing = value
    return self
end

---Sets the cross-axis alignment of stack children.
---@param self DeclarusStack
---@param value DeclarusAlignment
---@return DeclarusStack
function Stack:alignment(value)
    self.properties.alignment = value
    return self
end

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the internal stack prototype within Declarus UI.
-- ============================================================================

---@cast Stack DeclarusStackClass

UI._Stack = Stack