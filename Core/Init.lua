
-- ============================================================================
-- Declarus
-- ============================================================================
-- Title:       Core/Init
-- Description: Initializes the Declarus namespace
-- ============================================================================

-- ============================================================================
-- Title:       Type Annotations
-- Description: Defines type annotations for the Declarus namespace
-- ============================================================================

---@class Declarus
---@field Client DeclarusClient
---@field UI DeclarusUI
---@field Localization DeclarusLocalizationManager

-- ============================================================================
-- Title:       Locals
-- Description: Defines the Declarus namespace
-- ============================================================================

local Declarus = {}

---@cast Declarus Declarus

-- ============================================================================
-- Title:       Global Assignment
-- Description: Registers the Declarus namespace globally
-- ============================================================================

_G.Declarus = Declarus

