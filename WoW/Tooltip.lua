-- WoW-specific helpers. Tooltip descriptions do not create native frames.
local UI = _G.Declarus.UI

---@alias DeclarusInfoTooltipKind 'item'|'spell'|'unit'
---@class DeclarusInfoTooltip
---@field kind DeclarusInfoTooltipKind
---@field value number|string

---@class DeclarusWoW
local WoW = {}

---@param source? DeclarusInfoTooltip
function WoW._ValidateInfo(source)
    if source == nil then return end
    assert(type(source) == "table", "Info tooltip requires WoW.Item, WoW.Spell or WoW.Unit")
    if source.kind == "unit" then
        assert(type(source.value) == "string" and source.value ~= "", "Unit requires a unit token")
    else
        assert(source.kind == "item" or source.kind == "spell", "Unsupported info tooltip kind")
        local id = source.value
        assert(type(id) == "number" and id > 0 and id < math.huge and id == math.floor(id),
            "Item and spell IDs must be positive integers")
    end
end

---@param kind DeclarusInfoTooltipKind
---@param value number|string
---@return DeclarusInfoTooltip
local function info(kind, value)
    local source = {kind = kind, value = value}
    WoW._ValidateInfo(source)
    return source
end

---Describes an item tooltip. Does not require the item to be cached yet.
---@param itemID number
---@return DeclarusInfoTooltip
function WoW.Item(itemID)
    return info("item", itemID)
end

---Describes a spell tooltip using a spell ID available on the current client.
---@param spellID number
---@return DeclarusInfoTooltip
function WoW.Spell(spellID)
    return info("spell", spellID)
end

---Describes a unit tooltip; the token is resolved when the mouse enters.
---@param unitToken string
---@return DeclarusInfoTooltip
function WoW.Unit(unitToken)
    return info("unit", unitToken)
end

-- Tooltip layouts deliberately stay passive, so hovering them cannot steal input.
---@param content? string|DeclarusView|DeclarusView[]
function WoW._ValidateTooltip(content)
    if content == nil or type(content) == "string" then return end
    local visiting = {}
    local function validate(view)
        assert(type(view) == "table" and not visiting[view], "Invalid or cyclic tooltip layout")
        assert(view.kind == "Text" or view.kind == "View" or view.kind == "HStack" or view.kind == "VStack",
            "Tooltip layouts support Text, View, HStack and VStack")
        visiting[view] = true
        assert(type(view.properties) == "table" and type(view.children) == "table", "Tooltip requires views")
        assert(not view.properties.tooltip and not view.properties.infoTooltip, "Nested tooltips are unsupported")
        for _, child in ipairs(view.children) do validate(child) end
        visiting[view] = nil
    end
    assert(type(content) == "table", "Tooltip requires text, a view or an array of views")
    if content.kind then validate(content)
    else
        local count = 0
        for key, view in pairs(content) do
            assert(type(key) == "number" and key >= 1 and key == math.floor(key), "Tooltip requires a dense array")
            count = count + 1
            validate(view)
        end
        assert(count > 0 and count == #content, "Tooltip requires a nonempty dense array")
    end
end

---@type Frame?
local owner
---@type table<Frame, {host: Frame, mount: DeclarusMountHandle}>
local layouts = {}
local native = false

---@param frame Frame
function WoW._HideTooltip(frame)
    if owner ~= frame then return end
    owner = nil
    if native and GameTooltip:IsOwned(frame) then GameTooltip:Hide() end
    native = false
    local layout = layouts[frame]
    if layout then layout.host:Hide() end
end

---Releases cached tooltip frames when the owning render tree is retired.
---@param frame Frame
function WoW._ReleaseTooltip(frame)
    WoW._HideTooltip(frame)
    local layout = layouts[frame]
    if layout then
        layouts[frame] = nil
        layout.mount:Unmount()
        layout.host:SetParent(nil)
    end
end

---@param frame Frame
---@param view DeclarusView
function WoW._ApplyTooltip(frame, view)
    local content, source = view.properties.tooltip, view.properties.infoTooltip
    if content == nil and source == nil then return end
    frame:EnableMouse(true)
    local onHide = frame:GetScript("OnHide")
    frame:SetScript("OnHide", function(self, ...)
        WoW._HideTooltip(self)
        if onHide then onHide(self, ...) end
    end)
    frame:SetScript("OnLeave", function(self) WoW._HideTooltip(self) end)
    frame:SetScript("OnEnter", function(self)
        if owner then WoW._HideTooltip(owner) end
        owner = self
        if source or type(content) == "string" then
            native = true
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if source then
                _G.Declarus.Client._SetInfoTooltip(GameTooltip, source)
            else
                ---@cast content string
                GameTooltip:SetText(content, 1, 1, 1, 1, true)
                GameTooltip:Show()
            end
        else
            local cached = layouts[self]
            if cached then
                cached.host:Show()
                return
            end
            assert(type(content) == "table")
            local layout
            if content.kind then
                ---@cast content DeclarusView
                layout = content
            else
                ---@cast content DeclarusView[]
                layout = UI.VStack(content):spacing(4)
            end
            local wrapper = UI.VStack({layout})
                :padding(10)
                :backgroundColor(UI.Color.RGBA(20, 20, 25, 0.98))
            local size = UI._Measure.Measure(wrapper)
            local customHost = CreateFrame("Frame", nil, UIParent)
            customHost:SetFrameStrata("TOOLTIP")
            customHost:SetSize(size.width, size.height)
            customHost:SetPoint("TOPLEFT", self, "TOPRIGHT", 8, 0)
            customHost:SetClampedToScreen(true)
            layouts[self] = {host = customHost, mount = UI.Mount(wrapper, customHost)}
        end
    end)
end

_G.Declarus.WoW = WoW
