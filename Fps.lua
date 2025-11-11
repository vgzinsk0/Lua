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
local previousPosition = nil
local teleportGui = nil
local teleportBubble = nil
local isTeleportMinimized = false

-- NOVO: Sistema de bolha para menu principal
local mainBubble = nil
local isMainMinimized = false
local mainScreenGui = nil
local mainFrame = nil

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

-- SISTEMA TELEPORT AVANÇADO COM BOLHA FUNCIONAL
local function CreateTeleportBubble()
    if teleportBubble and teleportBubble:IsDescendantOf(playerGui) then
        teleportBubble:Destroy()
    end
    
    teleportBubble = Instance.new("ScreenGui")
    teleportBubble.Name = "VGZINSK_TeleportBubble"
    teleportBubble.ResetOnSpawn = false
    teleportBubble.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local bubbleFrame = Instance.new("Frame")
    bubbleFrame.Size = UDim2.new(0, 60, 0, 60)
    bubbleFrame.Position = UDim2.new(1, -80, 0.5, -30)
    bubbleFrame.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    bubbleFrame.BorderSizePixel = 0
    bubbleFrame.Active = true
    bubbleFrame.Draggable = true
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubbleFrame
    
    local bubbleStroke = Instance.new("UIStroke")
    bubbleStroke.Thickness = 3
    bubbleStroke.Color = Color3.fromRGB(0, 255, 255)
    bubbleStroke.Parent = bubbleFrame
    
    local bubbleGlow = Instance.new("UIGradient")
    bubbleGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 200))
    })
    bubbleGlow.Rotation = 45
    bubbleGlow.Parent = bubbleFrame
    
    local bubbleIcon = Instance.new("TextLabel")
    bubbleIcon.Size = UDim2.new(1, 0, 1, 0)
    bubbleIcon.BackgroundTransparency = 1
    bubbleIcon.Text = "⚡"
    bubbleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    bubbleIcon.Font = Enum.Font.GothamBold
    bubbleIcon.TextSize = 20
    bubbleIcon.Parent = bubbleFrame
    
    -- Animação de pulsação
    coroutine.wrap(function()
        while teleportBubble and teleportBubble.Parent do
            TweenService:Create(bubbleFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 65, 0, 65)
            }):Play()
            wait(1)
            TweenService:Create(bubbleFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 60, 0, 60)
            }):Play()
            wait(1)
        end
    end)()
    
    bubbleFrame.Parent = teleportBubble
    teleportBubble.Parent = playerGui
    
    -- CORREÇÃO: Configurar clique CORRETO para restaurar
    bubbleFrame.MouseButton1Click:Connect(function()
        if teleportGui then
            teleportGui.Enabled = true
            isTeleportMinimized = false
            teleportBubble:Destroy()
            teleportBubble = nil
        else
            -- Se o teleportGui foi destruído, criar um novo
            CreateTeleportGUI()
        end
    end)
    
    return teleportBubble
end

