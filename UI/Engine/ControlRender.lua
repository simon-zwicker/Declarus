local UI = _G.Declarus.UI

---@class DeclarusControlRenderer
local Controls = {}

---@param view DeclarusView
---@return string
function Controls.FrameType(view)
    local types = { Button = "Button", TextField = "EditBox", Slider = "Slider", Toggle = "CheckButton", Dropdown = "Button" }
    return types[view.kind] or "Frame"
end

---@param frame Frame
---@param view DeclarusView
function Controls.Apply(frame, view)
    ---@cast view DeclarusControl
    local p = view.properties
    local function changed(value)
        if p.value == value then return end
        p.value = value
        if p.onChange then p.onChange(value) end
    end
    if view.kind == "Button" then
        ---@cast frame Button
        frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        frame:SetScript("OnClick", function(_, button) p.onClick(button) end)
    elseif view.kind == "TextField" then
        ---@cast frame EditBox
        local initialValue = p.value
        assert(type(initialValue) == "string", "Invalid EditBox value")
        frame:SetAutoFocus(false)
        frame:SetMultiLine(false)
        frame:SetFont(UI._FontResolver.Resolve(p))
        frame:SetTextInsets(4, 4, 2, 2)
        frame:SetText(initialValue)
        frame:SetScript("OnTextChanged", function(self, userInput)
            if userInput then changed(self:GetText()) end
        end)
        frame:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
        frame:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    elseif view.kind == "Slider" then
        ---@cast frame Slider
        local initialValue = p.value
        assert(type(initialValue) == "number", "Invalid Slider value")
        frame:SetOrientation("HORIZONTAL")
        frame:SetMinMaxValues(p.minimum, p.maximum)
        frame:SetValueStep(p.step)
        frame:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
        frame:SetValue(initialValue)
        frame:SetScript("OnValueChanged", function(self, value)
            local rounded = math.max(p.minimum, math.min(p.maximum,
                p.minimum + math.floor((value - p.minimum) / p.step + 0.5) * p.step))
            if value ~= rounded then self:SetValue(rounded) end
            changed(rounded)
        end)
    elseif view.kind == "Toggle" then
        ---@cast frame CheckButton
        local initialValue = p.value
        assert(type(initialValue) == "boolean", "Invalid CheckButton value")
        frame:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
        frame:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
        frame:SetChecked(initialValue)
        frame:SetScript("OnClick", function(self) changed(self:GetChecked() and true or false) end)
    elseif view.kind == "Dropdown" then
        local label = frame:CreateFontString(nil, "OVERLAY")
        label:SetFont(UI._FontResolver.Resolve(p))
        label:SetPoint("LEFT", frame, "LEFT", 4, 0)
        label:SetText(p.value .. " v")
        local menu = CreateFrame("Frame", nil, frame)
        menu:SetSize(180, #p.options * 28)
        menu:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
        menu:SetFrameStrata("DIALOG")
        menu:Hide()
        for index, option in ipairs(p.options) do
            local row = CreateFrame("Button", nil, menu)
            row:SetSize(180, 28)
            row:SetPoint("TOPLEFT", menu, "TOPLEFT", 0, -(index - 1) * 28)
            local background = row:CreateTexture(nil, "BACKGROUND")
            background:SetAllPoints(row)
            background:SetColorTexture(0.1, 0.1, 0.1, 1)
            local text = row:CreateFontString(nil, "OVERLAY")
            text:SetFont(UI._FontResolver.Resolve(p))
            text:SetPoint("LEFT", row, "LEFT", 4, 0)
            text:SetText(option)
            row:SetScript("OnClick", function()
                label:SetText(option .. " v")
                menu:Hide()
                changed(option)
            end)
        end
        frame:SetScript("OnClick", function() if menu:IsShown() then menu:Hide() else menu:Show() end end)
        frame:SetScript("OnHide", function() menu:Hide() end)
    end
end
UI._ControlRender = Controls
