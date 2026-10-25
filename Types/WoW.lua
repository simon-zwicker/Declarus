---@meta
-- Minimal WoW API surface used by Declarus. Editor-only; never loaded by the TOC.

---@class Texture
---@field SetAllPoints fun(self: Texture, frame: Frame)
---@field SetColorTexture fun(self: Texture, r: number, g: number, b: number, a?: number)
---@field SetTexture fun(self: Texture, source: string|number)
---@field SetTexCoord fun(self: Texture, left: number, right: number, top: number, bottom: number)
---@field SetVertexColor fun(self: Texture, r: number, g: number, b: number, a?: number)
---@field SetDrawLayer fun(self: Texture, layer: string, sublevel?: number)

---@class FontString
---@field SetFont fun(self: FontString, path: string, size: number, flags?: string): boolean
---@field SetText fun(self: FontString, text: string)
---@field SetTextColor fun(self: FontString, r: number, g: number, b: number, a?: number)
---@field SetPoint fun(self: FontString, point: string, relative: Frame, relativePoint: string, x: number, y: number)
---@field GetStringWidth fun(self: FontString): number
---@field GetStringHeight fun(self: FontString): number

---@class Frame
---@field SetSize fun(self: Frame, width: number, height: number)
---@field SetPoint fun(self: Frame, point: string, relative: Frame, relativePoint: string, x: number, y: number)
---@field CreateTexture fun(self: Frame, name?: string, layer?: string): Texture
---@field CreateFontString fun(self: Frame, name?: string, layer?: string): FontString
---@field SetAlpha fun(self: Frame, alpha: number)
---@field Hide fun(self: Frame)
---@field Show fun(self: Frame)
---@field IsShown fun(self: Frame): boolean
---@field SetFrameStrata fun(self: Frame, strata: string)
---@field SetScript fun(self: Frame, event: string, callback?: function)
---@field HasScript fun(self: Frame, event: string): boolean
---@field GetChildren fun(self: Frame): Frame ...
---@field SetParent fun(self: Frame, parent?: Frame)
---@field UnregisterAllEvents fun(self: Frame)
---@field EnableMouseWheel fun(self: Frame, enabled: boolean)
---@field GetObjectType fun(self: Frame): string

---@class Button: Frame
---@field RegisterForClicks fun(self: Button, ...: string)
---@field SetNormalTexture fun(self: Button, source: string|number)

---@class EditBox: Frame
---@field SetAutoFocus fun(self: EditBox, enabled: boolean)
---@field SetMultiLine fun(self: EditBox, enabled: boolean)
---@field SetFont fun(self: EditBox, path: string, size: number, flags?: string): boolean
---@field SetTextInsets fun(self: EditBox, left: number, right: number, top: number, bottom: number)
---@field SetText fun(self: EditBox, text: string)
---@field GetText fun(self: EditBox): string
---@field ClearFocus fun(self: EditBox)

---@class Slider: Frame
---@field SetOrientation fun(self: Slider, orientation: string)
---@field SetMinMaxValues fun(self: Slider, minimum: number, maximum: number)
---@field SetValueStep fun(self: Slider, step: number)
---@field SetThumbTexture fun(self: Slider, source: string|number)
---@field SetValue fun(self: Slider, value: number)

---@class CheckButton: Button
---@field SetCheckedTexture fun(self: CheckButton, source: string|number)
---@field SetChecked fun(self: CheckButton, checked: boolean)
---@field GetChecked fun(self: CheckButton): boolean

---@class ScrollFrame: Frame
---@field SetScrollChild fun(self: ScrollFrame, child: Frame)
---@field GetVerticalScroll fun(self: ScrollFrame): number
---@field SetVerticalScroll fun(self: ScrollFrame, offset: number)

---@type Frame
UIParent = nil

---@overload fun(frameType: 'Button', name?: string, parent?: Frame): Button
---@overload fun(frameType: 'EditBox', name?: string, parent?: Frame): EditBox
---@overload fun(frameType: 'Slider', name?: string, parent?: Frame): Slider
---@overload fun(frameType: 'CheckButton', name?: string, parent?: Frame): CheckButton
---@overload fun(frameType: 'ScrollFrame', name?: string, parent?: Frame): ScrollFrame
---@param frameType string
---@param name? string
---@param parent? Frame
---@return Frame
function CreateFrame(frameType, name, parent) end

---@type string?
STANDARD_TEXT_FONT = nil
---@type number?
WOW_PROJECT_ID = nil

---@return string version
---@return string build
---@return string date
---@return number interface
function GetBuildInfo() end

---@type table<string, fun(message: string)>
SlashCmdList = {}
---@type string
SLASH_DECLARUS1 = "/declarus"
