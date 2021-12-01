if UnitLevel("player") <= 48 then return end
--[and not UnitLevel("player") >= 60]]--
local addon = ...
local function Event(event, handler)
    if _G.event == nil then
        _G.event = CreateFrame('Frame')
        _G.event.handler = {}
        _G.event.OnEvent = function(frame, event, ...)
            for key, handler in pairs(_G.event.handler[event]) do
                handler(...)
            end
        end
        _G.event:SetScript('OnEvent', _G.event.OnEvent)
    end
    if _G.event.handler[event] == nil then
        _G.event.handler[event] = {}
        _G.event:RegisterEvent(event)
    end
    table.insert(_G.event.handler[event], handler)
end
local level,CovenantID
local name, realm
Event(
    'ADDON_LOADED',
    function(name)
        if name == addon then
        return end
    end
)
Event(
    'PLAYER_LOGIN',
    function()
        if not TCR then
            TCR = {}
        end
        name, realm = UnitFullName('player'), GetNormalizedRealmName()
        if not TCR[name .. '-' .. realm] then
            TCR[name .. '-' .. realm]={}
            for i=1,4 do
                TCR[name .. '-' .. realm][i]=0
            end
        end
    end
)
Event(
    'PLAYER_ENTERING_WORLD',
    function()
        level = C_CovenantSanctumUI.GetRenownLevel()
        CovenantID = C_Covenants.GetActiveCovenantID()  
        name, realm = UnitFullName('player')     
        TCR[name .. '-' .. realm][CovenantID] = level
    end
)
Event(
    'COVENANT_CHOSEN',
    function()
        C_Timer.After(3, function()
        level = C_CovenantSanctumUI.GetRenownLevel()
        CovenantID = C_Covenants.GetActiveCovenantID()
        TCR[name .. '-' .. realm][CovenantID] = level
    end )
end
)
Event(
    'COVENANT_SANCTUM_RENOWN_LEVEL_CHANGED',
    function()
        C_Timer.After(5, function()
        level = C_CovenantSanctumUI.GetRenownLevel()
        CovenantID = C_Covenants.GetActiveCovenantID()
        TCR[name .. '-' .. realm][CovenantID] = level
    end )
end
)

GameTooltip:HookScript(
    'OnTooltipSetUnit',
    function(self)
        local unit = select(2, self:GetUnit())
        if tostring(unit) =="player" then
            
            GameTooltip:AddDoubleLine("|A:sanctumupgrades-kyrian-32x32:16:16|a"..COVENANT_COLORS.Kyrian:WrapTextInColorCode("Kyrian"), TCR[name .. '-' .. realm][1])
            GameTooltip:AddDoubleLine("|A:sanctumupgrades-venthyr-32x32:16:16|a"..COVENANT_COLORS.Venthyr:WrapTextInColorCode("Venthyr"), TCR[name .. '-' .. realm][2])
            GameTooltip:AddDoubleLine("|A:sanctumupgrades-nightfae-32x32:16:16|a "..COVENANT_COLORS.NightFae:WrapTextInColorCode("Night Fae"), TCR[name .. '-' .. realm][3])
            GameTooltip:AddDoubleLine("|A:sanctumupgrades-necrolord-32x32:16:16|a "..COVENANT_COLORS.Necrolord:WrapTextInColorCode("Necrolord"), TCR[name .. '-' .. realm][4])
        end
    end
)