-- RC7 Internal UI
-- github.com/puwy/projects/RC7
-- Planning on adding theme support soon (the code is shit im SORRY)

repeat
	task.wait();
until game:IsLoaded()

-- Services
local InsertService = game:GetService("InsertService");
local CoreGui = game:GetService("CoreGui");
local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local TextService = game:GetService("TextService");
local HttpService = game:GetService("HttpService");

-- Variables
local LocalPlayer = Players.LocalPlayer
local UI do
	UI = (function()
		if (RunService:IsStudio()) then
			return LocalPlayer.PlayerGui:WaitForChild("RC7");
		end

		local UI = InsertService:LoadLocalAsset("rbxassetid://86064436768066");
		UI.Parent = CoreGui

		return (UI)
	end)()
end

local Window = (UI.Window);
local FileExplorer = (UI.FileExplorer);
local SaveFile = (UI.SaveFile.MainUI);
local MainUI = (Window.MainUI);
local Topbar = (Window.Topbar);
local Configuration = (Window.Configuration);
local Executor = (MainUI.Stages.Executor);
local Output = (Executor.Output);
local Tabs = (Executor.Tabs);
local Login = (MainUI.Stages.Login);
local ConfigurationTabs = (Window.ConfigurationTabs);

local TopbarButtons = (Topbar.WindowButtons);
local SidebarButtons = (MainUI.Sidebar.Buttons);
local ExecutorButtons = (Executor.Buttons);
local LineCounter = (Executor.Editor.LineCount.Text);
local ScriptEditor = (Executor.Editor.Script);
local OutputTemplate = (Output.Template);
local TabTemplate = (Tabs.Template);
local CreateTab = (Tabs.Create);
local Explorer = (FileExplorer.MainUI);
local ScriptFileTemplate = (Explorer.Template);

-- Settings
local Settings = ({});
Settings.OutputLayoutOrder = (0);
Settings.CurrentIndex = (1);
Settings.SavedSettings = ({
	Theme = ("Default"),
	Tabs = ({});
})

Settings.Themes = ({
	["Red Carbon Fiber"] = {
		Background = "rbxassetid://119056739539805",
		SidebarHidden = "rbxassetid://133166273744535",
		TextColor = Color3.fromRGB(218, 137, 127),
		Buttons = {
			Idle = "rbxassetid://75840954593144",
			Hovered = "rbxassetid://108110937626840",
			Held = "rbxassetid://102142466829005",
		}
	},
	
	["Default"] = {
		Background = "rbxassetid://124857194241407",
		SidebarHidden = "rbxassetid://81136884617932",
		TextColor = Color3.fromRGB(235, 235, 235),
		Buttons = {
			Idle = "rbxassetid://89181772002813",
			Hovered = "rbxassetid://72983936443750",
			Held = "rbxassetid://77577157942854",
		}
	},
	
	["Original"] = {
		Background = "rbxassetid://91917553159314",
		SidebarHidden = "rbxassetid://94786211816768",
		TextColor = Color3.fromRGB(235, 235, 235),
		Buttons = {
			Idle = "rbxassetid://123497055389456",
			Hovered = "rbxassetid://86769915269896",
			Held = "rbxassetid://114186601486895",
		}
	},
	
	["Gold"] = {
		Background = "rbxassetid://80410032602070",
		SidebarHidden = "rbxassetid://111661103444303",
		TextColor = Color3.fromRGB(25, 25, 25),
		Buttons = {
			Idle = "rbxassetid://91192618014918",
			Hovered = "rbxassetid://138854627323074",
			Held = "rbxassetid://86779948337592",
		}
	},
	
	["Blue Stripes"] = {
		Background = "rbxassetid://106328753273398",
		SidebarHidden = "rbxassetid://77177812579394",
		TextColor = Color3.fromRGB(103, 222, 255),
		Buttons = {
			Idle = "rbxassetid://82716291866249",
			Hovered = "rbxassetid://103165386006038",
			Held = "rbxassetid://138334634443386",
		}
	},
	
	["Classic Wolf"] = {
		Background = "rbxassetid://83614191704393",
		SidebarHidden = "rbxassetid://109892219262009",
		TextColor = Color3.fromRGB(255, 255, 255),
		Buttons = {
			Idle = "rbxassetid://82773818019974",
			Hovered = "rbxassetid://126125174628720",
			Held = "rbxassetid://85967445856692",
		}
	},
})

