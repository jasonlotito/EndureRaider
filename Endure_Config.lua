local Endure_Char = UnitName("player")
local Endure_Realm = GetCVar("realmName")
local EndureProfile = Endure_Realm.." - "..Endure_Char;

Endure.Config = {};

function EndureConfig_OnLoad(panel)
    panel.name = "Endure " .. GetAddonMetadata("Endure", "Verison");
    -- panel.default = function(self) 
    --     print("Loaded....")
    -- end
    -- panel.cancel = function(self) end;
    -- panel.okay = function(self) end;

    print("Endure Config Loaded")

    InterfaceOptions_AddCategory(panel)
end

