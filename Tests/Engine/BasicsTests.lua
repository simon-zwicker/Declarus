local UI = _G.Declarus.UI
local function render(view)
    return UI._Render.Render(view, UI._Arrange.Arrange(view, UI._Measure.Measure(view)), UIParent)
end
return {
    TestFontAndPadding = function()
        local view = UI.Text("abc"):font("custom.ttf", "OUTLINE"):fontSize(20):padding(7)
        local size = UI._Measure.Measure(view)
        local frame = render(view)
        local text = frame.fontStrings[1]
        assert(size.width == 44 and size.height == 34)
        assert(text.font == "custom.ttf" and text.fontSize == 20 and text.flags == "OUTLINE")
        assert(text.point.x == 7 and text.point.y == -7)
    end,
    TestTextureAppearance = function()
        local frame = render(UI.View():size(40, 50):texture(123):opacity(0.4):visible(false))
        assert(frame.textures[1].source == 123 and frame.textures[1].allPoints == frame)
        assert(frame.alpha == 0.4 and frame.hidden)
    end,
    TestFontDoesNotBleed = function()
        render(UI.Text("custom"):font("other.ttf", "OUTLINE"):fontSize(40))
        local view = UI.Text("abc")
        local size = UI._Measure.Measure(view)
        local text = render(view).fontStrings[1]
        assert(size.width == 24 and size.height == 16)
        assert(text.font == "Fonts\\FRIZQT__.TTF" and text.flags == "")
    end,
    TestTextureWithBackground = function()
        local frame = render(UI.View():texture("icon.blp"):backgroundColor(UI.Color.RGB(255, 0, 0)))
        assert(#frame.textures == 2 and frame.textures[1].layer == "BACKGROUND")
        assert(frame.textures[2].source == "icon.blp" and frame.textures[2].layer == "ARTWORK")
    end,
    TestFontValidation = function()
        assert(not pcall(function() UI.Text("x"):fontSize(0) end))
    end,
}
