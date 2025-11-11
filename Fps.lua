--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║           VGZINSK V2 - MOBILE EDITION                     ║
    ║           Steal a Brainrot Hack Script                    ║
    ║           Optimized for Touch-Screen                      ║
    ╚═══════════════════════════════════════════════════════════╝
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

-- VARIABLES
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local camera = Workspace.CurrentCamera

-- STATE MANAGEMENT
local scriptState = {
    -- ESP States
    espPlayers = false,
    rainbowBase = false,
    xray = false,
    timerESP = false,
    espLines = false,
    
    -- Main States
    platformBuilder = false,
    autoSteal = false,
    wallhack = false,
    antiAFK = false,
    freeze = false,
    expelBanned = false,
    
    -- FPS States (25 optimization functions)
    removeTextures = false,
    removeParticles = false,
    disableShadows = false,
    removeDecals = false,
    optimizeLighting = false,
    removeWaterEffects = false,
    optimizePhysics = false,
    removeBillboardGuis = false,
    simplifySkybox = false,
    removeAtmosphere = false,
    disablePostProcessing = false,
    optimizeNetwork = false,
    removeSparkles = false,
    simplifyMaterials = false,
    removeFire = false,
    optimizeCharacters = false,
    disableCameraEffects = false,
    reduceTextureQuality = false,
    fpsBoostUltimate = false,
    removeSmoke = false,
    disableBloom = false,
    removePointLights = false,
    disableDepthOfField = false,
    optimizeAnimations = false,
    reduceShadowQuality = false,
    disableMotionBlur = false
}

-- CONNECTIONS
local connections = {}

-- DATA STORAGE
local setPoint = nil
local previousPosition = nil
local platformParts = {}
local espObjects = {}
local wallhackOriginalStates = {}

-- GUI VARIABLES
local mainGui = nil
local bubbleButton = nil
local menuFrame = nil
local isMenuOpen = false

--[[
    ═══════════════════════════════════════════════════════════
                        UTILITY FUNCTIONS
    ═══════════════════════════════════════════════════════════
]]

