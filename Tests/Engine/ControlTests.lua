local UI = _G.Declarus.UI
local function render(view)
    local frame = UI._Render.Render(view, UI._Arrange.Arrange(view, UI._Measure.Measure(view)), UIParent)
    ---@cast frame DeclarusMockFrame
    return frame
end
return {
    TestButton = function()
        local clicked
        local frame = render(UI.Button("Save", function(button) clicked = button end))
        assert(frame:GetObjectType() == "Button" and frame.fontStrings[1].text == "Save")
        frame.scripts.OnClick(frame, "RightButton")
        assert(clicked == "RightButton")
    end,
    TestTextField = function()
        local calls = 0
        local view = UI.TextField("old", function(value) assert(value == "new"); calls = calls + 1 end)
        local frame = render(view)
        frame:SetText("new")
        frame.scripts.OnTextChanged(frame, false)
        assert(calls == 0)
        frame.scripts.OnTextChanged(frame, true)
        frame.scripts.OnTextChanged(frame, true)
        assert(calls == 1 and view.properties.value == "new" and frame.autoFocus == false)
    end,
    TestSlider = function()
        local calls = 0
        local frame = render(UI.Slider(0, 0, 10, 2, function(value) assert(value == 4); calls = calls + 1 end))
        assert(calls == 0)
        frame:SetValue(3.2)
        assert(frame.value == 4 and calls == 1)
    end,
    TestToggle = function()
        local result
        local frame = render(UI.Toggle(false, function(value) result = value end))
        frame:SetChecked(true)
        frame.scripts.OnClick(frame)
        assert(result == true)
    end,
    TestDropdown = function()
        local result
        local frame = render(UI.Dropdown({"one", "two"}, "one", function(value) result = value end))
        local menu = frame.children[1]
        assert(menu.hidden)
        frame.scripts.OnClick(frame)
        assert(menu:IsShown())
        menu.children[2].scripts.OnClick()
        assert(result == "two" and menu.hidden and frame.fontStrings[1].text == "two v")
    end,
    TestInvalidControls = function()
        assert(not pcall(UI.Slider, 4, 0, 2))
        assert(not pcall(UI.Dropdown, {"a"}, "b"))
        assert(not pcall(UI.Toggle, "yes"))
    end,
}
