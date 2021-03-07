SLASH_MARKYSTART1 = "/markystart"
SLASH_MARKYSTOP1 = "/markystop"
SLASH_MARKYCONTINUE1 = "/markycont"
SLASH_MARKYCLEAR1 = "/markyclear"
SLASH_MARKYNOTES1 = "/markynotes"
SLASH_MARKYANNOUNCE1 = "/markyannounce"
SLASH_MARKYCLEARASSIGNMENTS1 = "/markyclearassignments"

EndureDB = {
    markers = {},
    markerOrder = {}
}
local MarkerOrder =  {
    "Skull",
    "X",
    "Square",
    "Moon",
    "Triangle",
    "Diamond",
    "Circle",
    "Star"
};

EndureDB.markers = { 
    Skull = "",
    X = "",
    Square = "",
    Moon = "",
    Triangle = "",
    Diamond = "",
    Circle = "",
    Star = ""
};

local DropDownFrames = {}

function explode (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

-- OnLoad
function Endure_OnLoad(self)
    print("OnLoad Loaded")
    DEFAULT_CHAT_FRAME:AddMessage("|cffffd200".."Endure"..":|r "..tostring("v1.0"));
    -- register events
    self:RegisterEvent("VARIABLES_LOADED"); -- eventually will call OnEvent
end

local function CreatePanelFrame(reference, title, version)
    -- local font = "Fonts\\FRIZQT__.TTF"

	local panelframe = CreateFrame( "Frame", reference, UIParent);
	panelframe.name = title
	panelframe.Label = panelframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	panelframe.Label:SetPoint("TOPLEFT", panelframe, "TOPLEFT", 16, -16)
	panelframe.Label:SetHeight(15)
	panelframe.Label:SetWidth(350)
	panelframe.Label:SetJustifyH("LEFT")
	panelframe.Label:SetJustifyV("TOP")
	panelframe.Label:SetText(title)

    panelframe.Version = panelframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
    panelframe.Version:SetPoint("TOPRIGHT", panelframe, "TOPRIGHT", -20, -26)
    panelframe.Version:SetHeight(15)
    panelframe.Version:SetWidth(350)
    panelframe.Version:SetJustifyH("RIGHT")
    panelframe.Version:SetJustifyV("TOP")
    panelframe.Version:SetText(version)
    panelframe.Version:SetFont(GameFontNormal:GetFont(), 12)

	return panelframe
end

local function CreateHelpFrame(reference, text)
	local helpframe = CreateFrame( "Frame", reference, UIParent);
	helpframe.name = reference
	helpframe.Label = helpframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	helpframe.Label:SetPoint("TOPLEFT", helpframe, "TOPLEFT", 16, -16)
	helpframe.Label:SetPoint("RIGHT", helpframe, "RIGHT", -16, 16)
	helpframe.Label:SetJustifyH("LEFT")
	helpframe.Label:SetJustifyV("TOP")
	helpframe.Label:SetText(text)
	return helpframe
end

local function isInRaid(member) 
    local groupCount = GetNumGroupMembers()
    local isRaidMember = false;
    for i = 1,groupCount do
        local name, _ = GetRaidRosterInfo(i)
        if (member == name) then
            isRaidMember = true;
            return isRaidMember;
        end
    end 

    return isRaidMember;
end

function EndureUI_hr(panel, ref)
    local DividerLine = panel:CreateTexture(nil, 'ARTWORK')
    DividerLine:SetTexture("Interface\\Addons\\FarmLog\\assets\\ThinBlackLine")
    DividerLine:SetSize(500, 12)
    DividerLine:SetPoint("TOPLEFT", ref, "BOTTOMLEFT", -6, -8)
    return DividerLine
end

function LoadConfigFrame() 
    local panel = CreatePanelFrame("EndureConfigPanel", "Endure's MarkyMark", "1.0")
    InterfaceOptions_AddCategory(panel)
    
    panel:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", insets = { left = 0, right = 2, top = 2, bottom = 2 },})
    panel:SetBackdropColor(0.06, 0.06, 0.06, .7)

    -- panel.Label:SetFont(font, 20)
    -- panel.Label:SetPoint("TOPLEFT", panel, "TOPLEFT", 16+6, -16-4)

    panel.DividerLine = EndureUI_hr(panel, panel.Label)

    -- Main Scrolled Frame
    ------------------------------
    panel.MainFrame = CreateFrame("Frame")
    panel.MainFrame:SetWidth(500)
    panel.MainFrame:SetHeight(100) 	
    local mfpanel = panel.MainFrame;

    -- Scrollable Panel Window
    ------------------------------
    panel.ScrollFrame = CreateFrame("ScrollFrame","FarmLog_Scrollframe", panel, "UIPanelScrollFrameTemplate")
    panel.ScrollFrame:EnableMouse(true)
    panel.ScrollFrame:EnableMouseWheel(true)
    panel.ScrollFrame:SetPoint("LEFT", 8)
    panel.ScrollFrame:SetPoint("TOP", panel.DividerLine, "BOTTOM", 0, -8)
    panel.ScrollFrame:SetPoint("BOTTOMRIGHT", -32 , 8)
    panel.ScrollFrame:SetScrollChild(panel.MainFrame)
    local spanel = panel.ScrollFrame

    for x, targetName in ipairs({"Skull", "X", "Square", "Moon", "Triangle", "Diamond", "Circle", "Star"}) do 
        -- First Drop Down
        local raidMembersFrame = CreateFrame("Frame", "FarmLogAHMinQualityDropdown", spanel, "UIDropDownMenuTemplate")

        DropDownFrames[targetName] = raidMembersFrame;
        raidMembersFrame:SetPoint("TOPLEFT", spanel, "TOPLEFT", 100, -2-(30*x))
        UIDropDownMenu_SetText(raidMembersFrame, EndureDB.markers[targetName])
        UIDropDownMenu_SetWidth(raidMembersFrame, 100) 
        UIDropDownMenu_Initialize(raidMembersFrame, function (frame, level, menuList)
            local info = UIDropDownMenu_CreateInfo()

            info.func = function (self) 
                local currentAssignee = EndureDB.markers[targetName]
                if (currentAssignee ~= "" and isInRaid(currentAssignee)) then
                    SendChatMessage("You've been unassigned from your target. Relax!", "WHISPER", nil, GetUnitName(currentAssignee))    
                end
                EndureDB.markers[targetName] = self.value
                UIDropDownMenu_SetText(raidMembersFrame, self.value)
                if( self.value ~= "") then
                    SendChatMessage("You've been assigned {"..targetName.."}. If you forget, you can always whisper me !target.", "WHISPER", nil, GetUnitName(self.value))
                end
            end;

            info.text = "Unassigned"
            info.value = ""
            
            UIDropDownMenu_AddButton(info)

            local groupCount = GetNumGroupMembers()
            for i = 1,groupCount do
                local name, rank, subgroup, level, class, fileName, 
                zone, online, isDead, role, isML = GetRaidRosterInfo(i)
                info.text = name.." - "..class
                info.value = name
                UIDropDownMenu_AddButton(info)
            end 
        end)

        EndureUI_Label(spanel, raidMembersFrame, targetName)
    end
end

-- Attaches the top right to the top left of another element
function EndureUI_Label(container, relativeTo, text)
    local labelFrame = CreateFrame( "Frame", nil, container);
    -- helpframe.name = tostring(x)
    labelFrame.label = labelFrame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
    labelFrame.label:SetHeight(relativeTo:GetHeight())
    labelFrame.label:SetPoint("TOPRIGHT", relativeTo, "TOPLEFT", 0, 0)
    labelFrame.label:SetJustifyH("RIGHT")
    labelFrame.label:SetJustifyV("MIDDLE")
    labelFrame.label:SetText(text)
    labelFrame.label:SetFont(GameFontNormal:GetFont(), 12)
    return labelFrame;
end

-- OnEvent
function Endure_OnEvent(self, event)
    if (event == "VARIABLES_LOADED") then
        EndureEvent_VARIABLES_LOADED();
    end
end

function EndureEvent_VARIABLES_LOADED() 
    LoadConfigFrame()
end

local MarkyNotes = {}
MarkyNotes["Infectious Ghoul"] = "Enrage and frenzy"

local MarkyList = {
    ["Infectious Ghoul"] = {"Plague Slime"},
    ["Deathknight"] = {"Risen Deathknight", "Dark Touched Warrior", "Death Touched Warrior", "Doom Touched Warrior",
                       "Deathknight Captain"},
    ["Deathknight Cavalier"] = {"Dark Touched Warrior", "Death Touched Warrior", "Doom Touched Warrior", "Death Lord"},
    ["Necro Knight"] = {"Shade of Naxxramas"},
    ["Death Lord"] = {"Deathknight Cavalier"},
    ["Skeletal Steed"] = {"Risen Deathknight"},
    ["Venom Stalker"] = {"Dread Creeper", "Carrion Spinner"},
    ["Crypt Reaver"] = {"Carrion Spinner"},
    ["Naxxramas Acolyte"] = {"Naxxramas Acolyte"},
    ["Patchwork Golem"] = {"Patchwork Golem"},
    ["Bile Retcher"] = {"Bile Retcher", "Patchwork Golem"},
    ["Living Monstrosity"] = {"Mad Scientist"}
}

local MarkedUnits = {}
local targetName = nil
local targetCount = 8
local targetMarkyOn = false
local targetMarkyClearOn = false
local currentGroup = nil

local function MarkyStopHandler()
    targetMarkyOn = false
    targetName = nil
    targetCount = 8;
    targetMarkyClearOn = false
    currentGroup = nil
    secondaryGroup = nil
    MarkedUnits = {}
end

local function MarkyStartHandler()
    MarkyStopHandler()
    targetCount = 8;
    targetName = GetUnitName("target")
    targetMarkyOn = true
end

local function MarkyContinueHandler()
    targetName = GetUnitName("target")
end

local function MarkyClearHandler()
    MarkyStopHandler()
    targetMarkyClearOn = true
end

local function MarkyNotesHandler()
    local unitName = GetUnitName("target")
    message(MarkyNotes[unitName])
end

local function ClearTargetNameHandler()
    targetName = nil
    print "Clearing primary targets"
end

local function ClearCurrentGroupHandler()
    MarkyStopHandler()
    currentGroup = nil
    print "Clearing group targets, stopped"
end

local function EventHandler_UpdateMouseoverUnit(event) 
    if (targetMarkyOn == false) then
        if (targetMarkyClearOn == true) then
            SetRaidTarget("mouseover", 0)
        end

        return
    end

    local guid = UnitGUID("mouseover")
    local hoverName = GetUnitName("mouseover")
    local unitFound = false

    -- Check first to see if we have a target, and find it
    if (hoverName == targetName and hoverName and targetName) then
        unitFound = true
        -- if we don't have a target, let's check our current group
    elseif (currentGroup and targetName == nil) then
        for key, value in pairs(currentGroup) do
            if (value == hoverName) then
                unitFound = true
                break
            end
        end
        -- if we don't have a group or a target, let's check our tables
    elseif (currentGroup == nil and targetName == nil) then
        for key, value in pairs(MarkyList) do
            if (key == hoverName) then
                unitFound = true
                targetName = key
                currentGroup = value

                C_Timer.After(2, ClearTargetNameHandler)
                C_Timer.After(5, ClearCurrentGroupHandler)
                break
            end
        end
    end

    if (unitFound and targetMarkyOn) then
        local raidTargetId = GetRaidTargetIndex("mouseover")

        if (raidTargetId) then
            return
        else
            if (MarkedUnits[guid]) then
                return
            end
            MarkedUnits[guid] = true;
            print("Setting raid target " .. targetCount .. " on raidTarget " .. tostring(raidTargetId))
            SetRaidTarget("mouseover", targetCount)

            targetCount = targetCount - 1
            if targetCount < 1 then
                MarkyStopHandler()
            end

        end
    end
end

local function EventHandler_ChatMsgWhisper(event, ...)
    local msg, author, language, _, _, _, _, senderGuid = ...
    aut = explode(author, "-")
    local authorName = aut[1]

    local groupCount = GetNumGroupMembers()
    local isRaidMember = false;
    for i = 1,groupCount do
        local name, rank, subgroup, level, class, fileName, 
        zone, online, isDead, role, isML = GetRaidRosterInfo(i)
        if (authorName == name) then
            isRaidMember = true;
        end
    end 

    if(authorName == "Cavi") then
        SendChatMessage("STOP IT NOW!!!! DAMNIT!!!!! STOP!!!!!", "WHISPER", nil, author)
    end

    if (isRaidMember == false) then
        return;
    end

    if (msg == '!target') then 
        for targetMarker, charName in pairs(EndureDB.markers) do
            if(charName == authorName) then
                SendChatMessage("You've been assigned {"..targetMarker.."}.", "WHISPER", nil, author)
                return
            end
        end
        
        SendChatMessage("You have no targets assigned to you. Relax!", "WHISPER", nil, author)
    end
end

local function MarkyAnnounceHandler() 
    for i=1, 8 do
        local target = MarkerOrder[i]
        local charName = EndureDB.markers[target];
        if(charName ~= "") then
            SendChatMessage(charName.." has been assigned {"..target.."}", "RAID")
        end
    end
end

local function MarkyClearAssignmentsHandler() 
    for targetMarker, _ in pairs(EndureDB.markers) do
        EndureDB.markers[targetMarker] = ""
        UIDropDownMenu_SetText(DropDownFrames[targetMarker], "")
    end
end

local function EventHandler(self, event, ...)
    if (event == "CHAT_MSG_WHISPER") then
        print(arg1)
        EventHandler_ChatMsgWhisper(event, ...)
    end

    if (event == "UPDATE_MOUSEOVER_UNIT") then
        EventHandler_UpdateMouseoverUnit(event)
    end
end

SlashCmdList["MARKYSTART"] = MarkyStartHandler
SlashCmdList["MARKYSTOP"] = MarkyStopHandler
SlashCmdList["MARKYCONTINUE"] = MarkyContinueHandler
SlashCmdList["MARKYCLEAR"] = MarkyClearHandler
SlashCmdList["MARKYNOTES"] = MarkyNotesHandler
SlashCmdList["MARKYANNOUNCE"] = MarkyAnnounceHandler
SlashCmdList["MARKYCLEARASSIGNMENTS"] = MarkyClearAssignmentsHandler

local frame = CreateFrame("FRAME", "EndureMarkyMark");
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
frame:RegisterEvent("CHAT_MSG_WHISPER")
frame:SetScript("OnEvent", EventHandler)

