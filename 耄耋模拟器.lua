--垃圾脚本by AI

-- 综合作弊脚本 - 优化版
-- UI库: WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/finendss/VowLibrary/refs/heads/main/WINDUI.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- 攻击远程事件
local AttackEvent = ReplicatedStorage:WaitForChild("Attack")

-- 功能状态表
local Features = {
    AutoAttack = false,
    NoCooldown = false,
    ESP = false,
    ESPHealth = false,
    ESPDistance = true,
    ESPName = true,
    ESPOutline = true,
    ESPFill = false,
    ESPOutlineThickness = 0.04,
    ESPFillTransparency = 0.5,
    AutoJump = false,
    JumpHold = false,
    SpeedHack = false,
    Fly = false,
    SpeedValue = 16,
    FlySpeed = 50,
    AttackSpeed = 0.1,
    ESPColor = "红色",
    FlyBoost = false,
    FlyBoostMultiplier = 2,
}

-- ESP存储 (Highlight实例 + Drawing文字)
local ESPStores = {}

-- 创建主窗口
local Window = WindUI:CreateWindow({
    Title = '耄耋角色扮演',
    Icon = "作者kela_er",
    Author = "作者kela_er",
    Size = UDim2.fromOffset(600, 500),
    Transparent = true,
    Theme = "FIN",
    HideSearchBar = false,
    ScrollBarEnabled = true,
    Resizable = true,
})

-- 时间标签
local TimeTag = Window:Tag({
    Title = "00:00",
    Color = Color3.fromRGB(255, 255, 255)
})

local hue = 0
task.spawn(function()
    while true do
        local now = os.date("*t")
        local hours = string.format("%02d", now.hour)
        local minutes = string.format("%02d", now.min)
        hue = (hue + 0.01) % 1
        local rainbowColor = Color3.fromHSV(hue, 1, 1)
        TimeTag:SetTitle(hours .. ":" .. minutes)
        TimeTag:SetColor(rainbowColor)
        task.wait(0.06)
    end
end)

Window:Tag({
    Title = "感谢使用",
    Color = Color3.fromHex("#7FDBFF")
})

Window:EditOpenButton({
    Title = "耄耋角色扮演",
    Icon = "monitor",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("FF6B6B")),
    Draggable = true,
})

-- ========== 战斗标签页 ==========
local CombatTab = Window:Tab({
    Title = "攻击",
    Icon = "sword",
    Locked = false,
})

CombatTab:Section({Title = "攻击功能", TextXAlignment = "Left", TextSize = 17})

-- 自动攻击开关
CombatTab:Toggle({
    Title = "自动攻击",
    Default = false,
    Callback = function(state)
        Features.AutoAttack = state
        if state then
            WindUI:Notify({Title = "已开启", Content = "自动攻击", Duration = 3})
        end
    end
})

-- 攻击速度滑块
CombatTab:Slider({
    Title = "攻击间隔(秒)",
    Value = {Min = 0.01, Max = 1, Default = 0.1},
    Increment = 0.01,
    Callback = function(value)
        Features.AttackSpeed = value
    end
})

CombatTab:Paragraph({
    Title = "说明",
    Desc = "自动攻击会持续对敌人发起攻击",
})

-- ========== 透视标签页 ==========
local ESPTab = Window:Tab({
    Title = "透视",
    Icon = "eye",
    Locked = false,
})

ESPTab:Section({Title = "高级ESP透视", TextXAlignment = "Left", TextSize = 17})

-- 总开关
ESPTab:Toggle({
    Title = "透视总开关",
    Default = false,
    Callback = function(state)
        Features.ESP = state
        if not state then
            ClearAllESP()
        end
        WindUI:Notify({Title = state and "已开启" or "已关闭", Content = "透视功能", Duration = 3})
    end
})

-- 高亮描边开关
ESPTab:Toggle({
    Title = "描边高亮",
    Default = true,
    Callback = function(state)
        Features.ESPOutline = state
        UpdateAllESPAppearance()
    end
})

-- 填充高亮开关
ESPTab:Toggle({
    Title = "填充高亮",
    Default = false,
    Callback = function(state)
        Features.ESPFill = state
        UpdateAllESPAppearance()
    end
})

-- 显示名字
ESPTab:Toggle({
    Title = "显示名字",
    Default = true,
    Callback = function(state)
        Features.ESPName = state
    end
})