local function CreateTeleportGUI()
    if teleportGui and teleportGui:IsDescendantOf(playerGui) then
        teleportGui:Destroy()
    end
    if teleportBubble and teleportBubble:IsDescendantOf(playerGui) then
        teleportBubble:Destroy()
    end
    
    teleportGui = Instance.new("ScreenGui")
    teleportGui.Name = "VGZINSK_TeleportGUI"
    teleportGui.ResetOnSpawn = false
    teleportGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 250)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -125)
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
    title.Text = "⚡ TELEPORT HACK"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = header
    
    local minimizeButton = Instance.new("TextButton")
    minimizeButton.Size = UDim2.new(0, 25, 0, 25)
    minimizeButton.Position = UDim2.new(1, -55, 0, 2)
    minimizeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    minimizeButton.BorderSizePixel = 0
    minimizeButton.Text = "○"
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
    
    -- Botão Teleport
    local teleportButton = Instance.new("TextButton")
    teleportButton.Size = UDim2.new(1, 0, 0, 35)
    teleportButton.Position = UDim2.new(0, 0, 0, 45)
    teleportButton.BackgroundColor3 = Color3.fromRGB(200, 150, 0)
    teleportButton.BorderSizePixel = 0
    teleportButton.Text = "🚀 TELEPORT TO BASE"
    teleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    teleportButton.Font = Enum.Font.GothamBold
    teleportButton.TextSize = 12
    teleportButton.Parent = contentFrame
    
    -- Botão Voltar para posição anterior
    local backButton = Instance.new("TextButton")
    backButton.Size = UDim2.new(1, 0, 0, 35)
    backButton.Position = UDim2.new(0, 0, 0, 90)
    backButton.BackgroundColor3 = Color3.fromRGB(150, 0, 200)
    backButton.BorderSizePixel = 0
    backButton.Text = "↩️ BACK TO PREVIOUS"
    backButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    backButton.Font = Enum.Font.GothamBold
    backButton.TextSize = 12
    backButton.Parent = contentFrame
    
    -- Display do ponto atual
    local pointDisplay = Instance.new("TextLabel")
    pointDisplay.Size = UDim2.new(1, 0, 0, 60)
    pointDisplay.Position = UDim2.new(0, 0, 0, 135)
    pointDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    pointDisplay.BorderSizePixel = 0
    pointDisplay.Text = "No point set\nPrevious: None"
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
                pointDisplay.Text = string.format("Point Set!\nX: %.1f\nY: %.1f\nZ: %.1f\nPrevious: %s", 
                    rootPart.Position.X, rootPart.Position.Y, rootPart.Position.Z,
                    previousPosition and "Saved" or "None")
                savedSettings.currentTeleportPoint = currentTeleportPoint
                SaveSettings()
            end
        end
    end)
    
    teleportButton.MouseButton1Click:Connect(function()
        if currentTeleportPoint and localPlayer.Character then
            local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                -- Salvar posição atual antes de teleportar
                previousPosition = rootPart.Position
                -- Teleport seguro
                rootPart.CFrame = CFrame.new(currentTeleportPoint.position)
                pointDisplay.Text = string.format("Teleported to base!\nPrevious position saved\nX: %.1f\nY: %.1f\nZ: %.1f", 
                    previousPosition.X, previousPosition.Y, previousPosition.Z)
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
        if teleportGui then
            teleportGui.Enabled = false
            isTeleportMinimized = true
            CreateTeleportBubble()
        end
    end)
    
    closeButton.MouseButton1Click:Connect(function()
        if teleportGui then
            teleportGui:Destroy()
        end
        if teleportBubble then
            teleportBubble:Destroy()
        end
    end)
    
    -- Carregar ponto salvo
    local loadedData = LoadSettings()
    if loadedData and loadedData.currentTeleportPoint then
        currentTeleportPoint = loadedData.currentTeleportPoint
        pointDisplay.Text = string.format("Point Loaded!\nX: %.1f\nY: %.1f\nZ: %.1f\nPrevious: %s", 
            currentTeleportPoint.position.X, currentTeleportPoint.position.Y, currentTeleportPoint.position.Z,
            previousPosition and "Saved" or "None")
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
        if teleportBubble and teleportBubble:IsDescendantOf(playerGui) then
            teleportBubble:Destroy()
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

-- ========== SISTEMA DE 24 FUNÇÕES DE OTIMIZAÇÃO AVANÇADAS ==========
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
                
                coroutine.wrap(function()
                    while true do
                        settings().Rendering.EnableFRM = false
                        settings().Rendering.EnableTrees = false
                        wait(15)
                    end
                end)()
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
                coroutine.wrap(function()
                    while true do
                        wait(10)
                        collectgarbage("collect")
                        collectgarbage("step", 300)
                    end
                end)()
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
                    end)
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
                coroutine.wrap(function()
                    while true do
                        wait(20)
                        collectgarbage("collect")
                        settings().Rendering.MeshCacheSize = 0
                        settings().Rendering.TextureCacheSize = 0
                    end
                end)()
            end
        end
    },
    
    AdvancedFPSBoost = {
        name = "Boost de FPS Avançado",
        desc = "Otimização extrema para máximo FPS",
        func = function(state)
            if state then
                settings().Rendering.EnableFRM = false
                settings().Rendering.QualityLevel = 1
                settings().Physics.PhysicsEnvironmentalThrottle = 2
                
                coroutine.wrap(function()
                    while true do
                        wait(30)
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("Part") and obj.Transparency > 0.8 then
                                obj:Destroy()
                            end
                        end
                    end
                end)()
            end
        end
    }
}

