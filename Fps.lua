--[[
    ╔═══════════════════════════════════════════════════════════╗
    ║           VGZINSK V3 - MOBILE EDITION                     ║
    ║           Optimized for Touch-Screen                      ║
    ║           35x FPS Boost Functions                         ║
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
    
    -- Main States
    platformBuilder = false,
    speedBoost = false,
    speedValue = 16, -- Default WalkSpeed
    
    -- FPS States (35 optimization functions)
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
    disableMotionBlur = false,
    -- 10 New Functions
    disableFog = false,
    removeTerrainDetails = false,
    disableCollisionFiltering = false,
    reduceRenderDistance = false,
    disableWaterReflections = false,
    removePostEffectInstances = false,
    optimizeSounds = false,
    disableHumanoidStates = false,
    reducePartCount = false,
    disableStreaming = false
}

-- CONNECTIONS
local connections = {}

-- DATA STORAGE
local platformParts = {}
local espObjects = {}

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

--[[
    ═══════════════════════════════════════════════════════════
                        ESP FUNCTIONS
    ═══════════════════════════════════════════════════════════
]]

-- ESP PLAYERS (MANTIDO)
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

--[[
    ═══════════════════════════════════════════════════════════
                        MAIN FUNCTIONS
    ═══════════════════════════════════════════════════════════
]]

-- PLATFORM BUILDER (MANTIDO)
local function TogglePlatformBuilder(state)
    scriptState.platformBuilder = state
    
    if state then
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

-- SPEED BOOST (NOVO)
local originalWalkSpeed = 16

local function ToggleSpeedBoost(state)
    scriptState.speedBoost = state
    
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            if state then
                humanoid.WalkSpeed = scriptState.speedValue
            else
                humanoid.WalkSpeed = originalWalkSpeed
            end
        end
    end
end

local function SetSpeedValue(value)
    scriptState.speedValue = value
    if scriptState.speedBoost and localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = value
        end
    end
end

--[[
    ═══════════════════════════════════════════════════════════
                        FPS OPTIMIZATION FUNCTIONS (35)
    ═══════════════════════════════════════════════════════════
]]

local optimizationFunctions = {
    -- 25 Existing (Corrigidas/Revisadas)
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
                -- Não podemos restaurar o original, mas podemos usar ShadowMap como padrão
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
            -- Aumentar IncomingReplicationLag pode reduzir o lag, mas pode causar desync
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
    },
    
    -- 10 New Functions (Total 35)
    {
        key = "disableFog",
        name = "Disable Fog",
        func = function(state)
            Lighting.FogEnd = state and 100000 or 0
            Lighting.FogStart = state and 100000 or 0
        end
    },
    {
        key = "removeTerrainDetails",
        name = "Remove Terrain Details",
        func = function(state)
            if state then
                Workspace.Terrain.Decoration = Enum.TerrainDecoration.None
            else
                Workspace.Terrain.Decoration = Enum.TerrainDecoration.Smooth
            end
        end
    },
    {
        key = "disableCollisionFiltering",
        name = "Disable Collision Filtering",
        func = function(state)
            -- Pode causar problemas, mas é uma otimização de física
            settings().Physics.AllowSleep = not state
        end
    },
    {
        key = "reduceRenderDistance",
        name = "Reduce Render Distance",
        func = function(state)
            -- Reduz a distância de renderização (pode ser um exploit)
            settings().Rendering.RenderDistance = state and 50 or 500
        end
    },
    {
        key = "disableWaterReflections",
        name = "Disable Water Reflections",
        func = function(state)
            settings().Rendering.Reflections = state and Enum.ReflectionLevel.None or Enum.ReflectionLevel.Low
        end
    },
    {
        key = "removePostEffectInstances",
        name = "Remove Post Effect Instances",
        func = function(state)
            for _, obj in pairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") then
                    obj.Enabled = not state
                end
            end
        end
    },
    {
        key = "optimizeSounds",
        name = "Optimize Sounds",
        func = function(state)
            -- Reduz a qualidade do som
            settings().Audio.QualityLevel = state and Enum.AudioQuality.Low or Enum.AudioQuality.High
        end
    },
    {
        key = "disableHumanoidStates",
        name = "Disable Humanoid States",
        func = function(state)
            -- Desativa estados como queda, pulo, etc. (pode ser um exploit)
            if localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, not state)
                    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, not state)
                end
            end
        end
    },
    {
        key = "reducePartCount",
        name = "Reduce Part Count",
        func = function(state)
            -- Tenta reduzir a contagem de partes (apenas para partes não essenciais)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") and obj.Name:lower():find("detail") then
                        obj.Parent = nil
                    end
                end
            end
        end
    },
    {
        key = "disableStreaming",
        name = "Disable Streaming",
        func = function(state)
            -- Desativa o streaming de partes (pode aumentar o uso de memória, mas reduz o lag de carregamento)
            settings().Client.StreamingEnabled = not state
        end
    }
}