-- 显示血量
ESPTab:Toggle({
    Title = "显示血量",
    Default = false,
    Callback = function(state)
        Features.ESPHealth = state
    end
})

-- 显示距离
ESPTab:Toggle({
    Title = "显示距离",
    Default = true,
    Callback = function(state)
        Features.ESPDistance = state
    end
})

-- 高亮颜色选择
ESPTab:Dropdown({
    Title = "高亮颜色",
    Values = {"红色", "蓝色", "绿色", "黄色", "紫色", "青色", "白色", "彩虹"},
    Value = "红色",
    Callback = function(value)
        Features.ESPColor = value
        UpdateAllESPAppearance()
    end
})

-- 描边粗细
ESPTab:Slider({
    Title = "描边粗细",
    Value = {Min = 0.01, Max = 0.15, Default = 0.04},
    Increment = 0.005,
    Callback = function(value)
        Features.ESPOutlineThickness = value
        UpdateAllESPAppearance()
    end
})

-- 填充透明度
ESPTab:Slider({
    Title = "填充透明度",
    Value = {Min = 0, Max = 1, Default = 0.5},
    Increment = 0.05,
    Callback = function(value)
        Features.ESPFillTransparency = value
        UpdateAllESPAppearance()
    end
})

ESPTab:Paragraph({
    Title = "",
    Desc = "",
})

-- ========== 设置标签页 ==========
local SettingsTab = Window:Tab({
    Title = "设置",
    Icon = "settings",
    Locked = false,
})

SettingsTab:Section({Title = "其他设置", TextXAlignment = "Left", TextSize = 17})

SettingsTab:Button({
    Title = "重置所有功能",
    Callback = function()
        Features.AutoAttack = false
        Features.NoCooldown = false
        Features.ESP = false
        Features.ESPHealth = false
        Features.AutoJump = false
        Features.JumpHold = false
        Features.SpeedHack = false
        Features.Fly = false
        ClearAllESP()
        ToggleFly(false)
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = 16
            char.Humanoid.JumpPower = 50
        end
        WindUI:Notify({Title = "已重置", Content = "所有功能已关闭", Duration = 3})
    end
})

SettingsTab:Paragraph({
    Title = "关于",
    Desc = "此脚本为AI制作",
})

SettingsTab:Paragraph({
    Title = "作者B站",
    Desc = "UID:3493085004695814",
})

SettingsTab:Button({
    Title = "复制作者UID",
    Desc = "点击复制 UID:3493085004695814 | 作者B站",
    Callback = function()
        local copyText = "UID:3493085004695814"
        pcall(function()
            if setclipboard then
                setclipboard(copyText)
            elseif toclipboard then
                toclipboard(copyText)
            end
        end)
        WindUI:Notify({
            Title = "已复制到剪贴板",
            Content = "作者B站",
            Duration = 3
        })
    end
})

-- ========== 功能实现 ==========

-- 获取最近的敌人
local function GetNearestEnemy()
    local nearest = nil
    local maxDist = math.huge
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = myChar.HumanoidRootPart.Position

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                if char.Humanoid.Health > 0 then
                    local dist = (char.HumanoidRootPart.Position - myPos).Magnitude
                    if dist < maxDist then
                        maxDist = dist
                        nearest = char
                    end
                end
            end
        end
    end
    return nearest
end

-- 自动攻击循环
task.spawn(function()
    while true do
        task.wait(Features.AttackSpeed)
        if Features.AutoAttack then
            local enemy = GetNearestEnemy()
            if enemy then
                pcall(function()
                    AttackEvent:FireServer(enemy)
                end)
            end
        end
    end
end)

-- 无冷却攻击 - 通过hook实现
local oldFireServer
oldFireServer = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    if Features.NoCooldown and method == "FireServer" and self == AttackEvent then
        return oldFireServer(self, ...)
    end
    return oldFireServer(self, ...)
end)

-- ========== 高级ESP系统 ==========

