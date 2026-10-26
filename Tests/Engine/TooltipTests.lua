local UI, WoW = Declarus.UI, Declarus.WoW

---@param view DeclarusView
---@return DeclarusMockMountHandle
local function mount(view)
    local handle = UI.Mount(view, UIParent)
    ---@cast handle DeclarusMockMountHandle
    return handle
end

return {
    TestNativeContentAndOwnership = function()
        local handle = mount(UI.Text("Hover"):tooltip("Help"))
        local frame = handle.frame
        frame.scripts.OnEnter(frame)
        assert(GameTooltip:IsOwned(frame) and GameTooltip:IsShown())
        frame.scripts.OnLeave(frame)
        assert(not GameTooltip:IsShown())
        frame.scripts.OnEnter(frame)
        local other = CreateFrame("Frame")
        GameTooltip:SetOwner(other, "ANCHOR_RIGHT")
        GameTooltip:Show()
        handle:Unmount()
        assert(GameTooltip:IsShown(), "Do not hide another addon's tooltip")
        GameTooltip:Hide()
    end,
    TestInfoKindsAndMissingUnit = function()
        local sources = {WoW.Item(6948), WoW.Spell(6603), WoW.Unit("player"), WoW.Unit("missing")}
        for _, source in ipairs(sources) do
            local handle = mount(UI.View():size(20, 20):infoTooltip(source))
            handle.frame.scripts.OnEnter(handle.frame)
            assert(GameTooltip:IsShown() == (source.value ~= "missing"))
            local tooltip = GameTooltip
            ---@cast tooltip DeclarusMockTooltip
            if source.value ~= "missing" then
                assert(tooltip.data[1] == source.kind and tooltip.data[2] == source.value)
            end
            handle:Unmount()
            assert(not GameTooltip:IsShown())
        end
    end,
    TestCustomLayoutAndUpdateCleanup = function()
        local handle = mount(UI.View():size(20, 20):tooltip({
            UI.Text("Title"):fontSize(20),
            UI.HStack({UI.Text("Left"), UI.Text("Right")}):spacing(8),
        }))
        local frame = handle.frame
        frame.scripts.OnEnter(frame)
        local parent = UIParent
        ---@cast parent DeclarusMockFrame
        local host = parent.children[#parent.children]
        assert(host.strata == "TOOLTIP" and #host.children == 1)
        assert(host.width > 20 and host.height > 20)
        local count = #parent.children
        frame.scripts.OnLeave(frame)
        assert(host.hidden)
        frame.scripts.OnEnter(frame)
        assert(not host.hidden and #parent.children == count, "Hover must reuse its tooltip frames")
        handle:Update(UI.Text("Updated"))
        assert(host.hidden and host.parent == nil and #host.children == 0)
        assert(frame.scripts.OnEnter == nil and frame.scripts.OnLeave == nil)
        handle:Unmount()
    end,
    TestHidePreservesControlBehavior = function()
        local handle = mount(UI.Dropdown({"A", "B"}, "A"):tooltip("Choose"))
        local frame = handle.frame
        frame.scripts.OnClick(frame)
        frame.scripts.OnEnter(frame)
        frame.scripts.OnHide(frame)
        assert(not GameTooltip:IsShown())
        assert(frame.children[1].hidden)
        handle:Unmount()
    end,
    TestValidationAndReplacement = function()
        assert(not pcall(WoW.Item, -1))
        assert(not pcall(WoW.Spell, math.huge))
        assert(not pcall(WoW.Unit, ""))
        assert(not pcall(function() UI.Text("x"):tooltip({UI.Button("x", function() end)}) end))
        local cyclic = UI.VStack({})
        cyclic.children[1] = cyclic
        assert(not pcall(function() UI.View():tooltip(cyclic) end))
        local view = UI.View():tooltip("A"):infoTooltip(WoW.Item(6948))
        assert(view.properties.tooltip == nil)
        view:tooltip(UI.Text("B"))
        assert(view.properties.infoTooltip == nil)
        view:tooltip(nil)
        assert(view.properties.tooltip == nil)
    end,
}
