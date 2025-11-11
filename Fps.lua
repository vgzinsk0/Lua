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

local platformParts = {}
local maxPlatforms = 50
local platformLifetime = 30
local currentPlatformCount = 0

local originalCollisions = {}
local wallhackConnections = {}

local teleportPoints = {}
local currentTeleportPoint = nil
local previousPosition = nil
local teleportGui = nil
local mainScreenGui = nil

local DATA_KEY = "VGZINSK_V1"

-- Sistema de arquivos alternativo para Delta Executor
local function WriteFile(filename, content)
    if writefile then
        return writefile(filename, content)
    else
        savedSettings[filename] = content
        return true
    end
end

local function ReadFile(filename)
    if readfile then
        return readfile(filename)
    else
        return savedSettings[filename]
    end
end

local function FileExists(filename)
    if isfile then
        return isfile(filename)
    else
        return savedSettings[filename] ~= nil
    end
end

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
        WriteFile(DATA_KEY, HttpService:JSONEncode(dataToSave))
        return true
    end)
    return success
end

local function LoadSettings()
    local success, result = pcall(function()
        if FileExists(DATA_KEY) then
            local data = ReadFile(DATA_KEY)
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

-- SISTEMA PLATFORM BUILDER AVANÇADO
local function CreatePlatform(position)
    if currentPlatformCount >= maxPlatforms then
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
    coroutine.wrap(function()
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
    end)()
    
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

-- SISTEMA WALLHACK AVANÇADO CORRIGIDO
local function IsGroundPart(part)
    -- Verifica se a parte é provavelmente o chão
    if part.Position.Y < 5 then return true end
    if part.Name:lower():find("floor") or part.Name:lower():find("ground") or part.Name:lower():find("base") or part.Name:lower():find("chao") then
        return true
    end
    -- Verifica se a parte está em uma posição muito baixa (provavelmente chão)
    if part.Position.Y < 10 and part.Size.Y > 2 and part.Size.X > 10 and part.Size.Z > 10 then
        return true
    end
    return false
end

local function ToggleWallhack(state)
    wallhackEnabled = state
    
    if state then
        -- Remover colisões de paredes e obstáculos (mas não do chão)
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
                if part.CanCollide and part.Parent ~= localPlayer.Character and not IsGroundPart(part) then
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
                if descendant.CanCollide and descendant.Parent ~= localPlayer.Character and not IsGroundPart(descendant) then
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
            if conn then
                conn:Disconnect()
            end
        end
        wallhackConnections = {}
        originalCollisions = {}
    end
    
    savedSettings.wallhack = state
    SaveSettings()
end

-- SISTEMA TELEPORT AVANÇADO CORRIGIDO
local function CreateTeleportGUI()
    if teleportGui and teleportGui:IsDescendantOf(playerGui) then
        teleportGui:Destroy()
    end
    
    teleportGui = Instance.new("ScreenGui")
    teleportGui.Name = "VGZINSK_TeleportGUI"
    teleportGui.ResetOnSpawn = false
    teleportGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 300, 0, 200) -- Menu pequeno
    mainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
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
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ TELEPORT"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = header
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -55, 0, 2)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 16
    minimizeButton.Parent = header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -25, 0, 2)
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
    setPointButton.Size = UDim2.new(1, 0, 0, 35)
    setPointButton.Position = UDim2.new(0, 0, 0, 0)
    setPointButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    setPointButton.BorderSizePixel = 0
    setPointButton.Text = "📍 SET POINT"
    setPointButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    setPointButton.Font = Enum.Font.GothamBold
    setPointButton.TextSize = 12
    setPointButton.Parent = contentFrame
    
    -- Botão Teleport para Base
    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(1, 0, 0, 35)
    teleportButton.Position = UDim2.new(0, 0, 0, 45)
    teleportButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    teleportButton.BorderSizePixel = 0
    teleportButton.Text = "🚀 TO BASE"
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 12
    teleportButton.Parent = contentFrame
    
    -- Botão Voltar para Posição Anterior
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(1, 0, 0, 35)
    backButton.Position = UDim2.new(0, 0, 0, 90)
    backButton.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    backButton.BorderSizePixel = 0
    backButton.Text = "↩️ RETURN"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.Font = Enum.Font.GothamBold
    backButton.TextSize = 12
    backButton.Parent = contentFrame
    
    -- Display do ponto atual
    local pointDisplay = Instance.new("TextLabel")
    pointDisplay.Size = UDim2.new(1, 0, 0, 40)
    pointDisplay.Position = UDim2.new(0, 0, 0, 135)
    pointDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    pointDisplay.BorderSizePixel = 0
    pointDisplay.Text = "No point set"
    pointDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
    pointDisplay.Font = Enum.Font.Gotham
    pointDisplay.TextSize = 10
    pointDisplay.TextWrapped = true
    pointDisplay.Parent = contentFrame
    
    -- Funcionalidades dos botões CORRIGIDAS
    setPointButton.MouseButton1Click:Connect(function()
        if localPlayer.Character then
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                currentTeleportPoint = rootPart.Position
                pointDisplay.Text = string.format("Point Set!\nX: %.1f Y: %.1f Z: %.1f", 
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
                -- Salvar posição atual ANTES de teleportar
                previousPosition = rootPart.Position
                -- Teleport para o ponto salvo
                rootPart.CFrame = CFrame.new(currentTeleportPoint)
                pointDisplay.Text = "Teleported to base!\nPrevious position saved"
            end
        else
            pointDisplay.Text = "No teleport point set!"
        end
    end)
    
    backButton.MouseButton1Click:Connect(function()
        if previousPosition and localPlayer.Character then
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Teleport de volta para posição anterior
                rootPart.CFrame = CFrame.new(previousPosition)
                pointDisplay.Text = "Returned to previous position!"
            end
        else
            pointDisplay.Text = "No previous position saved!"
        end
    end)
    
    minimizeButton.MouseButton1Click:Connect(function()
        teleportGui.Enabled = false
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        teleportGui:Destroy()
    end)
    
    -- Carregar ponto salvo
    local loadedData = LoadSettings()
    if loadedData and loadedData.currentTeleportPoint then
        currentTeleportPoint = loadedData.currentTeleportPoint
        pointDisplay.Text = string.format("Point Loaded!\nX: %.1f Y: %.1f Z: %.1f", 
            currentTeleportPoint.X, currentTeleportPoint.Y, currentTeleportPoint.Z)
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

-- ========== SISTEMA DE 24 FUNÇÕES DE OTIMIZAÇÃO ==========
local optimizationFunctions = {
    RemoveCharacterAnimations = {
        name = "Sem Animações",
        desc = "Remove movimentos do personagem",
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
        desc = "Configurações mínimas de iluminação",
        func = function(state)
            if state then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 40
                Lighting.Brightness = 1.1
                Lighting.OutdoorAmbient = Color3.fromRGB(100, 100, 100)
                Lighting.ClockTime = 12
            end
        end
    },
    
    RemoveAllSkins = {
        name = "Skins Pretas",
        desc = "Todos players ficam pretos",
        func = function(state)
            if state then
                local function blackenCharacter(character)
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("Part") or part:IsA("MeshPart") then
                            part.BrickColor = BrickColor.new("Really black")
                            part.Material = Enum.Material.Plastic
                        end
                    end
                end
                
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character then
                        blackenCharacter(player.Character)
                    end
                    player.CharacterAdded:Connect(blackenCharacter)
                end
            end
        end
    },
    
    ReduceRenderDistance = {
        name = "Render Reduzido",
        desc = "Diminui distância de renderização",
        func = function(state)
            if state then
                local camera = Workspace.CurrentCamera
                if camera then
                    camera.FieldOfView = 60
                end
            end
        end
    },
    
    RemoveParticles = {
        name = "Sem Partículas", 
        desc = "Remove efeitos visuais",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") then
                        obj.Enabled = false
                    end
                end
            end
        end
    },
    
    RemoveTextures = {
        name = "Sem Texturas",
        desc = "Remove texturas do jogo",
        func = function(state)
            if state then
                for _, texture in pairs(Workspace:GetDescendants()) do
                    if texture:IsA("Decal") then
                        texture.Transparency = 1
                    end
                end
            end
        end
    },
    
    OptimizeGraphics = {
        name = "Gráficos Mínimos",
        desc = "Configurações gráficas no mínimo",
        func = function(state)
            if state then
                settings().Rendering.QualityLevel = 1
            end
        end
    },
    
    DisablePhysics = {
        name = "Física Leve",
        desc = "Reduz qualidade da física",
        func = function(state)
            if state then
                settings().Physics.PhysicsEnvironmentalThrottle = 3
            end
        end
    },
    
    RemoveSounds = {
        name = "Sem Sons",
        desc = "Desativa sons ambientais",
        func = function(state)
            if state then
                for _, sound in pairs(Workspace:GetDescendants()) do
                    if sound:IsA("Sound") then
                        sound.Volume = 0
                    end
                end
            end
        end
    },
    
    SimplifyTerrain = {
        name = "Terreno Simples",
        desc = "Otimiza terreno e água",
        func = function(state)
            if state then
                if Workspace:FindFirstChildOfClass("Terrain") then
                    local terrain = Workspace:FindFirstChildOfClass("Terrain")
                    terrain.Decoration = false
                end
            end
        end
    },
    
    RemoveGUIEffects = {
        name = "Sem Efeitos GUI",
        desc = "Remove efeitos da interface",
        func = function(state)
            if state then
                for _, gui in pairs(playerGui:GetDescendants()) do
                    if gui:IsA("UIStroke") or gui:IsA("UIGradient") then
                        gui.Enabled = false
                    end
                end
            end
        end
    },
    
    LimitPartCount = {
        name = "Limitar Partes",
        desc = "Reduz quantidade de objetos",
        func = function(state)
            if state then
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Part") and descendant.Parent ~= localPlayer.Character then
                        wait(0.01)
                        descendant.Transparency = 0.5
                    end
                end)
            end
        end
    },
    
    OptimizeNetwork = {
        name = "Rede Otimizada",
        desc = "Melhora conexão e latência", 
        func = function(state)
            if state then
                settings().Network.IncomingReplicationLag = 0.1
            end
        end
    },
    
    ReduceShadowMap = {
        name = "Sombras Reduzidas",
        desc = "Remove sombras do jogo",
        func = function(state)
            if state then
                Lighting.GlobalShadows = false
            end
        end
    },
    
    EnableAggressiveGC = {
        name = "GC Agressivo",
        desc = "Limpeza frequente de memória",
        func = function(state)
            if state then
                coroutine.wrap(function()
                    while true do
                        wait(10)
                        collectgarbage("collect")
                    end
                end)()
            end
        end
    },
    
    RemoveWaterEffects = {
        name = "Sem Efeitos Água",
        desc = "Remove efeitos da água",
        func = function(state)
            if state then
                if Workspace:FindFirstChildOfClass("Terrain") then
                    local terrain = Workspace:FindFirstChildOfClass("Terrain")
                    terrain.WaterReflectance = 0
                end
            end
        end
    },
    
    SimplifyMaterials = {
        name = "Materiais Simples",
        desc = "Todos materiais em plástico",
        func = function(state)
            if state then
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("Part") then
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
        end
    },
    
    OptimizeCharacters = {
        name = "Personagens Otimizados",
        desc = "Reduz detalhes dos personagens",
        func = function(state)
            if state then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("Part") or part:IsA("MeshPart") then
                                part.Material = Enum.Material.Plastic
                            end
                        end
                    end
                end
            end
        end
    },
    
    RemoveLightingEffects = {
        name = "Sem Efeitos de Luz",
        desc = "Remove efeitos especiais de luz",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("PointLight") or obj:IsA("SpotLight") then
                        obj.Enabled = false
                    end
                end
            end
        end
    },
    
    OptimizeTextures = {
        name = "Texturas Otimizadas",
        desc = "Compressão de texturas",
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
                    end
                end
            end
        end
    },
    
    OptimizeRendering = {
        name = "Renderização Otimizada",
        desc = "Configurações de renderização",
        func = function(state)
            if state then
                settings().Rendering.EnableFRM = false
            end
        end
    },
    
    MemoryOptimization = {
        name = "Otimização de Memória",
        desc = "Gestão de memória RAM",
        func = function(state)
            if state then
                coroutine.wrap(function()
                    while true do
                        wait(20)
                        collectgarbage("collect")
                    end
                end)()
            end
        end
    },
    
    AdvancedFPSBoost = {
        name = "Boost de FPS",
        desc = "Otimização para máximo FPS",
        func = function(state)
            if state then
                settings().Rendering.EnableFRM = false
                settings().Rendering.QualityLevel = 1
            end
        end
    }
}

