if game.PlaceId == 141084271 then return end
local Stats = game:GetService("Stats")
local Ping = Stats.Network.ServerStatsItem["Data Ping"]
local set_identity = (type(syn) == 'table' and syn.set_thread_identity) or setidentity or setthreadcontext
local aimtarget = nil
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local GetChildren = game.GetChildren
local GetPlayers = Players.GetPlayers
local WorldToScreen = Camera.WorldToScreenPoint
local WorldToViewportPoint = Camera.WorldToViewportPoint
local GetPartsObscuringTarget = Camera.GetPartsObscuringTarget
local FindFirstChild = game.FindFirstChild
local RenderStepped = RunService.RenderStepped
local GuiInset = GuiService.GetGuiInset
local GetMouseLocation = UserInputService.GetMouseLocation

local function getPositionOnScreen(Vector)
    local Vec3, OnScreen = WorldToScreen(Camera, Vector)
    return Vector2.new(Vec3.X, Vec3.Y), OnScreen
end

local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end

local function getDirection(Origin, Position)
    return (Position - Origin).Unit * 1000
end

local function getMousePosition()
    return GetMouseLocation(UserInputService)
end

local Window = LanezHub.Utilities.UI:Window({
    Name = "> LanezHub | "..LanezHub.Current,
    Position = UDim2.new(0.05,0,0.5,-248)
    }) do Window:Watermark({Enabled = true})
    local AutoTab = Window:Tab({Name = "Main"}) do
        local SilentSection = AutoTab:Section({Name = "Silent",Side = "Left"}) do
            SilentSection:Toggle({Name = "Enabled",Flag = "SilentAim/Enabled",Value = false})
            SilentSection:Toggle({Name = "Visible Check",Flag = "SilentAim/VisibleCheck",Value = true})
        end
        local MainSection = AutoTab:Section({Name = "Other",Side = "Left"}) do
            MainSection:Toggle({Name = "No Chad (Bow)",Flag = "Other/NoChad",Value = false})
        end
        local SAFoVSection = AutoTab:Section({Name = "Silent Aim FoV Circle",Side = "Right"}) do
            SAFoVSection:Toggle({Name = "Enabled",Flag = "SilentAim/Circle/Enabled",Value = true})
            SAFoVSection:Slider({Name = "Field of View",Flag = "SilentAim/FieldOfView",Min = 0,Max = 500,Value = 50})
            SAFoVSection:Toggle({Name = "Filled",Flag = "SilentAim/Circle/Filled",Value = false})
            SAFoVSection:Colorpicker({Name = "Color",Flag = "SilentAim/Circle/Color",Value = {0.66666668653488,0.75,1,0.5,true}})
            SAFoVSection:Slider({Name = "NumSides",Flag = "SilentAim/Circle/NumSides",Min = 3,Max = 100,Value = 100})
            SAFoVSection:Slider({Name = "Thickness",Flag = "SilentAim/Circle/Thickness",Min = 1,Max = 10,Value = 1})
        end
    end

    local NPCVisualsTab = Window:Tab({Name = "NPC"}) do
        local GlobalSection = NPCVisualsTab:Section({Name = "Global",Side = "Left"}) do
            GlobalSection:Colorpicker({Name = "Civilian Color",Flag = "ESP/NPC/Ally",Value = {0.33333334326744,0.75,1,0,false}})
            GlobalSection:Colorpicker({Name = "Enemy Color",Flag = "ESP/NPC/Enemy",Value = {1,0.75,1,0,false}})
            GlobalSection:Toggle({Name = "Hide Civilians",Flag = "ESP/NPC/TeamCheck",Value = true})
        end
        local BoxSection = NPCVisualsTab:Section({Name = "Boxes",Side = "Left"}) do
            BoxSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Box/Enabled",Value = false})
            BoxSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Box/Filled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Box/Outline",Value = true})
            BoxSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Box/Thickness",Min = 1,Max = 10,Value = 1})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Box/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            BoxSection:Divider({Text = "Text / Info"})
            BoxSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Text/Enabled",Value = false})
            BoxSection:Toggle({Name = "Outline",Flag = "ESP/NPC/Text/Outline",Value = true})
            BoxSection:Toggle({Name = "Autoscale",Flag = "ESP/NPC/Text/Autoscale",Value = true})
            BoxSection:Dropdown({Name = "Font",Flag = "ESP/NPC/Text/Font",List = {
                {Name = "UI",Mode = "Button"},
                {Name = "System",Mode = "Button"},
                {Name = "Plex",Mode = "Button"},
                {Name = "Monospace",Mode = "Button",Value = true}
            }})
            BoxSection:Slider({Name = "Size",Flag = "ESP/NPC/Text/Size",Min = 13,Max = 100,Value = 16})
            BoxSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Text/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local OoVSection = NPCVisualsTab:Section({Name = "Offscreen Arrows",Side = "Left"}) do
            OoVSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Arrow/Enabled",Value = false})
            OoVSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Arrow/Filled",Value = true})
            OoVSection:Slider({Name = "Height",Flag = "ESP/NPC/Arrow/Height",Min = 14,Max = 28,Value = 28})
            OoVSection:Slider({Name = "Width",Flag = "ESP/NPC/Arrow/Width",Min = 14,Max = 28,Value = 18})
            OoVSection:Slider({Name = "Distance From Center",Flag = "ESP/NPC/Arrow/Distance",Min = 80,Max = 200,Value = 200})
            OoVSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Arrow/Thickness",Min = 1,Max = 10,Value = 1})
            OoVSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Arrow/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HeadSection = NPCVisualsTab:Section({Name = "Head Circles",Side = "Right"}) do
            HeadSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Head/Enabled",Value = false})
            HeadSection:Toggle({Name = "Filled",Flag = "ESP/NPC/Head/Filled",Value = true})
            HeadSection:Toggle({Name = "Autoscale",Flag = "ESP/NPC/Head/Autoscale",Value = true})
            HeadSection:Slider({Name = "Radius",Flag = "ESP/NPC/Head/Radius",Min = 1,Max = 10,Value = 8})
            HeadSection:Slider({Name = "NumSides",Flag = "ESP/NPC/Head/NumSides",Min = 3,Max = 100,Value = 4})
            HeadSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Head/Thickness",Min = 1,Max = 10,Value = 1})
            HeadSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Head/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local TracerSection = NPCVisualsTab:Section({Name = "Tracers",Side = "Right"}) do
            TracerSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Tracer/Enabled",Value = false})
            TracerSection:Dropdown({Name = "Mode",Flag = "ESP/NPC/Tracer/Mode",List = {
                {Name = "From Bottom",Mode = "Button",Value = true},
                {Name = "From Mouse",Mode = "Button"}
            }})
            TracerSection:Slider({Name = "Thickness",Flag = "ESP/NPC/Tracer/Thickness",Min = 1,Max = 10,Value = 1})
            TracerSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Tracer/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
        end
        local HighlightSection = NPCVisualsTab:Section({Name = "Highlights",Side = "Right"}) do
            HighlightSection:Toggle({Name = "Enabled",Flag = "ESP/NPC/Highlight/Enabled",Value = false})
            HighlightSection:Slider({Name = "Transparency",Flag = "ESP/NPC/Highlight/Transparency",Min = 0,Max = 1,Precise = 2,Value = 0})
            HighlightSection:Colorpicker({Name = "Outline Color",Flag = "ESP/NPC/Highlight/OutlineColor",Value = {1,1,0,0.5,false}})
        end
    end

    local SettingsTab = Window:Tab({Name = "Settings"}) do
        local MenuSection = SettingsTab:Section({Name = "Menu",Side = "Left"}) do
            local MenuToggle = MenuSection:Toggle({Name = "Enabled",IgnoreFlag = true,Value = Window.Enabled,
            Callback = function(Bool)
                Window:Toggle(Bool)
            end}):Keybind({
                Value = "Home",
                Flag = "UI/Keybind",
                DoNotClear = true
            })
            MenuSection:Toggle({Name = "Watermark",Flag = "UI/Watermark",Value = true,
            Callback = function(Bool)
                Window.Watermark:Toggle(Bool)
            end})
            MenuSection:Colorpicker({Name = "UI Color",Flag = "UI/Color",Value = {1,0.25,1,0,true},
            Callback = function(HSVAR,Color)
                Window:SetColor(Color)
            end})
        end
        local BackgroundSection = SettingsTab:Section({Name = "Background",Side = "Right"}) do
            BackgroundSection:Dropdown({Name = "Image",Flag = "Background/Image",List = {
                {Name = "Legacy",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://2151741365"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Hearts",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073763717"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Abstract",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073743871"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Hexagon",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6073628839"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Circles",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071579801"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Lace With Flowers",Mode = "Button",Callback = function()
                    Window.Background.Image = "rbxassetid://6071575925"
                    Window.Flags["Background/CustomImage"] = ""
                end},
                {Name = "Floral",Mode = "Button",Value = true,Callback = function()
                    Window.Background.Image = "rbxassetid://5553946656"
                    Window.Flags["Background/CustomImage"] = ""
                end}
            }})
            BackgroundSection:Textbox({Name = "Custom Image",Flag = "Background/CustomImage",Placeholder = "ImageId",
            Callback = function(String)
                if string.gsub(String," ","") ~= "" then
                    Window.Background.Image = "rbxassetid://" .. String
                end
            end})
            BackgroundSection:Colorpicker({Name = "Color",Flag = "Background/Color",Value = {1,1,0,0,false},
            Callback = function(HSVAR,Color)
                Window.Background.ImageColor3 = Color
                Window.Background.ImageTransparency = HSVAR[4]
            end})
            BackgroundSection:Slider({Name = "Tile Offset",Flag = "Background/Offset",Min = 74, Max = 296,Value = 74,
            Callback = function(Number)
                Window.Background.TileSize = UDim2.new(0,Number,0,Number)
            end})
        end
        local CreditsSection = SettingsTab:Section({Name = "Credits",Side = "Left"}) do
            CreditsSection:Label({Text = "Script By | Lanez TH"})
            CreditsSection:Divider()
            CreditsSection:Label({Text = "Built | 17/3/2565"})
            CreditsSection:Label({Text = "Status | Now in testing"})
            CreditsSection:Button({Name = "Join Discord Server",Callback = function()
                local Request = syn and syn.request or request
                Request({
                    ["Url"] = "http://localhost:6463/rpc?v=1",
                    ["Method"] = "POST",
                    ["Headers"] = {
                        ["Content-Type"] = "application/json",
                        ["Origin"] = "https://discord.com"
                    },
                    ["Body"] = httpService:JSONEncode({
                        ["cmd"] = "INVITE_BROWSER",
                        ["nonce"] = string.lower(httpService:GenerateGUID(false)),
                        ["args"] = {
                            ["code"] = "BXW37g3j8P"
                        }
                    })
                })
            end}):ToolTip("Join for support, updates and more!")
            CreditsSection:Button({Name = "Server Hop",Callback = function()
                local Request = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                local DataDecoded,Servers = httpService:JSONDecode(Request).data,{}
                for Index,ServerData in ipairs(DataDecoded) do
                    if type(ServerData) == "table" and ServerData.id ~= game.JobId then
                        table.insert(Servers,ServerData.id)
                    end
                end
                if #Servers > 0 then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1, #Servers)])
                else
                    LanezHub.Utilities.UI:Notification({
                        Title = "LanezHub",
                        Description = "Couldn't find a server",
                        Duration = 5
                    })
                end
            end})
            CreditsSection:Button({Name = "Rejoin",Callback = function()
                if #game:GetService('Players'):GetPlayers() <= 1 then
                    LanezHub.Utilities.UI:Notification({
                        Title = "LanezHub",
                        Description = "change from rejoin to server hop",
                        Duration = 5
                    })
                    local Request = game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
                    local DataDecoded,Servers = httpService:JSONDecode(Request).data,{}
                    for Index,ServerData in ipairs(DataDecoded) do
                        if type(ServerData) == "table" and ServerData.id ~= game.JobId then
                            table.insert(Servers,ServerData.id)
                        end
                    end
                    if #Servers > 0 then
                        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, Servers[math.random(1, #Servers)])
                    else
                        LanezHub.Utilities.UI:Notification({
                            Title = "LanezHub",
                            Description = "Couldn't find a server",
                            Duration = 5
                        })
                    end
                else
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                end
            end})
        end
    end
end

Window:LoadDefaultConfig()
local GetFPS = LanezHub.Utilities.SetupFPS()
LanezHub.Utilities.Drawing:FoVCircle("SilentAim",Window.Flags)
local NPCFolder = game:GetService("Workspace").Entity

for Index,NPC in pairs(NPCFolder:GetChildren()) do
    if not NPC:FindFirstChildOfClass("Humanoid") and NPC:FindFirstChild("Head") and NPC:FindFirstChild("HumanoidRootPart") then else
        Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
    end
end
NPCFolder.ChildAdded:Connect(function(NPC)
    if not NPC:FindFirstChildOfClass("Humanoid") and NPC:FindFirstChild("Head") and NPC:FindFirstChild("HumanoidRootPart") then else
        Parvus.Utilities.Drawing:AddESP(NPC,"NPC","ESP/NPC",Window.Flags)
    end
end)
NPCFolder.ChildRemoved:Connect(function(NPC)
    if not NPC:FindFirstChildOfClass("Humanoid") and NPC:FindFirstChild("Head") and NPC:FindFirstChild("HumanoidRootPart") then else
        Parvus.Utilities.Drawing:RemoveESP(NPC)
    end
end)

local ExpectedArguments = {
    Raycast = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Vector3", "Vector3", "RaycastParams"
        }
    }
}

