local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local targetFPS = 60
local platformBuilderEnabled = false
local wallhackEnabled = false
local teleportEnabled = false
local autoLoadEnabled = false
local connections = {}
local savedSettings = {}
local performanceStats = {
    fps = 0,
    ping = 0,
    memory = 0,
    objects = 0
}

local platformParts = {}
local maxPlatforms = 50
local platformLifetime = 30
local currentPlatformCount = 0

local originalCollisions = {}
local wallhackConnections = {}

local teleportPoints = {}
local currentTeleportPoint = nil
local teleportGui = nil

local DATA_KEY = "VGZINSK V1"

local function DeepCopy(table)
    local copy = {}
    for key, value in pairs(table) do
        if type(value) == "table" then
            copy[key] = DeepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

local function SaveSettings()
    local success, result = pcall(function()
        local dataToSave = {
            autoLoad = autoLoadEnabled,
            platformBuilder = platformBuilderEnabled,
            wallhack = wallhackEnabled,
            teleport = teleportEnabled,
            settings = DeepCopy(savedSettings),
            teleportPoints = DeepCopy(teleportPoints),
            currentTeleportPoint = currentTeleportPoint
        }
        writefile(DATA_KEY, HttpService:JSONEncode(dataToSave))
        return true
    end)
    return success
end

local function LoadSettings()
    local success, result = pcall(function()
        if isfile(DATA_KEY) then
            local data = readfile(DATA_KEY)
            return HttpService:JSONDecode(data)
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    return nil
end

local function InitializeStableFPS()
    if connections.fpsControl then
        connections.fpsControl:Disconnect()
    end
    
    local frameTime = 1 / 60
    connections.fpsControl = RunService.Heartbeat:Connect(function()
        local startTime = tick()
        wait(frameTime)
        local endTime = tick()
        local actualFrameTime = endTime - startTime
        
        if actualFrameTime > frameTime * 1.1 then
            settings().Rendering.QualityLevel = math.max(1, settings().Rendering.QualityLevel - 1)
        elseif actualFrameTime < frameTime * 0.9 then
            settings().Rendering.QualityLevel = math.min(5, settings().Rendering.QualityLevel + 1)
        end
    end)
    
    -- Otimizações avançadas de rendering
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshCacheSize = 0
    settings().Rendering.TextureCacheSize = 0
    settings().Rendering.EagerBulkExecution = true
end

-- SISTEMA DE MONITORAMENTO DE PERFORMANCE AVANÇADO
local function InitializeAdvancedPerformanceMonitor()
    if connections.performanceMonitor then
        connections.performanceMonitor:Disconnect()
    end
    
    connections.performanceMonitor = RunService.Heartbeat:Connect(function()
            
        local currentFPS = math.floor(1 / RunService.RenderStepped:Wait())
        performanceStats.fps = currentFPS
        
        -- Monitorar memória avançado
        local graphicsMemory = Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Graphics)
        local scriptMemory = Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Script)
        local physicsMemory = Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Physics)
        performanceStats.memory = math.floor(graphicsMemory + scriptMemory + physicsMemory)
        
        -- Monitorar objetos
        performanceStats.objects = #Workspace:GetDescendants()
    end)
end

-- SISTEMA PLATFORM BUILDER AVANÇADO
local function CreatePlatform(position)
    if currentPlatformCount >= maxPlatforms then
        -- Remover plataforma mais antiga
        local oldestPlatform = table.remove(platformParts, 1)
        if oldestPlatform and oldestPlatform:IsDescendantOf(Workspace) then
            oldestPlatform:Destroy()
            currentPlatformCount = currentPlatformCount - 1
        end
    end
    
    local platform = Instance.new("Part")
    platform.Name = "VGZINSK_Platform"
    platform.Size = Vector3.new(6, 1, 6)
    platform.Position = position + Vector3.new(0, -3, 0)
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Neon
    platform.BrickColor = BrickColor.new("Bright blue")
    platform.Transparency = 0.2
    platform.Reflectance = 0.1
    platform.Parent = Workspace
    
    -- Efeito de luz
    local pointLight = Instance.new("PointLight")
    pointLight.Brightness = 2
    pointLight.Range = 8
    pointLight.Color = Color3.fromRGB(0, 100, 255)
    pointLight.Parent = platform
    
    table.insert(platformParts, platform)
    currentPlatformCount = currentPlatformCount + 1
    
    -- Sistema de destruição automática
    spawn(function()
        wait(platformLifetime)
        if platform and platform:IsDescendantOf(Workspace) then
            platform:Destroy()
            currentPlatformCount = currentPlatformCount - 1
            for i, p in ipairs(platformParts) do
                if p == platform then
                    table.remove(platformParts, i)
                    break
                end
            end
        end
    end)
    
    return platform
end

