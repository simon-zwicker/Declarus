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
---@field Top DeclarusAlignment
---@field Bottom DeclarusAlignment
---@field Left DeclarusAlignment
---@field Right DeclarusAlignment
---@field Center DeclarusAlignment
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
---@field ScrollView fun(content: DeclarusView): DeclarusView
---@field Button fun(label: string, callback: fun(button: string)): DeclarusControl
---@field TextField fun(value: string, callback?: fun(value: string)): DeclarusControl
---@field Slider fun(value: number, minimum: number, maximum: number, step?: number, callback?: fun(value: number)): DeclarusControl
---@field Toggle fun(value: boolean, callback?: fun(value: boolean)): DeclarusControl
---@field Dropdown fun(options: string[], value: string, callback?: fun(value: string)): DeclarusControl
---@field _ControlRender DeclarusControlRenderer
---@field Alignment DeclarusAlignmentValues
---@field Size DeclarusSizeValues
---@field Edge DeclarusEdgeValues
---@field Color DeclarusColorFactory
---@field HStack fun(children: DeclarusView[]): DeclarusStack
---@field VStack fun(children: DeclarusView[]): DeclarusStack
---@field View fun(): DeclarusView
---@field Mount fun(view: DeclarusView, parent: Frame): DeclarusMountHandle
---@field Text fun(value: string): DeclarusTextView
---@field _View DeclarusViewClass
---@field _Stack DeclarusStackClass
---@field _Measure DeclarusMeasureEngine
---@field _Arrange DeclarusArrangeEngine
---@field _Render DeclarusRenderEngine
---@field _LocalizationResolver DeclarusLocalizationResolver
---@field _TextView DeclarusTextView
---@field _FontResolver DeclarusFontResolver
---@field _TextMeasure DeclarusTextMeasure

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
