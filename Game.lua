local UIS = game:GetService('UserInputService')
local RS = game:GetService('RunService')
local Players = game:GetService('Players')
local StarterGui = game:GetService('StarterGui')
local Player = Players.LocalPlayer
local Studio = RS:IsStudio()
local PlayerGui = RS:IsStudio() and Player:WaitForChild('PlayerGui') or game.CoreGui
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera
targetpart = 'Head' -- Don't change this.
-- It can be changed with the targetpart_change hotkey ingame.
local target
local target_old
local alert = false
local lockedon = false
local val = 1
local windows = {}
local function hb() RS.Heartbeat:wait() end
 
local version = 1.12
 
Mouse.TargetFilter = Camera
 
-- hotkey
toggle_aim = Enum.UserInputType.MouseButton2
toggle_aimbot = Enum.KeyCode.LeftAlt
toggle_trigger = Enum.KeyCode.RightAlt
toggle_esp = Enum.KeyCode.End
-- aim fov
fov_increase = Enum.KeyCode.KeypadPlus
fov_decrease = Enum.KeyCode.KeypadMinus
-- aim sens (how smooth your crosshair will move)
sens_increase = Enum.KeyCode.RightBracket
sens_decrease = Enum.KeyCode.LeftBracket
-- aim part
targetpart_change = Enum.KeyCode.BackSlash
 
textSet = false
 
-- aim
fov = 5
sens = 1
aim_toggled = false
aim_priority = 'FOV'
-- FOV or Distance
aimingcolor = Color3.fromRGB(0,165,255)
aimbot_toggled = true
aim_line = true
locksoundid = 538769304
 
-- trigger
trigger_toggled = false
trigger_delay = 1/20
 
-- esp
esp_toggled = true
esp_bones = true
-- esp_chams (coming soon)
-- item_esp (coming soon)
linesize = 1
showdists = true
textsize = 14
textoffset = 20
visiblecolor = Color3.fromRGB(38,255,99)
hiddencolor = Color3.fromRGB(255,37,40)
headboxsize = 4
headboxaimsize = 6
headboxshape = 'diamond'
-- rectangle or diamond
 
-- box esp
bounding_box = false
box_pointsize = 0
box_line_size = 1
box_line_size_visible = 2
 
-- parts
parts = {
    'Head';
    'Torso'
}
 
local GUI = Instance.new('ScreenGui',PlayerGui)
GUI.ResetOnSpawn = false
local Status = Instance.new('TextLabel',GUI)
Status.Name = 'Status'
Status.BackgroundTransparency = 1
Status.Size = UDim2.new(0,500,0,50)
Status.Position = UDim2.new(.5,-250,.85,0)
Status.TextSize = 24
Status.Font = Enum.Font.SourceSansBold
Status.TextColor3 = Color3.new(1,1,1)
Status.TextStrokeColor3 = Color3.new(0,0,0)
Status.TextStrokeTransparency = .6
Status.Text = 'On Standby'
Status.ZIndex = 50
 
local Credits = Status:Clone()
Credits.Name = 'Credits'
Credits.Parent = GUI
Credits.Position = UDim2.new(.5,-250,.85,-20)
Credits.TextSize = 16
Credits.Text = 'GameSense '..version..' Sense'
 
if fov>0 then
FovGui = Instance.new('ImageLabel',GUI)
FovGui.Name = 'FovGui'
FovGui.Image = 'rbxassetid://304079274'
FovGui.Size = UDim2.new(0,(Camera.ViewportSize.X/(90/fov))*2,0,(Camera.ViewportSize.X/(90/fov))*2)
FovGui.Position = UDim2.new(0.5,-FovGui.AbsoluteSize.X/2,0.5,-FovGui.AbsoluteSize.Y/2)
FovGui.BackgroundTransparency = 1
FovGui.ImageTransparency = .5
FovGui.ImageColor3 = Color3.new(1,0,0)
end
 
local n = 0
 