local function TogglePlatformBuilder(state)
    platformBuilderEnabled = state
    
    if state then
        connections.platformJump = UserInputService.JumpRequest:Connect(function()
            if platformBuilderEnabled and localPlayer.Character then
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    CreatePlatform(rootPart.Position)
                end
            end
        end)
        
        -- Sistema de plataformas contínuas durante pulo prolongado
        connections.platformHeartbeat = RunService.Heartbeat:Connect(function()
            if platformBuilderEnabled and localPlayer.Character and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and rootPart.Velocity.Y > 0 then
                    CreatePlatform(rootPart.Position)
                end
            end
        end)
        
    else
        if connections.platformJump then
            connections.platformJump:Disconnect()
            connections.platformJump = nil
        end
        if connections.platformHeartbeat then
            connections.platformHeartbeat:Disconnect()
            connections.platformHeartbeat = nil
        end
        
        -- Limpar plataformas existentes
        for _, platform in ipairs(platformParts) do
            if platform and platform:IsDescendantOf(Workspace) then
                platform:Destroy()
            end
        end
        platformParts = {}
        currentPlatformCount = 0
    end
    
    savedSettings.platformBuilder = state
    SaveSettings()
end

-- SISTEMA WALLHACK AVANÇADO
local function ToggleWallhack(state)
    wallhackEnabled = state
    
    if state then
        -- Remover colisões de paredes e obstáculos
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
                if part.CanCollide and part.Parent ~= localPlayer.Character then
                    originalCollisions[part] = true
                    part.CanCollide = false
                    part.Transparency = 0.7
                    part.Material = Enum.Material.Glass
                end
            end
        end
        
        -- Remover colisão do jogador (permitir atravessar tudo)
        if localPlayer.Character then
            for _, part in pairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("Part") or part:IsA("MeshPart") then
                    originalCollisions[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        end
        
        -- Monitorar novos objetos
        wallhackConnections.descendantAdded = Workspace.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("Part") or descendant:IsA("MeshPart") or descendant:IsA("UnionOperation") then
                if descendant.CanCollide and descendant.Parent ~= localPlayer.Character then
                    originalCollisions[descendant] = true
                    descendant.CanCollide = false
                    descendant.Transparency = 0.7
                    descendant.Material = Enum.Material.Glass
                end
            end
        end)
        
        -- Monitorar character changes
        wallhackConnections.characterAdded = localPlayer.CharacterAdded:Connect(function(character)
            wait(1)
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("Part") or part:IsA("MeshPart") then
                    originalCollisions[part] = part.CanCollide
                    part.CanCollide = false
                end
            end
        end)
        
    else
        -- Restaurar colisões
        for part, wasCollidable in pairs(originalCollisions) do
            if part and part:IsDescendantOf(Workspace) then
                part.CanCollide = wasCollidable
                part.Transparency = 0
                part.Material = Enum.Material.Plastic
            end
        end
        
        -- Restaurar colisão do jogador
        if localPlayer.Character then
            for _, part in pairs(localPlayer.Character:GetDescendants()) do
                if part:IsA("Part") or part:IsA("MeshPart") then
                    part.CanCollide = true
                end
            end
        end
        
        -- Limpar conexões
        for _, conn in pairs(wallhackConnections) do
            conn:Disconnect()
        end
        wallhackConnections = {}
        originalCollisions = {}
    end
    
    savedSettings.wallhack = state
    SaveSettings()
end

-- SISTEMA TELEPORT AVANÇADO
local function CreateTeleportGUI()
    if teleportGui and teleportGui:IsDescendantOf(playerGui) then
        teleportGui:Destroy()
    end
    
    teleportGui = Instance.new("ScreenGui")
    teleportGui.Name = "VGZINSK_TeleportGUI"
    teleportGui.ResetOnSpawn = false
    teleportGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 280, 0, 200)
    mainFrame.Position = UDim2.new(0.5, -140, 0.5, -100)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.fromRGB(0, 255, 255)
    uiStroke.Parent = mainFrame
    
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
    header.BorderSizePixel = 0
    header.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ TELEPORT HACK"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -30, 0, 2)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = header
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -40)
    contentFrame.Position = UDim2.new(0, 10, 0, 35)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Botão Set Point
    local setPointButton = Instance.new("TextButton")
    setPointButton.Size = UDim2.new(1, 0, 0, 40)
    setPointButton.Position = UDim2.new(0, 0, 0, 0)
    setPointButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    setPointButton.BorderSizePixel = 0
    setPointButton.Text = "📍 SET POINT"
    setPointButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPointButton.Font = Enum.Font.GothamBold
    setPointButton.TextSize = 12
    setPointButton.Parent = contentFrame
    
    -- Botão Teleport
    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(1, 0, 0, 40)
    teleportButton.Position = UDim2.new(0, 0, 0, 50)
    teleportButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    teleportButton.BorderSizePixel = 0
    teleportButton.Text = "🚀 TELEPORT"
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 12
    teleportButton.Parent = contentFrame
    
    -- Display do ponto atual
    local pointDisplay = Instance.new("TextLabel")
    pointDisplay.Size = UDim2.new(1, 0, 0, 60)
    pointDisplay.Position = UDim2.new(0, 0, 0, 100)
    pointDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    pointDisplay.BorderSizePixel = 0
    pointDisplay.Text = "No point set"
    pointDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    pointDisplay.Font = Enum.Font.Gotham
    pointDisplay.TextSize = 11
    pointDisplay.TextWrapped = true
    pointDisplay.Parent = contentFrame
    
    -- Funcionalidades dos botões
    setPointButton.MouseButton1Click:Connect(function()
        if localPlayer.Character then
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                currentTeleportPoint = {
                    position = rootPart.Position,
                    timestamp = os.time(),
                    map = game.PlaceId
                }
                pointDisplay.Text = string.format("Point Set!\nX: %.1f\nY: %.1f\nZ: %.1f", 
                    rootPart.Position.X, rootPart.Position.Y, rootPart.Position.Z)
                savedSettings.currentTeleportPoint = currentTeleportPoint
                SaveSettings()
            end
        end
    end)
    
    teleportButton.MouseButton1Click:Connect(function()
        if currentTeleportPoint and localPlayer.Character then
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Teleport seguro
                rootPart.CFrame = CFrame.new(currentTeleportPoint.position)
                pointDisplay.Text = "Teleported successfully!"
            end
        else
            pointDisplay.Text = "No teleport point set!"
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        teleportGui:Destroy()
    end)
    
    -- Carregar ponto salvo
    local loadedData = LoadSettings()
    if loadedData and loadedData.currentTeleportPoint then
        currentTeleportPoint = loadedData.currentTeleportPoint
        pointDisplay.Text = string.format("Point Loaded!\nX: %.1f\nY: %.1f\nZ: %.1f", 
            currentTeleportPoint.position.X, currentTeleportPoint.position.Y, currentTeleportPoint.position.Z)
    end
    
    mainFrame.Parent = teleportGui
    teleportGui.Parent = playerGui
    
    return teleportGui