-- FUNÇÃO PARA CRIAR TOGGLES
local function CreateCyberToggle(name, description, defaultState, callback, settingKey, parentFrame, positionY)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
    ToggleFrame.Position = UDim2.new(0, 0, 0, positionY)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(1, 0, 1, 0)
    ToggleBG.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = ToggleFrame
    
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Thickness = 1
    ToggleStroke.Color = Color3.fromRGB(60, 60, 80)
    ToggleStroke.Parent = ToggleBG
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextSize = 12
    ToggleLabel.Parent = ToggleFrame
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    DescriptionLabel.Position = UDim2.new(0, 10, 0.6, 0)
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.TextSize = 9
    DescriptionLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    ToggleKnob.Position = defaultState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.Parent = ToggleButton
    
    local isEnabled = defaultState
    
    if isEnabled then
        pcall(callback, true)
        savedSettings[settingKey] = true
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        if isEnabled then
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 200, 0)}):Play()
            TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(1, -21, 0.5, -9)}):Play()
        else
            TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
            TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
        end
        
        pcall(callback, isEnabled)
        savedSettings[settingKey] = isEnabled
        SaveSettings()
    end)
    
    ToggleFrame.Parent = parentFrame
    return ToggleFrame
end

-- CRIAR MENU PRINCIPAL PEQUENO
local function CreateMainGUI()
    if mainScreenGui and mainScreenGui:IsDescendantOf(playerGui) then
        mainScreenGui:Destroy()
    end
    
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = "VGZINSK_V1"
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 400) -- Menu pequeno
    mainFrame.Position = UDim2.new(0, 50, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local OuterGlow = Instance.new("UIStroke")
    OuterGlow.Thickness = 3
    OuterGlow.Color = Color3.fromRGB(0, 255, 255)
    OuterGlow.Transparency = 0.2
    OuterGlow.Parent = mainFrame
    
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 30)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    Header.BorderSizePixel = 0
    Header.Parent = mainFrame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.6, 0, 1, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ VGZINSK V1"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = Header
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -55, 0, 2)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "_"
    minimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeButton.Font = Enum.Font.GothamBold
    minimizeButton.TextSize = 16
    minimizeButton.Parent = Header
    
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 25, 0, 25)
    closeButton.Position = UDim2.new(1, -25, 0, 2)
    closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 12
    closeButton.Parent = Header
    
    local MainContainer = Instance.new("ScrollingFrame")
    MainContainer.Size = UDim2.new(1, -10, 1, -40)
    MainContainer.Position = UDim2.new(0, 5, 0, 35)
    MainContainer.BackgroundTransparency = 1
    MainContainer.BorderSizePixel = 0
    MainContainer.ScrollBarThickness = 6
    MainContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    MainContainer.Parent = mainFrame

    local currentY = 0

    -- Lista de toggles principais
    local mainToggles = {
        {key = "autoLoad", name = "🔄 AUTO LOAD", desc = "Carrega configurações salvas", func = ToggleAutoLoad, default = false},
        {key = "platformBuilder", name = "🏗️ PLATFORM BUILDER", desc = "Cria plataformas ao pular", func = TogglePlatformBuilder, default = false},
        {key = "wallhack", name = "👻 WALLHACK", desc = "Atravessa paredes", func = ToggleWallhack, default = false},
        {key = "teleport", name = "💫 TELEPORT", desc = "Sistema de teletransporte", func = ToggleTeleport, default = false},
    }

    -- Adicionar toggles principais
    for i, toggleData in ipairs(mainToggles) do
        CreateCyberToggle(
            toggleData.name,
            toggleData.desc,
            toggleData.default,
            toggleData.func,
            toggleData.key,
            MainContainer,
            currentY
        )
        currentY = currentY + 45
    end

    -- Separador
    local separator = Instance.new("Frame")
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.Position = UDim2.new(0, 0, 0, currentY)
    separator.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    separator.BorderSizePixel = 0
    separator.Parent = MainContainer
    currentY = currentY + 10

    -- Título das otimizações
    local optimTitle = Instance.new("TextLabel")
    optimTitle.Size = UDim2.new(1, 0, 0, 20)
    optimTitle.Position = UDim2.new(0, 0, 0, currentY)
    optimTitle.BackgroundTransparency = 1
    optimTitle.Text = "OTIMIZAÇÕES:"
    optimTitle.TextColor3 = Color3.fromRGB(0, 255, 255)
    optimTitle.Font = Enum.Font.GothamBold
    optimTitle.TextSize = 12
    optimTitle.Parent = MainContainer
    currentY = currentY + 25

    -- Adicionar algumas otimizações principais
    local optimToggles = {
        {key = "OptimizeGraphics", name = "🎮 Gráficos Mínimos", desc = "Configurações no mínimo", func = optimizationFunctions.OptimizeGraphics.func, default = false},
        {key = "RemoveCharacterAnimations", name = "🎭 Sem Animações", desc = "Remove movimentos", func = optimizationFunctions.RemoveCharacterAnimations.func, default = false},
        {key = "RemoveParticles", name = "✨ Sem Partículas", desc = "Remove efeitos visuais", func = optimizationFunctions.RemoveParticles.func, default = false},
        {key = "RemoveSounds", name = "🔇 Sem Sons", desc = "Desativa sons", func = optimizationFunctions.RemoveSounds.func, default = false},
        {key = "AdvancedFPSBoost", name = "🚀 Boost de FPS", desc = "Otimização extrema", func = optimizationFunctions.AdvancedFPSBoost.func, default = false},
    }

    for i, toggleData in ipairs(optimToggles) do
        CreateCyberToggle(
            toggleData.name,
            toggleData.desc,
            toggleData.default,
            toggleData.func,
            toggleData.key,
            MainContainer,
            currentY
        )
        currentY = currentY + 45
    end

    -- Botão de reset
    local resetFrame = Instance.new("Frame")
    resetFrame.Size = UDim2.new(1, 0, 0, 35)
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
    resetButton.TextSize = 12
    resetButton.Parent = resetFrame

    resetButton.MouseButton1Click:Connect(function()
        for _, toggleData in ipairs(mainToggles) do
            if savedSettings[toggleData.key] then
                pcall(toggleData.func, false)
                savedSettings[toggleData.key] = false
            end
        end
        for _, toggleData in ipairs(optimToggles) do
            if savedSettings[toggleData.key] then
                pcall(toggleData.func, false)
                savedSettings[toggleData.key] = false
            end
        end
        SaveSettings()
    end)

    currentY = currentY + 45
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, currentY)

    -- Configurar botões
    minimizeButton.MouseButton1Click:Connect(function()
        mainScreenGui.Enabled = false
    end)

    closeButton.MouseButton1Click:Connect(function()
        mainScreenGui:Destroy()
    end)

    mainFrame.Parent = mainScreenGui
    mainScreenGui.Parent = playerGui

    return mainScreenGui
end

-- INICIALIZAÇÃO DO SISTEMA
coroutine.wrap(function()
    wait(1)
    
    -- Criar interface principal
    CreateMainGUI()
    
    -- Inicializar sistemas
    InitializeStableFPS()
    
    -- Carregar configurações
    local loadedData = LoadSettings()
    if loadedData then
        if loadedData.autoLoad then
            ToggleAutoLoad(true)
        end
    end
    
    print("⚡ VGZINSK V1 - SISTEMA INICIALIZADO!")
    print("✅ Menu principal: FUNCIONANDO")
    print("✅ Teleport system: FUNCIONAL") 
    print("✅ Wallhack: OPERACIONAL")
    print("✅ Platform builder: PRONTO")
end)()
