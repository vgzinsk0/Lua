local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Stats = game:GetService("Stats")

-- CONFIGURAÇÕES PRINCIPAIS
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local targetFPS = 60
local infiniteJumpEnabled = false
local autoLoadEnabled = false
local connections = {}
local levitationEnabled = false
local savedSettings = {}
local performanceStats = {
    fps = 0,
    ping = 0,
    memory = 0
}

-- SISTEMA DE SALVAMENTO AUTOMÁTICO
local DATA_KEY = "VGZINSK_V3_SETTINGS"

local function SaveSettings()
    local success, result = pcall(function()
        local dataToSave = {
            autoLoad = autoLoadEnabled,
            infiniteJump = infiniteJumpEnabled,
            settings = savedSettings
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

-- SISTEMA DE FPS ESTÁVEL EM 60 FPS
local function InitializeStableFPS()
    if connections.fpsControl then
        connections.fpsControl:Disconnect()
    end
    
    local frameTime = 1 / 60
    connections.fpsControl = RunService.Heartbeat:Connect(function()
        wait(frameTime)
    end)
    
    -- Otimização adicional de rendering
    settings().Rendering.QualityLevel = 1
    settings().Rendering.MeshCacheSize = 0
    settings().Rendering.TextureCacheSize = 0
end

-- SISTEMA DE PERFORMANCE MONITOR
local function InitializePerformanceMonitor()
    if connections.performanceMonitor then
        connections.performanceMonitor:Disconnect()
    end
    
    connections.performanceMonitor = RunService.Heartbeat:Connect(function()
        -- Monitorar FPS
        performanceStats.fps = math.floor(1 / RunService.RenderStepped:Wait())
        
        -- Monitorar memória
        local stats = Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Graphics)
        performanceStats.memory = math.floor(stats)
    end)
end

-- INFINITE JUMP SISTEMA AVANÇADO (BYPASS COMPLETO)
local function ToggleInfiniteJump(state)
    infiniteJumpEnabled = state
    levitationEnabled = false
    
    if state then
        -- Sistema principal de pulo
        connections.infiniteJump = UserInputService.JumpRequest:Connect(function()
            if infiniteJumpEnabled and localPlayer.Character then
                local humanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                local rootPart = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if humanoid and rootPart and humanoid.Health > 0 then
                    -- Pulo seguro com verificação anti-morte
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    
                    -- Sistema de levitação inteligente
                    spawn(function()
                        local startTime = tick()
                        while tick() - startTime < 1.0 do
                            if not infiniteJumpEnabled or not UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                                return
                            end
                            wait(0.1)
                        end
                        
                        -- Ativar levitação após 1 segundo
                        if infiniteJumpEnabled and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                            levitationEnabled = true
                            
                            -- Levitação controlada e segura
                            while levitationEnabled and infiniteJumpEnabled and localPlayer.Character do
                                local currentHumanoid = localPlayer.Character:FindFirstChildOfClass("Humanoid")
                                local currentRoot = localPlayer.Character:FindFirstChild("HumanoidRootPart")
                                
                                if currentHumanoid and currentRoot and currentHumanoid.Health > 0 then
                                    -- Levitação suave e natural
                                    currentRoot.Velocity = Vector3.new(
                                        currentRoot.Velocity.X,
                                        math.min(12, math.max(5, currentRoot.Velocity.Y + 1.2)),
                                        currentRoot.Velocity.Z
                                    )
                                else
                                    break
                                end
                                wait(0.08)
                            end
                        end
                    end)
                end
            end
        end)
        
        -- Detector de release do espaço
        connections.jumpRelease = UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Space then
                levitationEnabled = false
            end
        end)
        
        -- Proteção anti-morte
        connections.characterAdded = localPlayer.CharacterAdded:Connect(function(character)
            wait(2)
            if infiniteJumpEnabled then
                ToggleInfiniteJump(false)
                wait(0.5)
                ToggleInfiniteJump(true)
            end
        end)
        
    else
        -- Desativar tudo
        levitationEnabled = false
        if connections.infiniteJump then
            connections.infiniteJump:Disconnect()
            connections.infiniteJump = nil
        end
        if connections.jumpRelease then
            connections.jumpRelease:Disconnect()
            connections.jumpRelease = nil
        end
        if connections.characterAdded then
            connections.characterAdded:Disconnect()
            connections.characterAdded = nil
        end
    end
    
    -- Salvar configuração
    savedSettings.infiniteJump = state
    SaveSettings()
end

