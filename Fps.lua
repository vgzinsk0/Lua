-- VGZINSK V3 - CONFIG PANEL COMPLETE
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Configurações
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local targetFPS = 60
local infiniteJumpEnabled = false
local showFpsEnabled = false
local fpsLabel = nil
local connections = {}
local levitationEnabled = false

-- Sistema de FPS estável
local function SetStableFPS(fps)
    targetFPS = fps
    
    if connections.fpsControl then
        connections.fpsControl:Disconnect()
    end
    
    if fps then
        local frameTime = 1 / fps
        connections.fpsControl = RunService.Heartbeat:Connect(function()
            wait(frameTime)
        end)
    end
end

-- Sistema de FPS display
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
            
            -- Sistema de FPS suave
            local fpsSamples = {}
            connections.fpsUpdate = RunService.RenderStepped:Connect(function()
                if fpsLabel then
                    local currentFPS = math.floor(1 / RunService.RenderStepped:Wait())
                    
                    -- Média móvel para FPS estável
                    table.insert(fpsSamples, currentFPS)
                    if #fpsSamples > 20 then
                        table.remove(fpsSamples, 1)
                    end
                    
                    local total = 0
                    for _, fps in ipairs(fpsSamples) do
                        total = total + fps
                    end
                    local averageFPS = math.floor(total / #fpsSamples)
                    
                    fpsLabel.Text = "FPS: " .. averageFPS
                    
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

-- Infinite Jump CORRIGIDO e seguro
local function ToggleInfiniteJump(state)
    infiniteJumpEnabled = state
    levitationEnabled = false
    
    if state then
        connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart and humanoid.Health > 0 then
                    -- Pulo normal primeiro
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    -- Levitação suave após segurar
                    spawn(function()
                        wait(0.8) -- Tempo reduzido para resposta mais rápida
                        if infiniteJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            levitationEnabled = true
                            
                            while levitationEnabled and infiniteJumpEnabled and localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart") do
                                local currentRoot = localPlayer.Character.HumanoidRootPart
                                -- Levitação controlada e segura
                                currentRoot.Velocity = Vector3.new(
                                    currentRoot.Velocity.X,
                                    math.min(8, currentRoot.Velocity.Y + 1.5), -- Mais suave
                                    currentRoot.Velocity.Z
                                )
                                wait(0.08)
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

-- ========== 18 FUNÇÕES DE OTIMIZAÇÃO ==========

local function RemoveCharacterAnimations()
    if localPlayer.Character then
        local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
                track:Stop()
            end
        end
    end
end

local function OptimizeLighting()
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 80
    Lighting.Brightness = 1.5
    Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
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
        camera.FieldOfView = 70
    end
end

local function RemoveParticles()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
            obj.Enabled = false
        end
    end
end

local function RemoveTextures()
    for _, texture in pairs(Workspace:GetDescendants()) do
        if texture:IsA("Decal") then
            texture.Transparency = 0.8
        end
    end
end

local function OptimizeGraphics()
    settings().Rendering.QualityLevel = 1
end

local function DisablePhysics()
    settings().Physics.PhysicsEnvironmentalThrottle = 1
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
    end
end

local function RemoveGUIEffects()
    for _, gui in pairs(playerGui:GetDescendants()) do
        if gui:IsA("UIStroke") then
            gui.Enabled = false
        end
    end
end

local function LimitPartCount()
    Workspace.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("Part") and descendant.Parent ~= localPlayer.Character then
            descendant.Transparency = 0.2
        end
    end)
end

local function OptimizeNetwork()
    settings().Network.IncomingReplicationLag = 0.2
end

local function ReduceShadowMap()
    Lighting.ShadowSoftness = 0.1
end

local function EnableAggressiveGC()
    spawn(function()
        while true do
            wait(20)
            collectgarbage("collect")
        end
    end)
end

local function RemoveWaterEffects()
    if Workspace:FindFirstChildOfClass("Terrain") then
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0.5
    end
end

local function SimplifyMaterials()
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("Part") then
            part.Material = Enum.Material.Plastic
        end
    end
end

local function ReduceQuality()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") then
            obj.Reflectance = 0
        end
    end
end

-- ========== INTERFACE SIMPLES ==========

-- Criar GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VGZINSK_V3_CONFIG"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 450)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Borda estilo cyberpunk
local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2
UIStroke.Color = Color3.fromRGB(0, 200, 255)
UIStroke.Parent = MainFrame

-- Header
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
Header.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ VGZINSK V3 - CONFIG"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14

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

-- Container principal
local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(1, -10, 1, -45)
MainContainer.Position = UDim2.new(0, 5, 0, 40)
MainContainer.BackgroundTransparency = 1
MainContainer.BorderSizePixel = 0
MainContainer.ScrollBarThickness = 5
MainContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 255)
MainContainer.CanvasSize = UDim2.new(0, 0, 0, 1200)

-- Sistema de Toggles
local function CreateToggle(name, description, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
    ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = name
    ToggleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    ToggleLabel.Font = Enum.Font.Gotham
    ToggleLabel.TextSize = 12
    
    local DescriptionLabel = Instance.new("TextLabel")
    DescriptionLabel.Size = UDim2.new(0.7, 0, 0.4, 0)
    DescriptionLabel.Position = UDim2.new(0, 0, 0.6, 0)
    DescriptionLabel.BackgroundTransparency = 1
    DescriptionLabel.Text = description
    DescriptionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
    DescriptionLabel.TextXAlignment = Enum.TextXAlignment.Left
    DescriptionLabel.Font = Enum.Font.Gotham
    DescriptionLabel.TextSize = 10
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 38, 0, 18)
    ToggleButton.Position = UDim2.new(1, -42, 0.5, -9)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(70, 70, 90)
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
            ToggleButton.BackgroundColor3 = Color3.fromRGB(70, 70, 90)
            ToggleKnob.Position = UDim2.new(0, 2, 0.5, -7)
        end
        callback(isEnabled)
    end)
    
    return ToggleFrame