-- FPS BOOST ULTIMATE (ativa todas as 35 funções)
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
    mainGui.Name = "VGZINSK_V3"
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
    title.Text = "⚡ VGZINSK V3"
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
        
        -- Reset WalkSpeed
        SetSpeedValue(originalWalkSpeed)
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

local function CreateSlider(name, description, minValue, maxValue, defaultValue, step, callback, parent)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 80)
    container.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local containerCorner = Instance.new("UICorner")
    containerCorner.CornerRadius = UDim.new(0, 10)
    containerCorner.Parent = container
    
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -20, 0, 25)
    nameLabel.Position = UDim2.new(0, 10, 0, 5)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name .. ": " .. tostring(defaultValue)
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = container
    
    local descLabel = Instance.new("TextLabel")
    descLabel.Size = UDim2.new(1, -20, 0, 20)
    descLabel.Position = UDim2.new(0, 10, 0, 30)
    descLabel.BackgroundTransparency = 1
    descLabel.Text = description
    descLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    descLabel.Font = Enum.Font.Gotham
    descLabel.TextSize = 10
    descLabel.TextXAlignment = Enum.TextXAlignment.Left
    descLabel.Parent = container
    
    local slider = Instance.new("Slider")
    slider.Size = UDim2.new(1, -20, 0, 20)
    slider.Position = UDim2.new(0, 10, 0, 55)
    slider.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    slider.BorderSizePixel = 0
    slider.Parent = container
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = slider
    
    slider.Value = defaultValue
    slider.Min = minValue
    slider.Max = maxValue
    
    slider.Changed:Connect(function(property)
        if property == "Value" then
            local newValue = math.floor(slider.Value / step) * step
            slider.Value = newValue
            nameLabel.Text = name .. ": " .. tostring(newValue)
            callback(newValue)
        end
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
        "⚡ Speed Boost",
        "Ativa/Desativa o controle de velocidade",
        ToggleSpeedBoost,
        parent
    )
    
    CreateSlider(
        "🏃 Velocidade",
        "Ajuste a velocidade de corrida (16 = normal)",
        1, -- Super Lento
        100, -- Super Rápido
        originalWalkSpeed,
        1,
        SetSpeedValue,
        parent
    )
end

function CreateFPSTab()
    local parent = menuFrame:FindFirstChild("ScrollingFrame")
    
    -- FPS Boost Ultimate (primeiro)
    CreateToggleButton(
        "🚀 FPS BOOST ULTIMATE (35x)",
        "Ativa TODAS as 35 otimizações de uma vez!",
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

-- Inicializa a velocidade original
if localPlayer.Character then
    local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        originalWalkSpeed = humanoid.WalkSpeed
    end
end

CreateBubbleGUI()

print("╔═══════════════════════════════════════════════════════════╗")
print("║           VGZINSK V3 - MOBILE EDITION                     ║")
print("║           Successfully Loaded!                            ║")
print("║           Click the bubble to open menu                   ║")
print("╚═══════════════════════════════════════════════════════════╝")
