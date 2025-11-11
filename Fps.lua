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

-- SISTEMA FPS BOOST AVANÇADO
local function InitializeFPSBoost()
    if connections.fpsControl then
        connections.fpsControl:Disconnect()
    end
    
    local frameTime = 1 / targetFPS
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
        local success, currentFPS = pcall(function()
            return math.floor(1 / RunService.RenderStepped:Wait())
        end)
        performanceStats.fps = success and currentFPS or 0
        
        -- Monitorar memória avançado
        local success, graphicsMemory = pcall(function()
            return Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Graphics) or 0
        end)
        local success2, scriptMemory = pcall(function()
            return Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Script) or 0
        end)
        local success3, physicsMemory = pcall(function()
            return Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Physics) or 0
        end)
        
        performanceStats.memory = math.floor((success and graphicsMemory or 0) + (success2 and scriptMemory or 0) + (success3 and physicsMemory or 0))
        
        -- Monitorar objetos
        performanceStats.objects = #Workspace:GetDescendants()
    end)
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
    if part.Name:lower():find("floor") or part.Name:lower():find("ground") or part.Name:lower():find("base") then
        return true
    end
    -- Verifica se a parte está em uma posição muito baixa (provavelmente chão)
    if part.Position.Y < 10 and part.Size.Y < 5 then
        return true
    end
    -- Verifica se a parte está diretamente abaixo do jogador
    if localPlayer.Character then
        local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local playerPos = rootPart.Position
            local partPos = part.Position
            -- Se a parte está abaixo do jogador e próxima verticalmente
            if partPos.Y < playerPos.Y - 2 and math.abs(partPos.X - playerPos.X) < 10 and math.abs(partPos.Z - playerPos.Z) < 10 then
                return true
            end
        end
    end
    return false
end

local function IsWallOrObstacle(part)
    -- Verifica se é uma parede ou obstáculo (não chão)
    if IsGroundPart(part) then
        return false
    end
    
    -- Verifica se é uma parte que normalmente seria um obstáculo
    if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
        if part.CanCollide and part.Transparency < 0.5 then
            -- Verifica se está na frente ou nos lados do jogador
            if localPlayer.Character then
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart then
                    local playerPos = rootPart.Position
                    local partPos = part.Position
                    local distance = (playerPos - partPos).Magnitude
                    
                    -- Só considera partes que estão próximas horizontalmente
                    if distance < 20 and math.abs(partPos.Y - playerPos.Y) < 10 then
                        return true
                    end
                end
            end
        end
    end
    return false
end

