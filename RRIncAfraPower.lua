local title = ""
local version = ""
local messagePrefix = ""

local addonChannel = "RRIncAfraPower"
local orderIndex = 1
local monitorActive = false

local function SendAddonMessageHandler(msg)
    if IsInRaid() then
        C_ChatInfo.SendAddonMessage(addonChannel, msg, "RAID");
    else
        C_ChatInfo.SendAddonMessage(addonChannel, msg, "SAY");
    end
end

local function AddHealHistory(text)
	-- print(player, action, item)
	local timestampformat="%y-%m-%d %H:%M:%S";
	local timestamp = "20"..date(timestampformat);
    table.insert(rriapHealHistory, "["..timestamp.."] "..text)
end

local function Reset()
    SendAddonMessageHandler("RESET")
    orderIndex = 0
    monitorActive = false
end

local function PlayerIsInRaid(player)
    local numMembers = GetNumGroupMembers()
    for i=0, numMembers, 1 do
        local name = GetRaidRosterInfo(i)
        if name == player then
            return true
        end
    end
    return false
end

local function PlayerIsAvailable(player)
    local numMembers = GetNumGroupMembers()
    for i=0, numMembers, 1 do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i);
        if name == player then
            if online and not isDead then
                return true
            else
                return false
            end
        end
    end
    return false
end

local function Next()
    orderIndex = orderIndex + 1

    local playerCount = 0
    for i=1, #rriapHealOrder do
        playerCount = playerCount + 1
    end

    -- If index is higher than players start over at 1.
    if orderIndex > playerCount then
        orderIndex = 1
    end

    if rriapOptionSkipDeadOffline then
        while not PlayerIsAvailable(rriapHealOrder[orderIndex]) do
            print(messagePrefix,"#"..orderIndex, rriapHealOrder[orderIndex],"is dead, offline or not in raid, skipping.")
            orderIndex = orderIndex + 1
            if orderIndex > playerCount then
                orderIndex = 1
            end
        end
    end

    SendAddonMessageHandler("NEXT_"..rriapHealOrder[orderIndex])
    if rriapOptionAnnounce then
        if IsInRaid() then
            SendChatMessage(rriapHealOrder[orderIndex].." healing next! "..orderIndex.." / "..playerCount,"RAID_WARNING","COMMON")
        else
            print(rriapHealOrder[orderIndex].." healing next! "..orderIndex.." / "..playerCount)
        end 
    end
end

local function PlayerIsInRaid(player)
    local numMembers = GetNumGroupMembers()
    for i=0, numMembers, 1 do
        local name = GetRaidRosterInfo(i)
        if name == player then
            return true
        end
    end
    return false
end

local function PlayerIsDeadOrOffline(player)
    local numMembers = GetNumGroupMembers()
    for i=0, i < numMembers, 1 do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(raidIndex);
        if name == player and (not online or isDead) then
            return true
        end
    end
    return false
end

local function IncomingMessage(...)
    local arg1, arg2, arg3, arg4, arg5, arg6 = ...

    local prefix=arg3;	
    local messageText = arg4;
    local sender = arg6;    

    if prefix==addonChannel then   
        
        local action = strsplit("_", messageText)

        if action == "VERSION" then
            local actionDump, sourcePlayer, title, version = strsplit("_", messageText)
            local versionWithStatus = ""

            if version == GetAddOnMetadata("RRIncHealPrompt", "Version") then
                versionWithStatus = "|cFF449944"..version.."|r"
            else
                versionWithStatus = "|cFFE2252D"..version.."|r"
            end

            print(messagePrefix, sourcePlayer,"has version:", versionWithStatus)            
            return
        end
    end
end

SLASH_RRINCAFRA1 = '/rrincafrapower'
SLASH_RRINCAFRA2 = '/rriap'
function SlashCmdList.RRINCAFRA(msg)
    local option, value = strsplit(" ",msg)	
    
    if(option == "" or option == nil) then
        if ( not InterfaceOptionsFrame:IsShown() ) then
            InterfaceOptionsFrame:Show();
            InterfaceOptionsFrame_OpenToCategory("RRInc AfraPower");
        end
        return
    end

    if option == "history" and value == "clear" then
        rriapHealHistory = {}
        print(messagePrefix, "History cleared.")
        return
    end  

    if option == "history" then        
        if rriapHealHistory == nil then
            print(messagePrefix, "No history recorded.")
        else
            local count = 0
            for i = 1, #rriapHealHistory do			
            	count = count + 1
            end
            
            if count >= 1 then
                print(messagePrefix, "- Heal History -")
                for i = 1, #rriapHealHistory do			
                    print(rriapHealHistory[i])
                end
            else
                print(messagePrefix, "No history recorded.")
            end
        end        
        return
    end      