spawn(function()
    while Status do
        if not textSet then
        if aim_toggled and target then
            Status.TextColor3 = aimingcolor
            Status.Text = ('Aiming at '..target.Name)
            if GUI:FindFirstChild('FovGui') then
                GUI.FovGui.ImageColor3 = Status.TextColor3
            end
        else
            Status.TextColor3 = Color3.fromHSV(n,.4,1)
            Status.Text = 'On Standby'
            if GUI:FindFirstChild('FovGui') then
                GUI.FovGui.ImageColor3 = Status.TextColor3
            end
            n = (n+.005)%1
        end
        end
        hb()
    end
end)
 
local function setText(text)
    spawn(function()
    textSet = true
    Status.Text = text
    Status.TextColor3 = Color3.new(1,1,1)
    wait(#text/4)
    textSet = false
    end)
end
 
local function playsound(id)
    local sound = Instance.new('Sound',Camera)
    sound.SoundId = 'rbxassetid://'..id
    sound.Volume = 3
    sound:Play()
    game:GetService('Debris'):AddItem(sound,1)
end
 
local function Notification(...)
    playsound(140910211)
    StarterGui:SetCore('SendNotification',...)
end
 
local function DrawLine(Folder,P1,P2,Thickness,Color,LineTransparency,BorderThickness,BorderColor)
    -- Declare variables
    local Point1,Point2 = P1.Position,P2.Position
    if Point1 and Point2 then
    local X,Y = Camera.ViewportSize.X, Camera.ViewportSize.Y
    local X1,X2 = (X * Point1.X.Scale + Point1.X.Offset + P1.Size.X.Offset/2), (X * Point2.X.Scale + Point2.X.Offset + P2.Size.X.Offset/2)
    local Y1,Y2 = (Y * Point1.Y.Scale + Point1.Y.Offset + P1.Size.Y.Offset/2), (Y * Point2.Y.Scale + Point2.Y.Offset + P2.Size.Y.Offset/2)
    local MidX,MidY = (X1+X2)/2, (Y1+Y2)/2
    -- Set defaults to prevent errors
    Thickness = type(Thickness)=='number' and Thickness or 1
    Color = type(Color)=='userdata' and Color or Color3.new(1,1,1)
    LineTransparency = type(LineTransparency)=='number' and LineTransparency or 0
    BorderThickness = type(BorderThickness)=='number' and BorderThickness or 0
    BorderColor = type(BorderColor)=='userdata' and BorderColor or Color3.new(0,0,0)
    -- Draw the line
    local Line = Folder:FindFirstChild(P1.Name..'-'..P2.Name) or Instance.new('Frame',Folder)
    Line.BackgroundTransparency = LineTransparency
    Line.BorderSizePixel = BorderThickness
    Line.BorderColor3 = BorderColor
    Line.Size = UDim2.new(0,(Vector2.new(X1,Y1) - Vector2.new(X2,Y2)).magnitude-1,0,Thickness)
    Line.Position = UDim2.new(0,MidX-Line.AbsoluteSize.X/2,0,MidY-Line.AbsoluteSize.Y)
    Line.BackgroundColor3 = Color
    Line.Rotation = math.deg(math.atan2((Y2-Y1),(X2-X1)))
    Line.Name = P1.Name..'-'..P2.Name
    return Line
    else
        return nil
    end
end
 
local function GetNearest(Mode)
    local lowest,nearest,gui = math.huge,nil,nil
    if Mode=='Distance' then
    for _,plr in next,Players:GetPlayers() do 
        if plr.Name~=Player.Name and plr.TeamColor~=Player.TeamColor and plr.Character:FindFirstChild(targetpart) then
            local dist = Player:DistanceFromCharacter(plr.Character[targetpart].Position)
            local ray = Ray.new(Player.Character[targetpart].Position,(plr.Character[targetpart].Position-Player.Character[targetpart].Position).unit*2048)
            local part,point = workspace:FindPartOnRayWithIgnoreList(ray,{Camera,Player.Character,unpack(windows)})
            local Z = Camera:WorldToScreenPoint(plr.Character[targetpart].Position).Z
            if part and part:IsDescendantOf(plr.Character) and Z>0 and dist < lowest then lowest = dist nearest = plr.Character end
        end
    end
    elseif Mode=='FOV' then
        for _,plr in next,Players:GetPlayers() do
            if plr.Name~=Player.Name and plr.TeamColor~=Player.TeamColor and plr.Character:FindFirstChild(targetpart) then
                local pos = Camera:WorldToScreenPoint(plr.Character[targetpart].Position)
                local ray = Ray.new(Player.Character[targetpart].Position,(plr.Character[targetpart].Position-Player.Character[targetpart].Position).unit*2048)
                local part,point = workspace:FindPartOnRayWithIgnoreList(ray,{Camera,Player.Character,unpack(windows)})
                local dist = (Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(pos.X,pos.Y)).magnitude
                if part and part:IsDescendantOf(plr.Character) and pos.Z>0 and dist <= Camera.ViewportSize.X/(90/fov) and dist < lowest then lowest = dist nearest = plr.Character end
            end
        end
    end
    return nearest
end
 
Mouse.Move:Connect(function()
    cursor = ESP:FindFirstChild('Cursor') or Instance.new('Frame',ESP)
    cursor.Name = 'Cursor'
    cursor.BackgroundTransparency = 1
    cursor.Size = UDim2.new(0,1,0,1)
    cursor.Position = UDim2.new(0,Mouse.X,0,Mouse.Y)
end)
 
UIS.InputBegan:Connect(function(Input)
    if Input.KeyCode == toggle_aim or Input.UserInputType == toggle_aim then
        aim_toggled = true
        warn('aim toggled',aim_toggled and 'on' or 'off')
        alert = true
        while aim_toggled and aimbot_toggled do
            target = GetNearest(aim_priority) or nil
            if target then
            local headpos = Camera:WorldToScreenPoint(target[targetpart].Position)
            local moveto = Vector2.new((headpos.X-Mouse.X)*sens,(headpos.Y-Mouse.Y)*sens)
            mousemoverel(moveto.X,moveto.Y)
            if alert or target~=target_old then
                playsound(locksoundid)
                print(target.Name)
                lockedon = true
                alert = false
            end
            end
            game:service'RunService'.Heartbeat:wait()
            target_old = target
        end
        lockedon = false
    elseif Input.KeyCode == toggle_trigger then
        trigger_toggled = not trigger_toggled
        setText('Toggled TriggerBot '..(trigger_toggled and 'On' or 'Off'))
        Notification({Title='TriggerBot';Text='TriggerBot was toggled '..(trigger_toggled and 'On' or 'Off');Duration=2;})
        warn('trigger toggled',trigger_toggled and 'on' or 'off')
        local Box = Instance.new('SelectionBox',PlayerGui)
        Box.Color3 = Color3.new(1,0,0)
        Box.LineThickness = .05
        Box.Adornee = nil
        if trigger_delay>0 then wait(trigger_delay) end
        while trigger_toggled do
        local Target = Mouse.Target
        local Char = Target and Target.Name == targetpart and Players:GetPlayerFromCharacter(Target.Parent)
        if Target and Target.Parent and Char and Char.TeamColor~=Player.TeamColor then
            Box.Adornee = Mouse.Target
            mouse1press()
            wait()
            mouse1release()
        end
        game:service'RunService'.Heartbeat:wait()
        end
        Box:Destroy()
    elseif Input.KeyCode == toggle_esp then
        esp_toggled = not esp_toggled
        Notification({Title='ESP';Text='ESP was toggled '..(esp_toggled and 'On' or 'Off');Duration=2;})
        setText('Toggled ESP '..(esp_toggled and 'On' or 'Off'))
    elseif Input.KeyCode == toggle_aimbot then
        aimbot_toggled = not aimbot_toggled 
        Notification({Title='AimBot';Text='AimBot was toggled '..(aimbot_toggled and 'On' or 'Off');Duration=2;})
        setText('Toggled AimBot '..(aimbot_toggled and 'On' or 'Off'))
    elseif Input.KeyCode == fov_increase then
        fov = fov + .5
        if FovGui~=nil then
            FovGui.Size = UDim2.new(0,(Camera.ViewportSize.X/(90/fov))*2,0,(Camera.ViewportSize.X/(90/fov))*2)
            FovGui.Position = UDim2.new(0.5,-FovGui.AbsoluteSize.X/2,0.5,-FovGui.AbsoluteSize.Y/2)
        end
        Notification({Title='FOV';Text='FOV increased to '..fov;Duration=2;})
        setText('Aim FOV: '..fov)
    elseif Input.KeyCode == fov_decrease then
        fov = fov - .5
        if FovGui~=nil then
            FovGui.Size = UDim2.new(0,(Camera.ViewportSize.X/(90/fov))*2,0,(Camera.ViewportSize.X/(90/fov))*2)
            FovGui.Position = UDim2.new(0.5,-FovGui.AbsoluteSize.X/2,0.5,-FovGui.AbsoluteSize.Y/2)
        end
        Notification({Title='FOV';Text='FOV decreased to '..fov;Duration=2;})
        setText('Aim FOV: '..fov)
    elseif Input.KeyCode == sens_increase then
        sens = sens + .1
        Notification({Title='Sensitivity';Text='Sens increased to '..sens;Duration=2;})
        setText('Sens: '..sens)
    elseif Input.KeyCode == sens_decrease then
        sens = sens - .1    
        Notification({Title='Sensitivity';Text='Sens decreased to '..sens;Duration=2;})
        setText('Sens: '..sens)
    elseif Input.KeyCode == targetpart_change then
        val = val+1
        targetpart = val<=#parts and parts[val] or parts[1]
        if parts[1]==targetpart then val = 1 end
        Notification({Title='Target Part';Text='Target part set to '..targetpart;Duration=2;})
        setText('Target Part: '..targetpart)
    end
end)
 
UIS.InputEnded:Connect(function(Input)
    if Input.KeyCode == toggle_aim or Input.UserInputType == toggle_aim then
        aim_toggled = false
    end
end)
 
ESP = Instance.new('Folder',GUI)
ESP.Name = 'ESP'
local Bottom = Instance.new('Frame',ESP)
Bottom.Name = 'Bottom'
Bottom.BackgroundTransparency = 1
Bottom.Size = UDim2.new(0,1,0,1)
Bottom.Position = UDim2.new(.5,0,1,1)
 
RS:BindToRenderStep('bind',1,function()
    if esp_toggled then
    for _,v in next,ESP:children() do
        if v~=Bottom and not Players:FindFirstChild(v.Name) then
            v:Destroy()
        end
    end
    for _,v in next,Players:GetPlayers() do
        local Char = v.Character
        if Char and v~=Player and v.TeamColor~=Player.TeamColor 
        and Char:FindFirstChild(targetpart) and Player:DistanceFromCharacter(Char:FindFirstChild(targetpart).Position)<600 then
            local X = Camera:GetPartsObscuringTarget({Camera.CFrame.p,Char[targetpart].CFrame.p},{v.Character,Char,Camera,unpack(windows)})
            local Dist = Player:DistanceFromCharacter(Char:FindFirstChild(targetpart).Position)
            local Color = hiddencolor
            local Folder = ESP:FindFirstChild(v.Name) or Instance.new('Folder',ESP)
            Folder.Name = v.Name
            -- ESP
            local Head = Folder:FindFirstChild('Head') or Instance.new('Frame',Folder)
            Head.Name = 'Head'
            Head.BorderSizePixel = 1
            Head.BorderColor3 = Color3.new(0,0,0)
            Head.BackgroundTransparency = 0
            Head.BackgroundColor3 = #X>0 and hiddencolor or #X==0 and visiblecolor
            Head.Rotation = headboxshape=='diamond' and 45 or 0
            Head.ZIndex = 3
            local HP = Folder:FindFirstChild('HP') or Instance.new('TextLabel',Folder)
            HP.Name = 'HP'
            HP.BackgroundTransparency = 1
            HP.Text = showdists and Char.Name..'\n'..math.floor(Dist+.5) or Char.Name
            HP.TextSize = 14
            HP.TextTransparency = Head.BackgroundTransparency-.4
            HP.Font = Enum.Font.SourceSansBold
            HP.TextStrokeTransparency = .6
            HP.Size = UDim2.new(0,headboxsize,0,headboxsize)
            if aim_toggled and target==Char then
                Head.Size = UDim2.new(0,headboxaimsize,0,headboxaimsize)
                Head.BackgroundColor3 = aimingcolor
                HP.Text = showdists and '['..Char.Name..']'..'\n'..math.floor(Dist+.5) or '['..Char.Name..']'
                HP.TextSize = 16
            else
                Head.Size = UDim2.new(0,headboxsize,0,headboxsize)
            end
            HP.TextColor3 = Head.BackgroundColor3
            local toScreen = Camera:WorldToScreenPoint(Char[targetpart].CFrame.p)
            if #X==0 then Color = visiblecolor end
            Head.Position = UDim2.new(0,toScreen.X-Head.Size.X.Offset/2,0,toScreen.Y-Head.Size.Y.Offset/2)
            HP.Position = Head.Position-UDim2.new(0,0,0,textoffset)
            local Line = DrawLine(Folder,ESP.Bottom,Head,linesize,Head.BackgroundColor3,.75,1,Color3.new(0,0,0))
            if toScreen.Z<=0 then Head.Visible = false else Head.Visible = true end
            Line.Visible = Head.Visible
            HP.Visible = Head.Visible
            local Neck = Folder:FindFirstChild('Neck') or Instance.new('Frame',Folder)
            Neck.Name = 'Neck'
            Neck.ZIndex = 2
            if Char['Torso']~=nil then
            local Pos = (Char.Torso.CFrame*CFrame.new(0,.8,0)).p
            local X,Y,Z = Camera:WorldToScreenPoint(Pos).X,Camera:WorldToScreenPoint(Pos).Y,Camera:WorldToScreenPoint(Pos).Z
            Neck.Position = UDim2.new(0,X,0,Y)
            Neck.BorderSizePixel = 0
            if Z<=0 then Neck.Visible = false else Neck.Visible = true end
            else
                Neck.Visible = false
            end
            --
            local Pelvis = Folder:FindFirstChild('Pelvis') or Instance.new('Frame',Folder)
            Pelvis.Name = 'Pelvis'
            Pelvis.ZIndex = 2
            Pelvis.BorderSizePixel = 0
            if Char['Torso']~=nil then
            local Pos = (Char.Torso.CFrame*CFrame.new(0,-1,0)).p
            local X,Y,Z = Camera:WorldToScreenPoint(Pos).X,Camera:WorldToScreenPoint(Pos).Y,Camera:WorldToScreenPoint(Pos).Z
            Pelvis.Position = UDim2.new(0,X,0,Y)
            if Z<=0 then Pelvis.Visible = false else Pelvis.Visible = true end
            else
                Pelvis.Visible = false
            end
            --
            local RightFoot = Folder:FindFirstChild('Right Foot') or Instance.new('Frame',Folder)
            RightFoot.Name = 'Right Foot'
            RightFoot.ZIndex = 2
            RightFoot.BorderSizePixel = 0
            if Char['Right Leg']~=nil then
            local Pos = (Char['Right Leg'].CFrame*CFrame.new(0,-1,0)).p
            local X,Y,Z = Camera:WorldToScreenPoint(Pos).X,Camera:WorldToScreenPoint(Pos).Y,Camera:WorldToScreenPoint(Pos).Z
            RightFoot.Position = UDim2.new(0,X,0,Y)
            if Z<=0 then RightFoot.Visible = false else RightFoot.Visible = true end
            else
                RightFoot.Visible = false
            end
            --
            local LeftFoot = Folder:FindFirstChild('Left Foot') or Instance.new('Frame',Folder)
            LeftFoot.Name = 'Left Foot'
            if Char['Left Leg']~=nil then
            local Pos = (Char['Left Leg'].CFrame*CFrame.new(0,-1,0)).p
            local X,Y,Z = Camera:WorldToScreenPoint(Pos).X,Camera:WorldToScreenPoint(Pos).Y,Camera:WorldToScreenPoint(Pos).Z
            LeftFoot.Position = UDim2.new(0,X,0,Y)
            LeftFoot.BorderSizePixel = 0
            if Z<=0 then LeftFoot.Visible = false else LeftFoot.Visible = true end
            else
                LeftFoot.Visible = false
            end
            --
            local RightHand = Folder:FindFirstChild('Right Hand') or Instance.new('Frame',Folder)
            RightHand.Name = 'Right Hand'
            RightHand.ZIndex = 2
            RightHand.BorderSizePixel = 0
            if Char['Right Arm']~=nil then
            local Pos = (Char['Right Arm'].CFrame*CFrame.new(0,-1,0)).p
            local X,Y,Z = Camera:WorldToScreenPoint(Pos).X,Camera:WorldToScreenPoint(Pos).Y,Camera:WorldToScreenPoint(Pos).Z
            RightHand.Position = UDim2.new(0,X,0,Y)
            if Z<=0 then RightHand.Visible = false else RightHand.Visible = true end
            else
                RightHand.Visible = false
            end
            --
            local LeftHand = Folder:FindFirstChild('Left Hand') or Instance.new('Frame',Folder)
            LeftHand.Name = 'Left Hand'
            LeftHand.ZIndex = 2
            LeftHand.BorderSizePixel = 0
            if Char['Left Arm']~=nil then
            local Pos = (Char['Left Arm'].CFrame*CFrame.new(0,-1,0)).p
            local X,Y,Z = Camera:WorldToScreenPoint(Pos).X,Camera:WorldToScreenPoint(Pos).Y,Camera:WorldToScreenPoint(Pos).Z
            LeftHand.Position = UDim2.new(0,X,0,Y)
            if Z<=0 then LeftHand.Visible = false else LeftHand.Visible = true end
            else
                LeftHand.Visible = false
            end
            -- draw joints
            if esp_bones then
            if Head.Visible then DrawLine(Folder,Head,Neck,2,Head.BackgroundColor3,Head.BackgroundTransparency) end
            if Neck.Visible then DrawLine(Folder,Neck,Pelvis,2,Head.BackgroundColor3,Head.BackgroundTransparency) end
            if Neck.Visible then DrawLine(Folder,Neck,RightHand,2,Head.BackgroundColor3,Head.BackgroundTransparency) end
            if Neck.Visible then DrawLine(Folder,Neck,LeftHand,2,Head.BackgroundColor3,Head.BackgroundTransparency) end
            if Pelvis.Visible then DrawLine(Folder,Pelvis,RightFoot,2,Head.BackgroundColor3,Head.BackgroundTransparency) end
            if Pelvis.Visible then DrawLine(Folder,Pelvis,LeftFoot,2,Head.BackgroundColor3,Head.BackgroundTransparency) end
            end
 
            if bounding_box then
                -- get extents
                local highest_X,highest_Y,lowest_X,lowest_Y = 0,0,9e7,9e7
                for _,v in next,Folder:children() do
                    if v:IsA('Frame') and not v.Name:match('-') and not v.Name:match('Point') then
                        if v.AbsolutePosition.X>=highest_X then
                            highest_X = v.AbsolutePosition.X
                        end
                        if v.AbsolutePosition.X<=lowest_X then
                            lowest_X = v.AbsolutePosition.X
                        end
                        if v.AbsolutePosition.Y>=highest_Y then
                            highest_Y = v.AbsolutePosition.Y
                        end
                        if v.AbsolutePosition.Y<=lowest_Y then
                            lowest_Y = v.AbsolutePosition.Y
                        end
                    end
                end
                --
                local Point1 = Folder:FindFirstChild('Point 1') or Instance.new('Frame',Folder)
                Point1.Name = 'Point 1'
                Point1.ZIndex = 2
                Point1.BorderSizePixel = 0
                Point1.Size = UDim2.new(0,1,0,1)
                Point1.BackgroundColor3 = Head.BackgroundColor3
                Point1.Position = UDim2.new(0,highest_X+1,0,highest_Y+1)
 
                local Point2 = Folder:FindFirstChild('Point 2') or Point1:Clone()
                Point2.Name = 'Point 2'
                Point2.BackgroundColor3 = Head.BackgroundColor3
                Point2.Parent = Folder
                Point2.Position = UDim2.new(0,highest_X+1,0,lowest_Y-1)
 
                local Point3 = Folder:FindFirstChild('Point 3') or Point2:Clone()
                Point3.Name = 'Point 3'
                Point3.BackgroundColor3 = Head.BackgroundColor3
                Point3.Parent = Folder
                Point3.Position = UDim2.new(0,lowest_X-1,0,lowest_Y-1)
 
                local Point4 = Folder:FindFirstChild('Point 4') or Point3:Clone()
                Point4.Name = 'Point 4'
                Point4.BackgroundColor3 = Head.BackgroundColor3
                Point4.Parent = Folder
                Point4.Position = UDim2.new(0,lowest_X-1,0,highest_Y+1)
 
                if Head.Visible then
                DrawLine(Folder,Point1,Point2,1,Head.BackgroundColor3,.25)
                DrawLine(Folder,Point2,Point3,1,Head.BackgroundColor3,.25)
                DrawLine(Folder,Point3,Point4,1,Head.BackgroundColor3,.25)
                DrawLine(Folder,Point4,Point1,1,Head.BackgroundColor3,.25)
                else
                DrawLine(Folder,Point1,Point2,1,Head.BackgroundColor3,1)
                DrawLine(Folder,Point2,Point3,1,Head.BackgroundColor3,1)
                DrawLine(Folder,Point3,Point4,1,Head.BackgroundColor3,1)
                DrawLine(Folder,Point4,Point1,1,Head.BackgroundColor3,1)                    
                end
            end
 
            if lockedon and target and aim_line and ESP:FindFirstChild(target.Name) then
                DrawLine(ESP,cursor,ESP:FindFirstChild(target.Name).Head,1,Head.BackgroundColor3,.5)
            end
 
        elseif not Char or Char:FindFirstChild(targetpart) and Player:DistanceFromCharacter(Char[targetpart].Position)>600 then
            if ESP:FindFirstChild(v.Name) then
                ESP:FindFirstChild(v.Name):Destroy()
            end
        end
        end
    else
        for _,v in next,ESP:children() do
            if v:IsA('Folder') then
                v:Destroy()
            end
        end
    end
end)
 
Notification({Title='GameSense '..version;Text='Cheat loaded successfully.';Icon='rbxassetid://2572157833';Duration=10;})
wait(.5)
Notification({Title='Main Coder';Text='AvexusDev';Duration=4;Icon='https://www.roblox.com/Thumbs/Avatar.ashx?x=100&y=100&username=AvexusDev'})
wait(.5)
Notification({Title='Thank you!';Text='If you like this script, please leave a vouch on my thread!';Duration=4;})
 
spawn(function()
while script and game.PlaceId == 292439477 and workspace:FindFirstChild('Map') do
    windows = {}
    for _,v in next,workspace.Map:GetChildren() do
        if v.Name=='Window' then
            table.insert(windows,v)
        end
    end
    wait(2)
end
end)