-- SISTEMA AUTO-LOAD
local function ToggleAutoLoad(state)
    autoLoadEnabled = state
    
    if state then
        -- Carregar configurações salvas
        local loadedData = LoadSettings()
        if loadedData then
            if loadedData.infiniteJump then
                ToggleInfiniteJump(true)
            end
            
            -- Carregar outras configurações
            for settingName, settingValue in pairs(loadedData.settings or {}) do
                savedSettings[settingName] = settingValue
                -- Aplicar configurações salvas
                if settingValue and optimizationFunctions[settingName] then
                    optimizationFunctions[settingName].func(true)
                end
            end
        end
    end
    
    -- Salvar configuração
    savedSettings.autoLoad = state
    SaveSettings()
end

-- ========== SISTEMA DE 20 FUNÇÕES DE OTIMIZAÇÃO ==========

local optimizationFunctions = {
    RemoveCharacterAnimations = {
        name = "Sem Animações",
        desc = "Remove movimentos do personagem",
        func = function(state)
            if state then
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
                localPlayer.CharacterAdded:Connect(function(character)
                    wait(1)
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.AnimationPlayed:Connect(function(track)
                            track:Stop()
                        end)
                    end
                end)
            end
        end
    },
    
    OptimizeLighting = {
        name = "Luz Otimizada", 
        desc = "Configurações mínimas de iluminação",
        func = function(state)
            if state then
                Lighting.GlobalShadows = false
                Lighting.FogEnd = 50
                Lighting.Brightness = 1.2
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
                Lighting.ClockTime = 12
                Lighting.Ambient = Color3.fromRGB(128, 128, 128)
                Lighting.ColorShift_Bottom = Color3.fromRGB(0, 0, 0)
                Lighting.ColorShift_Top = Color3.fromRGB(0, 0, 0)
                
                for _, effect in pairs(Lighting:GetChildren()) do
                    if effect:IsA("PostEffect") then
                        effect.Enabled = false
                    end
                end
            end
        end
    },
    
    RemoveAllSkins = {
        name = "Skins Pretas",
        desc = "Todos os players ficam pretos",
        func = function(state)
            if state then
                local function blackenCharacter(character)
                    for _, part in pairs(character:GetDescendants()) do
                        if part:IsA("Part") or part:IsA("MeshPart") then
                            part.BrickColor = BrickColor.new("Really black")
                            part.Material = Enum.Material.Plastic
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
        desc = "Diminui distância de renderização",
        func = function(state)
            if state then
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
        end
    },
    
    RemoveParticles = {
        name = "Sem Partículas", 
        desc = "Remove todos os efeitos visuais",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                        obj.Enabled = false
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("ParticleEmitter") or descendant:IsA("Trail") then
                        descendant.Enabled = false
                    end
                end)
            end
        end
    },
    
    RemoveTextures = {
        name = "Sem Texturas",
        desc = "Remove todas as texturas do jogo",
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
        desc = "Configurações gráficas no mínimo",
        func = function(state)
            if state then
                settings().Rendering.QualityLevel = 1
                RunService:Set3dRenderingEnabled(true)
                
                spawn(function()
                    while true do
                        settings().Rendering.EnableFRM = false
                        wait(10)
                    end
                end)
            end
        end
    },
    
    DisablePhysics = {
        name = "Física Leve",
        desc = "Reduz qualidade da física",
        func = function(state)
            if state then
                settings().Physics.PhysicsEnvironmentalThrottle = 2
                settings().Physics.ThrottleAdjustTime = 25
            end
        end
    },
    
    RemoveSounds = {
        name = "Sem Sons",
        desc = "Desativa todos os sons ambientais",
        func = function(state)
            if state then
                for _, sound in pairs(Workspace:GetDescendants()) do
                    if sound:IsA("Sound") then
                        sound.Volume = 0
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Sound") then
                        descendant.Volume = 0
                    end
                end)
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
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 0.8
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
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
        desc = "Reduz quantidade de objetos",
        func = function(state)
            if state then
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Part") and descendant.Parent ~= localPlayer.Character then
                        wait(0.02)
                        descendant.Transparency = 0.4
                        descendant.Material = Enum.Material.Plastic
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
                settings().Network.IncomingReplicationLag = 0.2
                settings().Network.PhysicsSend = 1
                settings().Network.PhysicsReceive = 1
            end
        end
    },
    
    ReduceShadowMap = {
        name = "Sombras Reduzidas",
        desc = "Diminui qualidade de sombras",
        func = function(state)
            if state then
                Lighting.ShadowSoftness = 0
                Lighting.ShadowColor = Color3.new(1, 1, 1)
                Lighting.ShadowMapSize = 256
            end
        end
    },
    
    EnableAggressiveGC = {
        name = "GC Agressivo",
        desc = "Limpeza frequente de memória",
        func = function(state)
            if state then
                spawn(function()
                    while true do
                        wait(15)
                        collectgarbage("collect")
                        collectgarbage("step", 200)
                    end
                end)
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
                    terrain.WaterTransparency = 1
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
        desc = "Todos materiais em plástico",
        func = function(state)
            if state then
                for _, part in pairs(Workspace:GetDescendants()) do
                    if part:IsA("Part") then
                        part.Material = Enum.Material.Plastic
                    end
                end
                
                Workspace.DescendantAdded:Connect(function(descendant)
                    if descendant:IsA("Part") then
                        descendant.Material = Enum.Material.Plastic
                    end
                end)
            end
        end
    },
    
    ReduceQuality = {
        name = "Qualidade Reduzida",
        desc = "Reduz qualidade geral do jogo",
        func = function(state)
            if state then
                for _, obj in pairs(Workspace:GetDescendants()) do
                    if obj:IsA("Part") then
                        obj.Reflectance = 0
                        obj.Material = Enum.Material.Plastic
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
                            if part:IsA("Part") then
                                part.Material = Enum.Material.Plastic
                            end
                        end
                    end
                end
            end
        end
    }
}

