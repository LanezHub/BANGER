repeat task.wait() until game.GameId ~= 0
if Parvus and Parvus.Loaded then
    Parvus.Utilities.UI:Notification({
        Title = "LanezHub Hub",
        Description = "Script already executed!",
        Duration = 5
    }) return nil
end
local script_details = {
    debug = false,
    version = "1.0.0",
}
local url = script_details.debug and "https://raw.githubusercontent.com/LanezHub/BANGER/main" or "https://raw.githubusercontent.com/LanezHub/BANGER/main"
local out = script_details.debug and function(T, ...) return warn("[LanezHub - Debug]: "..T:format(...)) end or function() end
function Importing(file) out("Importing File \"%s\"", file)
    local x, a = pcall(function()
        return loadstring(game:HttpGet(url .. file))()
    end)
    if not x then
        return warn('failed to import • ', file)
    end
end
function Searchfile(file) out("Search File \"%s\"", file)
    local x, a = pcall(function()
        return game:HttpGetAsync(url .. file)
    end)
    if not x then
        return warn('failed to Search • ', file)
    end
    return a
end
function LoadScript(Supported) 
    Parvus.Current = Supported.Name
    local x, a = pcall(function()
        return loadstring(Supported.Script)()
    end)
    if not x then
        return warn('failed to url • ', Supported.Script)
    end
end

getgenv().Parvus = {Loaded = false,Debug = false,Current = "Loader",Utilities = {}} getgenv().LanezHub = getgenv().Parvus
Parvus.Utilities.UI = Parvus.Debug and Importing("/Library/UtilitiesUI") or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Library/UtilitiesUI"))()
Parvus.Utilities.UI2 = Parvus.Debug and Importing("/Library/loader.lua") or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Library/loader.lua"))()
Parvus.Utilities.Drawing = Parvus.Debug and Importing("/Library/Drawing.lua") or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Library/Drawing.lua"))()
Parvus.Utilities.AimBot = Parvus.Debug and Importing("/ModuleScript/AimBot.lua") or loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/ModuleScript/AimBot.lua"))()
Parvus.Utilities.SetupFPS = function()
    local StartTime,TimeTable,  
    LastTime = os.clock(), {}
    return function()
        LastTime = os.clock()
        for Index = #TimeTable, 1, -1 do
            TimeTable[Index + 1] = TimeTable[Index] >= LastTime - 1 and TimeTable[Index] or nil
        end
        TimeTable[1] = LastTime 
        return os.clock() - StartTime >= 1 and #TimeTable or #TimeTable / (os.clock() - StartTime)
    end
end

Parvus.Utilities.NewThreadLoop = function(Wait,Function)
    coroutine.wrap(function()
        while task.wait(Wait) do
            local Success, Error = pcall(Function)
            if not Success then
                warn("thread error " .. Error)
            end
        end
    end)()
end

Parvus.Utilities.RequireModule = function(Name)
    for Index, Instance in pairs(getloadedmodules()) do
        if Instance.Name == Name then
            return require(Instance)
        end
    end
end
Parvus.Utilities.HookSignal = function(Signal,Index,Callback)
    local Connection = getconnections(Signal)[Index]
    local OldConnection = Connection.Function
    Connection:Disable()
    Signal:Connect(function(...)
        local args = Callback({...})
        OldConnection(unpack(args))
    end)
end

Parvus.Utilities.HookFunction = function(Module,Function,Callback)
    Module = Parvus.Utilities.RequireModule(Module) local OldFunction
    while task.wait() do
        if Module and Module[Function] then
            OldFunction = Module[Function]
            break
        end
        Module = Parvus.Utilities.RequireModule("ControllerClass")
    end
    Module[Function] = function(...)
        local args = Callback({...})
        return OldFunction(unpack(args))
    end
end

Parvus.Games = {
    ["1054526971"] = {
        Name = "Blackhawk Rescue Mission 5",
        Script = Parvus.Debug and Searchfile("/Game/Blackhawk%20Rescue%20Mission%205.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Game/Blackhawk%20Rescue%20Mission%205.lua")
    },
    ["187796008"] = {
        Name = "Those Who Remain",
        Script = Parvus.Debug and Searchfile("/Game/Those%20Who%20Remain.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Game/Those%20Who%20Remain.lua")
    },
    ["1494262959"] = {
        Name = "Criminality",
        Script = Parvus.Debug and Searchfile("/Game/Criminality.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Game/Criminality.lua")
    },
    ["113491250"] = {
        Name = "Phantom Forces",
        Script = Parvus.Debug and Searchfile("/Game/Phantom%20Forces.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Game/Phantom%20Forces.lua")
    },
}

local PlayerService = game:GetService("Players")
local LocalPlayer = PlayerService.LocalPlayer

Parvus.Utilities.UI:Notification({
    Title = "LanezHub",
    Description = "Library | Bracket V3 (Parvus Hub Edition)",
    Duration = 5
})

function IfGameSupported()
    for Id, Info in pairs(Parvus.Games) do
        if tostring(game.GameId) == Id then
            return Info
        end
    end
end
LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        local QueueOnTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport
        QueueOnTeleport(Parvus.Debug and Searchfile("/Loader.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/LanezHub/BANGER/main/Loader.lua"))
    end
end)
local SupportedGame = IfGameSupported()
if SupportedGame then
    LoadScript(SupportedGame) Parvus.Utilities.UI:Notification({
        Title = "LanezHub",
        Description = Parvus.Current .. " loaded!",
        Duration = 5
    })Parvus.Loaded = true
else
    Parvus.Utilities.UI:Notification({
        Title = "LanezHub",
        Description = "Not Supported",
        Duration = 5
    })Parvus.Loaded = true
end
