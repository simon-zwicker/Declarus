---@diagnostic disable: undefined-global
return {
    TestDemoLifecycle = function()
        local parent = UIParent
        ---@cast parent DeclarusMockFrame
        local before = #parent.children
        SlashCmdList.DECLARUS("info")
        assert(#parent.children == before)
        SlashCmdList.DECLARUS("demo")
        assert(#parent.children == before + 1)
        local host = parent.children[#parent.children]
        local root = host.children[1]
        -- ScrollView, counter, update button, close button.
        root.children[3].scripts.OnClick(root.children[3], "LeftButton")
        assert(root.hidden and #host.children == 1)
        assert(host.children[1].children[2].fontStrings[1].text == "Updates: 1")
        -- Reopening replaces the host instead of retaining another active tree.
        SlashCmdList.DECLARUS("")
        assert(#parent.children == before + 1)
        SlashCmdList.DECLARUS("hide")
        assert(#parent.children == before)
        SlashCmdList.DECLARUS("hide")
    end,
}
