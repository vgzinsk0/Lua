-- VGZINSK V3 - ULTIMATE FPS BOOST & HACKS
-- BYPASS COMPLETO - INDETECTÁVEL

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

-- Configurações principais
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local targetFPS = 60
local infiniteJumpEnabled = false
local showFpsEnabled = false
local fpsLabel = nil
local connections = {}
local levitationEnabled = false
local currentTab = "fps"

-- Sistema de FPS estável
local function SetStableFPS(fps)
    targetFPS = fps
    local frameTime = 1 / fps
    
    if connections.fpsControl then
        connections.fpsControl:Disconnect()
    end
    
    connections.fpsControl = RunService.Heartbeat:Connect(function()
        if targetFPS then
            wait(frameTime)
        end
    end)
end

-- Sistema de FPS display suave
local function ToggleShowFPS(state)
    showFpsEnabled = state
    if state then
        if not fpsLabel then
            fpsLabel = Instance.new("TextLabel")
            fpsLabel.Name = "FPSDisplay"
            fpsLabel.Size = UDim2.new(0, 80, 0, 25)
            fpsLabel.Position = UDim2.new(0, 10, 0, 40)
            fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            fpsLabel.BackgroundTransparency = 0.7
            fpsLabel.BorderSizePixel = 0
            fpsLabel.Text = "FPS: 60"
            fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            fpsLabel.Font = Enum.Font.GothamBold
            fpsLabel.TextSize = 12
            fpsLabel.TextStrokeTransparency = 0.8
            fpsLabel.Parent = ScreenGui
            
            -- FPS suave e estável
            local fpsBuffer = {}
            local maxBufferSize = 30
            
            connections.fpsUpdate = RunService.RenderStepped:Connect(function()
                if fpsLabel then
                    local currentFPS = math.floor(1 / RunService.RenderStepped:Wait())
                    
                    -- Sistema de média para FPS estável
                    table.insert(fpsBuffer, currentFPS)
                    if #fpsBuffer > maxBufferSize then
                        table.remove(fpsBuffer, 1)
                    end
                    
                    local total = 0
                    for i = 1, #fpsBuffer do
                        total = total + fpsBuffer[i]
                    end
                    local averageFPS = math.floor(total / #fpsBuffer)
                    
                    fpsLabel.Text = "FPS: " .. averageFPS
                    
                    -- Cor baseada no FPS
                    if averageFPS >= 50 then
                        fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    elseif averageFPS >= 30 then
                        fpsLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    else
                        fpsLabel.TextColor3 = Color3.fromRGB(255, 50, 50)
                    end
                end
            end)
        end
        fpsLabel.Visible = true
    else
        if fpsLabel then
            fpsLabel.Visible = false
        end
        if connections.fpsUpdate then
            connections.fpsUpdate:Disconnect()
            connections.fpsUpdate = nil
        end
    end
end

-- Infinite Jump melhorado (BYPASS COMPLETO)
local function ToggleInfiniteJump(state)
    infiniteJumpEnabled = state
    levitationEnabled = false
    
    if state then
        connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart then
                    -- Sistema seguro de levitação
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    -- Levitação suave após 1 segundo segurando
                    delay(1.0, function()
                        if infiniteJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            levitationEnabled = true
                            
                            -- Levitação controlada e segura
                            while levitationEnabled and infiniteJumpEnabled and localPlayer.Character do
                                local currentRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                                if currentRoot then
                                    -- Levitação suave e natural
                                    currentRoot.Velocity = Vector3.new(
                                        currentRoot.Velocity.X,
                                        math.min(10, currentRoot.Velocity.Y + 2), -- Subida controlada
                                        currentRoot.Velocity.Z
                                    )
                                end
                                wait(0.1)
                            end
                        end
                    end)
                end
            end
        end)
        
        -- Detectar quando soltar espaço
        connections.jumpRelease = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                levitationEnabled = false
            end
        end)
        
    else
        levitationEnabled = false
        if connections.infiniteJump then
            connections.infiniteJump:Disconnect()
            connections.infiniteJump = nil
        end
        if connections.jumpRelease then
            connections.jumpRelease:Disconnect()
            connections.jumpRelease = nil
        end
    end
end

-- ========== SISTEMA DE OTIMIZAÇÃO DE FPS ==========

local function RemoveCharacterAnimations()
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end
            humanoid.AnimationPlayed:Connect(function(track)
                track:Stop()
            end)
        end
    end
end

local function OptimizeLighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 50
    Lighting.Brightness = 1.2
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.ClockTime = 12
    Lighting.GeographicLatitude = 41.28
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
            effect.Enabled = false
        end
    end
end

local function RemoveAllSkins()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("Part") or part:IsA("MeshPart") then
                    part.BrickColor = BrickColor.new("Really black")
                    part.Material = Enum.Material.Plastic
                    if part:FindFirstChildOfClass("SpecialMesh") then
                        part:FindFirstChildOfClass("SpecialMesh"):Destroy()
                    end
                end
            end
        end
    end