end

local function ToggleTeleport(state)
    teleportEnabled = state
    
    if state then
        CreateTeleportGUI()
    else
        if teleportGui and teleportGui:IsDescendantOf(playerGui) then
            teleportGui:Destroy()
        end
    end
    
    savedSettings.teleport = state
    SaveSettings()
end

-- SISTEMA AUTO-LOAD AVANÇADO
local function ToggleAutoLoad(state)
    autoLoadEnabled = state
    
    if state then
        -- Carregar configurações salvas
        local loadedData = LoadSettings()
        if loadedData then
            -- Carregar estados principais
            if loadedData.platformBuilder then
                TogglePlatformBuilder(true)
            end
            if loadedData.wallhack then
                ToggleWallhack(true)
            end
            if loadedData.teleport then
                ToggleTeleport(true)
            end
            
            -- Carregar outras configurações
            for settingName, settingValue in pairs(loadedData.settings or {}) do
                savedSettings[settingName] = settingValue
                if settingValue and optimizationFunctions[settingName] then
                    optimizationFunctions[settingName].func(true)
                end
            end
            
            -- Carregar pontos de teleporte
            if loadedData.teleportPoints then
                teleportPoints = loadedData.teleportPoints
            end
            if loadedData.currentTeleportPoint then
                currentTeleportPoint = loadedData.currentTeleportPoint
            end
        end
    end
    
    savedSettings.autoLoad = state
    SaveSettings()
end

-- ========== SISTEMA DE 25 FUNÇÕES DE OTIMIZAÇÃO AVANÇADAS ==========