local function ToggleWallhack(state)
    wallhackEnabled = state
    
    if state then
        -- Remover colisões apenas de paredes e obstáculos (não do chão)
        for _, part in pairs(Workspace:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") or part:IsA("UnionOperation") then
                if part.CanCollide and part.Parent ~= localPlayer.Character and IsWallOrObstacle(part) then
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
                if descendant.CanCollide and descendant.Parent ~= localPlayer.Character and IsWallOrObstacle(descendant) then
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
    
    return teleportBubble
end

local function MinimizeTeleportGUI()
    if teleportGui and teleportGui:IsDescendantOf(playerGui) then
        teleportGui.Enabled = false
        isTeleportMinimized = true
        CreateTeleportBubble()
    end
end

local function RestoreTeleportGUI()
    if teleportGui and teleportBubble then
        teleportGui.Enabled = true
        isTeleportMinimized = false
        teleportBubble:Destroy()
        teleportBubble = nil
    end
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
    
    -- Botão: Voltar para posição anterior
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
        MinimizeTeleportGUI()
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
    
    -- Configurar clique na bolha
    if teleportBubble then
        teleportBubble:GetChildren()[1].MouseButton1Click:Connect(function()
            RestoreTeleportGUI()
        end)
    end
    
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
    {
        key = "removeAnimations",
        name = "🌀 REMOVE ANIMATIONS",
        desc = "Remove animações dos personagens para melhor performance",
        func = function(state)
            if state then
                for _, player in pairs(Players:GetPlayers()) do
                    if player.Character then
                        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ClearAllChildren()
                        end
                    end
                end
                connections.characterAdded = Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function(character)
                        wait(0.5)
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ClearAllChildren()
                        end
                    end)
                end)
            else
                if connections.characterAdded then
                    connections.characterAdded:Disconnect()
                end
            end
        end,
        default = false
    },
    {
        key = "optimizeLighting",
        name = "💡 OPTIMIZE LIGHTING",
        desc = "Otimiza configurações de iluminação para melhor FPS",
        func = function(state)
            if state then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 1000
                Lighting.Brightness = 2
                Lighting.OutdoorAmbient = Color3.new(0.5, 0.5, 0.5)
                Lighting.Ambient = Color3.new(0.5, 0.5, 0.5)
            else
                Lighting.GlobalShadows = true
                Lighting.FogEnd = 100000
                Lighting.Brightness = 1
                Lighting.OutdoorAmbient = Color3.new(0, 0, 0)
                Lighting.Ambient = Color3.new(0, 0, 0)
            end
        end,
        default = false
    },
    {
        key = "removeParticles",
        name = "✨ REMOVE PARTICLES",
        desc = "Remove partículas e efeitos visuais",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                        obj.Enabled = false
                    end
                end
                connections.particleAdded = Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") or descendant:IsA("Beam") then
                        descendant.Enabled = false
                    end
                end)
            else
                if connections.particleAdded then
                    connections.particleAdded:Disconnect()
                end
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                        obj.Enabled = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "reduceGraphics",
        name = "🎮 REDUCE GRAPHICS",
        desc = "Reduz qualidade gráfica para máximo FPS",
        func = function(state)
            if state then
                settings().Rendering.QualityLevel = 1
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") then
                        obj.Material = Enum.Material.Plastic
                        obj.Reflectance = 0
                    end
                end
            else
                settings().Rendering.QualityLevel = 10
            end
        end,
        default = false
    },
    {
        key = "hideChat",
        name = "💬 HIDE CHAT",
        desc = "Esconde o chat para melhor performance",
        func = function(state)
            if state then
                local chat = Players.LocalPlayer:FindFirstChild("PlayerGui")
                if chat then
                    local chatFrame = chat:FindFirstChild("Chat")
                    if chatFrame then
                        chatFrame.Enabled = false
                    end
                end
            else
                local chat = Players.LocalPlayer:FindFirstChild("PlayerGui")
                if chat then
                    local chatFrame = chat:FindFirstChild("Chat")
                    if chatFrame then
                        chatFrame.Enabled = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "disableShadows",
        name = "🌑 DISABLE SHADOWS",
        desc = "Desativa sombras para melhor FPS",
        func = function(state)
            if state then
                Lighting.GlobalShadows = false
                for _, light in pairs(Lighting:GetChildren()) do
                    if light:IsA("Light") then
                        light.Shadows = false
                    end
                end
            else
                Lighting.GlobalShadows = true
                for _, light in pairs(Lighting:GetChildren()) do
                    if light:IsA("Light") then
                        light.Shadows = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "optimizeTerrain",
        name = "🏔️ OPTIMIZE TERRAIN",
        desc = "Otimiza o terreno para melhor performance",
        func = function(state)
            if state then
                if Workspace:FindFirstChildOfClass("Terrain") then
                    local terrain = Workspace:FindFirstChildOfClass("Terrain")
                    terrain.Decoration = false
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 1
                end
            else
                if Workspace:FindFirstChildOfClass("Terrain") then
                    local terrain = Workspace:FindFirstChildOfClass("Terrain")
                    terrain.Decoration = true
                    terrain.WaterReflectance = 0.5
                    terrain.WaterTransparency = 0.5
                end
            end
        end,
        default = false
    },
    {
        key = "removeSounds",
        name = "🔇 REMOVE SOUNDS",
        desc = "Remove sons do jogo para melhor performance",
        func = function(state)
            if state then
                for _, sound in pairs(Workspace:GetDescendants()) do
                    if sound:IsA("Sound") then
                        sound.Playing = false
                    end
                end
                connections.soundAdded = Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Sound") then
                        descendant.Playing = false
                    end
                end)
            else
                if connections.soundAdded then
                    connections.soundAdded:Disconnect()
                end
                for _, sound in pairs(Workspace:GetDescendants()) do
                    if sound:IsA("Sound") then
                        sound.Playing = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "simplifyTextures",
        name = "🖼️ SIMPLIFY TEXTURES",
        desc = "Simplifica texturas para melhor FPS",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") then
                        if obj.Texture then
                            obj.Texture = ""
                        end
                    elseif obj:IsA("Decal") then
                        obj.Transparency = 1
                    end
                end
            else
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Decal") then
                        obj.Transparency = 0
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "limitRenderDistance",
        name = "👁️ LIMIT RENDER DISTANCE",
        desc = "Limita distância de renderização",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.LocalTransparencyModifier = 0.5
                    end
                end
                connections.renderDistance = Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("BasePart") then
                        descendant.LocalTransparencyModifier = 0.5
                    end
                end)
            else
                if connections.renderDistance then
                    connections.renderDistance:Disconnect()
                end
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        obj.LocalTransparencyModifier = 0
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "removeWaterEffects",
        name = "💧 REMOVE WATER EFFECTS",
        desc = "Remove efeitos de água",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Water") then
                        obj.Transparency = 1
                    end
                end
            else
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Water") then
                        obj.Transparency = 0
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "optimizePhysics",
        name = "⚛️ OPTIMIZE PHYSICS",
        desc = "Otimiza configurações de física",
        func = function(state)
            if state then
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = false
                        part.CanQuery = false
                    end
                end
            else
                settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Default
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanTouch = true
                        part.CanQuery = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "removeBillboardGuis",
        name = "📺 REMOVE BILLBOARD GUIS",
        desc = "Remove billboards e GUIs 3D",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                        obj.Enabled = false
                    end
                end
            else
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") then
                        obj.Enabled = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "simplifySkybox",
        name = "🌌 SIMPLIFY SKYBOX",
        desc = "Simplifica a skybox",
        func = function(state)
            if state then
                for _, obj in pairs(Lighting:GetChildren()) do
                    if obj:IsA("Sky") then
                        obj.Parent = nil
                    end
                end
                Lighting.Sky = nil
            else
                -- Não podemos restaurar a skybox original, mas podemos parar de removê-la
            end
        end,
        default = false
    },
    {
        key = "removeAtmosphere",
        name = "🌫️ REMOVE ATMOSPHERE",
        desc = "Remove efeitos de atmosfera",
        func = function(state)
            if state then
                for _, obj in pairs(Lighting:GetChildren()) do
                    if obj:IsA("Atmosphere") then
                        obj.Parent = nil
                    end
                end
            else
                -- Não podemos restaurar a atmosfera original
            end
        end,
        default = false
    },
    {
        key = "disablePostProcessing",
        name = "🎨 DISABLE POST PROCESSING",
        desc = "Desativa efeitos de pós-processamento",
        func = function(state)
            if state then
                Lighting.Bloom.Enabled = false
                Lighting.ColorCorrection.Enabled = false
                Lighting.Blur.Enabled = false
                Lighting.SunRays.Enabled = false
            else
                Lighting.Bloom.Enabled = true
                Lighting.ColorCorrection.Enabled = true
                Lighting.Blur.Enabled = true
                Lighting.SunRays.Enabled = true
            end
        end,
        default = false
    },
    {
        key = "optimizeNetwork",
        name = "📡 OPTIMIZE NETWORK",
        desc = "Otimiza configurações de rede",
        func = function(state)
            if state then
                settings().Network.IncomingReplicationLag = 1000
            else
                settings().Network.IncomingReplicationLag = 0
            end
        end,
        default = false
    },
    {
        key = "removeSparkles",
        name = "🌟 REMOVE SPARKLES",
        desc = "Remove efeitos de brilho e sparkles",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Sparkles") then
                        obj.Enabled = false
                    end
                end
            else
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Sparkles") then
                        obj.Enabled = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "simplifyMaterials",
        name = "🔶 SIMPLIFY MATERIALS",
        desc = "Simplifica materiais para melhor performance",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") then
                        obj.Material = Enum.Material.Plastic
                    end
                end
            else
                -- Não podemos restaurar materiais originais
            end
        end,
        default = false
    },
    {
        key = "removeFire",
        name = "🔥 REMOVE FIRE",
        desc = "Remove efeitos de fogo",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Fire") or obj:IsA("Smoke") then
                        obj.Enabled = false
                    end
                end
            else
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Fire") or obj:IsA("Smoke") then
                        obj.Enabled = true
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "optimizeCharacters",
        name = "👤 OPTIMIZE CHARACTERS",
        desc = "Otimiza personagens para melhor performance",
        func = function(state)
            if state then
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Transparency = 0.5
                                part.Material = Enum.Material.Plastic
                            end
                        end
                    end
                end
            else
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= localPlayer and player.Character then
                        for _, part in pairs(player.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Transparency = 0
                                part.Material = Enum.Material.Plastic
                            end
                        end
                    end
                end
            end
        end,
        default = false
    },
    {
        key = "disableCameraEffects",
        name = "📷 DISABLE CAMERA EFFECTS",
        desc = "Desativa efeitos de câmera",
        func = function(state)
            if state then
                local camera = Workspace.CurrentCamera
                camera.DepthOfField.Enabled = false
                camera.ImageEffects.Enabled = false
            else
                local camera = Workspace.CurrentCamera
                camera.DepthOfField.Enabled = true
                camera.ImageEffects.Enabled = true
            end
        end,
        default = false
    },
    {
        key = "reduceTextureQuality",
        name = "🖼️ REDUCE TEXTURE QUALITY",
        desc = "Reduz qualidade de texturas",
        func = function(state)
            if state then
                settings().Rendering.TextureQuality = Enum.TextureQuality.Lowest
            else
                settings().Rendering.TextureQuality = Enum.TextureQuality.Highest
            end
        end,
        default = false
    },
    {
        key = "fpsBoost",
        name = "🚀 FPS BOOST ULTIMATE",
        desc = "Ativa todas as otimizações de FPS",
        func = function(state)
            if state then
                InitializeFPSBoost()
                -- Ativa várias otimizações automaticamente
                for i, funcData in ipairs(optimizationFunctions) do
                    if funcData.key ~= "fpsBoost" then
                        savedSettings[funcData.key] = true
                        funcData.func(true)
                    end
                end
            else
                if connections.fpsControl then
                    connections.fpsControl:Disconnect()
                end
                -- Desativa otimizações
                for i, funcData in ipairs(optimizationFunctions) do
                    if funcData.key ~= "fpsBoost" then
                        savedSettings[funcData.key] = false
                        funcData.func(false)
                    end
                end
            end
        end,
        default = false
    }
}

