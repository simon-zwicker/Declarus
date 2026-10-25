local Client = _G.Declarus.Client
local UI = _G.Declarus.UI
return {
    TestClientDeclaredByTOC = function()
        local interface = tostring(Client.GetInfo().interface)
        local file = assert(io.open("Declarus.toc"))
        local header = file:read("*l")
        file:close()
        assert(header:find(interface, 1, true), "Client fixture missing from TOC")
    end,
    TestClientIdentities = function()
        local original = GetBuildInfo
        local cases = {
            {16001, "Forever"}, {120105, "Retail"}, {11509, "Classic Era"},
            {20506, "Burning Crusade Classic"},
            {38002, "Titan Reforged"}, {50504, "Mists Classic"},
            {17000, "Unknown"}, {11200, "Unknown"}, {30300, "Unknown"},
        }
        for _, case in ipairs(cases) do
            GetBuildInfo = function() return "fixture", "build", "date", case[1] end
            local info = Client.GetInfo()
            assert(info.flavor == case[2] and info.interface == case[1])
        end
        GetBuildInfo = original
    end,
    TestClientFontSharedByMeasureAndRender = function()
        local original = STANDARD_TEXT_FONT
        STANDARD_TEXT_FONT = "Fonts\\client-locale.ttf"
        local view = UI.Text("locale"):fontSize(20)
        local size = UI._Measure.Measure(view)
        local frame = UI._Render.Render(view, UI._Arrange.Arrange(view, size), UIParent)
        ---@cast frame DeclarusMockFrame
        assert(frame.fontStrings[1].font == STANDARD_TEXT_FONT)
        assert(size.width == 60 and size.height == 20)
        local path = UI._FontResolver.Resolve(UI.Text("override"):font("explicit.ttf").properties)
        assert(path == "explicit.ttf")
        STANDARD_TEXT_FONT = nil
        assert(Client.GetDefaultFont() == "Fonts\\FRIZQT__.TTF")
        STANDARD_TEXT_FONT = original
    end,
}