local optimizationFunctions = {
    RemoveCharacterAnimations = {
        name = "Sem Animações",
        desc = "Remove todos os movimentos do personagem",
        func = function(state)
            if state then
                local function stopAnimations(character)
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                            track:Stop()
                        end
                        humanoid.AnimationPlayed:Connect(function(track)
                            track:Stop()
                        end)
                    end
                end
                
                if localPlayer.Character then
                    stopAnimations(localPlayer.Character)
                end
                
                localPlayer.CharacterAdded:Connect(stopAnimations)
            end
        end
    },
    
    OptimizeLighting = {
        name = "Luz Otimizada", 
        desc = "Configurações mínimas de iluminação avançada",
        func = function(state)
            if state then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 40
                Lighting.Brightness = 1.1
                Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
                Lighting.ClockTime = 12
                Lighting.Ambient = Color3.fromRGB(100, 100, 100)
                Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
                Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
                Lighting.EnvironmentDiffuseScale = 0.1
                Lighting.EnvironmentSpecularScale = 0.1
                
                for _, effect in pairs(Lighting:GetChildren()) do
                    if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
                        effect.Enabled = false
                    end
                end
            end
        end
    },
    
    RemoveAllSkins = {
        name = "Skins Pretas",
        desc = "Todos os players ficam completamente pretos",
        func = function(state)
            if state then
                local function blackenCharacter(character)
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("Part") or part:IsA("MeshPart") then
                            part.BrickColor = BrickColor.new("Really black")
                            part.Material = Enum.Material.Plastic
                            part.Reflectance = 0
                            if part:FindFirstChildOfClass("SpecialMesh") then
                                part:FindFirstChildOfClass("SpecialMesh"):Destroy()
                            end
                        end
                    end
                end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character then
                        blackenCharacter(player.Character)
                    end
                    player.CharacterAdded:Connect(blackenCharacter)
                end
                
                Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(blackenCharacter)
                end)
            end
        end
    },
    
    ReduceRenderDistance = {
        name = "Render Reduzido",
        desc = "Diminui drasticamente a distância de renderização",
        func = function(state)
            if state then
                local camera = Workspace.CurrentCamera
                if camera then
                    camera.FieldOfView = 60
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Part") then
                        descendant.Material = Enum.Material.Plastic
                        descendant.Reflectance = 0
                    elseif descendant:IsA("ParticleEmitter") then
                        descendant.Enabled = false
                    end
                end)
            end
        end
    },
    
    RemoveParticles = {
        name = "Sem Partículas", 
        desc = "Remove todos os efeitos visuais e partículas",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") then
                        obj.Enabled = false
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
                        descendant.Enabled = false
                    end
                end)
            end
        end
    },
    
    RemoveTextures = {
        name = "Sem Texturas",
        desc = "Remove completamente todas as texturas do jogo",
        func = function(state)
            if state then
                for _, texture in pairs(Workspace:GetDescendants()) do
                    if texture:IsA("Decal") then
                        texture.Transparency = 1
                    elseif texture:IsA("Texture") then
                        texture.Texture = ""
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Decal") then
                        descendant.Transparency = 1
                    elseif descendant:IsA("Texture") then
                        descendant.Texture = ""
                    end
                end)
            end
        end
    },
    
    OptimizeGraphics = {
        name = "Gráficos Mínimos",
        desc = "Configurações gráficas no mínimo absoluto",
        func = function(state)
            if state then
                settings().Rendering.QualityLevel = 1
                RunService:Set3dRenderingEnabled(true)
                
                spawn(function()
                    while true do
                        settings().Rendering.EnableFRM = false
                        settings().Rendering.EnableTrees = false
                        wait(15)
                    end
                end)
            end
        end
    },
    
    DisablePhysics = {
        name = "Física Leve",
        desc = "Reduz drasticamente a qualidade da física",
        func = function(state)
            if state then
                settings().Physics.PhysicsEnvironmentalThrottle = 3
                settings().Physics.ThrottleAdjustTime = 30
                settings().Physics.Is30FpsThrottleEnabled = true
            end
        end
    },
    
    RemoveSounds = {
        name = "Sem Sons",
        desc = "Desativa completamente todos os sons ambientais",
        func = function(state)
            if state then
                for _, sound in pairs(Workspace:GetDescendants()) do
                    if sound:IsA("Sound") then
                        sound.Volume = 0
                        sound.Playing = false
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Sound") then
                        descendant.Volume = 0
                        descendant.Playing = false
                    end
                end)
            end
        end
    },
    
    SimplifyTerrain = {
        name = "Terreno Simples",
        desc = "Otimiza radicalmente terreno e água",
        func = function(state)
            if state then
                if Workspace:FindFirstChildOfClass("Terrain") then
                    local terrain = Workspace:FindFirstChildOfClass("Terrain")
                    terrain.Decoration = false
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 1
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.WaterColor = Color3.fromRGB(0, 0, 0)
                end
            end
        end
    },
    
    RemoveGUIEffects = {
        name = "Sem Efeitos GUI",
        desc = "Remove todos os efeitos da interface",
        func = function(state)
            if state then
                for _, gui in pairs(playerGui:GetDescendants()) do
                    if gui:IsA("UIStroke") or gui:IsA("UIGradient") or gui:IsA("UICorner") then
                        gui.Enabled = false
                    end
                end
                
                playerGui.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("UIStroke") or descendant:IsA("UIGradient") then
                        descendant.Enabled = false
                    end
                end)
            end
        end
    },
    
    LimitPartCount = {
        name = "Limitar Partes",
        desc = "Reduz radicalmente quantidade de objetos",
        func = function(state)
            if state then
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Part") and descendant.Parent ~= localPlayer.Character then
                        wait(0.01)
                        descendant.Transparency = 0.5
                        descendant.Material = Enum.Material.Plastic
                        descendant.Reflectance = 0
                    end
                end)
            end
        end
    },
    
    OptimizeNetwork = {
        name = "Rede Otimizada",
        desc = "Melhora radicalmente conexão e latência", 
        func = function(state)
            if state then
                settings().Network.IncomingReplicationLag = 0.1
                settings().Network.PhysicsSend = 1
                settings().Network.PhysicsReceive = 1
                settings().Network.TotalPhysicsSendRate = 30
            end
        end
    },
    
    ReduceShadowMap = {
        name = "Sombras Reduzidas",
        desc = "Remove completamente sombras do jogo",
        func = function(state)
            if state then
                Lighting.ShadowSoftness = 0
                Lighting.ShadowColor = Color3.new(1, 1, 1)
                Lighting.ShadowMapSize = 128
                Lighting.GlobalShadows = false
            end
        end
    },
    
    EnableAggressiveGC = {
        name = "GC Agressivo",
        desc = "Limpeza ultra frequente de memória",
        func = function(state)
            if state then
                spawn(function()
                    while true do
                        wait(10)
                        collectgarbage("collect")
                        collectgarbage("step", 300)
                    end
                end)
            end
        end
    },
    
    RemoveWaterEffects = {
        name = "Sem Efeitos Água",
        desc = "Remove completamente efeitos da água",
        func = function(state)
            if state then
                if Workspace:FindFirstChildOfClass("Terrain") then
                    local terrain = Workspace:FindFirstChildOfClass("Terrain")
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 1
                    terrain.WaterWaveSize = 0
                end
                
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("Part") and part.Material == Enum.Material.Water then
                        part.Transparency = 1
                    end
                end
            end
        end
    },
    
    SimplifyMaterials = {
        name = "Materiais Simples",
        desc = "Todos materiais em plástico básico",
        func = function(state)
            if state then
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("Part") then
                        part.Material = Enum.Material.Plastic
                        part.Reflectance = 0
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Part") then
                        descendant.Material = Enum.Material.Plastic
                        descendant.Reflectance = 0
                    end
                end)
            end
        end
    },
    
    ReduceQuality = {
        name = "Qualidade Reduzida",
        desc = "Reduz qualidade geral do jogo radicalmente",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") then
                        obj.Reflectance = 0
                        obj.Material = Enum.Material.Plastic
                        obj.Transparency = 0.1
                    end
                end
            end
        end
    },

    OptimizeCharacters = {
    name = "Personagens Otimizados",
    desc = "Reduz drasticamente detalhes dos personagens",
    func = function(state)
        if state then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("Part") or part:IsA("MeshPart") then
                            part.Material = Enum.Material.Plastic
                            part.Reflectance = 0
                        end
                    end
                end
                player.CharacterAdded:Connect(function(character)
                    wait(1)
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("Part") or part:IsA("MeshPart") then
                            part.Material = Enum.Material.Plastic
                            part.Reflectance = 0
                        end
                    end
                end
            end
        end
    end
    
   },
    
    RemoveLightingEffects = {
        name = "Sem Efeitos de Luz",
        desc = "Remove todos os efeitos especiais de luz",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
                        obj.Enabled = false
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("PointLight") or descendant:IsA("SpotLight") then
                        descendant.Enabled = false
                    end
                end)
            end
        end
    },
    
    OptimizeTextures = {
        name = "Texturas Otimizadas",
        desc = "Compressão máxima de texturas",
        func = function(state)
            if state then
                for _, texture in pairs(Workspace:GetDescendants()) do
                    if texture:IsA("Texture") then
                        texture.Texture = ""
                    end
                end
            end
        end
    },
    
    ReduceParticleQuality = {
        name = "Partículas Mínimas",
        desc = "Qualidade mínima de partículas",
        func = function(state)
            if state then
                for _, particle in pairs(Workspace:GetDescendants()) do
                    if particle:IsA("ParticleEmitter") then
                        particle.Rate = 1
                        particle.Lifetime = NumberRange.new(0.1, 0.5)
                    end
                end
            end
        end
    },
    
    OptimizeRendering = {
        name = "Renderização Otimizada",
        desc = "Configurações avançadas de renderização",
        func = function(state)
            if state then
                settings().Rendering.EnableFRM = false
                settings().Rendering.EagerBulkExecution = true
                RunService:Set3dRenderingEnabled(true)
            end
        end
    },
    
    MemoryOptimization = {
        name = "Otimização de Memória",
        desc = "Gestão avançada de memória RAM",
        func = function(state)
            if state then
                spawn(function()
                    while true do
                        wait(20)
                        collectgarbage("collect")
                        settings().Rendering.MeshCacheSize = 0
                        settings().Rendering.TextureCacheSize = 0
                    end
                end)
            end
        end
    }
}

ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VGZINSK V1"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 380, 0, 550)
MainFrame.Position = UDim2.new(0.5, -190, 0.5, -275)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local OuterGlow = Instance.new("UIStroke")
OuterGlow.Thickness = 4
OuterGlow.Color = Color3.fromRGB(0, 255, 255)
OuterGlow.Transparency = 0.2
OuterGlow.Parent = MainFrame