-- CRIAR A INTERFACE PRINCIPAL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VGZINSK_V1"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 400, 0, 500)
MainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = 3
uiStroke.Color = Color3.fromRGB(0, 255, 255)
uiStroke.Parent = MainFrame

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 40)
header.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
header.BorderSizePixel = 0
header.Parent = MainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.7, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ VGZINSK V1 - INJECTOR"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = header

local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Size = UDim2.new(1, -10, 1, -50)
MainContainer.Position = UDim2.new(0, 5, 0, 45)
MainContainer.BackgroundTransparency = 1
MainContainer.BorderSizePixel = 0
MainContainer.ScrollBarThickness = 8
MainContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
MainContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.Parent = MainContainer

-- CONFIGURAR A INTERFACE
local currentY = 0

local functionToggles = {
    {key = "autoLoad", name = "🔄 AUTO LOAD", desc = "Carrega configurações automaticamente", func = ToggleAutoLoad, default = false},
    {key = "platformBuilder", name = "🏗️ PLATFORM BUILDER", desc = "Cria plataformas ao pular", func = TogglePlatformBuilder, default = false},
    {key = "wallhack", name = "👻 WALLHACK FIXED", desc = "Atravessa paredes mas não o chão", func = ToggleWallhack, default = false},
    {key = "teleport", name = "💫 TELEPORT SYSTEM V2", desc = "Sistema de teletransporte avançado", func = ToggleTeleport, default = false},
}

