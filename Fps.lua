-- vgzinsk V1 - FPS Boost Script
-- Otimizado para dispositivos fracos (Galaxy A01 Android 12)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Configurações iniciais
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Criar a GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VgzinskV1"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Header do painel
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 30)
Header.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "vgzinsk V1 - FPS Boost"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

-- Botão minimizar
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -60, 0, 0)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16

-- Botão fechar
local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14

-- Container de botões
local ButtonsContainer = Instance.new("ScrollingFrame")
ButtonsContainer.Name = "ButtonsContainer"
ButtonsContainer.Size = UDim2.new(1, -20, 1, -50)
ButtonsContainer.Position = UDim2.new(0, 10, 0, 40)
ButtonsContainer.BackgroundTransparency = 1
ButtonsContainer.BorderSizePixel = 0
ButtonsContainer.ScrollBarThickness = 4
ButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, 600)

-- Variáveis de estado
local isMinimized = false
local originalSize = MainFrame.Size
local originalPosition = MainFrame.Position

-- Funções de otimização de FPS
local function RemoveCharacterAnimations()
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            -- Remove animações padrão
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end
            
            -- Previne novas animações
            humanoid.AnimationPlayed:Connect(function(track)
                track:Stop()
            end)
        end
    end
end

local function OptimizeLighting()
    -- Configurações de iluminação para melhor performance
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1000
    Lighting.Brightness = 2
    Lighting.GeographicLatitude = 41.733
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    
    -- Remove efeitos visuais pesados
    if Lighting:FindFirstChild("Blur") then
        Lighting.Blur:Destroy()
    end
    if Lighting:FindFirstChild("ColorCorrection") then
        Lighting.ColorCorrection:Destroy()
    end
    if Lighting:FindFirstChild("SunRays") then
        Lighting.SunRays:Destroy()
    end
end

local function OptimizeGraphics()
    -- Reduz qualidade gráfica
    settings().Rendering.QualityLevel = 1
    
    -- Otimiza workspace
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
            descendant.Enabled = false
        end
    end)
end

local function RemovePlayerSkin()
    if localPlayer.Character then
        -- Remove roupas e acessórios
        for _, item in pairs(localPlayer.Character:GetChildren()) do
            if item:IsA("Accessory") or item:IsA("Clothing") then
                item:Destroy()
            end
        end
        
        -- Simplifica partes do corpo (mantém apenas o essencial)
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        end
    end
end

local function ReduceRenderDistance()
    -- Reduz distância de renderização
    local camera = Workspace.CurrentCamera
    if camera then
        camera.FieldOfView = 70
    end
    
    -- Configurações de renderização
    RunService:Set3dRenderingEnabled(true)
    RunService.RenderStepped:Wait()
end

local function DisablePhysics()
    -- Reduz qualidade da física
    settings().Physics.PhysicsEnvironmentalThrottle = 2
    settings().Physics.ThrottleAdjustTime = 10
end

local function OptimizeParticles()
    -- Desativa partículas
    for _, particle in pairs(Workspace:GetDescendants()) do
        if particle:IsA("ParticleEmitter") then
            particle.Enabled = false
        end
    end
end

local function ReduceTextureQuality()
    -- Reduz qualidade de texturas
    for _, texture in pairs(Workspace:GetDescendants()) do
        if texture:IsA("Texture") then
            texture.Texture = ""
        end
    end
end

local function EnableAggressiveGC()
    -- Coleta de lixo agressiva
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200)
end

-- Sistema de toggle switches
local function CreateToggleSwitch(name, description, defaultState, callback)
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
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 12
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Name = "Description"
    DescriptionLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    DescriptionLabel.Position = UDim2.new(0, 0, 0.6, 0)
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.TextSize = 10
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "Toggle"
    ToggleButton.Size = UDim2.new(0, 40, 0, 20)
    ToggleButton.Position = UDim2.new(1, -45, 0.5, -10)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(80, 80, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Name = "Knob"
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
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            ToggleKnob:TweenPosition(UDim2.new(1, -18, 0.5, -8), "Out", "Quad", 0.2)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
            ToggleKnob:TweenPosition(UDim2.new(0, 2, 0.5, -8), "Out", "Quad", 0.2)
        end
        
        callback(isEnabled)
    end)
    
    return ToggleFrame
end

-- Adicionar elementos à GUI
Header.Parent = MainFrame
Title.Parent = Header
MinimizeButton.Parent = Header
CloseButton.Parent = Header
ButtonsContainer.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = playerGui

-- Criar botões de toggle
local toggles = {
    {
        name = "Remover Animações",
        description = "Remove movimentos de braços/pernas",
        default = true,
        callback = function(state)
            if state then
                RemoveCharacterAnimations()
            end
        end
    },
    {
        name = "Otimizar Iluminação",
        description = "Reduz sombras e efeitos de luz",
        default = true,
        callback = OptimizeLighting
    },
    {
        name = "Remover Skin",
        description = "Remove roupas e acessórios",
        default = true,
        callback = function(state)
            if state then
                RemovePlayerSkin()
            end
        end
    },
    {
        name = "Reduzir Renderização",
        description = "Diminui distância de renderização",
        default = true,
        callback = ReduceRenderDistance
    },
    {
        name = "Física Leve",
        description = "Reduz qualidade da física",
        default = true,
        callback = DisablePhysics
    },
    {
        name = "Remover Partículas",
        description = "Desativa todos os efeitos de partículas",
        default = true,
        callback = OptimizeParticles
    },
    {
        name = "Texturas Baixas",
        description = "Reduz qualidade das texturas",
        default = false,
        callback = ReduceTextureQuality
    },
    {
        name = "GC Agressivo",
        description = "Coleta de lixo mais frequente",
        default = true,
        callback = EnableAggressiveGC
    },
    {
        name = "Otimizar Gráficos",
        description = "Configurações gráficas mínimas",
        default = true,
        callback = OptimizeGraphics
    }
}

-- Adicionar toggles ao container
for i, toggleConfig in ipairs(toggles) do
    local toggle = CreateToggleSwitch(
        toggleConfig.name,
        toggleConfig.description,
        toggleConfig.default,
        toggleConfig.callback
    )
    toggle.Position = UDim2.new(0, 0, 0, (i-1) * 55)
    toggle.Parent = ButtonsContainer
    
    -- Ativar função se estiver ativado por padrão
    if toggleConfig.default then
        toggleConfig.callback(true)
    end
end

-- Atualizar tamanho do canvas
ButtonsContainer.CanvasSize = UDim2.new(0, 0, 0, #toggles * 55)

-- Funções dos botões
MinimizeButton.MouseButton1Click:Connect(function()
    if isMinimized then
        MainFrame.Size = originalSize
        ButtonsContainer.Visible = true
        isMinimized = false
    else
        originalSize = MainFrame.Size
        originalPosition = MainFrame.Position
        MainFrame.Size = UDim2.new(0, 300, 0, 30)
        ButtonsContainer.Visible = false
        isMinimized = true
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Aplicar otimizações iniciais
wait(1)
RemoveCharacterAnimations()
OptimizeLighting()
RemovePlayerSkin()

-- Conectar eventos para quando o personagem respawnar
localPlayer.CharacterAdded:Connect(function(character)
    wait(1) -- Esperar character carregar
    RemoveCharacterAnimations()
    RemovePlayerSkin()
end)

print("vgzinsk V1 - FPS Boost carregado com sucesso!")
print("Painel arrastável ativo - Use para controlar as otimizações")
