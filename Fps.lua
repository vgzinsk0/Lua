-- vgzinsk V3 - Cyberpunk 2099 FPS Boost
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Configurações
local targetFPS = 60
local infiniteJumpEnabled = false
local showFpsEnabled = false
local fpsLabel = nil
local connections = {}

-- Criar GUI Cyberpunk
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VgzinskV3_Cyberpunk"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal com efeito cyberpunk
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Efeito de borda neon
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.Parent = MainFrame

-- Header cyberpunk
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

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)
MinimizeButton.Position = UDim2.new(1, -55, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
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

-- Container com abas
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Name = "TabButtonsFrame"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 25)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 35)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TabButtonsFrame.BorderSizePixel = 0

local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -10, 1, -70)
TabsContainer.Position = UDim2.new(0, 5, 0, 65)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0

-- Sistema de abas
local currentTab = "optimization"
local tabs = {}

local function CreateTab(name, displayName)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0.33, -2, 1, 0)
    tabButton.Position = UDim2.new((#tabs * 0.33), 0, 0, 0)
    tabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    tabButton.BorderSizePixel = 0
    tabButton.Text = displayName
    tabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
    tabButton.Font = Enum.Font.Gotham
    tabButton.TextSize = 11
    tabButton.Parent = TabButtonsFrame
    
    local tabFrame = Instance.new("ScrollingFrame")
    tabFrame.Name = name .. "Tab"
    tabFrame.Size = UDim2.new(1, 0, 1, 0)
    tabFrame.Position = UDim2.new(0, 0, 0, 0)
    tabFrame.BackgroundTransparency = 1
    tabFrame.BorderSizePixel = 0
    tabFrame.ScrollBarThickness = 3
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
                tab.button.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            end
        end
        currentTab = name
    end)
    
    return tabFrame
end

-- Criar abas
local optimizationTab = CreateTab("optimization", "OPTIMIZE")
local fpsTab = CreateTab("fps", "FPS CONTROL")
local hacksTab = CreateTab("hacks", "HACKS")

-- Funções de Otimização (15 métodos)
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
    Lighting.Brightness = 1.5
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.ClockTime = 12
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") then
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
                end
            end
        end
    end
end

local function ReduceRenderDistance()
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = 60
    end
    
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Part") then
            descendant.Material = Enum.Material.Plastic
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
    runSpawn(function()
        while true do
            settings().Rendering.EnableFRM = false
            wait(5)
        end
    end)
end

local function DisablePhysics()
    settings().Physics.PhysicsEnvironmentalThrottle = 2
    settings().Physics.ThrottleAdjustTime = 15
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
        terrain.WaterTransparency = 1
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
        if descendant:IsA("Part") then
            wait(0.1)
            if descendant.Parent ~= localPlayer.Character then
                descendant.Transparency = 0.5
            end
        end
    end)
end

local function OptimizeNetwork()
    settings().Network.IncomingReplicationLag = 0.5
end

local function ReduceShadowMap()
    Lighting.ShadowSoftness = 0
    Lighting.ShadowColor = Color3.new(1, 1, 1)
end

local function EnableAggressiveGC()
    runSpawn(function()
        while true do
            wait(10)
            collectgarbage("collect")
        end
    end)
end

-- Controle de FPS
local function SetTargetFPS(fps)
    targetFPS = fps
    runSpawn(function()
        while true do
            local currentFPS = 1/RunService.RenderStepped:Wait()
            if currentFPS > targetFPS then
                wait(1/targetFPS)
            end
        end
    end)
end

-- Infinite Jump melhorado para celular
local function ToggleInfiniteJump(state)
    infiniteJumpEnabled = state
    if state then
        connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    else
        if connections.infiniteJump then
            connections.infiniteJump:Disconnect()
            connections.infiniteJump = nil
        end
    end
end

