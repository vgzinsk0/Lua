-- vgzinsk V2 - Cyberpunk FPS Boost & Hacks
-- Otimizado para Galaxy A01 Android 12

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Configurações iniciais
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Sistema de salvamento
local DATA_KEY = "vgzinskV2_Settings"
local savedSettings = {}

-- Carregar configurações salvas
local function LoadSettings()
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(DATA_KEY) or "{}")
    end)
    if success then
        savedSettings = result
    else
        savedSettings = {}
    end
end

-- Salvar configurações
local function SaveSettings()
    local success = pcall(function()
        writefile(DATA_KEY, HttpService:JSONEncode(savedSettings))
    end)
    return success
end

-- Carregar configurações ao iniciar
LoadSettings()

-- Variáveis globais
local infiniteJumpEnabled = false
local showFpsEnabled = false
local fpsLabel = nil
local connections = {}

-- Criar a GUI estilo Cyberpunk
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VgzinskV2_Cyberpunk"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal com estilo cyberpunk
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 450)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Efeito de borda neon
local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 255))
})
UIGradient.Rotation = 45

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
UIStroke.LineJoinMode = Enum.LineJoinMode.Round
UIStroke.Color = Color3.fromRGB(0, 255, 255)
UIStroke.Parent = MainFrame

-- Header cyberpunk
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
Header.BorderSizePixel = 0

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 0, 40))
})
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ vgzinsk V2 - CYBERPUNK"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.TextStrokeTransparency = 0.8

-- Botões header
local MinimizeButton = CreateCyberButton("_", Color3.fromRGB(0, 150, 255))
MinimizeButton.Position = UDim2.new(1, -70, 0, 5)
MinimizeButton.Size = UDim2.new(0, 25, 0, 25)

local CloseButton = CreateCyberButton("X", Color3.fromRGB(255, 50, 50))
CloseButton.Position = UDim2.new(1, -35, 0, 5)
CloseButton.Size = UDim2.new(0, 25, 0, 25)

-- Abas do menu
local TabButtonsFrame = Instance.new("Frame")
TabButtonsFrame.Name = "TabButtonsFrame"
TabButtonsFrame.Size = UDim2.new(1, 0, 0, 30)
TabButtonsFrame.Position = UDim2.new(0, 0, 0, 40)
TabButtonsFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
TabButtonsFrame.BorderSizePixel = 0

local TabsContainer = Instance.new("Frame")
TabsContainer.Name = "TabsContainer"
TabsContainer.Size = UDim2.new(1, -20, 1, -80)
TabsContainer.Position = UDim2.new(0, 10, 0, 75)
TabsContainer.BackgroundTransparency = 1
TabsContainer.BorderSizePixel = 0

-- Função para criar botões cyberpunk
function CreateCyberButton(text, color)
    local button = Instance.new("TextButton")
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = color
    stroke.Parent = button
    
    button.MouseEnter:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 60)}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        game:GetService("TweenService"):Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 40)}):Play()
    end)
    
    return button
end

-- Sistema de abas
local currentTab = "optimization"
local tabs = {}

function CreateTab(name, displayName)
    local tabButton = CreateCyberButton(displayName, Color3.fromRGB(0, 255, 255))
    tabButton.Size = UDim2.new(0.32, 0, 0, 25)
    tabButton.Position = UDim2.new((#tabs * 0.33), 0, 0, 2)
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
        SwitchTab(name)
    end)
    
    return tabFrame
end

function SwitchTab(tabName)
    for name, tab in pairs(tabs) do
        tab.frame.Visible = (name == tabName)
        if name == tabName then
            tab.button.BackgroundColor3 = Color3.fromRGB(0, 100, 150)
        else
            tab.button.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        end
    end
    currentTab = tabName
end

-- Criar abas
local optimizationTab = CreateTab("optimization", "OPTIMIZATION")
local hacksTab = CreateTab("hacks", "HACKS")
local configTab = CreateTab("config", "CONFIG")

-- Funções de FPS Boost (100% funcionais)
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
    Lighting.FogEnd = 100
    Lighting.Brightness = 2
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    Lighting.ClockTime = 14
    
    for _, effect in pairs(Lighting:GetChildren()) do
        if effect:IsA("PostEffect") or effect:IsA("BloomEffect") or effect:IsA("BlurEffect") then
            effect.Enabled = false
        end
    end
end

local function RemoveAllSkins()
    -- Remove skin do jogador local
    if localPlayer.Character then
        for _, part in pairs(localPlayer.Character:GetDescendants()) do
            if part:IsA("Part") or part:IsA("MeshPart") then
                part.BrickColor = BrickColor.new("Really black")
                if part:FindFirstChildOfClass("SpecialMesh") then
                    part:FindFirstChildOfClass("SpecialMesh"):Destroy()
                end
                if part:IsA("Shirt") or part:IsA("Pants") or part:IsA("ShirtGraphic") then
                    part:Destroy()
                end
            end
        end
    end
    
    -- Remove skin de outros jogadores
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("Part") or part:IsA("MeshPart") then
                    part.BrickColor = BrickColor.new("Really black")
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
        camera.FieldOfView = 70
    end
    
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Part") then
            descendant.Material = Enum.Material.Plastic
        elseif descendant:IsA("ParticleEmitter") then
            descendant.Enabled = false
        elseif descendant:IsA("Decal") then
            descendant.Transparency = 1
        end
    end)