local oldNamecall;oldNamecall = hookmetamethod(game, "__namecall", function(...)
    local Method = getnamecallmethod()
    local Arguments = {...}
    local self = Arguments[1]
    if Window.Flags["SilentAim/Enabled"] and self == workspace then
        if Method == "Raycast" and aimtarget then
            if ValidateArguments(Arguments, ExpectedArguments.Raycast) then
                local A_Origin = Arguments[2]
                local HitPart = FindFirstChild(aimtarget, "HumanoidRootPart")
                if HitPart then
                    Arguments[3] = getDirection(A_Origin, HitPart.Position)
                end
            end
        end
    end
    return oldNamecall(unpack(Arguments))
end)

local hook = getrawmetatable(game);local fuckyoumom = hook.__namecall;setreadonly(hook,false)
hook.__namecall = newcclosure(function(self, ...)
    local args = {...}
    if getnamecallmethod() == 'FireServer' then
        if self.Name == 'PrimaryFire' and Window.Flags["Other/NoChad"] then
            if not args[3].FocusCharge then
            else
                args[3].FocusCharge = 1
            end
        end
    end
    return fuckyoumom(self, unpack(args))
end)


local function IsPlayerVisible(Target)
    local PlayerCharacter = Target
    local LocalPlayerCharacter = LocalPlayer.Character
    if not (PlayerCharacter or LocalPlayerCharacter) then return end 
    local PlayerRoot = FindFirstChild(PlayerCharacter, "HumanoidRootPart") or FindFirstChild(PlayerCharacter, "HumanoidRootPart")
    if not PlayerRoot then return end 
    local CastPoints, IgnoreList = {PlayerRoot.Position, LocalPlayerCharacter, PlayerCharacter}, {LocalPlayerCharacter, PlayerCharacter}
    local ObscuringObjects = #GetPartsObscuringTarget(Camera, CastPoints, IgnoreList)
    return ((ObscuringObjects == 0 and true) or (ObscuringObjects > 0 and false))