end

SLASH_RRINCLOATHEB1 = '/loatheb'
function SlashCmdList.RRINCLOATHEB(msg)
    local option, value = strsplit(" ",msg)	
    -- if option == "" or option == nil then
    --     return 
    -- end
    
    if option == "" or option == "start" then
        Reset()
        monitorActive = true
        -- Add check/warning if assigned player is not in raid or offline.
        -- SendAddonMessageHandler("START")

        local orderString = ""
        for i=1, #rriapHealOrder do
            if i == 1 then
                orderString = "#"..i.." "..rriapHealOrder[i]
            else
                orderString = orderString..", #"..i.." "..rriapHealOrder[i]
            end

            if not PlayerIsInRaid(rriapHealOrder[i]) then
                print(messagePrefix, "|cFFFF0000"..rriapHealOrder[i].." is not in the raid!|r Make sure your list is correct.")
            end
        end

        print(messagePrefix, "Starting with heal order:", orderString)

        if rriapOptionAnnounceHealOrder then
            SendChatMessage("Heal order: "..orderString,"RAID","COMMON")
        end

        Next()
    end

    if(option == "next") then 
        SendAddonMessageHandler("SKIP_"..rriapHealOrder[orderIndex])
        Next()
    end

    if(option == "reset" or option == "stop") then
        SendAddonMessageHandler("RESET")
    end

    if(option == "display") then
        -- Post heal order to raid.
    end

    if(option == "versioncheck" or option == "version") then
        -- Post heal order to raid.
        SendAddonMessageHandler("VERSIONCHECK")
    end
end

local function EventEnterWorld(self, event, isLogin, isReload)
    title = GetAddOnMetadata("RRIncAfraPower", "Title")
    version = GetAddOnMetadata("RRIncAfraPower", "Version")
    messagePrefix = title..": "

    local successfulRequest = C_ChatInfo.RegisterAddonMessagePrefix(addonChannel)
    if isLogin or isReload then      
        print(title.." v"..version.." loaded.")
    end
end

local RRIncAfraPower_FrameEnterWorld = CreateFrame("Frame")
RRIncAfraPower_FrameEnterWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
RRIncAfraPower_FrameEnterWorld:SetScript("OnEvent", EventEnterWorld)

local RRIncAfraPower_IncomingMessage = CreateFrame("Frame")
RRIncAfraPower_IncomingMessage:RegisterEvent("CHAT_MSG_ADDON")
RRIncAfraPower_IncomingMessage:SetScript("OnEvent", IncomingMessage)

-- Event for Combat log
local RRIncAfraPower_CombatlogFrame = CreateFrame("Frame")
RRIncAfraPower_CombatlogFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
RRIncAfraPower_CombatlogFrame:SetScript("OnEvent", function(self, event, ...)
	local timestamp, type, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellId, spellName, spellSchool, amount, overkill = CombatLogGetCurrentEventInfo()
   
    if not monitorActive then
        return
    end       

    if type == "SPELL_HEAL" then
        -- print(sourceName, type, destName)
        -- local playerName = select(6, GetPlayerInfoByGUID(UnitGUID("PLAYER")))
        if rriapHealOrder[orderIndex] == sourceName then
            if rriapOptionPrintHeals then
                print(messagePrefix, sourceName, "cast", spellName, "on", destName, "for", "|cFF449944"..amount.."|r", "(|cFF8F0000"..overkill.."|r)")
            end
            AddHealHistory(sourceName.." cast "..spellName.." on "..destName.." for ".."|cFF449944"..amount.."|r".." (|cFF8F0000"..overkill.."|r)")
            SendAddonMessageHandler("DONE_"..rriapHealOrder[orderIndex])
            Next()
            -- print(messagePrefix, type, sourceName, destName, spellName, "|cFF5CB85C"..amount.."|r", "|cFFE2252D"..overkill.."|r")
        end
	end   
	
end)