--luau开源
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local FireServer, InvokeServer
pcall(function()
    local devv = require(ReplicatedStorage.devv)
    local SignalModule = require(devv.client.Helpers.remotes.Signal)
    FireServer = SignalModule.FireServer
    InvokeServer = SignalModule.InvokeServer
end)

local itemMap = {}
local function updateCache()
    local itemPickup = Workspace.Game.Entities:FindFirstChild("ItemPickup")
    if not itemPickup then
        itemMap = {}
        return
    end
    itemMap = {}
    for _, model in pairs(itemPickup:GetChildren()) do
        for _, v in pairs(model:GetChildren()) do
            if v:IsA("MeshPart") or v:IsA("Part") then
                local prompt = v:FindFirstChildOfClass("ProximityPrompt")
                if prompt and prompt.ObjectText then
                    itemMap[prompt.ObjectText] = { part = v, prompt = prompt }
                end
            end
        end
    end
end
updateCache()
local itemPickupFolder = Workspace.Game.Entities:FindFirstChild("ItemPickup")
if itemPickupFolder then
    itemPickupFolder.ChildAdded:Connect(updateCache)
    itemPickupFolder.ChildRemoved:Connect(updateCache)
end

local function Autoitem(itemName)
    local itemData = itemMap[itemName]
    if not itemData then return false end
    local char = Players.LocalPlayer.Character
    if not char then return false end
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    rootPart.CFrame = itemData.part.CFrame
    itemData.prompt.RequiresLineOfSight = false
    itemData.prompt.HoldDuration = 0
    fireproximityprompt(itemData.prompt)
    return true
end

local balloonItems = {
    "Bunny Balloon", "Ghost Balloon", "Clover Balloon", "Bat Balloon",
    "Gold Clover Balloon", "Golden Rose", "Black Rose", "Heart Balloon"
}

local function collectBalloons()
    for _, name in ipairs(balloonItems) do
        Autoitem(name)
    end
end

local function getCharAndRoot()
    local char = Players.LocalPlayer.Character
    if not char then return nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    return char, hrp
end

local function robBankOnce()
    local char, hrp = getCharAndRoot()
    if not char then return false end
    local bankRobbery = Workspace:FindFirstChild("BankRobbery")
    if not bankRobbery then return false end
    local cashContainer = bankRobbery:FindFirstChild("BankCash") and bankRobbery.BankCash:FindFirstChild("Cash")
    if not cashContainer then return false end
    if #cashContainer:GetChildren() == 0 then return false end
    pcall(function()
        hrp.CFrame = bankRobbery.BankCash.Pallet.CFrame
        fireproximityprompt(bankRobbery.BankCash.Main.Attachment.ProximityPrompt)
    end)
    return true
end

local switched = false
function switchServer()
    if switched then return end
    switched = true
    local requestFunc = http_request or syn.request or request
    if not requestFunc then return end
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local response = requestFunc({Url = url, Method = "GET"})
    if response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data and data.data and #data.data > 0 then
            TeleportService:TeleportToPlaceInstance(
                game.PlaceId,
                data.data[math.random(1, #data.data)].id,
                Players.LocalPlayer
            )
        end
    end
end

repeat task.wait(0.5) until Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

task.spawn(function()
    while true do
        collectBalloons()
        task.wait(0.1)
    end
end)

local emptySince = nil
while true do
    local bank = Workspace:FindFirstChild("BankRobbery")
    local cashFolder = bank and bank:FindFirstChild("BankCash") and bank.BankCash:FindFirstChild("Cash")
    local hasCash = false
    if cashFolder and #cashFolder:GetChildren() > 0 then
        hasCash = true
    end

    if hasCash then
        emptySince = nil
        pcall(robBankOnce)
        task.wait(1)
    else
        if not emptySince then
            emptySince = tick()
        elseif tick() - emptySince >= 8 then
            switchServer()
            break
        end
        task.wait(1)
    end
end

while true do task.wait(10) end