end

task.spawn(function()
    while true do task.wait();
        local ClosestDistance, ClosestInfected = math.huge, nil;
        for _,Infected in next, NPCFolder:GetChildren() do
            local pos = nil
            if not Infected:FindFirstChild("HumanoidRootPart") then else
                pos = Infected:FindFirstChild("HumanoidRootPart").Position
            end
            if pos then
                local ScreenPosition, IsVisibleOnViewPort = Camera:WorldToViewportPoint(pos)
                if IsVisibleOnViewPort then
                    if Window.Flags["SilentAim/VisibleCheck"] and not IsPlayerVisible(Infected) then continue end
                    local dist = (getMousePosition() - Vector2.new(ScreenPosition.X, ScreenPosition.Y)).Magnitude
                    if ScreenPosition.Z > 0 and dist <= Window.Flags["SilentAim/FieldOfView"] then
                        local dist3 = (pos - Camera.CFrame.Position).Magnitude
                        if dist3 < ClosestDistance then
                            ClosestInfected = Infected
                            ClosestDistance = dist3
                        end
                    end
                end
                aimtarget = ClosestInfected
            end
        end
    end
end);

task.spawn(function()
    while true do task.wait();
        if Window.Flags["UI/Watermark"] then
            Window.Watermark:SetTitle(string.format(
                "LanezHub |  %s    %i FPS    %i MS",os.date("%X"),GetFPS(),math.round(Ping:GetValue())
            ))
        end
    end
end);