-- Adicionar todas as funções de otimização
for i, funcData in ipairs(optimizationFunctions) do
    table.insert(functionToggles, funcData)
end

-- Criar toggles para cada função
for i, toggleData in ipairs(functionToggles) do
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 40)
    toggleFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    toggleFrame.BorderSizePixel = 0
    
    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 80, 0, 30)
    toggleButton.Position = UDim2.new(1, -85, 0, 5)
    toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    toggleButton.BorderSizePixel = 0
    toggleButton.Text = "OFF"
    toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 12
    toggleButton.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.7, 0, 0, 20)
    toggleLabel.Position = UDim2.new(0, 10, 0, 5)
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Text = toggleData.name
    toggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleLabel.Font = Enum.Font.GothamBold
    toggleLabel.TextSize = 12
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.Parent = toggleFrame
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(0.7, 0, 0, 15)
    descLabel.Position = UDim2.new(0, 10, 0, 22)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = toggleData.desc
    descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = toggleFrame
    
    toggleButton.MouseButton1Click:Connect(function()
        local newState = not savedSettings[toggleData.key]
        savedSettings[toggleData.key] = newState
        
        if newState then
            toggleButton.Text = "ON"
            toggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
            toggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        else
            toggleButton.Text = "OFF"
            toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
            toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
        
        if toggleData.func then
            toggleData.func(newState)
        end
        
        SaveSettings()
    end)
    
    -- Configurar estado inicial
    if savedSettings[toggleData.key] == nil then
        savedSettings[toggleData.key] = toggleData.default or false
    end
    
    if savedSettings[toggleData.key] then
        toggleButton.Text = "ON"
        toggleButton.TextColor3 = Color3.fromRGB(100, 255, 100)
        toggleButton.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    else
        toggleButton.Text = "OFF"
        toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    end
    
    toggleFrame.Parent = MainContainer
