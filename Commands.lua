
local AdminUsers = {"TimesIllusion", "Player1", "Player2"}
local Commands = {}

local DS = game:GetService("DataStoreService")
local BanData = DS:GetDataStore("BannedPlayers")

local function FindFirstChildLower(parent, name)
	name = string.lower(name)
	for i,v in pairs(parent:GetChildren()) do
		if string.lower(v.Name) == name then
			return v
		end
	end
end

Commands.tp = function(sender, arguments)
	if #arguments == 1 then
		local player1 = sender
		local player2 = FindFirstChildLower(game.Players, arguments[2])

		if player1 ~= nil and player2 ~= nil then
			player1.Character:PivotTo(player2.Character.PrimaryPart.CFrame)
		end		
	end

	if #arguments == 2 then
		local player1 = FindFirstChildLower(game.Players, arguments[1])
		local player2 = FindFirstChildLower(game.Players, arguments[2])

		if player1 ~= nil and player2 ~= nil then
			player1.Character:PivotTo(player2.Character.PrimaryPart.CFrame)
		end
	end
end

Commands.kick = function(sender, arguments)
	if #arguments == 1 then
		local player = FindFirstChildLower(game.Players, arguments[1])
		if player ~= nil then
			player:Kick()
		end
	elseif #arguments == 2 then
		local player = FindFirstChildLower(game.Players, arguments[1])
		if player ~= nil then
			player:Kick(arguments[2])
		end
	end
end

Commands.ban = function(sender, arguments)
	local Player = FindFirstChildLower(game.Players, arguments[1])
	if Player ~= nil then
		if not BanData:GetAsync(Player.UserId) then
			BanData:SetAsync(Player.UserId, true)
			Player:Kick()
		end
	end
end

Commands.unban = function(sender, arguments)
	local Player = game.Players:GetUserIdFromNameAsync(arguments[1])
	if Player ~= nil then
		if BanData:GetAsync(Player) == true then
			BanData:SetAsync(Player, false)
			Notify:NotifyPlayer(sender, {Text = "Unban Successful"; BackgroundColor = Color3.fromRGB(80, 179, 86); Transparency = .5} ,4)
		else
			Notify:NotifyPlayer(sender, {Text = "Error: Not Banned"; Transparency = .5} ,4)
		end
	else
		Notify:NotifyPlayer(sender, {Text = "Error: Not Found"; Transparency = .5} ,4)
	end
end

function CheckAdmin(Player)
	for i, v in pairs(AdminUsers) do
		if Player.Name == v then
			return(true)
		end
	end
	return(false)
end

function CheckBan(Player)
	if BanData:GetAsync(Player.UserId) == true then
		return true
	end
	return false
end

game.Players.PlayerAdded:Connect(function(Player)
	local PlayerID = Player.UserId
	local Admin = CheckAdmin(Player)
	Player:WaitForChild("PlayerGui")

	if Admin then
		Player.Chatted:Connect(function(message, receiptent)
			message = string.lower(message)

			local SplitString = message:split(" ")

			local SlashCommand = SplitString[1]
			local Cmd = SlashCommand:split("/")
			local Command = Cmd[2]

			if Commands[Command] then
				local Arguments = {}

				for i =2, #SplitString do
					table.insert(Arguments,SplitString[i])
				end

				Commands[Command](Player, Arguments)
			end
		end)

		local SpectateMenu = script.Spectate:Clone()
		SpectateMenu.Parent = Player.PlayerGui
		SpectateMenu.SpectateScript.Disabled = false
	end
	
	if CheckBan(Player) == true then
		Player:Kick("Banned")
	end
end)