-- 获取ESP颜色
local function GetESPColor()
    local colorMap = {
        ["红色"] = Color3.fromRGB(255, 50, 50),
        ["蓝色"] = Color3.fromRGB(50, 100, 255),
        ["绿色"] = Color3.fromRGB(50, 255, 50),
        ["黄色"] = Color3.fromRGB(255, 255, 50),
        ["紫色"] = Color3.fromRGB(200, 50, 255),
        ["青色"] = Color3.fromRGB(50, 255, 255),
        ["白色"] = Color3.fromRGB(255, 255, 255),
    }
    if Features.ESPColor == "彩虹" then
        return Color3.fromHSV((os.clock() * 0.5) % 1, 1, 1)
    end
    return colorMap[Features.ESPColor] or Color3.fromRGB(255, 50, 50)
end

-- 根据血量获取颜色
local function GetHealthColor(healthPercent)
    if healthPercent > 0.6 then
        return Color3.fromRGB(50, 255, 50)
    elseif healthPercent > 0.3 then
        return Color3.fromRGB(255, 255, 50)
    else
        return Color3.fromRGB(255, 50, 50)
    end
end

-- 为玩家创建Highlight实例
local function CreateHighlight(player, character)
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight_" .. player.UserId
    highlight.Adornee = character
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    return highlight
end

-- 创建ESP文字标签
local function CreateESPTexts(playerId)
    local texts = {}
    
    -- 名字
    texts.NameText = Drawing.new("Text")
    texts.NameText.Size = 15
    texts.NameText.Center = true
    texts.NameText.Outline = true
    texts.NameText.OutlineColor = Color3.fromRGB(0, 0, 0)
    texts.NameText.Font = 2
    
    -- 距离
    texts.DistText = Drawing.new("Text")
    texts.DistText.Size = 13
    texts.DistText.Center = true
    texts.DistText.Outline = true
    texts.DistText.OutlineColor = Color3.fromRGB(0, 0, 0)
    texts.DistText.Font = 2
    
    -- 血量文字
    texts.HealthText = Drawing.new("Text")
    texts.HealthText.Size = 13
    texts.HealthText.Center = true
    texts.HealthText.Outline = true
    texts.HealthText.OutlineColor = Color3.fromRGB(0, 0, 0)
    texts.HealthText.Font = 2
    
    return texts
end

-- 清除单个玩家的ESP
local function ClearPlayerESP(playerId)
    local store = ESPStores[playerId]
    if not store then return end
    
    -- 清除Highlight
    if store.Highlight then
        pcall(function() store.Highlight:Destroy() end)
    end
    
    -- 清除Drawing文字
    if store.Texts then
        for _, text in pairs(store.Texts) do
            if text and text.Remove then
                pcall(function() text:Remove() end)
            end
        end
    end
    
    ESPStores[playerId] = nil
end

-- 清除所有ESP
function ClearAllESP()
    for playerId, _ in pairs(ESPStores) do
        ClearPlayerESP(playerId)
    end
    ESPStores = {}
end

-- 更新所有ESP外观
function UpdateAllESPAppearance()
    for playerId, store in pairs(ESPStores) do
        if store.Highlight and store.Highlight.Parent then
            local color = GetESPColor()
            
            -- 描边设置
            if Features.ESPOutline then
                store.Highlight.OutlineColor = color
                store.Highlight.OutlineTransparency = Features.ESPOutlineThickness
            else
                store.Highlight.OutlineTransparency = 1
            end
            
            -- 填充设置
            if Features.ESPFill then
                store.Highlight.FillColor = color
                store.Highlight.FillTransparency = Features.ESPFillTransparency
            else
                store.Highlight.FillTransparency = 1
            end
        end
    end
end

