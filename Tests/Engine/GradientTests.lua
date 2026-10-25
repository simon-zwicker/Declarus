local UI = _G.Declarus.UI
local function render(view)
    local frame = UI._Render.Render(view, UI._Arrange.Arrange(view, UI._Measure.Measure(view)), UIParent)
    ---@cast frame DeclarusMockFrame
    return frame
end
return {
    TestGradientWithoutImage = function()
        local view = UI.View():size(120, 40):gradient("HORIZONTAL", UI.Color.RGB(255, 0, 0), UI.Color.RGB(0, 0, 255))
        local frame = render(view)
        assert(frame.width == 120 and frame.height == 40 and #frame.textures == 1)
        local texture = frame.textures[1]
        assert(texture.color[1] == 1 and texture.color[2] == 1 and texture.color[3] == 1)
        assert(texture.layer == "BORDER" and texture.allPoints == frame)
        assert(texture.gradient.orientation == "HORIZONTAL")
        assert(texture.gradient.fromColor[1] == 1 and texture.gradient.toColor[3] == 1)
    end,
    TestGradientAlphaAndCoordinates = function()
        local texture = render(UI.View():texture(134400):texCoords(0.1, 0.9, 0.2, 0.8)
            :textureLayer("ARTWORK", 2):gradient("VERTICAL", UI.Color.RGBA(255, 255, 255, 0), UI.Color.RGBA(255, 255, 255, 0.8))).textures[1]
        assert(texture.source == 134400 and texture.texCoords[1] == 0.1 and texture.sublevel == 2)
        assert(texture.gradient.orientation == "VERTICAL")
        assert(texture.gradient.fromColor[4] == 0 and texture.gradient.toColor[4] == 0.8)
    end,
    TestTintMultipliesBothGradientEndpoints = function()
        local view = UI.View():gradient("HORIZONTAL", {1, 0.5, 0.25, 0.4}, {0.2, 1, 0.5, 0.8})
            :textureTint({0.5, 0.2, 1, 0.5})
        local gradient = assert(render(view).textures[1].gradient)
        assert(gradient.fromColor[1] == 0.5 and gradient.fromColor[2] == 0.1 and gradient.fromColor[4] == 0.2)
        assert(gradient.toColor[1] == 0.1 and gradient.toColor[2] == 0.2 and gradient.toColor[4] == 0.4)
        assert(view.properties.gradient.fromColor[1] == 1) -- stored colors are not modified
    end,
    TestEveryComponentInheritsGradient = function()
        for _, view in ipairs({UI.View(), UI.Text("A"), UI.Button("A", function() end), UI.TextField("A"),
            UI.Slider(1, 0, 2), UI.Toggle(true), UI.Dropdown({"A"}, "A"), UI.HStack({}), UI.VStack({}), UI.ScrollView(UI.View():size(20, 40))}) do
            assert(view:gradient("HORIZONTAL", UI.Color.RGB(20, 40, 60), UI.Color.RGB(80, 100, 120)) == view)
            local found = false
            for _, texture in ipairs(render(view).textures) do if texture.gradient then found = true end end
            assert(found, view.kind)
        end
    end,
    TestBackgroundAndLabelStayIndependent = function()
        local frame = render(UI.Button("Readable", function() end):backgroundColor(UI.Color.RGB(20, 40, 60))
            :foregroundColor(UI.Color.RGB(255, 255, 255)):gradient("HORIZONTAL", {1, 0, 0, 1}, {0, 0, 1, 1}):opacity(0.5))
        assert(frame.textures[1].layer == "BACKGROUND" and not frame.textures[1].gradient)
        assert(frame.textures[2].gradient and frame.fontStrings[1].layer == "OVERLAY")
        assert(frame.fontStrings[1].color[1] == 1 and frame.alpha == 0.5)
    end,
    TestColorSnapshotValidationAndClearing = function()
        local from, to = {1, 0, 0}, {0, 1, 0}
        local view = UI.View():gradient("HORIZONTAL", from, to)
        from[1], to[2] = 0, 0
        assert(view.properties.gradient.fromColor[1] == 1 and view.properties.gradient.toColor[2] == 1)
        assert(view.properties.gradient.fromColor[4] == 1)
        local invalid = view
        ---@cast invalid any
        assert(not pcall(function() invalid:gradient("DIAGONAL", from, to) end))
        assert(not pcall(function() invalid:gradient("HORIZONTAL", {2, 0, 0}, to) end))
        assert(not pcall(function() invalid:gradient("HORIZONTAL", from) end))
        assert(not pcall(function() invalid:gradient(nil, from, to) end))
        assert(view.properties.gradient.fromColor[1] == 1)
        assert(view:gradient(nil) == view and view.properties.gradient == nil)
        assert(#render(view).textures == 0)
    end,
    TestClearingKeepsImageAndTint = function()
        local view = UI.View():texture(134400):textureTint({0.5, 1, 1, 0.3})
            :gradient("HORIZONTAL", {1, 0, 0, 1}, {0, 1, 0, 1}):gradient(nil)
        local texture = render(view).textures[1]
        assert(texture.source == 134400 and not texture.gradient)
        assert(texture.vertexColor[1] == 0.5 and texture.vertexColor[4] == 0.3)
    end,
    TestUnavailableNativeAPIReportsError = function()
        local unavailable = {}
        ---@cast unavailable any
        local ok, message = pcall(_G.Declarus.Client._ApplyGradient, unavailable,
            "HORIZONTAL", {1, 0, 0, 1}, {0, 1, 0, 1})
        assert(not ok and tostring(message):find("Texture:SetGradient", 1, true))
    end,
    TestMountUpdateDoesNotKeepOldGradient = function()
        local handle = UI.Mount(UI.View():gradient("HORIZONTAL", {1, 0, 0, 1}, {0, 1, 0, 1}), UIParent)
        handle:Update(UI.View():texture(134400))
        local frame = handle.frame
        ---@cast frame DeclarusMockFrame
        assert(not frame.textures[1].gradient)
        handle:Unmount()
    end,
}