-- Show FPS
local function ToggleShowFPS(state)
    showFpsEnabled = state
    if state then
        fpsLabel = Instance.new("TextLabel")
        fpsLabel.Size = UDim2.new(0, 70, 0, 20)
        fpsLabel.Position = UDim2.new(0, 10, 0, 10)
        fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        fpsLabel.BackgroundTransparency = 0.7
        fpsLabel.Text = "FPS: 0"
        fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        fpsLabel.Font = Enum.Font.GothamBold
        fpsLabel.TextSize = 12
        fpsLabel.Parent = ScreenGui
        
        connections.fpsUpdate = RunService.RenderStepped:Connect(function()
            if fpsLabel then
                fpsLabel.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
            end
        end)
    else
        if fpsLabel then
            fpsLabel:Destroy()
            fpsLabel = nil
        end
        if connections.fpsUpdate then
            connections.fpsUpdate:Disconnect()
            connections.fpsUpdate = nil
        end
    end
end

-- Sistema de Toggles Cyberpunk
function CreateCyberToggle(name, description, tab, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
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
    ToggleLabel.TextSize = 11
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    DescriptionLabel.Position = UDim2.new(0, 0, 0.6, 0)
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.TextSize = 9
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 35, 0, 18)
    ToggleButton.Position = UDim2.new(1, -40, 0.5, -9)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 14, 0, 14)
    ToggleKnob.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
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
            ToggleKnob.Position = UDim2.new(1, -16, 0.5, -7)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            ToggleKnob.Position = UDim2.new(0, 2, 0.5, -7)
        end
        callback(isEnabled)
    end)
    
    ToggleFrame.Parent = tab
    return ToggleFrame
end

-- Botões de FPS
function CreateFPSButton(fpsValue, tab)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, #tab:GetChildren() * 35)
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    button.BorderSizePixel = 0
    button.Text = "🎯 " .. fpsValue .. " FPS"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = tab
    
    button.MouseButton1Click:Connect(function()
        SetTargetFPS(fpsValue)
        for _, child in pairs(tab:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    end)
    
    return button
end

-- Adicionar otimizações
local optimizationToggles = {
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

-- Adicionar toggles de hacks
local hackToggles = {
    {name = "Pulo Infinito", desc = "Segure para flutuar", func = ToggleInfiniteJump},
    {name = "Mostrar FPS", desc = "FPS em tempo real", func = ToggleShowFPS}
}

-- Adicionar elementos às abas
for i, toggle in ipairs(optimizationToggles) do
    local toggleFrame = CreateCyberToggle(toggle.name, toggle.desc, optimizationTab, false, toggle.func)
    toggleFrame.Position = UDim2.new(0, 0, 0, (i-1) * 45)
end

for i, toggle in ipairs(hackToggles) do
    local toggleFrame = CreateCyberToggle(toggle.name, toggle.desc, hacksTab, false, toggle.func)
    toggleFrame.Position = UDim2.new(0, 0, 0, (i-1) * 45)
end

-- Adicionar botões de FPS
local fpsValues = {30, 60, 90, 120}
for i, fps in ipairs(fpsValues) do
    CreateFPSButton(fps, fpsTab)
end

-- Ajustar tamanho dos containers
optimizationTab.CanvasSize = UDim2.new(0, 0, 0, #optimizationToggles * 45)
hacksTab.CanvasSize = UDim2.new(0, 0, 0, #hackToggles * 45)
fpsTab.CanvasSize = UDim2.new(0, 0, 0, #fpsValues * 35)

-- Montar GUI
Header.Parent = MainFrame
Title.Parent = Header
MinimizeButton.Parent = Header
CloseButton.Parent = Header
TabButtonsFrame.Parent = MainFrame
TabsContainer.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = playerGui

-- Efeitos cyberpunk
runSpawn(function()
    while true do
        wait(0.1)
        UIStroke.Color = Color3.fromHSV(tick() % 3 / 3, 1, 1)
    end
end)

-- Funções dos botões
local isMinimized = false

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 320, 0, 35)
        TabButtonsFrame.Visible = false
        TabsContainer.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 400)
        TabButtonsFrame.Visible = true
        TabsContainer.Visible = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    for _, conn in pairs(connections) do
        if conn then
            conn:Disconnect()
        end
    end
end)

-- Inicializar na primeira aba
for tabName, tab in pairs(tabs) do
    tab.frame.Visible = (tabName == "optimization")
    if tabName == "optimization" then
        tab.button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    end
end

-- Conectar eventos de character
localPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    -- Reaplicar otimizações se necessário
end)
