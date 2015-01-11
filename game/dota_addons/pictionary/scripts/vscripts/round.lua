Styles = {
	[1] = {
		["red"] = "particles/ballpoint_red/ballpoint_red_frost.vpcf",
		["green"] = "particles/ballpoint_green/ballpoint_green_frost.vpcf",
		["yellow"] = "particles/ballpoint_yellow/ballpoint_yellow_frost.vpcf",
		["blue"] = "particles/ballpoint_blue/ballpoint_blue_frost.vpcf",
		["purple"] = "particles/ballpoint_purple/ballpoint_purple_frost.vpcf",
		["orange"] = "particles/ballpoint_orange/ballpoint_orange_frost.vpcf",
		["pink"] = "particles/ballpoint_pink/ballpoint_pink_frost.vpcf",
		["teal"] = "particles/ballpoint_teal/ballpoint_teal_frost.vpcf",
		["brown"] = "particles/ballpoint_brown/ballpoint_brown_frost.vpcf",
	},
	[2] = {
		["red"] = "particles/style2/red.vpcf",
		["green"] = "particles/style2/green.vpcf",
		["yellow"] = "particles/style2/yellow.vpcf",
		["blue"] = "particles/style2/blue.vpcf",
		["purple"] = "particles/style2/purple.vpcf",
		["orange"] = "particles/style2/orange.vpcf",
		["pink"] = "particles/style2/pink.vpcf",
		["teal"] = "particles/style2/teal.vpcf",
		["brown"] = "particles/style2/brown.vpcf",
	}
}

NoSounds = {
	[1] = "Drow_No",
	[2] = "Earthshaker_No",
	[3] = "Gyro_Uhuhuh",
	[4] = "Axe_Nuhuh",
	[5] = "Invoker_No",
	[6] = "Lina_Nuhuh",
	[7] = "Ogre_Nono",
	[8] = "Ogre_Nope",
	[9] = "Techies_Nope",
	[10] = "Terrorblade_Nonono",
	[11] = "Terrorblade_Nonono2",
}

YesSounds = {
	[1] = "Omni_Yes",
	[2] = "Ench_Yes",
}

function Pictionary:BeginRound(  )
	self:GetDrawer()
	GameRules:SendCustomMessage(ColorIt("Round ", "pink") .. ColorIt(RoundsCompleted+1, "orange") .. ColorIt(" begins!", "pink"), 0, 0)
	RoundInProgress = true
end

function Pictionary:EndRound(  )
	self:CleanupDrawer()

	-- stop the music for all players.
	self:StopMusic()

	RoundsCompleted = RoundsCompleted + 1
	-- notification timer
	local countdown = 5
	if TimeTillNextRound > 5 then
		Timers:CreateTimer(TimeTillNextRound-5, function()
			if countdown == 0 then
				return nil
			end

			Say(nil, "..." .. tostring(countdown), false)
			countdown = countdown - 1
			return 1
		end)
	end

	Timers:CreateTimer(TimeTillNextRound, function()
		-- Check if game is completely over.
		if SecondsPassed >= MaxGameLength then
			-- Do end of game shit, cleanup.
			GameRules:SendCustomMessage(ColorIt("That was the last round! Congratulations to ", "blue") .. ColorIt(CurrentWinner.playerName, "green") .. 
				ColorIt("! You've won the game!", "blue"), 0, 0)
			GameRules:SendCustomMessage(ColorIt("Thank you for playing Pictionary! Please leave your comments and suggestions on the", "orange") ..
				ColorIt("Pictionary Workshop Page.", "purple"), 0, 0)

		end

		self:BeginRound()
	end)



	Timers:CreateTimer(TimeTillNextRound*1/4,function()
		if SecondsPassed >= MaxGameLength then
			-- Games over.
			return
		end

		local totalSecsRemaining = MaxGameLength-SecondsPassed
		local minsRemain = math.floor(totalSecsRemaining/60)
		local secsRemain = totalSecsRemaining%60
		GameRules:SendCustomMessage(ColorIt("Game time remaining: ", "blue") .. ColorIt(minsRemain .. " mins " .. secsRemain .. " secs", "orange"), 0, 0)
	end)
  RoundInProgress = false
end

