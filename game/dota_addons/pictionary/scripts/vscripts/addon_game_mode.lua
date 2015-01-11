-- module_loader by Adynathos.
BASE_MODULES = {
	'util.myll_util', 
	'util.valve_util',
	'timers', 
	'physics',
	'lib.statcollection',

	'abilities',
	'pictionary',
	'round',
}

local function load_module(mod_name)
	-- load the module in a monitored environment
	local status, err_msg = pcall(function()
		require(mod_name)
	end)

	if status then
		log(' module ' .. mod_name .. ' OK')
	else
		err(' module ' .. mod_name .. ' FAILED: '..err_msg)
	end
end

-- Load all modules
for i, mod_name in pairs(BASE_MODULES) do
	load_module(mod_name)
end

statcollection.addStats({
	modID = 'XXXXXXXXXXXXXXXXXXX' --GET THIS FROM http://getdotastats.com/#d2mods__my_mods
})

function Precache( context )
	--[[
		This function is used to precache resources/units/items/abilities that will be needed
		for sure in your game and that cannot or should not be precached asynchronously or 
		after the game loads.

		See Pictionary:PostLoadPrecache() in pictionary.lua for more information
		]]

		print("[PICTIONARY] Performing pre-load precache")

		-- Particles can be precached individually or by folder
		-- It it likely that precaching a single particle system will precache all of its children, but this may not be guaranteed
		PrecacheResource("particle_folder", "particles/ballpoint_red", context)
		PrecacheResource("particle_folder", "particles/ballpoint_green", context)
		PrecacheResource("particle_folder", "particles/ballpoint_yellow", context)
		PrecacheResource("particle_folder", "particles/ballpoint_blue", context)
		PrecacheResource("particle_folder", "particles/ballpoint_purple", context)
		PrecacheResource("particle_folder", "particles/ballpoint_orange", context)
		PrecacheResource("particle_folder", "particles/ballpoint_pink", context)
		PrecacheResource("particle_folder", "particles/ballpoint_teal", context)
		PrecacheResource("particle_folder", "particles/ballpoint_brown", context)

		PrecacheResource("particle_folder", "particles/style2", context)



		-- Models can also be precached by folder or individually
		-- PrecacheModel should generally used over PrecacheResource for individual models
		--PrecacheResource("model_folder", "particles/heroes/antimage", context)
		--PrecacheResource("model", "particles/heroes/viper/viper.vmdl", context)
		--PrecacheModel("models/heroes/viper/viper.vmdl", context)

		-- Sounds can precached here like anything else
		--PrecacheResource("soundfile", "soundevents/soundevents_diagnostics.vsndevts", context)
		PrecacheResource("soundfile", "soundevents/game_sounds_custom.vsndevts", context)

		-- Entire items can be precached by name
		-- Abilities can also be precached in this way despite the name

		-- Entire heroes (sound effects/voice/models/particles) can be precached with PrecacheUnitByNameSync
		-- Custom units from npc_units_custom.txt can also have all of their abilities and precache{} blocks precached in this way
		PrecacheUnitByNameSync("npc_dota_hero_wisp", context)
		PrecacheUnitByNameSync("npc_dota_hero_antimage", context)
end

-- Create the game mode when we activate
function Activate()
	GameRules.Pictionary = Pictionary()
	GameRules.Pictionary:InitPictionary()
end
