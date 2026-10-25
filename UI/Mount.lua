local UI = _G.Declarus.UI

---@class DeclarusMountHandle
---@field frame Frame
---@field Update fun(self: DeclarusMountHandle, view: DeclarusView)
---@field Unmount fun(self: DeclarusMountHandle)

-- WoW frames cannot be destroyed. Retire old trees and remove event closures.
---@param frame Frame
local function release(frame)
    frame:Hide()
    for _, child in ipairs({frame:GetChildren()}) do release(child) end
    for _, event in ipairs({"OnClick", "OnTextChanged", "OnEscapePressed", "OnEnterPressed", "OnValueChanged", "OnMouseWheel", "OnHide"}) do
        if frame:HasScript(event) then frame:SetScript(event, nil) end
    end
    frame:UnregisterAllEvents()
    frame:SetParent(nil)
end

---@param view DeclarusView
---@param parent Frame
---@return DeclarusMountHandle
function UI.Mount(view, parent)
    assert(view and parent, "Mount requires view and parent")
    local host = CreateFrame("Frame", nil, parent)
    host:SetPoint("CENTER", parent, "CENTER", 0, 0)
    local active = true
    local handle = {}
    function handle:Update(nextView)
        assert(active, "Cannot update an unmounted view")
        assert(nextView and nextView.kind, "Update requires a view")
        local size = UI._Measure.Measure(nextView)
        local arranged = UI._Arrange.Arrange(nextView, size)
        local nextFrame = UI._Render.Render(nextView, arranged, host)
        if self.frame then release(self.frame) end
        self.frame = nextFrame
        host:SetSize(size.width, size.height)
    end
    function handle:Unmount()
        if not active then return end
        active = false
        release(host)
    end
    handle:Update(view)
    return handle
end