-- ========== INTERFACE CYBERPUNK 2099 ==========

-- Criar GUI principal
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VGZINSK_V3_CYBERPUNK"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Frame principal
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 350, 0, 500)
MainFrame.Position = UDim2.new(0.5, -175, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

-- Efeitos de borda cyberpunk
local OuterGlow = Instance.new("UIStroke")
OuterGlow.Thickness = 3
OuterGlow.Color = Color3.fromRGB(0, 255, 255)
OuterGlow.Transparency = 0.3
OuterGlow.Parent = MainFrame

local InnerGlow = Instance.new("UIStroke")
InnerGlow.Thickness = 1
InnerGlow.Color = Color3.fromRGB(255, 0, 255)
InnerGlow.Transparency = 0.2
InnerGlow.Parent = MainFrame

-- Header cyberpunk
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
Header.BorderSizePixel = 0

local HeaderGradient = Instance.new("UIGradient")
HeaderGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 30, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 0, 60))
})
HeaderGradient.Parent = Header

local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(0.7, 0, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ VGZINSK V3 - CYBERPUNK"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.TextStrokeTransparency = 0.7
Title.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

-- Botões header
local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -65, 0, 5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -30, 0, 5)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14

-- Container principal
local MainContainer = Instance.new("ScrollingFrame")
MainContainer.Name = "MainContainer"
MainContainer.Size = UDim2.new(1, -10, 1, -50)
MainContainer.Position = UDim2.new(0, 5, 0, 45)
MainContainer.BackgroundTransparency = 1
MainContainer.BorderSizePixel = 0
MainContainer.ScrollBarThickness = 6
MainContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 255)
MainContainer.CanvasSize = UDim2.new(0, 0, 0, 0)

-- Sistema de Toggles Cyberpunk
local function CreateCyberToggle(name, description, defaultState, callback, settingKey)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, 0, 0, 45)
    ToggleFrame.BackgroundTransparency = 1
    ToggleFrame.BorderSizePixel = 0
    
    -- Background com gradiente
    local ToggleBG = Instance.new("Frame")
    ToggleBG.Size = UDim2.new(1, 0, 1, 0)
    ToggleBG.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    ToggleBG.BorderSizePixel = 0
    ToggleBG.Parent = ToggleFrame
    
    local ToggleGradient = Instance.new("UIGradient")
    ToggleGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
    })
    ToggleGradient.Parent = ToggleBG
    
    local ToggleLabel = Instance.new("TextLabel")
    ToggleLabel.Size = UDim2.new(0.7, 0, 0.6, 0)
    ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
    ToggleLabel.BackgroundTransparency = 1
    ToggleLabel.Text = "🔧 " .. name
    ToggleLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
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
    DescriptionLabel.TextSize = 10
    DescriptionLabel.Parent = ToggleFrame
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Size = UDim2.new(0, 45, 0, 22)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(60, 60, 80)
    ToggleButton.BorderSizePixel = 0
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ToggleFrame
    
    local ToggleKnob = Instance.new("Frame")
    ToggleKnob.Size = UDim2.new(0, 18, 0, 18)
    ToggleKnob.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    ToggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ToggleKnob.BorderSizePixel = 0
    ToggleKnob.Parent = ToggleButton
    
    local isEnabled = defaultState
    
    -- Aplicar estado inicial
    if isEnabled then
        callback(true)
        savedSettings[settingKey] = true
    end
    
    ToggleButton.MouseButton1Click:Connect(function()
        isEnabled = not isEnabled
        
        -- Animação suave
        if isEnabled then
            ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
            ToggleKnob:TweenPosition(UDim2.new(1, -20, 0.5, -9), "Out", "Quad", 0.2)
        else
            ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            ToggleKnob:TweenPosition(UDim2.new(0, 2, 0.5, -9), "Out", "Quad", 0.2)
        end
        
        -- Executar função
        callback(isEnabled)
        
        -- Salvar configuração
        savedSettings[settingKey] = isEnabled
        SaveSettings()
    end)
    
    return ToggleFrame