function Pictionary:GetDrawer(  )
	-- first we need to get the drawer.
	local lowest = {[1] = Players[1]}
	for i,v in ipairs(Players) do
		if v.timesDrawer < lowest[1].timesDrawer then
			lowest = {}
			lowest[1] = v
		elseif v.timesDrawer == lowest[1].timesDrawer then
			table.insert(lowest, v)
		end
	end
	Drawer = lowest[math.random(#lowest)]
	Drawer.timesDrawer = Drawer.timesDrawer + 1
	print("Drawer id: " .. Drawer:GetPlayerID())

	-- TODO: give drawer word hints in here.
	FireGameEvent('pictionary_drawer_changed', { player_ID = Drawer:GetPlayerID() })
	ShowGenericPopupToPlayer(Drawer.player, "#drawer_instructions_title", "#drawer_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	-- tell everyone who the drawer is.
	Say(nil, Drawer.playerName .. " is now the drawer! " .. Drawer.playerName .. " has " .. TimeToChooseWord .. " seconds to choose his word.", false)
	-- set the drawer up with particle stuff.
	self:InitDrawer()

	-- give the drawer another reminder on how to choose a word.
	Timers:CreateTimer(TimeToChooseWord/2, function()
		if WaitingForWord then
			Say(nil, Drawer.playerName .. ", preface your next line with a '/' to choose your word.", false)
			--GameRules:SendCustomMessage(ColorIt(Drawer.playerName, "cyan") .. ColorIt(", preface your next line with a ", "blue") .. ColorIt("/", "purple") .. 
			--	ColorIt(" to choose your word.", "blue"), 0, 0)
		end
	end)

	WaitingForWord = true
	-- afk check timer
	self.afkTimer = Timers:CreateTimer(TimeToChooseWord, function()
		if WaitingForWord then
			print("afk detected. changing drawer.")
			Say(nil, Drawer.playerName .. " has been detected AFK." , false)
			self:ChangeDrawer()
		end
	end)
end

function Pictionary:InitDrawer(  )
	Drawer.lastPos = Drawer:GetAbsOrigin()
	Drawer.style = Styles[1]
	Drawer.colorKey = "teal"
	Drawer.color = Drawer.style[Drawer.colorKey]
	Drawer.penOn = true
	Drawer.particles = {}
	Drawer.usedBlink = false

	Timers:CreateTimer(.03, function()
		Drawer:SetAbsOrigin(GetGroundPosition(Vector(0,0,0), Drawer))
		Drawer:Stop() -- prevents weird random movement.
	end)

	Drawer.drawerTimer = Timers:CreateTimer(.05, function()
		local p1 = Drawer:GetAbsOrigin()
		local p2 = Drawer.lastPos

		-- determine if we should draw the particle.
		if not Drawer.penOn or (p1.x > p2.x - 32 and p1.x < p2.x + 32 and p1.y > p2.y - 32 and p1.y < p2.y + 32) then
			-- don't draw a particle.

		elseif Drawer.usedBlink then
			-- prevent drawing of annoying pixel after blink.
			Drawer.lastPos = Drawer:GetAbsOrigin()
			Drawer.usedBlink = false
		else
			local p = ParticleManager:CreateParticle(Drawer.color, PATTACH_ABSORIGIN, Drawer)
			table.insert(Drawer.particles, p)
			Drawer.lastPos = Drawer:GetAbsOrigin()
		end

		return .03
	end)

end

function Pictionary:CleanupDrawer(  )
	-- cleanup current drawer.
	-- stun and set underground.
	Drawer:AddNewModifier(Drawer, nil, "modifier_stunned", {})
	local id = Drawer:GetPlayerID()
	Timers:CreateTimer(.04, function()
		-- need to get the lastDrawer this way, because Drawer will change in the .04 secs.
		local lastDrawer = PlayerResource:GetPlayer(id):GetAssignedHero()
		lastDrawer:SetAbsOrigin(OutOfWorldVector)
		lastDrawer.drawerTimer = nil
		-- need to make sure drawer is completely in a different area before deleting all particles.
		Timers:CreateTimer(.05, function()
			for i,v in ipairs(lastDrawer.particles) do
				ParticleManager:DestroyParticle(v, true)
			end
			lastDrawer.particles = {}
		end)
	end)
end

-- change drawer function. Used mainly for afks.
function Pictionary:ChangeDrawer()
	self:CleanupDrawer()
	self:GetDrawer()
end