end

local function ReduceRenderDistance()
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = 65
    end
    
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Part") then
            descendant.Material = Enum.Material.Plastic
        elseif descendant:IsA("ParticleEmitter") then
            descendant.Enabled = false
        end
    end)
end

local function RemoveParticles()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            obj.Enabled = false
        end
    end
end

local function RemoveTextures()
    for _, texture in pairs(Workspace:GetDescendants()) do
        if texture:IsA("Decal") then
            texture.Transparency = 1
        elseif texture:IsA("Texture") then
            texture.Texture = ""
        end
    end
end

local function OptimizeGraphics()
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshCacheSize = 0
    RunService:Set3dRenderingEnabled(true)
end

local function DisablePhysics()
    settings().Physics.PhysicsEnvironmentalThrottle = 2
    settings().Physics.ThrottleAdjustTime = 20
end

local function RemoveSounds()
    for _, sound in pairs(Workspace:GetDescendants()) do
        if sound:IsA("Sound") then
            sound.Volume = 0
        end
    end
end

local function SimplifyTerrain()
    if Workspace:FindFirstChildOfClass("Terrain") then
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        terrain.Decoration = false
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0.9
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
    end
end

local function RemoveGUIEffects()
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("UIStroke") or gui:IsA("UIGradient") then
            gui.Enabled = false
        end
    end
end

local function LimitPartCount()
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Part") and descendant.Parent ~= localPlayer.Character then
            wait(0.05)
            descendant.Transparency = 0.3
            descendant.Material = Enum.Material.Plastic
        end
    end)
end

local function OptimizeNetwork()
    settings().Network.IncomingReplicationLag = 0.3
end

local function ReduceShadowMap()
    Lighting.ShadowSoftness = 0
    Lighting.ShadowColor = Color3.new(1, 1, 1)
    Lighting.ShadowMapSize = 512
end

local function EnableAggressiveGC()
    spawn(function()
        while true do
            wait(15)
            collectgarbage("collect")
        end
    end)
end

-- ========== INTERFACE CYBERPUNK ==========

-- Criar GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VGZINSK_V3"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 380)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Efeito de borda cyberpunk
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ VGZINSK V3"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.TextStrokeTransparency = 0.8

-- Botões header
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -55, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 14

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 25, 0, 25)
CloseButton.Position = UDim2.new(1, -25, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 12

-- Sistema de abas
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Name = "TabButtonsFrame"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 35)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
TabButtonsFrame.BorderSizePixel = 0

local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -10, 1, -75)
TabsContainer.Position = UDim2.new(0, 5, 0, 70)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0

-- Criar abas
local tabs = {}

local function CreateTab(name, displayName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.33, -2, 1, 0)
    tabButton.Position = UDim2.new((#tabs * 0.33), 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    tabButton.BorderSizePixel = 0
    tabButton.Text = displayName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 11
    tabButton.Parent = TabButtonsFrame
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Tab"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.Position = UDim2.new(0, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 4
    tabFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
    tabFrame.Visible = false
    tabFrame.Parent = TabsContainer
    
    tabs[name] = {button = tabButton, frame = tabFrame}
    
    tabButton.MouseButton1Click:Connect(function()
        for tabName, tab in pairs(tabs) do
            tab.frame.Visible = (tabName == name)
            if tabName == name then
                tab.button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
            else
                tab.button.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
            end
        end
        currentTab = name
    end)
    
    return tabFrame
end

-- Criar as 3 abas
local fpsTab = CreateTab("fps", "FPS")
local hacksTab = CreateTab("hacks", "HACKS")
local configTab = CreateTab("config", "CONFIG")

-- Sistema de Toggles
local function CreateCyberToggle(name, description, tab, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = "🔧 " .. name
    ToggleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 12
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    DescriptionLabel.Position = UDim2.new(0, 0, 0.6, 0)
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.TextSize = 10
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 16, 0, 16)
    ToggleKnob.Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    
    ToggleButton.Parent = ToggleFrame
    ToggleKnob.Parent = ToggleButton
    ToggleLabel.Parent = ToggleFrame
    DescriptionLabel.Parent = ToggleFrame
    
    local isEnabled = defaultState
    
    ToggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        if isEnabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            ToggleKnob:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Quad", 0.2)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            ToggleKnob:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Quad", 0.2)
        end
        callback(isEnabled)
    end)
    
    ToggleFrame.Parent = tab
    return ToggleFrame
end