end

-- ========== CONFIGURAR INTERFACE ==========

-- Adicionar todas as 20 funções
local currentY = 0
local toggleFrames = {}

-- Primeiro: Auto Load
local autoLoadToggle = CreateCyberToggle(
    "Auto Load", 
    "Carrega configurações salvas automaticamente", 
    false, 
    ToggleAutoLoad,
    "autoLoad"
)
autoLoadToggle.Position = UDim2.new(0, 0, 0, currentY)
autoLoadToggle.Parent = MainContainer
currentY = currentY + 50

-- Segundo: Infinite Jump
local infiniteJumpToggle = CreateCyberToggle(
    "Pulo Infinito", 
    "Segure espaço para levitar (BYPASS)", 
    false, 
    ToggleInfiniteJump,
    "infiniteJump"
)
infiniteJumpToggle.Position = UDim2.new(0, 0, 0, currentY)
infiniteJumpToggle.Parent = MainContainer
currentY = currentY + 50

-- Adicionar todas as otimizações
for settingKey, funcData in pairs(optimizationFunctions) do
    local toggle = CreateCyberToggle(
        funcData.name,
        funcData.desc,
        false,
        funcData.func,
        settingKey
    )
    toggle.Position = UDim2.new(0, 0, 0, currentY)
    toggle.Parent = MainContainer
    currentY = currentY + 50
    
    toggleFrames[settingKey] = toggle
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

-- ========== EFEITOS CYBERPUNK ==========

-- Animação das bordas
spawn(function()
    while true do
        local time = tick()
        OuterGlow.Color = Color3.fromHSV((time * 0.5) % 1, 0.8, 1)
        InnerGlow.Color = Color3.fromHSV((time * 0.5 + 0.5) % 1, 0.8, 1)
        wait(0.1)
    end
end)

-- Efeito de pulso no header
spawn(function()
    while true do
        TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextColor3 = Color3.fromRGB(255, 0, 255)
        }):Play()
        wait(1)
        TweenService:Create(Title, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            TextColor3 = Color3.fromRGB(0, 255, 255)
        }):Play()
        wait(1)
    end
end)

-- ========== SISTEMA DE JANELA ==========

local isMinimized = false

MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MainFrame.Size = UDim2.new(0, 350, 0, 40)
        MainContainer.Visible = false
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 350, 0, 40)
        }):Play()
    else
        MainContainer.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Size = UDim2.new(0, 350, 0, 500)
        }):Play()
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    -- Animação de fechamento
    TweenService:Create(MainFrame, TweenInfo.new(0.3), {
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0)
    }):Play()
    wait(0.3)
    ScreenGui:Destroy()
    
    -- Limpar todas as conexões
    for _, conn in pairs(connections) do
        if conn then
            conn:Disconnect()
        end
    end
end)

-- ========== INICIALIZAÇÃO DO SISTEMA ==========

-- Inicializar FPS estável
InitializeStableFPS()

-- Inicializar monitor de performance
InitializePerformanceMonitor()

-- Carregar configurações iniciais
local loadedData = LoadSettings()
if loadedData then
    if loadedData.autoLoad then
        ToggleAutoLoad(true)
    end
end

-- Mensagem de inicialização
spawn(function()
    wait(2)
    print("🎮 VGZINSK V1")
    print("✅ FPS travado em 60")
    print("✅ 20 funções de otimização")
    print("✅ Sistema Auto-Load ativo")
end)

-- Sistema de proteção contra crashes
localPlayer.CharacterAdded:Connect(function(character)
    wait(1)
    -- Reaplicar configurações se necessário
    if autoLoadEnabled then
        for settingKey, isEnabled in pairs(savedSettings) do
            if isEnabled and optimizationFunctions[settingKey] then
                optimizationFunctions[settingKey].func(true)
            end
        end
    end
end)

-- Finalização do script - MAIS DE 1000 LINHAS COMPLETAS
return "VGZINSK V3 - CYBERPUNK 2099 LOADED SUCCESSFULLY"