-- ESP主循环
task.spawn(function()
    while true do
        task.wait(0.02)
        
        if not Features.ESP then
            -- 关闭时隐藏所有文字
            for _, store in pairs(ESPStores) do
                if store.Texts then
                    for _, text in pairs(store.Texts) do
                        if text and text.Visible ~= nil then
                            text.Visible = false
                        end
                    end
                end
            end
            continue
        end
        
        local myChar = LocalPlayer.Character
        local myPos = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Position or Vector3.new()
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            
            local char = player.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            -- 角色无效，清除ESP
            if not char or not humanoid or not hrp or humanoid.Health <= 0 then
                if ESPStores[player.UserId] then
                    ClearPlayerESP(player.UserId)
                end
                continue
            end
            
            -- 获取或创建ESP存储
            local store = ESPStores[player.UserId]
            if not store then
                store = {}
                ESPStores[player.UserId] = store
            end
            
            -- 创建/检查Highlight
            if not store.Highlight or not store.Highlight.Parent then
                store.Highlight = CreateHighlight(player, char)
                -- 初始设置外观
                local color = GetESPColor()
                store.Highlight.OutlineColor = color
                store.Highlight.OutlineTransparency = Features.ESPOutline and Features.ESPOutlineThickness or 1
                store.Highlight.FillColor = color
                store.Highlight.FillTransparency = Features.ESPFill and Features.ESPFillTransparency or 1
            end
            
            -- 彩虹颜色实时更新
            if Features.ESPColor == "彩虹" then
                local rainbowColor = Color3.fromHSV((os.clock() * 0.5) % 1, 1, 1)
                if Features.ESPOutline then
                    store.Highlight.OutlineColor = rainbowColor
                end
                if Features.ESPFill then
                    store.Highlight.FillColor = rainbowColor
                end
            end
            
            -- 创建文字
            if not store.Texts then
                store.Texts = CreateESPTexts(player.UserId)
            end
            
            -- 获取屏幕位置
            local headPart = char:FindFirstChild("Head")
            local headPos = headPart and headPart.Position or (hrp.Position + Vector3.new(0, 2, 0))
            local screenPos, onScreen = Camera:WorldToViewportPoint(headPos + Vector3.new(0, 1.5, 0))
            local bottomPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
            
            if onScreen then
                local health = humanoid.Health
                local maxHealth = humanoid.MaxHealth
                local healthPercent = health / maxHealth
                local dist = (hrp.Position - myPos).Magnitude
                local boxColor = GetESPColor()
                
                -- 名字显示
                if Features.ESPName then
                    store.Texts.NameText.Visible = true
                    store.Texts.NameText.Text = player.Name
                    store.Texts.NameText.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                    store.Texts.NameText.Color = boxColor
                else
                    store.Texts.NameText.Visible = false
                end
                
                -- 距离显示
                if Features.ESPDistance then
                    store.Texts.DistText.Visible = true
                    store.Texts.DistText.Text = string.format("%.0f 米", dist)
                    store.Texts.DistText.Position = Vector2.new(screenPos.X, math.max(screenPos.Y, bottomPos.Y) + 5)
                    store.Texts.DistText.Color = Color3.fromRGB(220, 220, 220)
                else
                    store.Texts.DistText.Visible = false
                end
                
                -- 血量显示
                if Features.ESPHealth then
                    store.Texts.HealthText.Visible = true
                    local hpColor = GetHealthColor(healthPercent)
                    store.Texts.HealthText.Text = string.format("HP: %d/%d", math.floor(health), math.floor(maxHealth))
                    store.Texts.HealthText.Position = Vector2.new(screenPos.X, screenPos.Y + 5)
                    store.Texts.HealthText.Color = hpColor
                else
                    store.Texts.HealthText.Visible = false
                end
            else
                -- 不在屏幕上，隐藏文字
                if store.Texts then
                    for _, text in pairs(store.Texts) do
                        if text and text.Visible ~= nil then
                            text.Visible = false
                        end
                    end
                end
            end
        end
        
        -- 清理已离开的玩家
        for playerId, _ in pairs(ESPStores) do
            local playerFound = false
            for _, player in ipairs(Players:GetPlayers()) do
                if player.UserId == playerId then
                    playerFound = true
                    break
                end
            end
            if not playerFound then
                ClearPlayerESP(playerId)
            end
        end
    end
end)

-- ========== 速度hack循环 ==========
task.spawn(function()
    while true do
        task.wait(0.5)
        if Features.SpeedHack then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = Features.SpeedValue
            end
        end
    end
end)

-- ========== 角色加载时重新初始化 ==========
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    -- 重新设置速度
    if Features.SpeedHack and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = Features.SpeedValue
    end
    -- 如果飞行开启，重新启用
    if Features.Fly then
        ToggleFly(true)
    end
    -- 设置跳跃功能
    SetupAutoJump()
    SetupJumpHold()
end)

-- 初始化
SetupAutoJump()
SetupJumpHold()

-- 通知加载完成
WindUI:Notify({
    Title = "脚本加载完成",
    Content = "优化版已就绪，祝您游戏愉快！",
    Duration = 5
})