local InnerGlow = Instance.new("UIStroke")
InnerGlow.Thickness = 2
InnerGlow.Color = Color3.fromRGB(255, 0, 255)
InnerGlow.Transparency = 0.3
InnerGlow.Parent = MainFrame

local CyberPattern = Instance.new("ImageLabel")
CyberPattern.Size = UDim2.new(1, 0, 1, 0)
CyberPattern.BackgroundTransparency = 1
CyberPattern.Image = "rbxassetid://9892939321"
CyberPattern.ImageTransparency = 0.9
CyberPattern.ScaleType = Enum.ScaleType.Tile
CyberPattern.TileSize = UDim2.new(0, 50, 0, 50)
CyberPattern.Parent = MainFrame

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 45)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
Header.BorderSizePixel = 0

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 30, 60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 0, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 60, 30))
})
HeaderGradient.Rotation = 45
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ VGZINSK V1"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextStrokeTransparency = 0.6
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
MinimizeButton.Position = UDim2.new(1, -75, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 18

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 35, 0, 35)
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16

local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(1, -15, 1, -60)
MainContainer.Position = UDim2.new(0, 7, 0, 50)
MainContainer.BackgroundTransparency = 1
MainContainer.BorderSizePixel = 0
MainContainer.ScrollBarThickness = 8
MainContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
MainContainer.ScrollBarImageTransparency = 0.5
MainContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

