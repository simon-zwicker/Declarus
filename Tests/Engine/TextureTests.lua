local UI = _G.Declarus.UI

---@param view DeclarusView
---@return DeclarusMockFrame
local function render(view)
    local frame = UI._Render.Render(view, UI._Arrange.Arrange(view, UI._Measure.Measure(view)), UIParent)
    ---@cast frame DeclarusMockFrame
    return frame
end

return {
    TestDefaultTextureBehindLabel = function()
        local frame = render(UI.Button("Readable", function() end):texture("white.blp"))
        assert(frame.textures[1].layer == "BACKGROUND")
        assert(frame.textures[2].layer == "BORDER" and frame.textures[2].sublevel == 0)
        assert(frame.fontStrings[1].layer == "OVERLAY" and frame.fontStrings[1].text == "Readable")
        assert(frame.textures[2].texCoords == nil and frame.textures[2].vertexColor == nil)
    end,
    TestCoordsTintAndLayer = function()
        local view = UI.Text("Visible"):size(80, 40):texture(134400)
            :texCoords(0.08, 0.92, 0.1, 0.9):textureTint(UI.Color.RGBA(255, 128, 0, 0.5))
            :textureLayer("ARTWORK", -3)
        local frame = render(view)
        local texture = frame.textures[1]
        assert(texture.source == 134400 and texture.allPoints == frame)
        assert(texture.layer == "ARTWORK" and texture.sublevel == -3)
        assert(texture.texCoords[1] == 0.08 and texture.texCoords[2] == 0.92)
        assert(texture.texCoords[3] == 0.1 and texture.texCoords[4] == 0.9)
        assert(texture.vertexColor[1] == 1 and texture.vertexColor[2] == 128 / 255)
        assert(texture.vertexColor[3] == 0 and texture.vertexColor[4] == 0.5)
        assert(frame.width == 80 and frame.height == 40 and frame.fontStrings[1].layer == "OVERLAY")
    end,
    TestEveryViewSupportsTextureModifiers = function()
        local views = {
            UI.View(), UI.Text("Text"), UI.Button("Button", function() end), UI.TextField("Field"),
            UI.Slider(5, 0, 10), UI.Toggle(true), UI.Dropdown({"One"}, "One"),
            UI.HStack({}), UI.VStack({}), UI.ScrollView(UI.View():size(40, 80)),
        }
        for _, view in ipairs(views) do
            local chained = view:texCoords(0, 1, 0, 1):textureTint(UI.Color.RGB(20, 40, 60))
                :textureLayer("BORDER", 2):texture("sample.blp")
            assert(chained == view)
            local found = false
            for _, texture in ipairs(render(view).textures) do
                if texture.source == "sample.blp" then
                    assert(texture.layer == "BORDER" and texture.sublevel == 2)
                    assert(texture.vertexColor[4] == 1 and texture.texCoords[2] == 1)
                    found = true
                end
            end
            assert(found, "Missing texture on " .. view.kind)
        end
    end,
    TestMirroredCoordsAndZeroAlpha = function()
        local texture = render(UI.View():texture(1):texCoords(1, 0, 0, 1)
            :textureTint(UI.Color.RGBA(255, 255, 255, 0))).textures[1]
        assert(texture.texCoords[1] == 1 and texture.texCoords[2] == 0)
        assert(texture.vertexColor[4] == 0)
    end,
    TestTintIsIndependentFromTextAndBackground = function()
        local tint = UI.Color.RGB(255, 0, 0)
        local view = UI.Text("Text"):backgroundColor(UI.Color.RGB(0, 0, 255))
            :foregroundColor(UI.Color.RGB(0, 255, 0)):texture("image.blp"):textureTint(tint)
        tint[1] = 0 -- the modifier owns a snapshot, not the caller's mutable color table
        local frame = render(view)
        assert(frame.textures[1].color[3] == 1)
        assert(frame.textures[2].vertexColor[1] == 1)
        assert(frame.fontStrings[1].color[2] == 1)
    end,
    TestLayerValidationAndBounds = function()
        for _, layer in ipairs({"BACKGROUND", "BORDER", "ARTWORK", "OVERLAY", "HIGHLIGHT"}) do
            local texture = render(UI.View():texture(1):textureLayer(layer, -8)).textures[1]
            assert(texture.layer == layer and texture.sublevel == -8)
        end
        assert(render(UI.View():texture(1):textureLayer("OVERLAY", 7)).textures[1].sublevel == 7)
        -- Intentionally bypass static types to exercise invalid runtime inputs.
        local invalid = UI.View()
        ---@cast invalid any
        assert(not pcall(function() invalid:textureLayer("invalid") end))
        for _, value in ipairs({-9, 8, 1.5, "1", false}) do
            assert(not pcall(function() UI.View():textureLayer("ARTWORK", value) end))
        end
    end,
    TestInvalidCoordsAndTint = function()
        for _, value in ipairs({-0.1, 1.1, "0", math.huge, 0/0}) do
            assert(not pcall(function() UI.View():texCoords(value, 1, 0, 1) end))
            assert(not pcall(function() UI.View():textureTint({value, 1, 1, 1}) end))
        end
        local invalid = UI.View()
        ---@cast invalid any
        assert(not pcall(function() invalid:texCoords(0, 1, 0) end))
        assert(not pcall(function() UI.View():textureTint({1, 1}) end))
        assert(not pcall(function() UI.View():textureTint({1, 1, 1, 2}) end))
        local view = UI.View():texCoords(0, 1, 0, 1)
        assert(not pcall(function() view:texCoords(-1, 1, 0, 1) end))
        assert(view.properties.texCoords.left == 0)
    end,
    TestUpdateDoesNotLeakTextureSettings = function()
        local handle = UI.Mount(UI.View():texture("first.blp"):texCoords(0.2, 0.8, 0.2, 0.8)
            :textureTint(UI.Color.RGB(255, 0, 0)):textureLayer("OVERLAY", 3), UIParent)
        handle:Update(UI.View():texture("second.blp"))
        local frame = handle.frame
        ---@cast frame DeclarusMockFrame
        local texture = frame.textures[1]
        assert(texture.source == "second.blp" and texture.layer == "BORDER" and texture.sublevel == 0)
        assert(texture.vertexColor == nil and texture.texCoords == nil)
        handle:Unmount()
    end,
}