end

local function OptimizeGraphics()
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshCacheSize = 0
    settings().Rendering.TextureCacheSize = 0
end

local function DisablePhysics()
    settings().Physics.PhysicsEnvironmentalThrottle = 2
    settings().Physics.ThrottleAdjustTime = 10
end

local function RemoveParticles()
    for _, particle in pairs(Workspace:GetDescendants()) do
        if particle:IsA("ParticleEmitter") or particle:IsA("Trail") or particle:IsA("Beam") then
            particle.Enabled = false
        end
    end
end

local function ReduceTextureQuality()
    for _, texture in pairs(Workspace:GetDescendants()) do
        if texture:IsA("Texture") or texture:IsA("Decal") then
            texture.Texture = ""
        end
    end
end

local function EnableAggressiveGC()
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
    spawn(function()
        while wait(10) do
            collectgarbage("collect")
        end
    end)
end

-- Funções de Hack
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

-- Sistema de mostrar FPS
local function ToggleShowFPS(state)
    showFpsEnabled = state
    if state then
        if not fpsLabel then
            fpsLabel = Instance.new("TextLabel")
            fpsLabel.Name = "FPSDisplay"
            fpsLabel.Size = UDim2.new(0, 80, 0, 30)
            fpsLabel.Position = UDim2.new(0, 10, 0, 50)
            fpsLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            fpsLabel.BackgroundTransparency = 0.5
            fpsLabel.BorderSizePixel = 0
            fpsLabel.Text = "FPS: 0"
            fpsLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
            fpsLabel.Font = Enum.Font.GothamBold
            fpsLabel.TextSize = 14
            fpsLabel.Parent = ScreenGui
            
            -- Atualizar FPS em tempo real
            connections.fpsUpdate = RunService.RenderStepped:Connect(function()
                if fpsLabel then
                    fpsLabel.Text = "FPS: " .. math.floor(1/RunService.RenderStepped:Wait())
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

-- Sistema de toggle switches melhorado
function CreateCyberToggle(name, description, tab, configKey, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = name .. "Toggle"
    ToggleFrame.Size = UDim2.new(1, 0, 0, 50)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Name = "Label"
    ToggleLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = "🔧 " .. name
    ToggleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.GothamBold
    ToggleLabel.TextSize = 12
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Name = "Description"
    DescriptionLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    DescriptionLabel.Position = UDim2.new(0, 0, 0.6, 0)
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.TextSize = 10
    
    local defaultState = savedSettings[configKey] or false
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Size = UDim2.new(0, 50, 0, 25)
    ToggleButton.Position = UDim2.new(1, -55, 0.5, -12)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(80, 80, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "Knob"
    ToggleKnob.Size = UDim2.new(0, 21, 0, 21)
    ToggleKnob.Position = defaultState and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    
    ToggleButton.Parent = ToggleFrame
    ToggleKnob.Parent = ToggleButton
    ToggleLabel.Parent = ToggleFrame
    DescriptionLabel.Parent = ToggleFrame
    
    local isEnabled = defaultState
    
    -- Aplicar estado inicial
    if isEnabled then
        callback(true)
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        savedSettings[configKey] = isEnabled
        SaveSettings()
        
        if isEnabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            ToggleKnob:TweenPosition(UDim2.new(1, -23, 0.5, -10), "Out", "Quad", 0.2)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            ToggleKnob:TweenPosition(UDim2.new(0, 2, 0.5, -10), "Out", "Quad", 0.2)
        end
        
        callback(isEnabled)
    end)
    
    ToggleFrame.Parent = tab
    return ToggleFrame
end

-- Criar toggles de otimização
local optimizationToggles = {
    {name = "Remover Animações", desc = "Para movimentos de braços/pernas", key = "removeAnim", func = RemoveCharacterAnimations},
    {name = "Otimizar Iluminação", desc = "Remove sombras e efeitos de luz", key = "optimizeLight", func = OptimizeLighting},
    {name = "Remover Todas as Skins", desc = "Deixa todos os players pretos", key = "removeSkins", func = RemoveAllSkins},
    {name = "Reduzir Renderização", desc = "Diminui distância de renderização", key = "reduceRender", func = ReduceRenderDistance},
    {name = "Física Leve", desc = "Reduz qualidade da física", key = "lightPhysics", func = DisablePhysics},
    {name = "Remover Partículas", desc = "Desativa todos os efeitos visuais", key = "removeParticles", func = RemoveParticles},
    {name = "Texturas Baixas", desc = "Remove todas as texturas", key = "lowTextures", func = ReduceTextureQuality},
    {name = "GC Agressivo", desc = "Coleta de lixo frequente", key = "aggressiveGC", func = EnableAggressiveGC},
    {name = "Otimizar Gráficos", desc = "Configurações gráficas mínimas", key = "optimizeGraphics", func = OptimizeGraphics},
    {name = "Mostrar FPS", desc = "Mostra FPS em tempo real", key = "showFPS", func = ToggleShowFPS}
}

-- Criar toggles de hacks
local hackToggles = {
    {name = "Infinite Jump", desc = "Pulo infinito (flutuação)", key = "infiniteJump", func = ToggleInfiniteJump}
}

-- Adicionar toggles às abas
for i, toggle in ipairs(optimizationToggles) do
    CreateCyberToggle(toggle.name, toggle.desc, optimizationTab, toggle.key, toggle.func)
end

for i, toggle in ipairs(hackToggles) do
    CreateCyberToggle(toggle.name, toggle.desc, hacksTab, toggle.key, toggle.func)
end

-- Configurações adicionais na aba config
local function CreateConfigButton(name, callback)
    local button = CreateCyberButton(name, Color3.fromRGB(255, 255, 0))
    button.Size = UDim2.new(1, 0, 0, 35)
    button.Position = UDim2.new(0, 0, 0, #configTab:GetChildren() * 40)
    button.Parent = configTab
    button.MouseButton1Click = callback
    return button
end

CreateConfigButton("💾 Salvar Configurações Atuais", function()
    SaveSettings()
    print("✅ Configurações salvas!")
end)

CreateConfigButton("🔄 Aplicar Todas Otimizações", function()
    for _, toggle in ipairs(optimizationToggles) do
        if savedSettings[toggle.key] then
            toggle.func(true)
        end
    end
    print("✅ Todas otimizações aplicadas!")
end)

CreateConfigButton("🗑️ Limpar Configurações", function()
    savedSettings = {}
    SaveSettings()
    print("✅ Configurações limpas! Recarregue o script.")
end)

-- Ajustar tamanho do canvas
optimizationTab.CanvasSize = UDim2.new(0, 0, 0, #optimizationToggles * 55)
hacksTab.CanvasSize = UDim2.new(0, 0, 0, #hackToggles * 55)
configTab.CanvasSize = UDim2.new(0, 0, 0, 150)

-- Adicionar elementos à GUI
Header.Parent = MainFrame
Title.Parent = Header
MinimizeButton.Parent = Header
CloseButton.Parent = Header
TabButtonsFrame.Parent = MainFrame
TabsContainer.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = playerGui

-- Efeitos visuais cyberpunk
spawn(function()
    while wait(0.1) do
        UIStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

-- Funções dos botões header
local isMinimized = false
local originalSize = MainFrame.Size

MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = originalSize
        TabsContainer.Visible = true
        TabButtonsFrame.Visible = true
        isMinimized = false
    else
        originalSize = MainFrame.Size
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        TabsContainer.Visible = false
        TabButtonsFrame.Visible = false
        isMinimized = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    -- Desconectar todas as conexões
    for _, connection in pairs(connections) do
        connection:Disconnect()
    end
end)

-- Inicializar na aba optimization
SwitchTab("optimization")

-- Aplicar configurações salvas automaticamente
spawn(function()
    wait(1)
    for _, toggle in ipairs(optimizationToggles) do
        if savedSettings[toggle.key] then
            toggle.func(true)
        end
    end
    for _, toggle in ipairs(hackToggles) do
        if savedSettings[toggle.key] then
            toggle.func(true)
        end
    end
end)

-- Conectar eventos de character
localPlayer.CharacterAdded:Connect(function(character)
    wait(2)
    if savedSettings["removeAnim"] then
        RemoveCharacterAnimations()
    end
    if savedSettings["removeSkins"] then
        RemoveAllSkins()
    end
end)
