--[[
oooo                              oooooooooo                o8              
 888       oooo  oooo  oooo   oooo  888    888 oooo   oooo o888oo ooooooooo8 
 888        888   888    888o888    888oooo88   888   888   888  888oooooo8  
 888      o 888   888    o88 88o    888    888   888 888    888  888         
o888ooooo88  888o88 8o o88o   o88o o888ooo888      8888      888o  88oooo888 
                                                o8o888
]]

-- Roblox Advanced Control Script
-- Includes FPS Control, Fly, Headsit, Rejoin, Bypass, Fun, and More
-- Credits: Made By LuxByte | blue app: catwix

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local Chat = game:GetService("Chat")

-- Variables
local lastFPS = 60 -- Default FPS
local isLagging = false
local isFlying = false
local isHeadsitting = false
local isBypassing = false
local isFun = false
local flyVelocity = Vector3.zero
local flySpeed = 50
local headsitTarget = nil
local headsitLoop = nil
local bypassLoop = nil
local bypassClone = nil
local funLoop = nil

-- Function to set FPS cap with error handling
local function setFPS(fps)
    local success, errorMessage = pcall(function()
        if fps and fps > 0 then
            RunService:SetFpsCap(fps)
            return true
        else
            error("Invalid FPS value.")
        end
    end)

    if not success then
        warn("Failed to set FPS: " .. errorMessage)
        return false
    end
    return true
end

-- Function to handle flying
local function startFlying(player)
    if isFlying then return end
    isFlying = true

    local character = player.Character
    if not character or not character.PrimaryPart then return end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Parent = character.PrimaryPart

    local function onInput(input)
        if not isFlying then return end
        local direction = Vector3.zero

        if input.KeyCode == Enum.KeyCode.W then
            direction = direction + Vector3.new(0, 0, -1)
        elseif input.KeyCode == Enum.KeyCode.S then
            direction = direction + Vector3.new(0, 0, 1)
        elseif input.KeyCode == Enum.KeyCode.A then
            direction = direction + Vector3.new(-1, 0, 0)
        elseif input.KeyCode == Enum.KeyCode.D then
            direction = direction + Vector3.new(1, 0, 0)
        end

        flyVelocity = direction * flySpeed
    end

    UserInputService.InputBegan:Connect(onInput)
    UserInputService.InputEnded:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or
           input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
            flyVelocity = Vector3.zero
        end
    end)

    RunService.Heartbeat:Connect(function()
        if isFlying and character and character.PrimaryPart then
            bodyVelocity.Velocity = flyVelocity
        end
    end)

    player:Chat("Fly mode activated. Use !unfly to stop.")
end

-- Function to stop flying
local function stopFlying(player)
    if not isFlying then return end
    isFlying = false

    local character = player.Character
    if character and character.PrimaryPart then
        for _, v in pairs(character.PrimaryPart:GetChildren()) do
            if v:IsA("BodyVelocity") then
                v:Destroy()
            end
        end
    end

    player:Chat("Fly mode deactivated.")
end

-- Function to start headsitting
local function startHeadsit(player, targetName)
    if isHeadsitting then return end
    isHeadsitting = true

    local targetPlayer = Players:FindFirstChild(targetName)
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("Head") then
        player:Chat("Target player not found or invalid.")
        return
    end

    headsitTarget = targetPlayer.Character.Head

    headsitLoop = RunService.Heartbeat:Connect(function()
        if isHeadsitting and player.Character and player.Character.PrimaryPart then
            local tween = TweenService:Create(
                player.Character.PrimaryPart,
                TweenInfo.new(0.2),
                {CFrame = headsitTarget.CFrame + Vector3.new(0, 2, 0)}
            )
            tween:Play()
        end
    end)

    player:Chat("Headsit mode activated. Use !unheadsit to stop.")
end

-- Function to stop headsitting
local function stopHeadsit(player)
    if not isHeadsitting then return end
    isHeadsitting = false

    if headsitLoop then
        headsitLoop:Disconnect()
        headsitLoop = nil
    end

    player:Chat("Headsit mode deactivated.")
end

-- Function to rejoin the game
local function rejoin(player)
    local success, errorMessage = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)

    if not success then
        player:Chat("Failed to rejoin. Error: " .. tostring(errorMessage))
    end
end

-- Function to start bypass effect
local function startBypass(player)
    if isBypassing then return end
    isBypassing = true

    local function resetCharacter()
        while isBypassing and player.Character do
            -- Create a clone of the character
            bypassClone = player.Character:Clone()
            bypassClone.Parent = workspace
            bypassClone:MoveTo(player.Character.PrimaryPart.Position)

            -- Reset the player's character
            player.Character:BreakJoints()

            -- Wait for a short duration
            task.wait(0.5)
        end
    end

    bypassLoop = RunService.Heartbeat:Connect(resetCharacter)

    player:Chat("Bypass mode activated. Use !unbypass to stop.")
end

-- Function to stop bypass effect
local function stopBypass(player)
    if not isBypassing then return end
    isBypassing = false

    if bypassLoop then
        bypassLoop:Disconnect()
        bypassLoop = nil
    end

    if bypassClone then
        bypassClone:Destroy()
        bypassClone = nil
    end

    player:Chat("Bypass mode deactivated.")
end