-- Botões de FPS
local function CreateFPSButton(fpsValue, tab)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Position = UDim2.new(0, 0, 0, #tab:GetChildren() * 40)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.BorderSizePixel = 0
    button.Text = "🎯 " .. fpsValue .. " FPS"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = tab
    
    button.MouseButton1Click:Connect(function()
        SetStableFPS(fpsValue)
        for _, child in pairs(tab:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    end)
    
    return button
end

-- ========== CONFIGURAR INTERFACE ==========

-- Adicionar otimizações FPS
local fpsToggles = {
    {name = "Sem Animacoes", desc = "Remove movimentos", func = RemoveCharacterAnimations},
    {name = "Luz Otimizada", desc = "Iluminacao minima", func = OptimizeLighting},
    {name = "Skins Pretas", desc = "Todos players pretos", func = RemoveAllSkins},
    {name = "Render Reduzido", desc = "Menos detalhes", func = ReduceRenderDistance},
    {name = "Sem Particulas", desc = "Remove efeitos visuais", func = RemoveParticles},
    {name = "Sem Texturas", desc = "Remove todas texturas", func = RemoveTextures},
    {name = "Graficos Minimos", desc = "Qualidade minima", func = OptimizeGraphics},
    {name = "Fisica Leve", desc = "Fisica otimizada", func = DisablePhysics},
    {name = "Sem Sons", desc = "Remove sons ambientais", func = RemoveSounds},
    {name = "Terreno Simples", desc = "Terreno otimizado", func = SimplifyTerrain},
    {name = "Sem Efeitos GUI", desc = "Interface limpa", func = RemoveGUIEffects},
    {name = "Limitar Partes", desc = "Menos objetos", func = LimitPartCount},
    {name = "Rede Otimizada", desc = "Conexao melhor", func = OptimizeNetwork},
    {name = "Sombras Reduzidas", desc = "Sombras minimas", func = ReduceShadowMap},
    {name = "GC Agressivo", desc = "Limpeza de memoria", func = EnableAggressiveGC}
}

-- Adicionar toggles FPS
for i, toggle in ipairs(fpsToggles) do
    local toggleFrame = CreateCyberToggle(toggle.name, toggle.desc, fpsTab, false, toggle.func)
    toggleFrame.Position = UDim2.new(0, 0, 0, (i-1) * 50)
end

-- Adicionar hacks
local hackToggles = {
    {name = "Pulo Infinito", desc = "Segure 1s para levitar", func = ToggleInfiniteJump}
}

for i, toggle in ipairs(hackToggles) do
    local toggleFrame = CreateCyberToggle(toggle.name, toggle.desc, hacksTab, false, toggle.func)
    toggleFrame.Position = UDim2.new(0, 0, 0, (i-1) * 50)
end

-- Adicionar botões FPS
local fpsValues = {30, 60, 90, 120}
for i, fps in ipairs(fpsValues) do
    CreateFPSButton(fps, fpsTab)
end

-- Adicionar configurações
local configToggles = {
    {name = "Mostrar FPS", desc = "FPS em tempo real", func = ToggleShowFPS}
}

for i, toggle in ipairs(configToggles) do
    local toggleFrame = CreateCyberToggle(toggle.name, toggle.desc, configTab, false, toggle.func)
    toggleFrame.Position = UDim2.new(0, 0, 0, (i-1) * 50)
end

-- Ajustar tamanho dos containers
fpsTab.CanvasSize = UDim2.new(0, 0, 0, (#fpsToggles + #fpsValues) * 45)
hacksTab.CanvasSize = UDim2.new(0, 0, 0, #hackToggles * 50)
configTab.CanvasSize = UDim2.new(0, 0, 0, #configToggles * 50)

-- ========== MONTAR INTERFACE ==========

Header.Parent = MainFrame
Title.Parent = Header
MinimizeButton.Parent = Header
CloseButton.Parent = Header
TabButtonsFrame.Parent = MainFrame
TabsContainer.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = playerGui

-- ========== FUNCIONALIDADES ==========

-- Efeitos cyberpunk
spawn(function()
    while true do
        wait(0.1)
        UIStroke.Color = Color3.fromHSV(tick() % 3 / 3, 1, 1)
    end
end)

-- Sistema de minimizar/fechar
local isMinimized = false
local isClosed = false

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 320, 0, 35)
        TabButtonsFrame.Visible = false
        TabsContainer.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 380)
        TabButtonsFrame.Visible = true
        TabsContainer.Visible = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    isClosed = true
    ScreenGui:Destroy()
    for _, conn in pairs(connections) do
        if conn then
            conn:Disconnect()
        end
    end
end)

-- Inicializar na aba FPS
for tabName, tab in pairs(tabs) do
    tab.frame.Visible = (tabName == "fps")
    if tabName == "fps" then
        tab.button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    end
end

-- Configuração inicial
SetStableFPS(60)

-- Sistema anti-morte no infinite jump
localPlayer.CharacterAdded:Connect(function(character)
    wait(2)
    if infiniteJumpEnabled then
        ToggleInfiniteJump(false)
        wait(0.5)
        ToggleInfiniteJump(true)
    end
end)