local function CreateTween(object, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Quad,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(object, tweenInfo, properties)
    return tween
end

local function IsGroundPart(part)
    if not localPlayer.Character then return false end
    local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local playerPos = rootPart.Position
    local partPos = part.Position
    
    -- Verifica se está abaixo do jogador (chão)
    if partPos.Y < playerPos.Y - 2 then
        -- Verifica se está próximo horizontalmente
        local horizontalDistance = math.sqrt((partPos.X - playerPos.X)^2 + (partPos.Z - playerPos.Z)^2)
        if horizontalDistance < 15 then
            return true
        end
    end
    
    -- Verifica nomes comuns de chão
    local name = part.Name:lower()
    if name:find("floor") or name:find("ground") or name:find("base") or name:find("terrain") then
        return true
    end
    
    -- Verifica partes muito baixas e largas (geralmente chão)
    if part.Position.Y < 10 and part.Size.Y < 3 and (part.Size.X > 20 or part.Size.Z > 20) then
        return true
    end
    
    return false
end

--[[
    ═══════════════════════════════════════════════════════════
                        ESP FUNCTIONS
    ═══════════════════════════════════════════════════════════
]]

-- ESP PLAYERS
local function ToggleESPPlayers(state)
    scriptState.espPlayers = state
    
    if state then
        local function CreateESP(player)
            if player == localPlayer then return end
            
            local function AddESPToCharacter(character)
                -- Remove ESP antigo
                for _, obj in pairs(character:GetDescendants()) do
                    if obj.Name == "VGZINSK_ESP" then
                        obj:Destroy()
                    end
                end
                
                -- Criar novo ESP
                local highlight = Instance.new("Highlight")
                highlight.Name = "VGZINSK_ESP"
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0
                highlight.Parent = character
                
                table.insert(espObjects, highlight)
            end
            
            if player.Character then
                AddESPToCharacter(player.Character)
            end
            
            player.CharacterAdded:Connect(function(character)
                if scriptState.espPlayers then
                    AddESPToCharacter(character)
                end
            end)
        end
        
        for _, player in pairs(Players:GetPlayers()) do
            CreateESP(player)
        end
        
        connections.espPlayers = Players.PlayerAdded:Connect(CreateESP)
    else
        if connections.espPlayers then
            connections.espPlayers:Disconnect()
        end
        
        -- Remover todos os ESPs
        for _, obj in pairs(espObjects) do
            if obj and obj.Parent then
                obj:Destroy()
            end
        end
        espObjects = {}
    end
end

-- RAINBOW BASE HIGHLIGHT
local function ToggleRainbowBase(state)
    scriptState.rainbowBase = state
    
    if state then
        -- Procurar pela base do jogador
        local function FindPlayerBase()
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Model") and obj.Name:lower():find("base") then
                    -- Verificar se é a base do jogador (próxima ao spawn)
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "VGZINSK_RainbowBase"
                    highlight.FillTransparency = 0.7
                    highlight.OutlineTransparency = 0
                    highlight.Parent = obj
                    
                    table.insert(espObjects, highlight)
                    
                    -- Efeito rainbow
                    connections.rainbowBase = RunService.Heartbeat:Connect(function()
                        if scriptState.rainbowBase and highlight and highlight.Parent then
                            local hue = tick() % 5 / 5
                            highlight.FillColor = Color3.fromHSV(hue, 1, 1)
                            highlight.OutlineColor = Color3.fromHSV(hue, 1, 1)
                        end
                    end)
                end
            end
        end
        
        FindPlayerBase()
    else
        if connections.rainbowBase then
            connections.rainbowBase:Disconnect()
        end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj.Name == "VGZINSK_RainbowBase" then
                obj:Destroy()
            end
        end
    end
end

-- X-RAY
local function ToggleXRay(state)
    scriptState.xray = state
    
    if state then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("wall") or obj.Name:lower():find("door") then
                obj.Transparency = 0.8
                obj.CanCollide = false
            end
        end
    else
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Transparency = 0
                obj.CanCollide = true
            end
        end
    end
end

-- TIMER ESP
local function ToggleTimerESP(state)
    scriptState.timerESP = state
    
    if state then
        -- Procurar bases inimigas e adicionar timer
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") and obj.Name:lower():find("timer") then
                obj.Enabled = true
                obj.AlwaysOnTop = true
            end
        end
    else
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BillboardGui") and obj.Name:lower():find("timer") then
                obj.AlwaysOnTop = false
            end
        end
    end
end

-- ESP LINES
local function ToggleESPLines(state)
    scriptState.espLines = state
    
    if state then
        -- Criar linha verde para base do jogador
        local greenLine = Drawing.new("Line")
        greenLine.Visible = true
        greenLine.Color = Color3.fromRGB(0, 255, 0)
        greenLine.Thickness = 3
        greenLine.Transparency = 1
        
        -- Criar linha vermelha para brainrot mais caro
        local redLine = Drawing.new("Line")
        redLine.Visible = true
        redLine.Color = Color3.fromRGB(255, 0, 0)
        redLine.Thickness = 3
        redLine.Transparency = 1
        
        connections.espLines = RunService.RenderStepped:Connect(function()
            if scriptState.espLines and localPlayer.Character then
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
                    
                    -- Linha verde para base
                    local playerBase = Workspace:FindFirstChild("YourBase") -- Ajustar nome
                    if playerBase then
                        local basePos, onScreen = camera:WorldToViewportPoint(playerBase.Position)
                        if onScreen then
                            greenLine.From = screenCenter
                            greenLine.To = Vector2.new(basePos.X, basePos.Y)
                        end
                    end
                    
                    -- Linha vermelha para brainrot mais caro
                    local mostExpensiveBrainrot = nil
                    local highestValue = 0
                    
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj.Name:lower():find("brainrot") and obj:IsA("Model") then
                            -- Procurar valor do brainrot
                            local valueObj = obj:FindFirstChild("Value")
                            if valueObj and valueObj.Value > highestValue then
                                highestValue = valueObj.Value
                                mostExpensiveBrainrot = obj
                            end
                        end
                    end
                    
                    if mostExpensiveBrainrot then
                        local brainrotPos, onScreen = camera:WorldToViewportPoint(mostExpensiveBrainrot:GetPivot().Position)
                        if onScreen then
                            redLine.From = screenCenter
                            redLine.To = Vector2.new(brainrotPos.X, brainrotPos.Y)
                        end
                    end
                end
            end
        end)
        
        table.insert(espObjects, greenLine)
        table.insert(espObjects, redLine)
    else
        if connections.espLines then
            connections.espLines:Disconnect()
        end
        
        for _, obj in pairs(espObjects) do
            if typeof(obj) == "table" and obj.Remove then
                obj:Remove()
            end
        end
    end
end

--[[
    ═══════════════════════════════════════════════════════════
                        MAIN FUNCTIONS
    ═══════════════════════════════════════════════════════════
]]

-- PLATFORM BUILDER
local function TogglePlatformBuilder(state)
    scriptState.platformBuilder = state
    
    if state then
        local lastPlatformTime = {}
        
        local function CreatePlatform(position)
            local platform = Instance.new("Part")
            platform.Name = "VGZINSK_Platform"
            platform.Size = Vector3.new(6, 0.5, 6)
            platform.Position = position + Vector3.new(0, -3, 0)
            platform.Anchored = true
            platform.CanCollide = true
            platform.Material = Enum.Material.Neon
            platform.BrickColor = BrickColor.new("Bright blue")
            platform.Transparency = 0.3
            platform.Parent = Workspace
            
            table.insert(platformParts, platform)
            lastPlatformTime[platform] = tick()
            
            -- Remover após 3 segundos
            task.delay(3, function()
                if platform and platform.Parent then
                    platform:Destroy()
                    for i, p in ipairs(platformParts) do
                        if p == platform then
                            table.remove(platformParts, i)
                            break
                        end
                    end
                end
            end)
        end
        
        connections.platformBuilder = UserInputService.JumpRequest:Connect(function()
            if scriptState.platformBuilder and localPlayer.Character then
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    CreatePlatform(rootPart.Position)
                end
            end
        end)
    else
        if connections.platformBuilder then
            connections.platformBuilder:Disconnect()
        end
        
        for _, platform in ipairs(platformParts) do
            if platform and platform.Parent then
                platform:Destroy()
            end
        end
        platformParts = {}
    end
end

-- AUTO STEAL
local autoStealEnabled = false
local autoStealSetPoint = nil

local function ToggleAutoSteal(state)
    scriptState.autoSteal = state
    autoStealEnabled = state
    
    if state then
        connections.autoSteal = RunService.Heartbeat:Connect(function()
            if not autoStealEnabled or not localPlayer.Character then return end
            
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Procurar brainrot próximo
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj.Name:lower():find("brainrot") and obj:IsA("Model") then
                    local distance = (obj:GetPivot().Position - rootPart.Position).Magnitude
                    
                    if distance < 10 then
                        -- Simular segurar botão de roubo
                        local stealButton = playerGui:FindFirstChild("StealButton", true)
                        if stealButton then
                            -- Ativar roubo
                            task.wait(2) -- Tempo de segurar
                            
                            -- Teleportar de volta para set point
                            if autoStealSetPoint then
                                -- Fazer personagem flutuar
                                local bodyVelocity = Instance.new("BodyVelocity")
                                bodyVelocity.Velocity = Vector3.new(0, 50, 0)
                                bodyVelocity.MaxForce = Vector3.new(0, math.huge, 0)
                                bodyVelocity.Parent = rootPart
                                
                                task.wait(0.5)
                                
                                -- Teleportar
                                rootPart.CFrame = CFrame.new(autoStealSetPoint)
                                
                                bodyVelocity:Destroy()
                            end
                        end
                    end
                end
            end
        end)
    else
        if connections.autoSteal then
            connections.autoSteal:Disconnect()
        end
    end
end

local function SetAutoStealPoint()
    if localPlayer.Character then
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            autoStealSetPoint = rootPart.Position
            return true
        end
    end
    return false
end

-- WALLHACK (CORRIGIDO)
local function ToggleWallhack(state)
    scriptState.wallhack = state
    
    if state then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not IsGroundPart(obj) then
                -- Salvar estado original
                if not wallhackOriginalStates[obj] then
                    wallhackOriginalStates[obj] = {
                        CanCollide = obj.CanCollide,
                        Transparency = obj.Transparency
                    }
                end
                
                -- Remover colisão e aumentar transparência
                obj.CanCollide = false
                obj.Transparency = 0.7
            end
        end
        
        -- Monitorar novos objetos
        connections.wallhack = Workspace.DescendantAdded:Connect(function(obj)
            if scriptState.wallhack and obj:IsA("BasePart") and not IsGroundPart(obj) then
                wallhackOriginalStates[obj] = {
                    CanCollide = obj.CanCollide,
                    Transparency = obj.Transparency
                }
                obj.CanCollide = false
                obj.Transparency = 0.7
            end
        end)
    else
        if connections.wallhack then
            connections.wallhack:Disconnect()
        end
        
        -- Restaurar estados originais
        for obj, state in pairs(wallhackOriginalStates) do
            if obj and obj.Parent then
                obj.CanCollide = state.CanCollide
                obj.Transparency = state.Transparency
            end
        end
        wallhackOriginalStates = {}
    end
end

-- ANTI AFK
local function ToggleAntiAFK(state)
    scriptState.antiAFK = state
    
    if state then
        local direction = 1 -- 1 for right, -1 for left
        connections.antiAFK = RunService.Heartbeat:Connect(function()
            if not localPlayer.Character then return end
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then return end
            
            -- Alternar direção a cada 2 segundos para simular movimento
            if tick() % 2 < 1 then
                direction = 1
            else
                direction = -1
            end
            
            -- Simular movimento lateral (analógico)
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local moveVector = rootPart.CFrame.RightVector * direction * 0.1 -- Pequeno movimento lateral
                humanoid:Move(moveVector)
            end
        end)
    else
        if connections.antiAFK then
            connections.antiAFK:Disconnect()
        end
        
        if localPlayer.Character then
            local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:Move(Vector3.new(0, 0, 0))
            end
        end
    end
end

-- FREEZE (CONGELAMENTO DE INIMIGO)
local function ToggleFreeze(state)
    scriptState.freeze = state
    
    if state then
        connections.freeze = localPlayer.Character.ChildAdded:Connect(function(child)
            -- Detectar se o jogador equipou o taco (ou ferramenta de ataque)
            if child:IsA("Tool") and (child.Name:lower():find("stick") or child.Name:lower():find("taco")) then
                child.Activated:Connect(function()
                    -- Procurar inimigo próximo
                    local target = nil
                    local minDistance = 10
                    local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                    
                    if not rootPart then return end
                    
                    for _, player in pairs(Players:GetPlayers()) do
                        if player ~= localPlayer and player.Character then
                            local enemyRoot = player.Character:FindFirstChild("HumanoidRootPart")
                            if enemyRoot then
                                local distance = (enemyRoot.Position - rootPart.Position).Magnitude
                                if distance < minDistance then
                                    minDistance = distance
                                    target = player
                                end
                            end
                        end
                    end
                    
                    if target and target.Character then
                        -- Tentar congelar o inimigo (Client-Side Block)
                        local enemyHumanoid = target.Character:FindFirstChildOfClass("Humanoid")
                        if enemyHumanoid then
                            enemyHumanoid.WalkSpeed = 0
                            enemyHumanoid.JumpPower = 0
                            
                            -- Adicionar um BodyPosition para tentar fixar a posição
                            local bodyPos = Instance.new("BodyPosition")
                            bodyPos.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                            bodyPos.Position = enemyHumanoid.Parent:GetPivot().Position
                            bodyPos.Parent = enemyHumanoid.Parent:FindFirstChild("HumanoidRootPart")
                            
                            -- Remover o congelamento após 5 segundos (para evitar suspeitas)
                            task.delay(5, function()
                                if enemyHumanoid and enemyHumanoid.Parent then
                                    enemyHumanoid.WalkSpeed = 16
                                    enemyHumanoid.JumpPower = 50
                                end
                                if bodyPos and bodyPos.Parent then
                                    bodyPos:Destroy()
                                end
                            end)
                        end
                    end
                end)
            end
        end)
    else
        if connections.freeze then
            connections.freeze:Disconnect()
        end
    end
end

-- EXPEL BANNED (KICK FORÇADO)
local function KickTargetPlayer(targetPlayer)
    if not targetPlayer then return end
    
    -- Tentar forçar o kick (Client-Side Exploit)
    -- A maneira mais "segura" (client-side) é destruir o Character e causar um erro de replicação.
    if targetPlayer.Character then
        targetPlayer.Character:Destroy()
    end
    
    -- Tentativa de causar um erro de script no lado do cliente do alvo (altamente dependente do jogo/executor)
    -- Não implementaremos código invasivo aqui, apenas a destruição do Character.
end

--[[
    ═══════════════════════════════════════════════════════════
                        FPS OPTIMIZATION FUNCTIONS (25)
    ═══════════════════════════════════════════════════════════
]]

local optimizationFunctions = {
    {
        key = "removeTextures",
        name = "Remove Textures",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Texture") or obj:IsA("Decal") then
                    obj.Transparency = state and 1 or 0
                end
            end
        end
    },
    {
        key = "removeParticles",
        name = "Remove Particles",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "disableShadows",
        name = "Disable Shadows",
        func = function(state)
            Lighting.GlobalShadows = not state
        end
    },
    {
        key = "removeDecals",
        name = "Remove Decals",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Decal") then
                    obj.Transparency = state and 1 or 0
                end
            end
        end
    },
    {
        key = "optimizeLighting",
        name = "Optimize Lighting",
        func = function(state)
            if state then
                Lighting.Technology = Enum.Technology.Compatibility
            else
                Lighting.Technology = Enum.Technology.ShadowMap
            end
        end
    },
    {
        key = "removeWaterEffects",
        name = "Remove Water Effects",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Water") then
                    obj.Transparency = state and 1 or 0
                end
            end
        end
    },
    {
        key = "optimizePhysics",
        name = "Optimize Physics",
        func = function(state)
            if state then
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
            else
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default
            end
        end
    },
    {
        key = "removeBillboardGuis",
        name = "Remove Billboard GUIs",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "simplifySkybox",
        name = "Simplify Skybox",
        func = function(state)
            if state then
                for _, obj in pairs(Lighting:GetChildren()) do
                    if obj:IsA("Sky") then
                        obj.Parent = nil
                    end
                end
            end
        end
    },
    {
        key = "removeAtmosphere",
        name = "Remove Atmosphere",
        func = function(state)
            if state then
                for _, obj in pairs(Lighting:GetChildren()) do
                    if obj:IsA("Atmosphere") then
                        obj.Parent = nil
                    end
                end
            end
        end
    },
    {
        key = "disablePostProcessing",
        name = "Disable Post Processing",
        func = function(state)
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "optimizeNetwork",
        name = "Optimize Network",
        func = function(state)
            settings().Network.IncomingReplicationLag = state and 1000 or 0
        end
    },
    {
        key = "removeSparkles",
        name = "Remove Sparkles",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Sparkles") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "simplifyMaterials",
        name = "Simplify Materials",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    },
    {
        key = "removeFire",
        name = "Remove Fire",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Fire") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "optimizeCharacters",
        name = "Optimize Characters",
        func = function(state)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.Material = Enum.Material.Plastic
                            part.CastShadow = not state
                        end
                    end
                end
            end
        end
    },
    {
        key = "disableCameraEffects",
        name = "Disable Camera Effects",
        func = function(state)
            for _, obj in pairs(camera:GetChildren()) do
                if obj:IsA("DepthOfFieldEffect") or obj:IsA("BlurEffect") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "reduceTextureQuality",
        name = "Reduce Texture Quality",
        func = function(state)
            settings().Rendering.QualityLevel = state and Enum.QualityLevel.Level01 or Enum.QualityLevel.Automatic
        end
    },
    {
        key = "removeSmoke",
        name = "Remove Smoke",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("Smoke") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "disableBloom",
        name = "Disable Bloom",
        func = function(state)
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("BloomEffect") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "removePointLights",
        name = "Remove Point Lights",
        func = function(state)
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "disableDepthOfField",
        name = "Disable Depth of Field",
        func = function(state)
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("DepthOfFieldEffect") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "optimizeAnimations",
        name = "Optimize Animations",
        func = function(state)
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= localPlayer and player.Character then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            if state then
                                track:Stop()
                            end
                        end
                    end
                end
            end
        end
    },
    {
        key = "reduceShadowQuality",
        name = "Reduce Shadow Quality",
        func = function(state)
            Lighting.ShadowSoftness = state and 0 or 0.2
        end
    },
    {
        key = "disableMotionBlur",
        name = "Disable Motion Blur",
        func = function(state)
            for _, obj in pairs(camera:GetChildren()) do
                if obj:IsA("BlurEffect") then
                    obj.Enabled = not state
                end
            end
        end
    }
}

-- FPS BOOST ULTIMATE (ativa todas as 25 funções)
local function ToggleFPSBoostUltimate(state)
    scriptState.fpsBoostUltimate = state
    
    for _, funcData in ipairs(optimizationFunctions) do
        scriptState[funcData.key] = state
        funcData.func(state)
    end
end

--[[
    ═══════════════════════════════════════════════════════════
                        GUI CREATION
    ═══════════════════════════════════════════════════════════
]]

local function CreateBubbleGUI()
    -- Main ScreenGui
    mainGui = Instance.new("ScreenGui")
    mainGui.Name = "VGZINSK_V2"
    mainGui.ResetOnSpawn = false
    mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- Bubble Button (Minimized State)
    bubbleButton = Instance.new("ImageButton")
    bubbleButton.Name = "BubbleButton"
    bubbleButton.Size = UDim2.new(0, 60, 0, 60)
    bubbleButton.Position = UDim2.new(1, -80, 0, 100)
    bubbleButton.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    bubbleButton.BorderSizePixel = 0
    bubbleButton.Active = true
    bubbleButton.Draggable = true
    bubbleButton.Parent = mainGui
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubbleButton
    
    local bubbleStroke = Instance.new("UIStroke")
    bubbleStroke.Thickness = 3
    bubbleStroke.Color = Color3.fromRGB(0, 255, 255)
    bubbleStroke.Parent = bubbleButton
    
    local bubbleIcon = Instance.new("TextLabel")
    bubbleIcon.Size = UDim2.new(1, 0, 1, 0)
    bubbleIcon.BackgroundTransparency = 1
    bubbleIcon.Text = "⚡"
    bubbleIcon.TextColor3 = Color3.fromRGB(0, 255, 255)
    bubbleIcon.Font = Enum.Font.GothamBold
    bubbleIcon.TextSize = 30
    bubbleIcon.Parent = bubbleButton
    
    -- Menu Frame (Expanded State)
    menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(0, 0, 0, 0)
    menuFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    menuFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    menuFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
    menuFrame.BorderSizePixel = 0
    menuFrame.Visible = false
    menuFrame.Parent = mainGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 15)
    menuCorner.Parent = menuFrame
    
    local menuStroke = Instance.new("UIStroke")
    menuStroke.Thickness = 3
    menuStroke.Color = Color3.fromRGB(0, 255, 255)
    menuStroke.Parent = menuFrame
    
    -- Header
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
    header.BorderSizePixel = 0
    header.Parent = menuFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 15)
    headerCorner.Parent = header
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.Position = UDim2.new(0, 10, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ VGZINSK V2"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    minimizeBtn.Position = UDim2.new(1, -80, 0, 7)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "_"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.TextSize = 20
    minimizeBtn.Parent = header
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 8)
    minimizeCorner.Parent = minimizeBtn
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -40, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.Parent = header
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = closeBtn
    
    -- Tab Container
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -20, 0, 40)
    tabContainer.Position = UDim2.new(0, 10, 0, 60)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = menuFrame
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Padding = UDim.new(0, 10)
    tabLayout.Parent = tabContainer
    
    -- Content Frame
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Size = UDim2.new(1, -20, 1, -120)
    contentFrame.Position = UDim2.new(0, 10, 0, 110)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = 6
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.Parent = menuFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.Parent = contentFrame
    
    -- Auto-resize canvas
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 10)
    end)
    
    -- Create Tabs
    local tabs = {"ESP", "MAIN", "+FPS"}
    local currentTab = "ESP"
    
    local function CreateTab(tabName)
        local tabBtn = Instance.new("TextButton")
        tabBtn.Size = UDim2.new(0, 100, 0, 35)
        tabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
        tabBtn.BorderSizePixel = 0
        tabBtn.Text = tabName
        tabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        tabBtn.Font = Enum.Font.GothamBold
        tabBtn.TextSize = 14
        tabBtn.Parent = tabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8)
        tabCorner.Parent = tabBtn
        
        tabBtn.MouseButton1Click:Connect(function()
            currentTab = tabName
            
            -- Update tab colors
            for _, tab in pairs(tabContainer:GetChildren()) do
                if tab:IsA("TextButton") then
                    if tab.Text == tabName then
                        tab.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
                        tab.TextColor3 = Color3.fromRGB(255, 255, 255)
                    else
                        tab.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
                        tab.TextColor3 = Color3.fromRGB(200, 200, 200)
                    end
                end
            end
            
            -- Clear content
            for _, child in pairs(contentFrame:GetChildren()) do
                if not child:IsA("UIListLayout") then
                    child:Destroy()
                end
            end
            
            -- Load tab content
            if tabName == "ESP" then
                CreateESPTab()
            elseif tabName == "MAIN" then
                CreateMainTab()
            elseif tabName == "+FPS" then
                CreateFPSTab()
            end
        end)
        
        return tabBtn
    end
    
    -- Create all tabs
    for _, tabName in ipairs(tabs) do
        CreateTab(tabName)
    end
    
    -- Set default tab
    tabContainer:GetChildren()[2].BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    tabContainer:GetChildren()[2].TextColor3 = Color3.fromRGB(255, 255, 255)
    
    -- Button Click Handlers
    bubbleButton.MouseButton1Click:Connect(function()
        if not isMenuOpen then
            -- Open menu with animation
            menuFrame.Visible = true
            menuFrame.Size = UDim2.new(0, 0, 0, 0)
            
            local openTween = CreateTween(menuFrame, {
                Size = UDim2.new(0, 350, 0, 500)
            }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            
            openTween:Play()
            
            bubbleButton.Visible = false
            isMenuOpen = true
            
            -- Load default tab
            CreateESPTab()
        end
    end)
    
    minimizeBtn.MouseButton1Click:Connect(function()
        -- Close menu with animation
        local closeTween = CreateTween(menuFrame, {
            Size = UDim2.new(0, 0, 0, 0)
        }, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        
        closeTween:Play()
        closeTween.Completed:Connect(function()
            menuFrame.Visible = false
            bubbleButton.Visible = true
            isMenuOpen = false
        end)
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        -- Destroy GUI completely
        mainGui:Destroy()
        
        -- Disconnect all connections
        for _, connection in pairs(connections) do
            if connection then
                connection:Disconnect()
            end
        end
    end)
    
    mainGui.Parent = CoreGui
end

--[[
    ═══════════════════════════════════════════════════════════
                        TAB CONTENT CREATION
    ═══════════════════════════════════════════════════════════
]]

local function CreateToggleButton(name, description, callback, parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.7, 0, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = container
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 60, 0, 30)
    toggleBtn.Position = UDim2.new(1, -70, 0.5, -15)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Text = "OFF"
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.Parent = container
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleBtn
    
    local isEnabled = false
    
    toggleBtn.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        if isEnabled then
            toggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
            toggleBtn.Text = "ON"
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            toggleBtn.Text = "OFF"
        end
        
        callback(isEnabled)
    end)
    
    return container
end

function CreateESPTab()
    local parent = menuFrame:FindFirstChild("ScrollingFrame")
    
    CreateToggleButton(
        "👁️ ESP Players",
        "Mostrar jogadores inimigos",
        ToggleESPPlayers,
        parent
    )
    
    CreateToggleButton(
        "🌈 Rainbow Base",
        "Destaque arco-íris na base",
        ToggleRainbowBase,
        parent
    )
    
    CreateToggleButton(
        "🔍 X-Ray",
        "Ver através das paredes",
        ToggleXRay,
        parent
    )
    
    CreateToggleButton(
        "⏱️ Timer ESP",
        "Mostrar tempo de abertura",
        ToggleTimerESP,
        parent
    )
    
    CreateToggleButton(
        "📍 ESP Lines",
        "Linhas para base e brainrot",
        ToggleESPLines,
        parent
    )
end

function CreateMainTab()
    local parent = menuFrame:FindFirstChild("ScrollingFrame")
    
    CreateToggleButton(
        "🏗️ Platform Builder",
        "Plataforma ao pular (3s)",
        TogglePlatformBuilder,
        parent
    )
    
    CreateToggleButton(
        "🚀 Auto Steal",
        "Roubar e voltar automático",
        ToggleAutoSteal,
        parent
    )
    
    -- Set Point Button
    local setPointContainer = Instance.new("Frame")
    setPointContainer.Size = UDim2.new(1, 0, 0, 50)
    setPointContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    setPointContainer.BorderSizePixel = 0
    setPointContainer.Parent = parent
    
    local setPointCorner = Instance.new("UICorner")
    setPointCorner.CornerRadius = UDim.new(0, 10)
    setPointCorner.Parent = setPointContainer
    
    local setPointBtn = Instance.new("TextButton")
    setPointBtn.Size = UDim2.new(1, -20, 1, -10)
    setPointBtn.Position = UDim2.new(0, 10, 0, 5)
    setPointBtn.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    setPointBtn.BorderSizePixel = 0
    setPointBtn.Text = "📍 SET POINT (Auto Steal)"
    setPointBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPointBtn.Font = Enum.Font.GothamBold
    setPointBtn.TextSize = 13
    setPointBtn.Parent = setPointContainer
    
    local setPointBtnCorner = Instance.new("UICorner")
    setPointBtnCorner.CornerRadius = UDim.new(0, 8)
    setPointBtnCorner.Parent = setPointBtn
    
    setPointBtn.MouseButton1Click:Connect(function()
        if SetAutoStealPoint() then
            setPointBtn.Text = "✅ POINT SET!"
            task.wait(1)
            setPointBtn.Text = "📍 SET POINT (Auto Steal)"
        end
    end)
    
    CreateToggleButton(
        "👻 Wallhack",
        "Atravessar paredes (não chão)",
        ToggleWallhack,
        parent
    )
    
    CreateToggleButton(
        "🚶 Anti AFK",
        "Movimento automático para não ser kickado",
        ToggleAntiAFK,
        parent
    )
    
    CreateToggleButton(
        "❄️ Freeze",
        "Congela inimigo ao acertar com taco",
        ToggleFreeze,
        parent
    )
    
    -- Botão para Expel Banned (Kick)
    local expelContainer = Instance.new("Frame")
    expelContainer.Size = UDim2.new(1, 0, 0, 50)
    expelContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    expelContainer.BorderSizePixel = 0
    expelContainer.Parent = parent
    
    local expelCorner = Instance.new("UICorner")
    expelCorner.CornerRadius = UDim.new(0, 10)
    expelCorner.Parent = expelContainer
    
    local expelBtn = Instance.new("TextButton")
    expelBtn.Size = UDim2.new(1, -20, 1, -10)
    expelBtn.Position = UDim2.new(0, 10, 0, 5)
    expelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    expelBtn.BorderSizePixel = 0
    expelBtn.Text = "❌ EXPEL BANNED (Kick Dono da Base)"
    expelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    expelBtn.Font = Enum.Font.GothamBold
    expelBtn.TextSize = 13
    expelBtn.Parent = expelContainer
    
    local expelBtnCorner = Instance.new("UICorner")
    expelBtnCorner.CornerRadius = UDim.new(0, 8)
    expelBtnCorner.Parent = expelBtn
    
    expelBtn.MouseButton1Click:Connect(function()
        -- Lógica para encontrar o dono da base inimiga mais próxima
        local targetPlayer = nil
        local minDistance = math.huge
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart then return end
        
        for _, base in pairs(Workspace:GetDescendants()) do
            if base:IsA("Model") and base.Name:lower():find("base") and base.Name:lower() ~= "yourbase" then
                -- Tentar extrair o nome do dono da base
                local baseOwnerName = base.Name:match("Base_(.+)")
                
                if baseOwnerName then
                    local owner = Players:FindFirstChild(baseOwnerName)
                    if owner and owner.Character then
                        local distance = (base:GetPivot().Position - rootPart.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            targetPlayer = owner
                        end
                    end
                end
            end
        end
        
        if targetPlayer then
            KickTargetPlayer(targetPlayer)
            expelBtn.Text = "✅ KICK TENTADO: " .. targetPlayer.Name
            task.delay(3, function()
                expelBtn.Text = "❌ EXPEL BANNED (Kick Dono da Base)"
            end)
        else
            expelBtn.Text = "⚠️ NENHUM ALVO ENCONTRADO"
            task.delay(3, function()
                expelBtn.Text = "❌ EXPEL BANNED (Kick Dono da Base)"
            end)
        end
    end)
    
    CreateToggleButton(
        "🚶 Anti AFK",
        "Movimento automático para não ser kickado",
        ToggleAntiAFK,
        parent
    )
    
    CreateToggleButton(
        "❄️ Freeze",
        "Congela inimigo ao acertar com taco",
        ToggleFreeze,
        parent
    )
    
    -- Botão para Expel Banned (Kick)
    local expelContainer = Instance.new("Frame")
    expelContainer.Size = UDim2.new(1, 0, 0, 50)
    expelContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    expelContainer.BorderSizePixel = 0
    expelContainer.Parent = parent
    
    local expelCorner = Instance.new("UICorner")
    expelCorner.CornerRadius = UDim.new(0, 10)
    expelCorner.Parent = expelContainer
    
    local expelBtn = Instance.new("TextButton")
    expelBtn.Size = UDim2.new(1, -20, 1, -10)
    expelBtn.Position = UDim2.new(0, 10, 0, 5)
    expelBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    expelBtn.BorderSizePixel = 0
    expelBtn.Text = "❌ EXPEL BANNED (Kick Dono da Base)"
    expelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    expelBtn.Font = Enum.Font.GothamBold
    expelBtn.TextSize = 13
    expelBtn.Parent = expelContainer
    
    local expelBtnCorner = Instance.new("UICorner")
    expelBtnCorner.CornerRadius = UDim.new(0, 8)
    expelBtnCorner.Parent = expelBtn
    
    expelBtn.MouseButton1Click:Connect(function()
        -- Lógica para encontrar o dono da base inimiga mais próxima
        local targetPlayer = nil
        local minDistance = math.huge
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not rootPart then return end
        
        for _, base in pairs(Workspace:GetDescendants()) do
            if base:IsA("Model") and base.Name:lower():find("base") and base.Name:lower() ~= "yourbase" then
                -- Tentar extrair o nome do dono da base
                local baseOwnerName = base.Name:match("Base_(.+)")
                
                if baseOwnerName then
                    local owner = Players:FindFirstChild(baseOwnerName)
                    if owner and owner.Character then
                        local distance = (base:GetPivot().Position - rootPart.Position).Magnitude
                        if distance < minDistance then
                            minDistance = distance
                            targetPlayer = owner
                        end
                    end
                end
            end
        end
        
        if targetPlayer then
            KickTargetPlayer(targetPlayer)
            expelBtn.Text = "✅ KICK TENTADO: " .. targetPlayer.Name
            task.delay(3, function()
                expelBtn.Text = "❌ EXPEL BANNED (Kick Dono da Base)"
            end)
        else
            expelBtn.Text = "⚠️ NENHUM ALVO ENCONTRADO"
            task.delay(3, function()
                expelBtn.Text = "❌ EXPEL BANNED (Kick Dono da Base)"
            end)
        end
    end)
end

function CreateFPSTab()
    local parent = menuFrame:FindFirstChild("ScrollingFrame")
    
    -- FPS Boost Ultimate (primeiro)
    CreateToggleButton(
        "🚀 FPS BOOST ULTIMATE",
        "Ativa TODAS as otimizações",
        ToggleFPSBoostUltimate,
        parent
    )
    
    -- Separator
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    separator.BorderSizePixel = 0
    separator.Parent = parent
    
    -- Individual optimizations
    for _, funcData in ipairs(optimizationFunctions) do
        CreateToggleButton(
            "⚡ " .. funcData.name,
            "Otimização individual",
            function(state)
                scriptState[funcData.key] = state
                funcData.func(state)
            end,
            parent
        )
    end
end

--[[
    ═══════════════════════════════════════════════════════════
                        INITIALIZATION
    ═══════════════════════════════════════════════════════════
]]

CreateBubbleGUI()

print("╔═══════════════════════════════════════════════════════════╗")
print("║           VGZINSK V2 - MOBILE EDITION                     ║")
print("║           Successfully Loaded!                            ║")
print("║           Click the bubble to open menu                   ║")
print("╚═══════════════════════════════════════════════════════════╝")