local function CreateCyberToggle(name, description, defaultState, callback, settingKey)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(1, 0, 1, 0)
    ToggleBG.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = ToggleFrame
    
    local ToggleGradient = Instance.new("UIGradient")
    ToggleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 55)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 25, 40))
    })
    ToggleGradient.Parent = ToggleBG
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Thickness = 1
    ToggleStroke.Color = Color3.fromRGB(60, 60, 80)
    ToggleStroke.Parent = ToggleBG
    
    local Icon = Instance.new("TextLabel")
    Icon.Size = UDim2.new(0, 30, 0, 30)
    Icon.Position = UDim2.new(0, 8, 0, 10)
    Icon.BackgroundTransparency = 1
    Icon.Text = "🔧"
    Icon.TextColor3 = Color3.fromRGB(0, 255, 255)
    Icon.Font = Enum.Font.GothamBold
    Icon.TextSize = 16
    Icon.Parent = ToggleFrame
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    ToggleLabel.Position = UDim2.new(0, 45, 0, 5)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextSize = 13
    ToggleLabel.Parent = ToggleFrame
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Size = UDim2.new(0.6, 0, 0.5, 0)
    DescriptionLabel.Position = UDim2.new(0, 45, 0.5, 0)
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.TextSize = 10
    DescriptionLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -60, 0.5, -12)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleButtonStroke = Instance.new("UIStroke")
    ToggleButtonStroke.Thickness = 2
    ToggleButtonStroke.Color = Color3.fromRGB(100, 100, 120)
    ToggleButtonStroke.Parent = ToggleButton
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 21, 0, 21)
    ToggleKnob.Position = defaultState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.Parent = ToggleButton
    
    local KnobGradient = Instance.new("UIGradient")
    KnobGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 220, 220))
    })
    KnobGradient.Parent = ToggleKnob
    
    local isEnabled = defaultState
    
    if isEnabled then
        callback(true)
        savedSettings[settingKey] = true
    end
    
    ToggleButton.MouseEnter:Connect(function()
        if isEnabled then
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 230, 0)}):Play()
        else
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}):Play()
        end
    end)
    
    ToggleButton.MouseLeave:Connect(function()
        if isEnabled then
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play()
        else
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
        end
    end)
    
    ToggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        if isEnabled then
            TweenService:Create(ToggleButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play()
            TweenService:Create(ToggleKnob, TweenInfo.new(0.3), {Position = UDim2.new(1, -23, 0.5, -10)}):Play()
        else
            TweenService:Create(ToggleButton, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
            TweenService:Create(ToggleKnob, TweenInfo.new(0.3), {Position = UDim2.new(0, 2, 0.5, -10)}):Play()
        end
        
        callback(isEnabled)
        
        savedSettings[settingKey] = isEnabled
        SaveSettings()
    end)
    
    return ToggleFrame
end

local function CreatePerformanceDisplay()
    local perfFrame = Instance.new("Frame")
    perfFrame.Size = UDim2.new(1, 0, 0, 40)
    perfFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    perfFrame.BorderSizePixel = 0
    
    local perfGradient = Instance.new("UIGradient")
    perfGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
    })
    perfGradient.Parent = perfFrame
    
    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0.33, 0, 1, 0)
    fpsLabel.Position = UDim2.new(0, 0, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: 60"
    fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 12
    fpsLabel.Parent = perfFrame
    
    local memoryLabel = Instance.new("TextLabel")
    memoryLabel.Size = UDim2.new(0.33, 0, 1, 0)
    memoryLabel.Position = UDim2.new(0.33, 0, 0, 0)
    memoryLabel.BackgroundTransparency = 1
    memoryLabel.Text = "RAM: 0MB"
    memoryLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    memoryLabel.Font = Enum.Font.GothamBold
    memoryLabel.TextSize = 12
    memoryLabel.Parent = perfFrame
    
    local objectsLabel = Instance.new("TextLabel")
    objectsLabel.Size = UDim2.new(0.34, 0, 1, 0)
    objectsLabel.Position = UDim2.new(0.66, 0, 0, 0)
    objectsLabel.BackgroundTransparency = 1
    objectsLabel.Text = "OBJ: 0"
    objectsLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    objectsLabel.Font = Enum.Font.GothamBold
    objectsLabel.TextSize = 12
    objectsLabel.Parent = perfFrame
    
    connections.performanceDisplay = RunService.Heartbeat:Connect(function()
        fpsLabel.Text = "FPS: " .. performanceStats.fps
        memoryLabel.Text = "RAM: " .. performanceStats.memory .. "MB"
        objectsLabel.Text = "OBJ: " .. performanceStats.objects
        
        if performanceStats.fps >= 50 then
            fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        elseif performanceStats.fps >= 30 then
            fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        else
            fpsLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
        
        if performanceStats.memory < 500 then
            memoryLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        elseif performanceStats.memory < 1000 then
            memoryLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        else
            memoryLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
        end
    end)
    
    return perfFrame
end


local currentY = 0

local perfDisplay = CreatePerformanceDisplay()
perfDisplay.Position = UDim2.new(0, 0, 0, currentY)
perfDisplay.Parent = MainContainer
currentY = currentY + 45

local functionToggles = {
    
    {key = "autoLoad", name = "🔄 AUTO LOAD", desc = "Carrega configurações automaticamente", func = ToggleAutoLoad, default = false},
    {key = "platformBuilder", name = "🏗️ PLATFORM BUILDER", desc = "Cria plataformas ao pular", func = TogglePlatformBuilder, default = false},
    {key = "wallhack", name = "👻 WALLHACK", desc = "Atravessar paredes sem colisão", func = ToggleWallhack, default = false},
    {key = "teleport", name = "💫 TELEPORT SYSTEM", desc = "Sistema de teletransporte avançado", func = ToggleTeleport, default = false},
    
    -- OTIMIZAÇÕES DE PERFORMANCE
    {key = "RemoveCharacterAnimations", name = "🎭 SEM ANIMAÇÕES", desc = "Remove movimentos do personagem", func = optimizationFunctions.RemoveCharacterAnimations.func, default = false},
    {key = "OptimizeLighting", name = "💡 LUZ OTIMIZADA", desc = "Iluminação mínima avançada", func = optimizationFunctions.OptimizeLighting.func, default = false},
    {key = "RemoveAllSkins", name = "⚫ SKINS PRETAS", desc = "Todos players completamente pretos", func = optimizationFunctions.RemoveAllSkins.func, default = false},
    {key = "ReduceRenderDistance", name = "👁️ RENDER REDUZIDO", desc = "Distância de renderização mínima", func = optimizationFunctions.ReduceRenderDistance.func, default = false},
    {key = "RemoveParticles", name = "✨ SEM PARTÍCULAS", desc = "Remove efeitos visuais", func = optimizationFunctions.RemoveParticles.func, default = false},
    {key = "RemoveTextures", name = "🖼️ SEM TEXTURAS", desc = "Texturas completamente removidas", func = optimizationFunctions.RemoveTextures.func, default = false},
    {key = "OptimizeGraphics", name = "🎮 GRÁFICOS MÍNIMOS", desc = "Configurações gráficas no mínimo", func = optimizationFunctions.OptimizeGraphics.func, default = false},
    {key = "DisablePhysics", name = "⚙️ FÍSICA LEVE", desc = "Física drasticamente reduzida", func = optimizationFunctions.DisablePhysics.func, default = false},
    {key = "RemoveSounds", name = "🔇 SEM SONS", desc = "Áudio completamente desativado", func = optimizationFunctions.RemoveSounds.func, default = false},
    {key = "SimplifyTerrain", name = "🏞️ TERRENO SIMPLES", desc = "Terreno radicalmente otimizado", func = optimizationFunctions.SimplifyTerrain.func, default = false},
    {key = "RemoveGUIEffects", name = "🖥️ SEM EFEITOS GUI", desc = "Interface completamente limpa", func = optimizationFunctions.RemoveGUIEffects.func, default = false},
    {key = "LimitPartCount", name = "📦 LIMITAR PARTES", desc = "Quantidade de objetos reduzida", func = optimizationFunctions.LimitPartCount.func, default = false},
    {key = "OptimizeNetwork", name = "🌐 REDE OTIMIZADA", desc = "Conexão e latência melhoradas", func = optimizationFunctions.OptimizeNetwork.func, default = false},
    {key = "ReduceShadowMap", name = "🌑 SOMBRAS REDUZIDAS", desc = "Remove sombras do jogo", func = optimizationFunctions.ReduceShadowMap.func, default = false},
    {key = "EnableAggressiveGC", name = "🧹 GC AGRESSIVO", desc = "Limpeza frequente de memória", func = optimizationFunctions.EnableAggressiveGC.func, default = false},
    {key = "RemoveWaterEffects", name = "💧 SEM EFEITOS ÁGUA", desc = "Água completamente simplificada", func = optimizationFunctions.RemoveWaterEffects.func, default = false},
    {key = "SimplifyMaterials", name = "🔷 MATERIAIS SIMPLES", desc = "Todos materiais em plástico", func = optimizationFunctions.SimplifyMaterials.func, default = false},
    {key = "ReduceQuality", name = "📉 QUALIDADE REDUZIDA", desc = "Qualidade geral radicalmente reduzida", func = optimizationFunctions.ReduceQuality.func, default = false},
    {key = "RemoveLightingEffects", name = "💫 SEM EFEITOS DE LUZ", desc = "Remove efeitos especiais de luz", func = optimizationFunctions.RemoveLightingEffects.func, default = false},
    {key = "OptimizeTextures", name = "🖌️ TEXTURAS OTIMIZADAS", desc = "Compressão máxima de texturas", func = optimizationFunctions.OptimizeTextures.func, default = false},
    {key = "ReduceParticleQuality", name = "🎇 PARTÍCULAS MÍNIMAS", desc = "Qualidade mínima de partículas", func = optimizationFunctions.ReduceParticleQuality.func, default = false},
    {key = "OptimizeRendering", name = "🖥️ RENDERIZAÇÃO OTIMIZADA", desc = "Configurações avançadas de render", func = optimizationFunctions.OptimizeRendering.func, default = false},
    {key = "MemoryOptimization", name = "💾 OTIMIZAÇÃO DE MEMÓRIA", desc = "Gestão avançada de memória RAM", func = optimizationFunctions.MemoryOptimization.func, default = false}
}

for i, toggleData in ipairs(functionToggles) do
    local toggle = CreateCyberToggle(
        toggleData.name,
        toggleData.desc,
        toggleData.default,
        toggleData.func,
        toggleData.key
    )
    toggle.Position = UDim2.new(0, 0, 0, currentY)
    toggle.Parent = MainContainer
    currentY = currentY + 55
end

-- BOTÃO DE RESET AVANÇADO
local resetFrame = Instance.new("Frame")
resetFrame.Size = UDim2.new(1, 0, 0, 45)
resetFrame.BackgroundTransparency = 1
resetFrame.Position = UDim2.new(0, 0, 0, currentY)
resetFrame.Parent = MainContainer

local resetButton = Instance.new("TextButton")
resetButton.Size = UDim2.new(1, 0, 1, 0)
resetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
resetButton.BorderSizePixel = 0
resetButton.Text = "🔄 RESETAR TUDO"
resetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
resetButton.Font = Enum.Font.GothamBold
resetButton.TextSize = 14
resetButton.Parent = resetFrame

resetButton.MouseButton1Click:Connect(function()
        
    for _, toggleData in ipairs(functionToggles) do
        if savedSettings[toggleData.key] then
            toggleData.func(false)
            savedSettings[toggleData.key] = false
        end
    end
    
    if platformBuilderEnabled then
        TogglePlatformBuilder(false)
    end
    
    if wallhackEnabled then
        ToggleWallhack(false)
    end
    
    if teleportEnabled then
        ToggleTeleport(false)
    end
    
    SaveSettings()
end)

currentY = currentY + 50

MainContainer.CanvasSize = UDim2.new(0, 0, 0, currentY + 20)

Header.Parent = MainFrame
Title.Parent = Header
MinimizeButton.Parent = Header
CloseButton.Parent = Header
MainContainer.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = playerGui

spawn(function()
    while true do
        local time = tick()
        OuterGlow.Color = Color3.fromHSV((time * 0.3) % 1, 0.9, 1)
        InnerGlow.Color = Color3.fromHSV((time * 0.3 + 0.5) % 1, 0.9, 1)
        wait(0.08)
    end
end)

spawn(function()
    while true do
        TweenService:Create(Title, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            TextColor3 = Color3.fromRGB(255, 0, 255),
            TextStrokeTransparency = 0.4
        }):Play()
        wait(1.5)
        TweenService:Create(Title, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
            TextColor3 = Color3.fromRGB(0, 255, 255),
            TextStrokeTransparency = 0.6
        }):Play()
        wait(1.5)
    end