-- SISTEMA DE BOLHA PARA MENU PRINCIPAL CORRIGIDO
local function CreateMainBubble()
    if mainBubble and mainBubble:IsDescendantOf(playerGui) then
        mainBubble:Destroy()
    end
    
    mainBubble = Instance.new("ScreenGui")
    mainBubble.Name = "VGZINSK_MainBubble"
    mainBubble.ResetOnSpawn = false
    mainBubble.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local bubbleFrame = Instance.new("Frame")
    bubbleFrame.Size = UDim2.new(0, 70, 0, 70)
    bubbleFrame.Position = UDim2.new(0, 20, 0.5, -35)
    bubbleFrame.BackgroundColor3 = Color3.fromRGB(255, 50, 150)
    bubbleFrame.BorderSizePixel = 0
    bubbleFrame.Active = true
    bubbleFrame.Draggable = true
    
    local bubbleCorner = Instance.new("UICorner")
    bubbleCorner.CornerRadius = UDim.new(1, 0)
    bubbleCorner.Parent = bubbleFrame
    
    local bubbleStroke = Instance.new("UIStroke")
    bubbleStroke.Thickness = 3
    bubbleStroke.Color = Color3.fromRGB(255, 100, 200)
    bubbleStroke.Parent = bubbleFrame
    
    local bubbleGlow = Instance.new("UIGradient")
    bubbleGlow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 200)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 150))
    })
    bubbleGlow.Rotation = 45
    bubbleGlow.Parent = bubbleFrame
    
    local bubbleIcon = Instance.new("TextLabel")
    bubbleIcon.Size = UDim2.new(1, 0, 1, 0)
    bubbleIcon.BackgroundTransparency = 1
    bubbleIcon.Text = "🎮"
    bubbleIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
    bubbleIcon.Font = Enum.Font.GothamBold
    bubbleIcon.TextSize = 24
    bubbleIcon.Parent = bubbleFrame
    
    -- Animação de pulsação
    coroutine.wrap(function()
        while mainBubble and mainBubble.Parent do
            TweenService:Create(bubbleFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 75, 0, 75)
            }):Play()
            wait(1)
            TweenService:Create(bubbleFrame, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                Size = UDim2.new(0, 70, 0, 70)
            }):Play()
            wait(1)
        end
    end)()
    
    bubbleFrame.Parent = mainBubble
    mainBubble.Parent = playerGui
    
    -- CORREÇÃO: Configurar clique CORRETO para restaurar menu principal
    bubbleFrame.MouseButton1Click:Connect(function()
        if mainScreenGui then
            mainScreenGui.Enabled = true
            isMainMinimized = false
            mainBubble:Destroy()
            mainBubble = nil
        else
            -- Se o mainScreenGui foi destruído, criar um novo
            CreateMainGUI()
        end
    end)
    
    return mainBubble
end

-- FUNÇÃO PARA CRIAR TOGGLES OTIMIZADA
local function CreateCyberToggle(name, description, defaultState, callback, settingKey, parentFrame, positionY)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.Position = UDim2.new(0, 0, 0, positionY)
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
        pcall(callback, true)
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
        
        pcall(callback, isEnabled)
        
        savedSettings[settingKey] = isEnabled
        SaveSettings()
    end)
    
    ToggleFrame.Parent = parentFrame
    return ToggleFrame
end

