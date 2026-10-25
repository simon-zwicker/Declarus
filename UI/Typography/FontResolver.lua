local UI = _G.Declarus.UI

---@class DeclarusFontResolver
local FontResolver = {}

---Shared font configuration for measurement and rendering.
---@param properties DeclarusTextViewProperties
---@return string path
---@return number size
---@return string flags
function FontResolver.Resolve(properties)
    return properties.font or "Fonts\\FRIZQT__.TTF", properties.fontSize or 16, properties.fontFlags or ""
end

UI._FontResolver = FontResolver