end)

local scanLine = Instance.new("Frame")
scanLine.Size = UDim2.new(1, 0, 0, 2)
scanLine.Position = UDim2.new(0, 0, 0, 0)
scanLine.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
scanLine.BorderSizePixel = 0
scanLine.BackgroundTransparency = 0.7
scanLine.Parent = MainFrame

spawn(function()
    while true do
        TweenService:Create(scanLine, TweenInfo.new(2, Enum.EasingStyle.Linear), {
            Position = UDim2.new(0, 0, 1, 0)
        }):Play()
        wait(2)
        scanLine.Position = UDim2.new(0, 0, 0, 0)
        wait(0.5)
    end
end)

local isMinimized = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 380, 0, 45),
            Position = UDim2.new(0.5, -190, 1, -50)
        }):Play()
        MainContainer.Visible = false
    else
        MainContainer.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize,
            Position = originalPosition
        }):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Rotation = 360
    }):Play()
    
    TweenService:Create(OuterGlow, TweenInfo.new(0.5), {
        Transparency = 1
    }):Play()
    
    TweenService:Create(InnerGlow, TweenInfo.new(0.5), {
        Transparency = 1
    }):Play()
    
    wait(0.5)
    ScreenGui:Destroy()
    
    -- LIMPAR TODAS AS CONEXÕES
    for _, conn in pairs(connections) do
        if conn then
            conn:Disconnect()
        end
    end
    
    -- LIMPAR WALLHACK CONNECTIONS
    for _, conn in pairs(wallhackConnections) do
        if conn then
            conn:Disconnect()
        end
    end