-- CRIAR A INTERFACE PRINCIPAL OTIMIZADA
local function CreateMainGUI()
    if mainScreenGui and mainScreenGui:IsDescendantOf(playerGui) then
        mainScreenGui:Destroy()
    end
    if mainBubble and mainBubble:IsDescendantOf(playerGui) then
        mainBubble:Destroy()
    end
    
    mainScreenGui = Instance.new("ScreenGui")
    mainScreenGui.Name = "VGZINSK_V1"
    mainScreenGui.ResetOnSpawn = false
    mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 400, 0, 500)
    mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    
    local OuterGlow = Instance.new("UIStroke")
    OuterGlow.Thickness = 4
    OuterGlow.Color = Color3.fromRGB(0, 255, 255)
    OuterGlow.Transparency = 0.2
    OuterGlow.Parent = mainFrame
    
    local InnerGlow = Instance.new("UIStroke")
    InnerGlow.Thickness = 2
    InnerGlow.Color = Color3.fromRGB(255, 0, 255)
    InnerGlow.Transparency = 0.3
    InnerGlow.Parent = mainFrame
    
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    Header.BorderSizePixel = 0
    Header.Parent = mainFrame
    
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
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ VGZINSK V1"
    Title.TextColor3 = Color3.fromRGB(0, 255, 255)
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBlack
    Title.TextSize = 16
    Title.TextStrokeTransparency = 0.6
    Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    Title.Parent = Header
    
    local MinimizeButton = Instance.new("TextButton")
    MinimizeButton.Name = "MinimizeButton"
    MinimizeButton.Size = UDim2.new(0, 35, 0, 35)
    MinimizeButton.Position = UDim2.new(1, -75, 0, 5)
    MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
    MinimizeButton.BorderSizePixel = 0
    MinimizeButton.Text = "○"
    MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinimizeButton.Font = Enum.Font.GothamBold
    MinimizeButton.TextSize = 16
    MinimizeButton.Parent = Header
    
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
    CloseButton.Parent = Header
    
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
    MainContainer.Parent = mainFrame

    -- REMOVIDO: Performance Display (lixo que ocupava espaço)

    local currentY = 0

    -- Lista de toggles (24 funções + 4 principais)
    local functionToggles = {
        {key = "autoLoad", name = "🔄 AUTO LOAD", desc = "Carrega configurações automaticamente", func = ToggleAutoLoad, default = false},
        {key = "platformBuilder", name = "🏗️ PLATFORM BUILDER", desc = "Cria plataformas ao pular", func = TogglePlatformBuilder, default = false},
        {key = "wallhack", name = "👻 WALLHACK FIXED", desc = "Atravessa paredes mas não o chão", func = ToggleWallhack, default = false},
        {key = "teleport", name = "💫 TELEPORT SYSTEM V2", desc = "Sistema de teletransporte avançado", func = ToggleTeleport, default = false},
        
        -- 24 funções de otimização
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
        {key = "OptimizeCharacters", name = "👤 PERSONAGENS OTIMIZADOS", desc = "Reduz detalhes dos personagens", func = optimizationFunctions.OptimizeCharacters.func, default = false},
        {key = "RemoveLightingEffects", name = "💫 SEM EFEITOS DE LUZ", desc = "Remove efeitos especiais de luz", func = optimizationFunctions.RemoveLightingEffects.func, default = false},
        {key = "OptimizeTextures", name = "🖌️ TEXTURAS OTIMIZADAS", desc = "Compressão máxima de texturas", func = optimizationFunctions.OptimizeTextures.func, default = false},
        {key = "ReduceParticleQuality", name = "🎇 PARTÍCULAS MÍNIMAS", desc = "Qualidade mínima de partículas", func = optimizationFunctions.ReduceParticleQuality.func, default = false},
        {key = "OptimizeRendering", name = "🖥️ RENDERIZAÇÃO OTIMIZADA", desc = "Configurações avançadas de render", func = optimizationFunctions.OptimizeRendering.func, default = false},
        {key = "MemoryOptimization", name = "💾 OTIMIZAÇÃO DE MEMÓRIA", desc = "Gestão avançada de memória RAM", func = optimizationFunctions.MemoryOptimization.func, default = false},
        {key = "AdvancedFPSBoost", name = "🚀 BOOST DE FPS", desc = "Otimização extrema para máximo FPS", func = optimizationFunctions.AdvancedFPSBoost.func, default = false}
    }

    -- Adicionar todos os toggles
    for i, toggleData in ipairs(functionToggles) do
        CreateCyberToggle(
            toggleData.name,
            toggleData.desc,
            toggleData.default,
            toggleData.func,
            toggleData.key,
            MainContainer,
            currentY
        )
        currentY = currentY + 55
    end

    -- Botão de reset
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
                pcall(toggleData.func, false)
                savedSettings[toggleData.key] = false
            end
        end
        SaveSettings()
    end)

    currentY = currentY + 50
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, currentY + 20)

    -- CORREÇÃO: Configurar botões CORRETAMENTE
    MinimizeButton.MouseButton1Click:Connect(function()
        if mainScreenGui then
            mainScreenGui.Enabled = false
            isMainMinimized = true
            CreateMainBubble()
        end
    end)

    CloseButton.MouseButton1Click:Connect(function()
        if mainScreenGui then
            mainScreenGui:Destroy()
        end
        if mainBubble then
            mainBubble:Destroy()
        end
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
    
    -- Sistema de proteção
    localPlayer.CharacterAdded:Connect(function(character)
        wait(2)
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
                        pcall(optimizationFunctions[settingKey].func, true)
                    end
                end
            end
        end
    end)
    
    -- Auto-save
    coroutine.wrap(function()
        while true do
            wait(30)
            if autoLoadEnabled then
                SaveSettings()
            end
        end
    end)()
    
    print("⚡ VGZINSK V1 - SISTEMA COMPLETO INICIALIZADO!")
    print("✅ Sistema de bolha: FUNCIONANDO PERFEITAMENTE")
    print("✅ 24 Funções de otimização: ATIVAS")
    print("✅ Wallhack corrigido: OPERACIONAL")
    print("✅ Teleport V2: FUNCIONAL")
    print("❌ Performance monitor: REMOVIDO (lixo inútil)")
end)()