end

-- Botões de FPS
local function CreateFPSButton(fpsValue)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 30)
    button.Position = UDim2.new(0, 0, 0, #MainContainer:GetChildren() * 35)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
    button.BorderSizePixel = 0
    button.Text = "🎯 " .. fpsValue .. " FPS"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = MainContainer
    
    button.MouseButton1Click:Connect(function()
        SetStableFPS(fpsValue)
        for _, child in pairs(MainContainer:GetChildren()) do
            if child:IsA("TextButton") and child.Text:find("FPS") then
                child.BackgroundColor3 = Color3.fromRGB(45, 45, 65)
            end
        end
        button.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    end)
    
    return button
end

-- ========== CONFIGURAR INTERFACE ==========

-- Lista de todas as 18 funções
local allFunctions = {
    -- FPS Control
    {type = "fps", name = "30 FPS", desc = "FPS mínimo"},
    {type = "fps", name = "60 FPS", desc = "FPS balanceado"},
    {type = "fps", name = "90 FPS", desc = "FPS suave"},
    {type = "fps", name = "120 FPS", desc = "FPS máximo"},
    
    -- Hacks
    {type = "toggle", name = "Pulo Infinito", desc = "Segure para levitar", func = ToggleInfiniteJump},
    {type = "toggle", name = "Mostrar FPS", desc = "Display em tempo real", func = ToggleShowFPS},
    
    -- Otimizações
    {type = "toggle", name = "Sem Animações", desc = "Remove movimentos", func = RemoveCharacterAnimations},
    {type = "toggle", name = "Luz Otimizada", desc = "Iluminação mínima", func = OptimizeLighting},
    {type = "toggle", name = "Skins Pretas", desc = "Todos players pretos", func = RemoveAllSkins},
    {type = "toggle", name = "Render Reduzido", desc = "Menos detalhes", func = ReduceRenderDistance},
    {type = "toggle", name = "Sem Partículas", desc = "Remove efeitos visuais", func = RemoveParticles},
    {type = "toggle", name = "Sem Texturas", desc = "Texturas removidas", func = RemoveTextures},
    {type = "toggle", name = "Gráficos Mínimos", desc = "Qualidade baixa", func = OptimizeGraphics},
    {type = "toggle", name = "Física Leve", desc = "Física otimizada", func = DisablePhysics},
    {type = "toggle", name = "Sem Sons", desc = "Áudio desativado", func = RemoveSounds},
    {type = "toggle", name = "Terreno Simples", desc = "Terreno otimizado", func = SimplifyTerrain},
    {type = "toggle", name = "Sem Efeitos GUI", desc = "Interface limpa", func = RemoveGUIEffects},
    {type = "toggle", name = "Limitar Partes", desc = "Menos objetos", func = LimitPartCount},
    {type = "toggle", name = "Rede Otimizada", desc = "Conexão melhor", func = OptimizeNetwork},
    {type = "toggle", name = "Sombras Reduzidas", desc = "Sombras mínimas", func = ReduceShadowMap},
    {type = "toggle", name = "GC Agressivo", desc = "Limpeza de memória", func = EnableAggressiveGC},
    {type = "toggle", name = "Sem Efeitos Água", desc = "Água simplificada", func = RemoveWaterEffects},
    {type = "toggle", name = "Materiais Simples", desc = "Materiais básicos", func = SimplifyMaterials},
    {type = "toggle", name = "Qualidade Reduzida", desc = "Qualidade mínima", func = ReduceQuality}
}

-- Adicionar elementos à interface
local currentY = 0
for i, funcData in ipairs(allFunctions) do
    if funcData.type == "fps" then
        local button = CreateFPSButton(tonumber(funcData.name:match("%d+")))
        button.Position = UDim2.new(0, 0, 0, currentY)
        currentY = currentY + 35
    elseif funcData.type == "toggle" then
        local toggle = CreateToggle(funcData.name, funcData.desc, false, funcData.func)
        toggle.Position = UDim2.new(0, 0, 0, currentY)
        currentY = currentY + 42
    end
end

-- Ajustar tamanho do container
MainContainer.CanvasSize = UDim2.new(0, 0, 0, currentY + 10)

-- ========== MONTAR INTERFACE ==========

Header.Parent = MainFrame
Title.Parent = Header
MinimizeButton.Parent = Header
CloseButton.Parent = Header
MainContainer.Parent = MainFrame
MainFrame.Parent = ScreenGui
ScreenGui.Parent = playerGui

-- ========== FUNCIONALIDADES ==========

-- Efeito de borda animada
spawn(function()
    while true do
        wait(0.15)
        local hue = (tick() % 5) / 5
        UIStroke.Color = Color3.fromHSV(hue, 0.8, 1)
    end
end)

-- Sistema de janela
local isMinimized = false

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 320, 0, 35)
        MainContainer.Visible = false
    else
        MainFrame.Size = UDim2.new(0, 320, 0, 450)
        MainContainer.Visible = true
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

-- Configuração inicial
SetStableFPS(60)

-- Sistema anti-morte
localPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    if infiniteJumpEnabled then
        ToggleInfiniteJump(false)
        wait(0.3)
        ToggleInfiniteJump(true)
    end
end)

-- Auto-executar FPS display inicial
wait(2)
ToggleShowFPS(true)