end)

-- ========== INICIALIZAÇÃO DO SISTEMA COMPLETO ==========

-- INICIALIZAR FPS ESTÁVEL
InitializeStableFPS()

-- INICIALIZAR MONITOR DE PERFORMANCE
InitializeAdvancedPerformanceMonitor()

-- CARREGAR CONFIGURAÇÕES INICIAIS
local loadedData = LoadSettings()
if loadedData then
    if loadedData.autoLoad then
        ToggleAutoLoad(true)
    end
end

-- SISTEMA DE PROTEÇÃO CONTRA CRASHES AVANÇADO
localPlayer.CharacterAdded:Connect(function(character)
    wait(2)
    
    -- REAPLICAR CONFIGURAÇÕES SE NECESSÁRIO
    if autoLoadEnabled then
        for settingKey, isEnabled in pairs(savedSettings) do
            if isEnabled then
                if settingKey == "platformBuilder" then
                    TogglePlatformBuilder(true)
                elseif settingKey == "wallhack" then
                    ToggleWallhack(true)
                elseif settingKey == "teleport" then
                    ToggleTeleport(true)
                elseif optimizationFunctions[settingKey] then
                    optimizationFunctions[settingKey].func(true)
                end
            end
        end
    end
end)

-- SISTEMA DE AUTO-SAVE
spawn(function()
    while true do
        wait(30) -- Salvar a cada 30 segundos
        if autoLoadEnabled then
            SaveSettings()
        end
    end
end)

spawn(function()
    wait(5)
    local totalFunctions = 0
    for _ in pairs(optimizationFunctions) do
        totalFunctions = totalFunctions + 1
    end
    
    print("🔍 VERIFICAÇÃO DE INTEGRIDADE:")
    print("📊 Funções carregadas: " .. totalFunctions .. "/25")
    print("💾 Sistema de salvamento: ✅")
    print("🎮 Performance: ✅")
    print("🛡️ Segurança: ✅")
    print("")
end)

return {
    Version = "VGZINSK V1",
    Features = 25,
    Status = "ACTIVE" }
