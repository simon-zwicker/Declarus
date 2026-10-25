local UI = _G.Declarus.UI

---@class DeclarusControl: DeclarusTextView
---@field properties DeclarusControlProperties
---@class DeclarusControlProperties: DeclarusTextViewProperties
---@field value? string|number|boolean
---@field onClick? fun(button: string)
---@field onChange? fun(value: any)
---@field minimum? number
---@field maximum? number
---@field step? number
---@field options? string[]

---@param kind string
---@param width number
---@param height number
---@return DeclarusControl
local function control(kind, width, height)
    local view = UI._TextView.New(kind):size(width, height)
    return view
end

---@param label string
---@param callback fun(button: string)
---@return DeclarusControl
function UI.Button(label, callback)
    assert(type(label) == "string" and type(callback) == "function", "Button requires label and callback")
    local view = control("Button", 120, 28)
    view.properties.text = label
    view.properties.onClick = callback
    return view
end

---@param value string
---@param callback? fun(value: string)
---@return DeclarusControl
function UI.TextField(value, callback)
    assert(type(value) == "string", "TextField requires a string")
    local view = control("TextField", 180, 28)
    view.properties.value = value
    view.properties.onChange = callback
    return view
end

---@param value number
---@param minimum number
---@param maximum number
---@param step? number
---@param callback? fun(value: number)
---@return DeclarusControl
function UI.Slider(value, minimum, maximum, step, callback)
    assert(type(minimum) == "number" and type(maximum) == "number" and maximum > minimum, "Invalid slider range")
    assert(type(value) == "number" and value >= minimum and value <= maximum, "Slider value outside range")
    assert(step == nil or (type(step) == "number" and step > 0), "Slider step must be positive")
    local view = control("Slider", 180, 20)
    view.properties.value, view.properties.minimum, view.properties.maximum = value, minimum, maximum
    view.properties.step, view.properties.onChange = step or 1, callback
    return view
end

---@param value boolean
---@param callback? fun(value: boolean)
---@return DeclarusControl
function UI.Toggle(value, callback)
    assert(type(value) == "boolean", "Toggle requires a boolean")
    local view = control("Toggle", 26, 26)
    view.properties.value, view.properties.onChange = value, callback
    return view
end

---A portable inline selection menu; no client-specific dropdown templates.
---@param options string[]
---@param value string
---@param callback? fun(value: string)
---@return DeclarusControl
function UI.Dropdown(options, value, callback)
    assert(type(options) == "table" and #options > 0, "Dropdown requires options")
    local found = false
    local copy = {}
    for i, option in ipairs(options) do
        assert(type(option) == "string", "Dropdown options must be strings")
        copy[i] = option
        if option == value then found = true end
    end
    assert(found, "Dropdown value must be an option")
    local view = control("Dropdown", 180, 28)
    view.properties.options, view.properties.value, view.properties.onChange = copy, value, callback
    return view
end

---A vertically scrollable viewport. Set an explicit viewport size.
---@param content DeclarusView
---@return DeclarusView
function UI.ScrollView(content)
    assert(type(content) == "table" and content.kind, "ScrollView requires content")
    return UI._View.New("ScrollView", {content}):size(240, 180)
end