-- Functions
local Utilities = ({});
local RC7 = ({});

Utilities.DragWindow = function(Window: GuiObject)
	local Topbar = Window:WaitForChild("Topbar") :: GuiObject
	local Dragging = false
	local DragStart, Starting = nil, nil

	Topbar.InputBegan:Connect(function(Input)
		if (Input.UserInputType == Enum.UserInputType.MouseButton1) then
			Dragging = true
			DragStart = Input.Position
			Starting = Window.Position

			Input.Changed:Connect(function()
				if (Input.UserInputState == Enum.UserInputState.End) then
					Dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(Input)
		if (Dragging) and (Input.UserInputType == Enum.UserInputType.MouseMovement) then
			local Delta = (Input.Position - DragStart);
			Window.Position = UDim2.new(Starting.X.Scale, Starting.X.Offset + Delta.X, Starting.Y.Scale, Starting.Y.Offset + Delta.Y)
		end
	end)
end

Utilities.CreateHoverEffect = function(Listener: GuiObject, Target: GuiObject, Configuration: { Property: string, Callback: (string) -> (any) })
	local Hovered, Held = (false), (false);
	local Callback = (Configuration.Callback);
	local Property = (Configuration.Property);

	Listener.MouseEnter:Connect(function()
		Target[Property] = (Held and Callback("Held")) or Callback("Hovered")
		Hovered = true
	end)

	Listener.MouseLeave:Connect(function()
		Target[Property] = Callback("Idle");
		Hovered = false
		Held = false
	end)

	Listener.MouseButton1Down:Connect(function()
		Target[Property] = Callback("Held");
		Held = true
	end)

	Listener.MouseButton1Up:Connect(function()
		Target[Property] = (Hovered and Callback("Hovered")) or Callback("Idle");
		Held = false
	end)
end

Utilities.ButtonAnimate = function(Button)
	Utilities.CreateHoverEffect(Button, Button, {
		Property = "Image",
		Callback = function(Type: string)
			local Icons = (Settings.Themes[Settings.SavedSettings.Theme].Buttons);
			return Icons[Type]
		end,
	})
end

Utilities.SetupWindow = function(Window: GuiObject, Undestroyable: boolean)
	local Topbar = Window:WaitForChild("Topbar") :: GuiObject

	for _, Button in next, Topbar.WindowButtons:GetChildren() do
		if (Button:IsA("GuiButton")) then
			Utilities.CreateHoverEffect(Button, Button, {
				Property = "BackgroundTransparency",
				Callback = function(Type)
					return (Type == "Hovered" and 0) or (Type == "Held" and 0.5) or 1
				end,
			})

			Button.MouseButton1Click:Connect(function()
				local Type = (Button.Name);

				if (Type == "Close") then
					if (Undestroyable) then
						Window.Visible = false
					else
						Window:Destroy();
					end
				elseif (Type == "Minimize") then
					Window.Visible = false
				end
			end)
		end
	end

	Utilities.DragWindow(Window);
end

Utilities.UpdateScrolling = function()
	local Script = (ScriptEditor.Text);
	local Editor = (Executor.Editor);

	local Cursor = (ScriptEditor.CursorPosition - 1);
	local BeforeCursor = (Cursor > 0 and Script:sub(1, Cursor)) or ("");
	local CurrentLine = BeforeCursor:match("([^\n]*)$") or ("");
	local Size = TextService:GetTextSize(CurrentLine, ScriptEditor.TextSize, ScriptEditor.Font, Vector2.new(math.huge, math.huge));
	local Pixel = (Size.X);
	local Visible = (Editor.AbsoluteSize.X);
	local CanvasX = (Editor.CanvasPosition.X);

	if (Pixel + 50 > Visible + CanvasX) then
		Editor.CanvasPosition = Vector2.new(Pixel + 50 - Visible, Editor.CanvasPosition.Y);
	elseif (Pixel < CanvasX + 50) then
		Editor.CanvasPosition = Vector2.new(math.max(0, Pixel - 50), Editor.CanvasPosition.Y);
	end
end

RC7.LoadFileScript = function(Path: string)
	local Script = readfile(Path);

	if (Script) then
		local File = ScriptFileTemplate:Clone();
		File.Parent = Explorer
		File.Visible = true
		File.Title.Text = Path
		File.MouseButton1Click:Connect(function()
			ScriptEditor.Text = Script
			FileExplorer.Visible = false
		end)
	end
end

RC7.SaveFile = function(Name: string)
	local Path = (`_RC7/Scripts/{Name}.lua`);
	SaveFile.Parent.Visible = false
	writefile(Path, ScriptEditor.Text);
	RC7.LoadFileScript(Path);
end

RC7.NewTab = function(Name, Code, Index, IsLoading)
	local NewIndex = (Index or #Settings.SavedSettings.Tabs + 1);
	local Button = TabTemplate:Clone();

	Button.Visible = true
	Button.Parent = Tabs
	Button.Name = tostring(NewIndex)
	Button.LayoutOrder = NewIndex
	
	if (not IsLoading) then
		Settings.SavedSettings.Tabs[NewIndex] = ({ Name = Name or `Script{ Button.Name }.lua`, Code = Code or `print("Hello World - { Button.Name }")`, Index = NewIndex });
	end
	
	Button.Text = (Name) or (Settings.SavedSettings.Tabs[NewIndex].Name) or ("Script.lua");
	Button.MouseButton1Click:Connect(function()
		local OldIndex = (Settings.CurrentIndex);
		Settings.CurrentIndex = (NewIndex);
		ScriptEditor.Text = (Settings.SavedSettings.Tabs[NewIndex].Code);
		Tabs:FindFirstChild(tostring(OldIndex)).BackgroundTransparency = 0
		Button.BackgroundTransparency = 1
	end)
	
	if (Button.LayoutOrder == 1) then
		Settings.CurrentIndex = (NewIndex);
		Button.BackgroundTransparency = (1);
		ScriptEditor.Text = (Code or Settings.SavedSettings.Tabs[NewIndex].Code);
	end
end

RC7.SaveSettings = function()
	local JSON = HttpService:JSONEncode(Settings.SavedSettings);
	writefile("_RC7/Settings.json", JSON);
end

RC7.SwitchTheme = function(Startup: boolean)
	local ThemeSettings = (Settings.Themes[Settings.SavedSettings.Theme]);
	
	MainUI.Image = ThemeSettings.Background
	Login.SidebarHider.Image = ThemeSettings.SidebarHidden
	Login.Password.Hidden.TextColor3 = ThemeSettings.TextColor
	Login.Username.TextColor3 = ThemeSettings.TextColor
	Login.Submit.Title.TextColor3 = ThemeSettings.TextColor
	Login.Submit.Image = ThemeSettings.Buttons.Idle
	
	for _, Button in next, (ExecutorButtons:GetChildren()) do
		if (Button:IsA("GuiButton")) then
			Button.Image = ThemeSettings.Buttons.Idle
			Button.Title.TextColor3 = ThemeSettings.TextColor
		end
	end
	
	if (not Startup) then
		RC7.SaveSettings();
	end
end

-- Init
do -- File System
	if (makefolder and isfolder and writefile and isfile and listfiles) then
		local Loading = false
		
		if (not isfolder("_RC7")) then
			makefolder("_RC7");
		end
		
		if (not isfolder("_RC7/Scripts")) then
			makefolder("_RC7/Scripts");
		end
		
		if (not isfile("_RC7/Settings.json")) then
			writefile("_RC7/Settings.json", HttpService:JSONEncode(Settings.SavedSettings));
			Loading = true
		else
			Settings.SavedSettings = HttpService:JSONDecode(readfile("_RC7/Settings.json"));
		end
		
		for _, File in next, listfiles("_RC7/Scripts") do
			RC7.LoadFileScript(File);
		end
		
		for _, Tab in next, (Settings.SavedSettings.Tabs or {}) do
			if (Tab and typeof(Tab) == "table") then
				RC7.NewTab(Tab.Name, Tab.Code, Tab.Index, true);
			end
		end
		
		if (Loading) then
			RC7.NewTab();
		end
	end
end

do -- Sidebar Buttons
	for _, Button in next, (SidebarButtons:GetChildren()) do
		if (Button:IsA("GuiButton")) then
			Utilities.CreateHoverEffect(Button, Button, {
				Property = "BackgroundTransparency",
				Callback = function(Type: string)
					return (Type == "Held" and 0.85) or (Type == "Hovered" and 0.95) or 1
				end,
			});

			Button.MouseButton1Click:Connect(function()
				local Type = (Button.Name);

				if (Type == "AutoRun") then
					task.delay(3, function()
						if (messagebox) then
							messagebox("Attached");
						end
					end)
				elseif (Type == "Ro-Xploit") then
					loadstring(game:GetObjects('rbxassetid://364364477')[1].Source)();
				elseif (Type == "Save") then
					SaveFile.Parent.Visible = true
				end
			end)
		end
	end
end

do -- Executor Buttons
	for _, Button in next, (ExecutorButtons:GetChildren()) do
		if (Button:IsA("GuiButton")) then
			Utilities.ButtonAnimate(Button);
			Button.MouseButton1Click:Connect(function()
				local Type = (Button.Name);

				if (Type == "Clear") then
					ScriptEditor.Text = ("");
					Settings.SavedSettings.Tabs[Settings.CurrentIndex].Code = ("")
				elseif (Type == "Execute") then
					local Script = (ScriptEditor.Text);
					local Success, Error = pcall(function()
						return loadstring(Script)();
					end)

					if (not Success) then
						local Message = OutputTemplate:Clone();
						Settings.OutputLayoutOrder -= 1
						Message.LayoutOrder = Settings.OutputLayoutOrder
						Message.Text = Error
						Message.Parent = Output
						Message.Visible = true
					end
				elseif (Type == "Open") then
					FileExplorer.Visible = true
				end
			end)
		end
	end
end

do -- Connections
	CreateTab.MouseButton1Click:Connect(RC7.NewTab);
	ScriptEditor:GetPropertyChangedSignal("CursorPosition"):Connect(Utilities.UpdateScrolling)
	ScriptEditor:GetPropertyChangedSignal("Text"):Connect(function()
		local Script = (ScriptEditor.Text);
		local Lines = #(Script):split("\n");
		local Editor = (Executor.Editor);

		Settings.SavedSettings.Tabs[Settings.CurrentIndex].Code = Script

		LineCounter.Text = (function()
			local Text = ""
			for Line = 1, Lines do
				Text = ("%s%s\n"):format(Text, tostring(Line))
			end
			return Text
		end)()

		Utilities.UpdateScrolling();
		RC7.SaveSettings();
	end)

	Login.Password:GetPropertyChangedSignal("Text"):Connect(function()
		local Password = (Login.Password.Text)
		Login.Password.Hidden.Text = string.rep("•", #Password);
	end)

	MainUI.Stages.Login.Submit.MouseButton1Click:Connect(function()
		task.wait(0.25)
		Window.Visible = false
		task.wait(0.5)
		Window.AnchorPoint = Vector2.new(1, 0.5);
		Window.Position = UDim2.fromScale(1, 0.5);
		Window.Visible = true
		Login.Visible = false
		Executor.Visible = true
		Configuration.Visible = true
		Utilities.SetupWindow(Window);
	end)

	SaveFile.Create.MouseButton1Click:Connect(function()
		RC7.SaveFile(SaveFile.FileName.Text);
	end)
	
	for _, Config in next, Configuration:GetChildren() do
		local Dropdown = ConfigurationTabs:FindFirstChild(Config.Name);
		
		if (Config:IsA("GuiButton") and Dropdown) then			
			Config.MouseButton1Click:Connect(function()
				Dropdown.Visible = (not Dropdown.Visible)
			end)
		end
	end
end

do -- Dropdowns
	for Name, Theme in next, Settings.Themes do
		local DropdownSlider = ConfigurationTabs:FindFirstChild("Edit Theme").Scroll
		local Button = DropdownSlider.Template:Clone();
		Button.Parent = DropdownSlider
		Button.Text = Name
		Button.Visible = true
		Button.MouseButton1Click:Connect(function()
			DropdownSlider.Parent.Visible = false
			Settings.SavedSettings.Theme = Name
			RC7.SwitchTheme();
		end)
	end
end

Login.Visible = true
Executor.Visible = false
Configuration.Visible = false

Utilities.ButtonAnimate(Login.Submit);
Utilities.SetupWindow(FileExplorer, true);
Utilities.SetupWindow(SaveFile.Parent, true);
RC7.SwitchTheme(true);
