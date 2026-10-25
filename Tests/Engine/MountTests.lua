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
    TestScrollPaddingAndFill = function()
        local content = UI.VStack({UI.View():size(UI.Size.Fill, 40)}):width(UI.Size.Fill)
        local handle = UI.Mount(UI.ScrollView(content):size(100, 80):padding(10), UIParent)
        local viewport = handle.frame.children[1]
        assert(viewport.width == 80 and viewport.height == 60)
        assert(viewport.points[1].x == 10 and viewport.points[1].y == -10)
        assert(viewport.scrollChild.width == 80 and viewport.scrollChild.points[1].x == 0)
        viewport.scripts.OnMouseWheel(viewport, -10)
        assert(viewport.scroll == 0)
        handle:Unmount()
    end,
    TestRepeatedUpdatesReleaseNestedHandlers = function()
        local handle = UI.Mount(UI.VStack({UI.Toggle(false), UI.TextField("a")}), UIParent)
        local old = handle.frame
        local toggle, field = old.children[1], old.children[2]
        local host = old.parent
        for i = 1, 20 do handle:Update(UI.Text(tostring(i))) end
        assert(#host.children == 1 and #old.children == 0)
        assert(toggle.scripts.OnClick == nil and field.scripts.OnTextChanged == nil)
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