-- Function to start fun effect (sliding loop)
local function startFun(player)
    if isFun then return end
    isFun = true

    local character = player.Character
    if not character or not character.PrimaryPart then return end

    local slideDistance = 10
    local slideDuration = 1

    funLoop = RunService.Heartbeat:Connect(function()
        if isFun and character and character.PrimaryPart then
            -- Slide forward
            local tweenForward = TweenService:Create(
                character.PrimaryPart,
                TweenInfo.new(slideDuration),
                {CFrame = character.PrimaryPart.CFrame + Vector3.new(0, 0, -slideDistance)}
            )
            tweenForward:Play()
            tweenForward.Completed:Wait()

            -- Slide backward
            local tweenBackward = TweenService:Create(
                character.PrimaryPart,
                TweenInfo.new(slideDuration),
                {CFrame = character.PrimaryPart.CFrame + Vector3.new(0, 0, slideDistance)}
            )
            tweenBackward:Play()
            tweenBackward.Completed:Wait()
        end
    end)

    player:Chat("Fun mode activated. Use !unfun to stop.")
end

-- Function to stop fun effect
local function stopFun(player)
    if not isFun then return end
    isFun = false

    if funLoop then
        funLoop:Disconnect()
        funLoop = nil
    end

    player:Chat("Fun mode deactivated.")
end

-- Function to handle chat commands with error handling
local function onPlayerChat(player, message)
    local success, errorMessage = xpcall(function()
        -- Check if the message starts with "!"
        if message:sub(1, 1) == "!" then
            local command = message:sub(2):lower() -- Remove "!" and convert to lowercase
            local args = {}

            -- Split the command into arguments
            for arg in string.gmatch(command, "%S+") do
                table.insert(args, arg)
            end

            -- Command: !fps <number>
            if args[1] == "fps" and args[2] then
                local newFPS = tonumber(args[2])
                if newFPS and setFPS(newFPS) then
                    lastFPS = newFPS
                    isLagging = false
                    player:Chat("FPS set to " .. lastFPS)
                else
                    player:Chat("Invalid FPS value. Usage: !fps <number>")
                end

            -- Command: !lag
            elseif args[1] == "lag" then
                isLagging = true
                if setFPS(10) then -- Set FPS to 10 to simulate lag
                    player:Chat("Lag mode activated. Use !fps to return to normal.")
                else
                    player:Chat("Failed to activate lag mode.")
                end

            -- Command: !return
            elseif args[1] == "return" then
                if isLagging then
                    player:Chat("Last FPS was " .. lastFPS .. " (Lag mode was active).")
                else
                    player:Chat("Last FPS was " .. lastFPS .. " (Good FPS).")
                end
                if setFPS(lastFPS) then
                    isLagging = false
                else
                    player:Chat("Failed to restore FPS.")
                end

            -- Command: !fly
            elseif args[1] == "fly" then
                startFlying(player)

            -- Command: !unfly
            elseif args[1] == "unfly" then
                stopFlying(player)

            -- Command: !headsit <player>
            elseif args[1] == "headsit" and args[2] then
                startHeadsit(player, args[2])

            -- Command: !unheadsit
            elseif args[1] == "unheadsit" then
                stopHeadsit(player)

            -- Command: !rejoin
            elseif args[1] == "rejoin" then
                rejoin(player)

            -- Command: !bypass
            elseif args[1] == "bypass" then
                startBypass(player)

            -- Command: !unbypass
            elseif args[1] == "unbypass" then
                stopBypass(player)

            -- Command: !fun
            elseif args[1] == "fun" then
                startFun(player)

            -- Command: !unfun
            elseif args[1] == "unfun" then
                stopFun(player)

            -- Invalid Command
            else
                player:Chat("Invalid command. Available commands: !fps <number>, !lag, !return, !fly, !unfly, !headsit <player>, !unheadsit, !rejoin, !bypass, !unbypass, !fun, !unfun")
            end
        end
    end, function(err)
        warn("Chat command error: " .. tostring(err))
        player:Chat("An error occurred while processing your command.")
    end)

    if not success then
        warn("Chat command handler failed: " .. tostring(errorMessage))
    end
end

-- Function to initialize player with error handling
local function initializePlayer(player)
    local success, errorMessage = pcall(function()
        -- Send credits to the player when they join
        player:Chat("Made By LuxByte | blue app: catwix")

        -- Connect the chat event to the handler
        player.Chatted:Connect(function(message)
            onPlayerChat(player, message)
        end)
    end)

    if not success then
        warn("Failed to initialize player: " .. tostring(errorMessage))
    end
end

-- Connect players to the handler with error handling
local function onPlayerAdded(player)
    local success, errorMessage = pcall(function()
        initializePlayer(player)
    end)

    if not success then
        warn("Failed to connect player: " .. tostring(errorMessage))
    end
end

-- Set default FPS cap with error handling
local function initializeFPS()
    local success, errorMessage = pcall(function()
        setFPS(lastFPS)
    end)

    if not success then
        warn("Failed to set default FPS: " .. tostring(errorMessage))
    end
end

-- Main initialization
local function main()
    -- Set default FPS
    initializeFPS()

    -- Connect players
    Players.PlayerAdded:Connect(onPlayerAdded)

    -- Announce script creation
    print("Advanced Control Script Loaded | Made By LuxByte | blue app: catwix")
end

-- Run the main function with error handling
local success, errorMessage = pcall(main)
if not success then
    warn("Script initialization failed: " .. tostring(errorMessage))
end
