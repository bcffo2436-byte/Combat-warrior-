-- Combat Warriors Mobile Ultimate
-- Delta Executor | Mobile Friendly
-- Auto Parry (Smart) + Aim Lock + Single Target Lock
-- Auto Attack + Detect Attack Animation
-- Anti Stun/Ragdoll + Floating Bubble

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

-- ================= SETTINGS =================
local AutoParry = false
local AimLock = false
local AutoAttack = false
local SingleLock = false
local LockedTarget = nil

local RANGE = 20
local ATTACK_RANGE = 14
local PARRY_VEL = 8

-- ================= UTILS =================
local function isEnemy(plr)
    return plr
        and plr ~= lp
        and plr.Character
        and plr.Character:FindFirstChild("HumanoidRootPart")
        and plr.Character:FindFirstChild("Humanoid")
end

local function getNearestEnemy()
    local closest, dist = nil, RANGE
    for _, plr in pairs(Players:GetPlayers()) do
        if isEnemy(plr) then
            local d = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                dist = d
                closest = plr
            end
        end
    end
    return closest
end

-- Detect attack animation
local function isAttacking(plr)
    local h = plr.Character:FindFirstChild("Humanoid")
    if not h then return false end
    for _, track in pairs(h:GetPlayingAnimationTracks()) do
        local id = tostring(track.Animation.AnimationId):lower()
        if id:find("attack") or id:find("slash") or id:find("swing") then
            return true
        end
    end
    return false
end

-- ================= ANTI STUN =================
hum.StateChanged:Connect(function(_, new)
    if new == Enum.HumanoidStateType.Physics
        or new == Enum.HumanoidStateType.Ragdoll
        or new == Enum.HumanoidStateType.FallingDown then
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end)

-- ================= MAIN LOOP =================
RunService.RenderStepped:Connect(function()
    local target

    if SingleLock and LockedTarget and isEnemy(LockedTarget) then
        target = LockedTarget
    else
        target = getNearestEnemy()
    end

    if not target then return end
    local thrp = target.Character.HumanoidRootPart

    -- Aim Lock
    if AimLock then
        hrp.CFrame = CFrame.new(hrp.Position, thrp.Position)
    end

    -- Smart Auto Parry
    if AutoParry then
        local dirToMe = (hrp.Position - thrp.Position).Unit
        local vel = thrp.Velocity
        local approaching = vel.Magnitude > 0 and vel.Unit:Dot(dirToMe) > 0.6
        local closeEnough = (thrp.Position - hrp.Position).Magnitude <= RANGE

        if (vel.Magnitude >= PARRY_VEL and approaching and closeEnough)
            or isAttacking(target) then
            mouse2click()
        end
    end

    -- Auto Attack
    if AutoAttack then
        local dist = (thrp.Position - hrp.Position).Magnitude
        if dist <= ATTACK_RANGE then
            mouse1click()
        end
    end
end)

-- ================= GUI =================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "CW_Ultimate_GUI"
gui.ResetOnSpawn = false

-- Floating Bubble
local bubble = Instance.new("TextButton", gui)
bubble.Size = UDim2.new(0, 60, 0, 60)
bubble.Position = UDim2.new(0.02, 0, 0.6, 0)
bubble.Text = "⚔️"
bubble.TextScaled = true
bubble.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
bubble.TextColor3 = Color3.new(1,1,1)
bubble.Active = true
bubble.Draggable = true

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 300)
frame.Position = UDim2.new(0.1, 0, 0.33, 0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Visible = false
frame.Active = true
frame.Draggable = true

local function btn(txt, y)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, -20, 0, 40)
    b.Position = UDim2.new(0, 10, 0, y)
    b.Text = txt
    b.TextScaled = true
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    return b
end

local bParry = btn("🗡️ Auto Parry : OFF", 10)
local bAim   = btn("🎯 Aim Lock : OFF", 55)
local bAtk   = btn("⚔️ Auto Attack : OFF", 100)
local bLock  = btn("🔴 Lock Target : OFF", 145)
local bPick  = btn("📌 Pick Nearest Target", 190)
local bClose = btn("❌ Close", 235)

bubble.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

bParry.MouseButton1Click:Connect(function()
    AutoParry = not AutoParry
    bParry.Text = "🗡️ Auto Parry : " .. (AutoParry and "ON" or "OFF")
end)

bAim.MouseButton1Click:Connect(function()
    AimLock = not AimLock
    bAim.Text = "🎯 Aim Lock : " .. (AimLock and "ON" or "OFF")
end)

bAtk.MouseButton1Click:Connect(function()
    AutoAttack = not AutoAttack
    bAtk.Text = "⚔️ Auto Attack : " .. (AutoAttack and "ON" or "OFF")
end)

bLock.MouseButton1Click:Connect(function()
    SingleLock = not SingleLock
    if not SingleLock then LockedTarget = nil end
    bLock.Text = "🔴 Lock Target : " .. (SingleLock and "ON" or "OFF")
end)

bPick.MouseButton1Click:Connect(function()
    LockedTarget = getNearestEnemy()
end)

bClose.MouseButton1Click:Connect(function()
    frame.Visible = false
end)
