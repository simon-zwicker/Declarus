local UI = _G.Declarus.UI
return {
    TestScrollBounds = function()
        local handle = UI.Mount(UI.ScrollView(UI.View():size(100, 400)):size(100, 100), UIParent)
        local viewport = handle.frame.children[1]
        assert(viewport.scrollChild.height == 400)
        viewport.scripts.OnMouseWheel(viewport, -100)
        assert(viewport.scroll == 300)
        viewport.scripts.OnMouseWheel(viewport, 100)
        assert(viewport.scroll == 0)
        handle:Unmount()
    end,
    TestUpdateAndCleanup = function()
        local calls = 0
        local handle = UI.Mount(UI.Button("old", function() calls = calls + 1 end), UIParent)
        local old = handle.frame
        local host = old.parent
        handle:Update(UI.Text("new"):fontSize(24))
        assert(old.hidden and old.parent == nil and old.scripts.OnClick == nil)
        assert(#host.children == 1 and handle.frame.fontStrings[1].text == "new")
        handle:Unmount()
        handle:Unmount()
        assert(host.hidden and host.parent == nil and #host.children == 0)
        assert(not pcall(function() handle:Update(UI.View()) end))
        assert(calls == 0)
    end,
    TestUpdateFromCallback = function()
        local handle
        handle = UI.Mount(UI.Button("change", function() handle:Update(UI.Text("changed")) end), UIParent)
        handle.frame.scripts.OnClick(handle.frame, "LeftButton")
        assert(handle.frame.fontStrings[1].text == "changed")
        handle:Unmount()
    end,
}
