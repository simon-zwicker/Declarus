-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       UI/Init
-- Description: Initializes the DeclarusUI namespace
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines type annotations for the DeclarusUI namespace
-- ============================================================================

---@class DeclarusAlignmentValues
---@field Start DeclarusAlignment
---@field Center DeclarusAlignment
---@field End DeclarusAlignment
---@field Stretch DeclarusAlignment

---@class DeclarusSizeValues
---@field Wrap DeclarusSize
---@field Fill DeclarusSize

---@class DeclarusEdgeValues
---@field All DeclarusEdge
---@field Top DeclarusEdge
---@field Bottom DeclarusEdge
---@field Left DeclarusEdge
---@field Right DeclarusEdge
---@field Horizontal DeclarusEdge
---@field Vertical DeclarusEdge

---@class DeclarusUI
---@field Alignment DeclarusAlignmentValues
---@field Size DeclarusSizeValues
---@field Edge DeclarusEdgeValues
---@field Color DeclarusColorFactory
---@field HStack fun(children: DeclarusView[]): DeclarusView
---@field VStack fun(children: DeclarusView[]): DeclarusView
---@field _View DeclarusViewClass
---@field _Stack DeclarusStackClass

-- ============================================================================
-- Title:       Locals
-- Description: Defines the DeclarusUI namespace
-- ============================================================================

local UI = {} 

---@cast UI DeclarusUI

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the UI namespace within Declarus
-- ============================================================================

_G.Declarus.UI = UI