--纸飞机yut

local var3, var4, var5 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/UI.txt"))()
local var9 = var3:MakeWindow({
    Icon = "rbxassetid://8834748103",
    IntroEnabled = true,
    Name = "服务器选择",
    IntroIcon = "rbxassetid://8834748103",
    ConfigFolder = "ServerSelect",
    IntroText = "服务器选择",
    HidePremium = false,
    SaveConfig = false
}):MakeTab({
    Name = "服务器选择",
    Icon = "server"
})
var9:AddSection({
    Name = "更新日志"
})
var9:AddLabel("更新了致命猴子")
var9:AddLabel("Ear Game添加了传送")
var9:AddLabel("最后更新时间:2026/9/14")
var9:AddSection({
    Name = "可选服务器"
})
var9:AddButton({
    Icon = "rbxassetid://3944703587",
    Name = "通用",
    Callback = function()
        local var23, var24, var25 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/%E9%80%9A%E7%94%A8.LUA"))()
    end
})
var9:AddButton({
    Icon = "rbxassetid://3944703587",
    Name = "Ear Game",
    Callback = function()
        local var30, var31, var32 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/EAR%20GAME.LUA"))()
    end
})
var9:AddButton({
    Icon = "rbxassetid://3944703587",
    Name = "致命猴子",
    Callback = function()
        local var37, var38, var39 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/LETHALAPE.LUA"))()
    end
})
var9:AddButton({
    Icon = "rbxassetid://3944703587",
    Name = "Scary Baboon",
    Callback = function()
        local var44, var45, var46 = loadstring(game:HttpGet("https://raw.githubusercontent.com/Baloksxin/ROBLOX-BKU-SCRIPT/refs/heads/main/SCARYBABOON.LUA"))()
    end
})
var3:Init()