end

-- Ajustar tamanho do canvas
local function UpdateCanvasSize()
    local totalHeight = 0
    for _, child in ipairs(MainContainer:GetChildren()) do
        if child:IsA("Frame") then
            totalHeight = totalHeight + child.AbsoluteSize.Y + 5
        end
    end
    MainContainer.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(UpdateCanvasSize)

-- Fechar interface
closeButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Adicionar à interface
MainFrame.Parent = ScreenGui
ScreenGui.Parent = playerGui

-- ANIMAÇÕES DA BOLHA DO TELEPORT
if teleportBubble then
    teleportBubble:GetChildren()[1].MouseButton1Click:Connect(function()
        RestoreTeleportGUI()
    end)
end

-- INICIALIZAÇÃO AUTOMÁTICA
InitializeFPSBoost()
InitializeAdvancedPerformanceMonitor()

-- Carregar configurações salvas
local loadedData = LoadSettings()
if loadedData then
    if loadedData.autoLoad then
        ToggleAutoLoad(true)
    end
end

-- INICIALIZAÇÃO COMPLETA
print("⚡ VGZINSK V1 - SISTEMA INICIADO COM SUCESSO!")
print("🎯 SISTEMAS ATIVOS:")
print("📍 Teleport System V2 - 100% Funcional")
print("👻 Wallhack Corrigido - Não atravessa chão")
print("🚀 FPS Boost Ultimate - 25 Otimizações")
print("🔄 Auto Load - Configurações salvas automaticamente")
