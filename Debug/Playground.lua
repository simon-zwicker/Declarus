-- Opt-in smoke test for the same UI on every official client.
local UI = _G.Declarus.UI
---@type DeclarusMountHandle?
local handle

local state = { clicks = 0, text = "Declarus", value = 50, enabled = true, choice = "Standard" }

local function close()
    if handle then handle:Unmount(); handle = nil end
end

local function report()
    local info = _G.Declarus.Client.GetInfo()
    print(string.format("Declarus: %s | %s | build %s | Interface %d | %s",
        info.flavor, info.version, info.build, info.interface, GetLocale()))
end

---@return DeclarusView
local function buildDemo()
    local content = {
        UI.Text("Declarus Client Test"):fontSize(22):padding(4),
        UI.Text("Text / Padding / Font"):padding(8),
        UI.View():size(32, 32):texture("Interface\\Icons\\INV_Misc_QuestionMark"),
        UI.Text("TextField"),
        UI.TextField(state.text, function(value) state.text = value end),
        UI.Text("Slider: 0 - 100, step 5"),
        UI.Slider(state.value, 0, 100, 5, function(value)
            state.value = value
            print("Declarus Slider:", value)
        end),
        UI.Text("Toggle"),
        UI.Toggle(state.enabled, function(value)
            state.enabled = value
            print("Declarus Toggle:", value)
        end),
        UI.Text("Dropdown"),
        UI.Dropdown({"Standard", "Raid", "Solo"}, state.choice, function(value)
            state.choice = value
            print("Declarus Dropdown:", value)
        end),
    }
    for index = 1, 8 do content[#content + 1] = UI.Text("Scroll row " .. index) end
    return UI.VStack({
        UI.ScrollView(UI.VStack(content):spacing(8):padding(12)):size(380, 340),
        UI.Text("Updates: " .. state.clicks),
        UI.Button("Update", function()
            state.clicks = state.clicks + 1
            if handle then handle:Update(buildDemo()) end
        end),
        UI.Button("Close", close),
    }):padding(12):spacing(8):backgroundColor(UI.Color.RGBA(10, 10, 10, 0.95))
end

SLASH_DECLARUS1 = "/declarus"
SlashCmdList.DECLARUS = function(message)
    local command = message:lower():match("^%s*(.-)%s*$")
    if command == "hide" then
        close()
    elseif command == "info" then
        report()
    elseif command == "" or command == "demo" then
        close()
        report()
        handle = UI.Mount(buildDemo(), UIParent)
    else
        print("Declarus: /declarus [demo|hide|info]")
    end
end
