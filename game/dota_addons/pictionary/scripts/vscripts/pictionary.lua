print ('[PICTIONARY] pictionary.lua' )

ENABLE_HERO_RESPAWN = true              -- Should the heroes automatically respawn on a timer or stay dead until manually respawned
UNIVERSAL_SHOP_MODE = false             -- Should the main shop contain Secret Shop items as well as regular items
ALLOW_SAME_HERO_SELECTION = true        -- Should we let people select the same hero as each other

HERO_SELECTION_TIME = 30.0              -- How long should we let people select their hero?
PRE_GAME_TIME = 30.0                    -- How long after people select their heroes should the horn blow and the game start?
POST_GAME_TIME = 60.0                   -- How long should we let people look at the scoreboard before closing the server automatically?
TREE_REGROW_TIME = 60.0                 -- How long should it take individual trees to respawn after being cut down/destroyed?

GOLD_PER_TICK = 100                     -- How much gold should players get per tick?
GOLD_TICK_TIME = 5                      -- How long should we wait in seconds between gold ticks?

RECOMMENDED_BUILDS_DISABLED = false     -- Should we disable the recommened builds for heroes (Note: this is not working currently I believe)
CAMERA_DISTANCE_OVERRIDE = 1600.0        -- How far out should we allow the camera to go?  1134 is the default in Dota

MINIMAP_ICON_SIZE = 1                   -- What icon size should we use for our heroes?
MINIMAP_CREEP_ICON_SIZE = 1             -- What icon size should we use for creeps?
MINIMAP_RUNE_ICON_SIZE = 1              -- What icon size should we use for runes?

RUNE_SPAWN_TIME = 120                    -- How long in seconds should we wait between rune spawns?
CUSTOM_BUYBACK_COST_ENABLED = true      -- Should we use a custom buyback cost setting?
CUSTOM_BUYBACK_COOLDOWN_ENABLED = true  -- Should we use a custom buyback time?
BUYBACK_ENABLED = false                 -- Should we allow people to buyback when they die?

DISABLE_FOG_OF_WAR_ENTIRELY = true      -- Should we disable fog of war entirely for both teams?
--USE_STANDARD_DOTA_BOT_THINKING = false  -- Should we have bots act like they would in Dota? (This requires 3 lanes, normal items, etc)
USE_STANDARD_HERO_GOLD_BOUNTY = true    -- Should we give gold for hero kills the same as in Dota, or allow those values to be changed?

USE_CUSTOM_TOP_BAR_VALUES = true        -- Should we do customized top bar values or use the default kill count per team?
TOP_BAR_VISIBLE = true                  -- Should we display the top bar score/count at all?
SHOW_KILLS_ON_TOPBAR = true             -- Should we display kills only on the top bar? (No denies, suicides, kills by neutrals)  Requires USE_CUSTOM_TOP_BAR_VALUES

ENABLE_TOWER_BACKDOOR_PROTECTION = false-- Should we enable backdoor protection for our towers?
REMOVE_ILLUSIONS_ON_DEATH = false       -- Should we remove all illusions if the main hero dies?
DISABLE_GOLD_SOUNDS = false             -- Should we disable the gold sound when players get gold?

END_GAME_ON_KILLS = true                -- Should the game end after a certain number of kills?
KILLS_TO_END_GAME_FOR_TEAM = 50         -- How many kills for a team should signify an end of game?

USE_CUSTOM_HERO_LEVELS = true           -- Should we allow heroes to have custom levels?
MAX_LEVEL = 50                          -- What level should we let heroes get to?
USE_CUSTOM_XP_VALUES = true             -- Should we use custom XP values to level up heroes, or the default Dota numbers?

OutOfWorldVector = Vector(-2000,-2000,-600)
MaxRounds = 10
RoundsCompleted = 0

TimeTillNextRound = 8
TimeToGuess = 120
TimeToChooseWord = 25

FreestyleMode = false
RoundInProgress = false
Players = {}
Drawer = nil
WaitingForWord = false
WrongGuesses = {}

SecondsPassed = 0
MaxGameLength = 780
Testing = false

Songs = {
  [1] = "Small_World",
  [2] = "Mary_Poppins",

}

--[[
pictionary_instructions_body = ColorIt("Try and guess other people's drawings!<br>", "blue") .. ColorIt("Player with the highest score after 10 rounds wins!", "pink")
pictionary_instructions_freestyle_body = ColorIt("Freestyle Mode!", "green") .. ColorIt("You are the only person in the game, so the world is your oyster!<br>", "blue") ..
   ColorIt("Please feel free to share your drawings and post screenshots of them on the Pictionary Workshop page:<br>", "orange") .. ColorIt("goo.gl/mVCcQb", "yellow")
]]

-- Fill this table up with the required XP per level if you want to change it
XP_PER_LEVEL_TABLE = {}
for i=1,MAX_LEVEL do
  XP_PER_LEVEL_TABLE[i] = i * 100
end

-- Generated from template
if Pictionary == nil then
    --print ( '[PICTIONARY] creating pictionary game mode' )
    Pictionary = class({})
end


--[[
  This function should be used to set up Async precache calls at the beginning of the game.  The Precache() function 
  in addon_game_mode.lua used to and may still sometimes have issues with client's appropriately precaching stuff.
  If this occurs it causes the client to never precache things configured in that block.

  In this function, place all of your PrecacheItemByNameAsync and PrecacheUnitByNameAsync.  These calls will be made
  after all players have loaded in, but before they have selected their heroes. PrecacheItemByNameAsync can also
  be used to precache dynamically-added datadriven abilities instead of items.  PrecacheUnitByNameAsync will 
  precache the precache{} block statement of the unit and all precache{} block statements for every Ability# 
  defined on the unit.

  This function should only be called once.  If you want to/need to precache more items/abilities/units at a later
  time, you can call the functions individually (for example if you want to precache units in a new wave of
  holdout).
]]
function Pictionary:PostLoadPrecache()
  --print("[PICTIONARY] Performing Post-Load precache")    
  --PrecacheItemByNameAsync("item_example_item", function(...) end)
  --PrecacheItemByNameAsync("example_ability", function(...) end)

  PrecacheUnitByNameAsync("npc_precache_everything", function(...) end)
end

--[[
  This function is called once and only once as soon as the first player (almost certain to be the server in local lobbies) loads in.
  It can be used to initialize state that isn't initializeable in InitPictionary() but needs to be done before everyone loads in.
]]
function Pictionary:OnFirstPlayerLoaded()
  --print("[PICTIONARY] First Player has loaded")
end

--[[
  This function is called once and only once after all players have loaded into the game, right as the hero selection time begins.
  It can be used to initialize non-hero player state or adjust the hero selection (i.e. force random etc)
]]
function Pictionary:OnAllPlayersLoaded()
  --print("[PICTIONARY] All Players have loaded into the game")
  -- check the # of players to determine freestyle mode.
  local count = 0
  for k,v in pairs(self.vUserIds) do
    count = count + 1
  end
  print("player count: " .. count)
  --TODO: this func is pretty late. player could already be in the game with a hero before this fires.
  -- at least in the alpha tools.
  if count == 1 and not Testing then
    FreestyleMode = true
  end

end

--[[
  This function is called once and only once for every player when they spawn into the game for the first time.  It is also called
  if the player's hero is replaced with a new hero for any reason.  This function is useful for initializing heroes, such as adding
  levels, changing the starting gold, removing/adding abilities, adding physics, etc.

  The hero parameter is the hero entity that just spawned in
]]
function Pictionary:OnHeroInGame(hero)
  --print("[PICTIONARY] Hero spawned in game for first time -- " .. hero:GetUnitName())
  if not self.initStuff then
    local firstLine = ColorIt("Welcome to", "blue") .. ColorIt(" Pictionary!", "purple") .. ColorIt("v0.1", "blue");
    local secondLine = ColorIt("Developer: ", "blue") .. ColorIt("Myll", "green")
    if not FreestyleMode then
      Timers:CreateTimer(5, function()
        GameRules:SendCustomMessage(firstLine, 0, 0)
        GameRules:SendCustomMessage(secondLine, 0, 0)
        --GameRules:SendCustomMessage(ColorIt("Player with the most points after 10 rounds wins!", "orange"), 0, 0)
        self:BeginRound()
        -- Fix game length to 13 mins.
        EndGameTimer = Timers:CreateTimer(function()
          SecondsPassed = SecondsPassed + 1

          return 1
        end)
      end)
    elseif FreestyleMode then
        GameRules:SendCustomMessage(firstLine, 0, 0)
        GameRules:SendCustomMessage(secondLine, 0, 0)
        GameRules:SendCustomMessage(ColorIt("Freestyle Mode! Draw whatever you like!", "purple"), 0, 0)

        Drawer = hero
        FireGameEvent('pictionary_drawer_changed', { player_ID = Drawer:GetPlayerID() })
        self:InitDrawer()
    end

    self.initStuff = true
  end

  table.insert(Players, hero)

  hero.player = PlayerResource:GetPlayer(hero:GetPlayerID())
  hero.playerName = PlayerResource:GetPlayerName(hero:GetPlayerID())
  hero.usedBlink = false

  -- Whitespace for scoreboard alignment.
  local whitespace = ""
  for i=1, 24-string.len(hero.playerName) do
    whitespace = whitespace .. " "
  end

  self.whitespace[hero.playerName] = whitespace
  hero.score = 0
  hero.timesDrawer = 0

  if not FreestyleMode then
    ShowGenericPopupToPlayer(hero.player, "#pictionary_instructions_title", "#pictionary_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
  elseif FreestyleMode then
    ShowGenericPopupToPlayer(hero.player, "#pictionary_instructions_title", "#pictionary_instructions_freestyle_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
  end

  -- This line for example will set the starting gold of every hero to 500 unreliable gold
  --hero:SetGold(500, false)

  -- give drawer his abilities.
  for i=0, hero:GetAbilityCount()-1 do
    local abil = hero:GetAbilityByIndex(i)
    if abil ~= nil then
      if hero:GetAbilityPoints() > 0 then
        hero:UpgradeAbility(abil)
      else
        abil:SetLevel(1)
      end
    end
  end

  -- stun and set underground.
  if not FreestyleMode then
    hero:AddNewModifier(hero, nil, "modifier_stunned", {})

    Timers:CreateTimer(.04, function()
      hero:SetAbsOrigin(OutOfWorldVector)
      hero:SetAbilityPoints(0)
    end)
  end

  --[[for i=0, hero:GetAbilityCount()-1 do
    local abil = hero:GetAbilityByIndex(i)
    if abil ~= nil then
      abil:SetLevel(1)
    end
  end]]

  -- These lines will create an item and add it to the player, effectively ensuring they start with the item
  local item = CreateItem("item_clear", hero, hero)
  hero:AddItem(item)

  --[[ --These lines if uncommented will replace the W ability of any hero that loads into the game
    --with the "example_ability" ability

  local abil = hero:GetAbilityByIndex(1)
  hero:RemoveAbility(abil:GetAbilityName())
  hero:AddAbility("example_ability")]]
end

--[[
  This function is called once and only once when the game completely begins (about 0:00 on the clock).  At this point,
  gold will begin to go up in ticks if configured, creeps will spawn, towers will become damageable etc.  This function
  is useful for starting any game logic timers/thinkers, beginning the first round, etc.
]]
function Pictionary:OnGameInProgress()
  --print("[PICTIONARY] The game has officially begun")

  Timers:CreateTimer(30, -- Start this timer 30 game-time seconds later
  function()
    --print("This function is called 30 seconds after the game begins, and every 30 seconds thereafter")
    return 30.0 -- Rerun this timer every 30 game-time seconds 
  end)
end




-- Cleanup a player when they leave
function Pictionary:OnDisconnect(keys)
  --print('[PICTIONARY] Player Disconnected ' .. tostring(keys.userid))
  --PrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

  -- disconnections are only a problem if the disconnectee is the Drawer.

end
-- The overall game state has changed
function Pictionary:OnGameRulesStateChange(keys)
  --print("[PICTIONARY] GameRules State Changed")
  --PrintTable(keys)

  local newState = GameRules:State_Get()
  if newState == DOTA_GAMERULES_STATE_WAIT_FOR_PLAYERS_TO_LOAD then
    self.bSeenWaitForPlayers = true
  elseif newState == DOTA_GAMERULES_STATE_INIT then
    Timers:RemoveTimer("alljointimer")
  elseif newState == DOTA_GAMERULES_STATE_HERO_SELECTION then
    local et = 6
    if self.bSeenWaitForPlayers then
      et = .01
    end
    Timers:CreateTimer("alljointimer", {
      useGameTime = true,
      endTime = et,
      callback = function()
        if PlayerResource:HaveAllPlayersJoined() then
          Pictionary:PostLoadPrecache()
          Pictionary:OnAllPlayersLoaded()
          return 
        end
        return 1
      end
      })
  elseif newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    Pictionary:OnGameInProgress()
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function Pictionary:OnNPCSpawned(keys)
  --print("[PICTIONARY] NPC Spawned")
  --PrintTable(keys)
  local npc = EntIndexToHScript(keys.entindex)

  if npc:IsRealHero() and npc.bFirstSpawned == nil then
    npc.bFirstSpawned = true
    Pictionary:OnHeroInGame(npc)
  end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function Pictionary:OnEntityHurt(keys)
  ----print("[PICTIONARY] Entity Hurt")
  ----PrintTable(keys)
  local entCause = EntIndexToHScript(keys.entindex_attacker)
  local entVictim = EntIndexToHScript(keys.entindex_killed)
end

-- An item was picked up off the ground
function Pictionary:OnItemPickedUp(keys)
  --print ( '[PICTIONARY] OnItemPurchased' )
  --PrintTable(keys)

  local heroEntity = EntIndexToHScript(keys.HeroEntityIndex)
  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function Pictionary:OnPlayerReconnect(keys)
  --print ( '[PICTIONARY] OnPlayerReconnect' )
  --PrintTable(keys) 
end

-- An item was purchased by a player
function Pictionary:OnItemPurchased( keys )
  --print ( '[PICTIONARY] OnItemPurchased' )
  --PrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function Pictionary:OnAbilityUsed(keys)
  --print('[PICTIONARY] AbilityUsed')
  --PrintTable(keys)

  local player = EntIndexToHScript(keys.PlayerID)
  local hero = player:GetAssignedHero()
  local abilityname = keys.abilityname

  if abilityname == "blink" then
    hero.usedBlink = true
  end
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function Pictionary:OnNonPlayerUsedAbility(keys)
  --print('[PICTIONARY] OnNonPlayerUsedAbility')
  --PrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function Pictionary:OnPlayerChangedName(keys)
  --print('[PICTIONARY] OnPlayerChangedName')
  --PrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function Pictionary:OnPlayerLearnedAbility( keys)
  --print ('[PICTIONARY] OnPlayerLearnedAbility')
  --PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function Pictionary:OnAbilityChannelFinished(keys)
  --print ('[PICTIONARY] OnAbilityChannelFinished')
  --PrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function Pictionary:OnPlayerLevelUp(keys)
  --print ('[PICTIONARY] OnPlayerLevelUp')
  --PrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function Pictionary:OnLastHit(keys)
  --print ('[PICTIONARY] OnLastHit')
  --PrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
end

-- A tree was cut down by tango, quelling blade, etc
function Pictionary:OnTreeCut(keys)
  --print ('[PICTIONARY] OnTreeCut')
  --PrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y
end

-- A rune was activated by a player
function Pictionary:OnRuneActivated (keys)
  --print ('[PICTIONARY] OnRuneActivated')
  --PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function Pictionary:OnPlayerTakeTowerDamage(keys)
  --print ('[PICTIONARY] OnPlayerTakeTowerDamage')
  --PrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function Pictionary:OnPlayerPickHero(keys)
  --print ('[PICTIONARY] OnPlayerPickHero')
  --PrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function Pictionary:OnTeamKillCredit(keys)
  --print ('[PICTIONARY] OnTeamKillCredit')
  --PrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
end

-- An entity died
function Pictionary:OnEntityKilled( keys )
  --print( '[PICTIONARY] OnEntityKilled Called' )
  --PrintTable( keys )
  
  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  if killedUnit:IsRealHero() then 
    --print ("KILLEDKILLER: " .. killedUnit:GetName() .. " -- " .. killerEntity:GetName())
    if killedUnit:GetTeam() == DOTA_TEAM_BADGUYS and killerEntity:GetTeam() == DOTA_TEAM_GOODGUYS then
      self.nRadiantKills = self.nRadiantKills + 1
      if END_GAME_ON_KILLS and self.nRadiantKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
      end
    elseif killedUnit:GetTeam() == DOTA_TEAM_GOODGUYS and killerEntity:GetTeam() == DOTA_TEAM_BADGUYS then
      self.nDireKills = self.nDireKills + 1
      if END_GAME_ON_KILLS and self.nDireKills >= KILLS_TO_END_GAME_FOR_TEAM then
        GameRules:SetSafeToLeave( true )
        GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
      end
    end

    if SHOW_KILLS_ON_TOPBAR then
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_BADGUYS, self.nDireKills )
      GameRules:GetGameModeEntity():SetTopBarTeamValue ( DOTA_TEAM_GOODGUYS, self.nRadiantKills )
    end
  end

  -- Put code here to handle when an entity gets killed
end


-- This function initializes the game mode and is called before anyone loads into the game
-- It can be used to pre-initialize any values/tables that will be needed later
function Pictionary:InitPictionary()
  Pictionary = self
  --print('[PICTIONARY] Starting to load Pictionary gamemode...')

  -- Setup rules
  GameRules:SetHeroRespawnEnabled( ENABLE_HERO_RESPAWN )
  GameRules:SetUseUniversalShopMode( UNIVERSAL_SHOP_MODE )
  GameRules:SetSameHeroSelectionEnabled( ALLOW_SAME_HERO_SELECTION )
  GameRules:SetHeroSelectionTime( HERO_SELECTION_TIME )
  GameRules:SetPreGameTime( PRE_GAME_TIME)
  GameRules:SetPostGameTime( POST_GAME_TIME )
  GameRules:SetTreeRegrowTime( TREE_REGROW_TIME )
  GameRules:SetUseCustomHeroXPValues ( USE_CUSTOM_XP_VALUES )
  GameRules:SetGoldPerTick(GOLD_PER_TICK)
  GameRules:SetGoldTickTime(GOLD_TICK_TIME)
  GameRules:SetRuneSpawnTime(RUNE_SPAWN_TIME)
  GameRules:SetUseBaseGoldBountyOnHeroes(USE_STANDARD_HERO_GOLD_BOUNTY)
  GameRules:SetHeroMinimapIconScale( MINIMAP_ICON_SIZE )
  GameRules:SetCreepMinimapIconScale( MINIMAP_CREEP_ICON_SIZE )
  GameRules:SetRuneMinimapIconScale( MINIMAP_RUNE_ICON_SIZE )
  --print('[PICTIONARY] GameRules set')

  InitLogFile( "log/pictionary.txt","")

  -- Event Hooks
  -- All of these events can potentially be fired by the game, though only the uncommented ones have had
  -- Functions supplied for them.  If you are interested in the other events, you can uncomment the
  -- ListenToGameEvent line and add a function to handle the event
  ListenToGameEvent('dota_player_gained_level', Dynamic_Wrap(Pictionary, 'OnPlayerLevelUp'), self)
  ListenToGameEvent('dota_ability_channel_finished', Dynamic_Wrap(Pictionary, 'OnAbilityChannelFinished'), self)
  ListenToGameEvent('dota_player_learned_ability', Dynamic_Wrap(Pictionary, 'OnPlayerLearnedAbility'), self)
  ListenToGameEvent('entity_killed', Dynamic_Wrap(Pictionary, 'OnEntityKilled'), self)
  ListenToGameEvent('player_connect_full', Dynamic_Wrap(Pictionary, 'OnConnectFull'), self)
  ListenToGameEvent('player_disconnect', Dynamic_Wrap(Pictionary, 'OnDisconnect'), self)
  ListenToGameEvent('dota_item_purchased', Dynamic_Wrap(Pictionary, 'OnItemPurchased'), self)
  ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(Pictionary, 'OnItemPickedUp'), self)
  ListenToGameEvent('last_hit', Dynamic_Wrap(Pictionary, 'OnLastHit'), self)
  ListenToGameEvent('dota_non_player_used_ability', Dynamic_Wrap(Pictionary, 'OnNonPlayerUsedAbility'), self)
  ListenToGameEvent('player_changename', Dynamic_Wrap(Pictionary, 'OnPlayerChangedName'), self)
  ListenToGameEvent('dota_rune_activated_server', Dynamic_Wrap(Pictionary, 'OnRuneActivated'), self)
  ListenToGameEvent('dota_player_take_tower_damage', Dynamic_Wrap(Pictionary, 'OnPlayerTakeTowerDamage'), self)
  ListenToGameEvent('tree_cut', Dynamic_Wrap(Pictionary, 'OnTreeCut'), self)
  ListenToGameEvent('entity_hurt', Dynamic_Wrap(Pictionary, 'OnEntityHurt'), self)
  ListenToGameEvent('player_connect', Dynamic_Wrap(Pictionary, 'PlayerConnect'), self)
  ListenToGameEvent('dota_player_used_ability', Dynamic_Wrap(Pictionary, 'OnAbilityUsed'), self)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(Pictionary, 'OnGameRulesStateChange'), self)
  ListenToGameEvent('npc_spawned', Dynamic_Wrap(Pictionary, 'OnNPCSpawned'), self)
  ListenToGameEvent('dota_player_pick_hero', Dynamic_Wrap(Pictionary, 'OnPlayerPickHero'), self)
  ListenToGameEvent('dota_team_kill_credit', Dynamic_Wrap(Pictionary, 'OnTeamKillCredit'), self)
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(Pictionary, 'OnPlayerReconnect'), self)
  --ListenToGameEvent('player_spawn', Dynamic_Wrap(Pictionary, 'OnPlayerSpawn'), self)
  --ListenToGameEvent('dota_unit_event', Dynamic_Wrap(Pictionary, 'OnDotaUnitEvent'), self)
  --ListenToGameEvent('nommed_tree', Dynamic_Wrap(Pictionary, 'OnPlayerAteTree'), self)
  --ListenToGameEvent('player_completed_game', Dynamic_Wrap(Pictionary, 'OnPlayerCompletedGame'), self)
  --ListenToGameEvent('dota_match_done', Dynamic_Wrap(Pictionary, 'OnDotaMatchDone'), self)
  --ListenToGameEvent('dota_combatlog', Dynamic_Wrap(Pictionary, 'OnCombatLogEvent'), self)
  --ListenToGameEvent('dota_player_killed', Dynamic_Wrap(Pictionary, 'OnPlayerKilled'), self)
  --ListenToGameEvent('player_team', Dynamic_Wrap(Pictionary, 'OnPlayerTeam'), self)



  -- Commands can be registered for debugging purposes or as functions that can be called by the custom Scaleform UI
  --Convars:RegisterCommand( "command_example", Dynamic_Wrap(Pictionary, 'ExampleConsoleCommand'), "A console command example", 0 )
  --Convars:RegisterCommand( "begin_round", Dynamic_Wrap(Pictionary, 'BeginRound'), "", 0 )
  if Testing then
    Convars:RegisterCommand('drawer_force_say', function(...)
      local arg = {...}
      table.remove(arg, 1)
      local keys = {}
      keys.hero = Drawer
      keys.text = table.concat(arg, " ")
      print("text is " .. keys.text)
      self:PlayerSay(keys)
    end, "woof", 0)
  end
  Convars:RegisterCommand('player_say', function(...)
    local arg = {...}
    table.remove(arg,1)
    local cmdPlayer = Convars:GetCommandClient()
    local keys = {}
    keys.ply = cmdPlayer
    keys.text = table.concat(arg, " ")
    self:PlayerSay(keys) -- This function is what your old "player_say" event latch called
  end, 'player say', 0)

  Convars:RegisterCommand( "ColorChange", function(name, color)
      --get the player that sent the command
      local cmdPlayer = Convars:GetCommandClient()
      if cmdPlayer then 
          local hero = cmdPlayer:GetAssignedHero()
          if Drawer == nil or Drawer ~= hero then return end;
          Drawer.color = Drawer.style[color];
          -- colorKey stores strings like 'red', 'green', etc
          Drawer.colorKey = color
      end
  end, "asdfasdf", 0 )

  Convars:RegisterCommand( "StyleChange", function(name, style)
      --get the player that sent the command
      local cmdPlayer = Convars:GetCommandClient()
      if cmdPlayer then 
          local hero = cmdPlayer:GetAssignedHero()
          if Drawer == nil or Drawer ~= hero then return end;
          --print("style is now " .. style)
          Drawer.style = Styles[tonumber(style)];
          Drawer.color = Drawer.style[Drawer.colorKey]
      end
  end, "asdfasdf", 0 )

  -- Fill server with fake clients
  -- Fake clients don't use the default bot AI for buying items or moving down lanes and are sometimes necessary for debugging
  Convars:RegisterCommand('fake', function()
    -- Check if the server ran it
    if not Convars:GetCommandClient() then
      -- Create fake Players
      SendToServerConsole('dota_create_fake_clients')
        
      Timers:CreateTimer('assign_fakes', {
        useGameTime = false,
        endTime = Time(),
        callback = function(pictionary, args)
          local userID = 20
          for i=0, 9 do
            userID = userID + 1
            -- Check if this player is a fake one
            if PlayerResource:IsFakeClient(i) then
              -- Grab player instance
              local ply = PlayerResource:GetPlayer(i)
              -- Make sure we actually found a player instance
              if ply then
                CreateHeroForPlayer('npc_dota_hero_axe', ply)
                self:OnConnectFull({
                  userid = userID,
                  index = ply:entindex()-1
                })

                ply:GetAssignedHero():SetControllableByPlayer(0, true)
              end
            end
          end
        end})
    end
  end, 'Connects and assigns fake Players.', 0)

  -- Change random seed
  local timeTxt = string.gsub(string.gsub(GetSystemTime(), ':', ''), '0','')
  math.randomseed(tonumber(timeTxt))

  -- Initialized tables for tracking state
  self.vUserIds = {}
  self.vSteamIds = {}
  self.vBots = {}
  self.vBroadcasters = {}

  self.vPlayers = {}
  self.vRadiant = {}
  self.vDire = {}

  self.nRadiantKills = 0
  self.nDireKills = 0

  self.bSeenWaitForPlayers = false

  -- MULTITEAM COLORS
  self.m_TeamColors = {}
  self.m_TeamColors[0] = { 255, 0, 0 }
  self.m_TeamColors[1] = { 0, 255, 0 }
  self.m_TeamColors[2] = { 0, 0, 255 }
  self.m_TeamColors[3] = { 255, 128, 64 }
  self.m_TeamColors[4] = { 255, 255, 0 }
  self.m_TeamColors[5] = { 128, 255, 0 }
  self.m_TeamColors[6] = { 128, 0, 255 }
  self.m_TeamColors[7] = { 255, 0, 128 }
  self.m_TeamColors[8] = { 0, 255, 255 }
  self.m_TeamColors[9] = { 255, 255, 255 }

  self.whitespace = {}
  self.scoreTimer = Timers:CreateTimer(function()
    self:UpdateScoreboard()
    return 1
  end)


  self.visionDummies = {}
  for x=-2550+1024,2550-1024, 1024 do
    for y=2550-1024, -2550+1024, -1024 do
      self:CreateVisionDummies(Vector(x,y,0))
    end
  end

  --print('[PICTIONARY] Done loading Pictionary gamemode!\n\n')
end

mode = nil

-- This function is called as the first player loads and sets up the Pictionary parameters
function Pictionary:CapturePictionary()
  if mode == nil then
    -- Set Pictionary parameters
    mode = GameRules:GetGameModeEntity()        
    mode:SetRecommendedItemsDisabled( RECOMMENDED_BUILDS_DISABLED )
    mode:SetCameraDistanceOverride( CAMERA_DISTANCE_OVERRIDE )
    mode:SetCustomBuybackCostEnabled( CUSTOM_BUYBACK_COST_ENABLED )
    mode:SetCustomBuybackCooldownEnabled( CUSTOM_BUYBACK_COOLDOWN_ENABLED )
    mode:SetBuybackEnabled( BUYBACK_ENABLED )
    mode:SetTopBarTeamValuesOverride ( USE_CUSTOM_TOP_BAR_VALUES )
    mode:SetTopBarTeamValuesVisible( TOP_BAR_VISIBLE )
    mode:SetUseCustomHeroLevels ( USE_CUSTOM_HERO_LEVELS )
    mode:SetCustomHeroMaxLevel ( MAX_LEVEL )
    mode:SetCustomXPRequiredToReachNextLevel( XP_PER_LEVEL_TABLE )

    --mode:SetBotThinkingEnabled( USE_STANDARD_DOTA_BOT_THINKING )
    mode:SetTowerBackdoorProtectionEnabled( ENABLE_TOWER_BACKDOOR_PROTECTION )

    mode:SetFogOfWarDisabled(DISABLE_FOG_OF_WAR_ENTIRELY)
    mode:SetGoldSoundDisabled( DISABLE_GOLD_SOUNDS )
    mode:SetRemoveIllusionsOnDeath( REMOVE_ILLUSIONS_ON_DEATH )
	
    self:OnFirstPlayerLoaded()
  end 
end

-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function Pictionary:PlayerConnect(keys)
  --print('[PICTIONARY] PlayerConnect')
  --PrintTable(keys)
  
  if keys.bot == 1 then
    -- This user is a Bot, so add it to the bots table
    self.vBots[keys.userid] = 1
  end
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function Pictionary:OnConnectFull(keys)
  --print ('[PICTIONARY] OnConnectFull')
  --PrintTable(keys)
  Pictionary:CapturePictionary()
  
  local entIndex = keys.index+1
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)
  
  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
  
  -- Update the user ID table with this user
  self.vUserIds[keys.userid] = ply

  -- Update the Steam ID table
  self.vSteamIds[PlayerResource:GetSteamAccountID(playerID)] = ply
  
  -- If the player is a broadcaster flag it in the Broadcasters table
  if PlayerResource:IsBroadcaster(playerID) then
    self.vBroadcasters[keys.userid] = 1
    return
  end
end

function Pictionary:PlayerSay( keys )
  local hero = nil
  if keys.ply == nil and keys.hero ~= nil then
    hero = keys.hero
  else
    hero = keys.ply:GetAssignedHero()
  end
  local txt = keys.text
  --print("text: " .. keys.text)

  if txt == nil or txt == "" or FreestyleMode then
    return
  end

  if WaitingForWord then
    if Drawer == hero then
      if string.sub(txt,1,1) == "/" and string.len(txt) > 1 then
        local word = string.sub(txt, 2, -1)
        CorrectWord = word
        WaitingForWord = false

        -- notify players that drawer has chosen his word.
        GameRules:SendCustomMessage(ColorIt(Drawer.playerName, "teal") .. ColorIt(" has chosen his drawing! You have ", "pink") .. 
            ColorIt(TimeToGuess, "green") .. ColorIt(" seconds to guess the correct drawing!", "pink"), 0, 0)

        -- unstun drawer.
        if Drawer:HasModifier("modifier_stunned") then
          Drawer:RemoveModifierByName("modifier_stunned")
          -- prevent awkward movement
          Drawer:Stop()
        end

        -- start the music around 10 secs after the word has been chosen.
        --local round = RoundsCompleted + 1
        Timers:CreateTimer(math.random(5,15), function()
          --local currRound = RoundsCompleted + 1
          if RoundInProgress then
             self:PlayMusic()
          end
        end)

        local firstHint = ""
        local secondHint = ""
        local split = string_split(word)
        for i,v in ipairs(split) do
          local len = string.len(v)
          -- show 40% of each sub-word for the second hint.
          local max = math.ceil(len*.4)
          for i2=1,len do
            -- second hint stuff.
            if i2 <= max then
              secondHint = secondHint .. string.sub(v, i2, i2)
            else
              secondHint = secondHint .. " _"
            end
            -- first hint stuff
            if i2 == 1 then
               firstHint = firstHint .. string.sub(v, 1, 1)
            else
              firstHint = firstHint .. " _"
            end
          end
          firstHint = firstHint .. "  "
          secondHint = secondHint .. "  "
        end
        --print("firstHint: " .. firstHint)
        --print("secondHint: " .. secondHint)

        local round = RoundsCompleted + 1

        -- First hint timer.
        Timers:CreateTimer(TimeToGuess*1/4, function()
          -- Make sure we're still on the same round after the time has passed.
          local thisRound = RoundsCompleted + 1
          if round ~= thisRound then
            return
          end

          Say(nil, "Hint #1: Length of word is " ..  string.len(word), false)
        end)

        -- Second hint timer.
        Timers:CreateTimer(TimeToGuess*1/3, function()
          -- Make sure we're still on the same round after the time has passed.
          local thisRound = RoundsCompleted + 1
          if round ~= thisRound then
            return
          end

          GameRules:SendCustomMessage(ColorIt(TimeToGuess*2/3, "orange") .. " seconds remain!", 0, 0)
          Say(nil, "Hint #2: " ..  firstHint, false)
          Say(nil, "Length: " .. string.len(word), false)
        end)

        --Third hint timer.
        Timers:CreateTimer(TimeToGuess*2/3, function()
          -- Make sure we're still on the same round after the time has passed.
          local thisRound = RoundsCompleted + 1
          if round ~= thisRound then
            return
          end

          GameRules:SendCustomMessage(ColorIt(TimeToGuess*1/3, "orange") .. " seconds remain!", 0, 0)
          Say(nil, "Hint #3: " ..  secondHint, false)
          Say(nil, "Length: " .. string.len(word), false)
        end)

        -- start the round timer.
        self.roundTimer = Timers:CreateTimer(TimeToGuess, function()
          -- Make sure we're still on the same round after the time has passed.
          local thisRound = RoundsCompleted + 1
          if round ~= thisRound then
            return
          end

          self:EndRound()
          Say(nil, "Times up! Nobody guessed the correct drawing." , false)
          GameRules:SendCustomMessage(ColorIt(Drawer.playerName, "cyan") .. ColorIt("'s drawing was: ", "green") .. ColorIt(CorrectWord, "orange"), 0, 0)
          GameRules:SendCustomMessage(ColorIt("Round ", "pink") .. ColorIt(RoundsCompleted+1, "red") .. ColorIt(" begins in ", "pink") .. ColorIt(TimeTillNextRound, "red") .. 
            ColorIt(" seconds!", "pink"), 0, 0)
        end)
      end
    end
  end

  if RoundInProgress then
    if CorrectWord ~= nil and txt == CorrectWord and Drawer ~= hero then
      --GameRules:SendCustomMessage(ColorIt(hero.playerName, "blue") .. ColorIt(" got the correct answer!", "green"), 0, 0)
      Say(nil, hero.playerName .. " got the correct answer!" , false)
      GameRules:SendCustomMessage(ColorIt("+10", "green") .. ColorIt(" points to ", "blue") .. ColorIt(hero.playerName, "cyan") .. ColorIt(" and ", "blue") ..
          ColorIt(Drawer.playerName, "cyan") .. ColorIt("!", "blue"), 0, 0)
      GameRules:SendCustomMessage(ColorIt("The drawing was: ", "green") .. ColorIt(CorrectWord, "cyan"), 0, 0)
      GameRules:SendCustomMessage(ColorIt("Round ", "pink") .. ColorIt(RoundsCompleted+1, "teal") .. ColorIt(" begins in ", "pink") .. ColorIt(TimeTillNextRound, "teal") .. 
            ColorIt(" seconds!", "pink"), 0, 0)

      -- give points to answerer and drawer.
      hero.score = hero.score + 5
      Drawer.score = Drawer.score + 5

      -- play a 'yes' sound.
      local soundStr = YesSounds[math.random(#YesSounds)]
      EmitGlobalSound(soundStr)

      WrongGuesses = {}
      CorrectWord = nil
      self:EndRound()

    -- Check if the text is a command
    elseif string.sub(txt,1,1) == "/" then
      local s = string.sub(txt, 2, -1)
      if hero == Drawer then
        -- various drawer-only commands.
      end
    elseif Drawer ~= hero and RoundInProgress then
      -- 50% chance to play some "nono" sound.
      if (coinFlipHeads()) then
        local soundStr = NoSounds[math.random(#NoSounds)]
        EmitGlobalSound(soundStr)
      end
      table.insert(WrongGuesses, txt)
    end
  end
end

-- This is an example console command
function Pictionary:ExampleConsoleCommand()
  --print( '******* Example Console Command ***************' )
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      PlayerResource:ReplaceHeroWith(playerID, "npc_dota_hero_viper", 1000, 1000)
    end
  end

  --print( '*********************************************' )
end

function Pictionary:BeginRound()
  local cmdPlayer = Convars:GetCommandClient()
  if cmdPlayer then
    local playerID = cmdPlayer:GetPlayerID()
    if playerID ~= nil and playerID ~= -1 then
      -- Do something here for the player who called this command
      self:BeginRound()
    end
  end
end

function Pictionary:CreateVisionDummies(pos)
  -- 1 for radiant.
  local dummy = CreateUnitByName("vision_dummy", pos, true, nil, nil, DOTA_TEAM_GOODGUYS)
  dummy:FindAbilityByName("pictionary_dummy_unit"):SetLevel(1)
  dummy:SetHullRadius(0) -- don't give it collision.
  table.insert(self.visionDummies, dummy)

  -- move the dummy up to the ground on next frame.
  Timers:CreateTimer(function()
    local ground = GetGroundPosition(dummy:GetAbsOrigin(), dummy)
    FindClearSpaceForUnit(dummy, ground, true)
  end)


  -- 1 for dire.
  dummy = CreateUnitByName("vision_dummy", pos, true, nil, nil, DOTA_TEAM_BADGUYS)
  dummy:FindAbilityByName("pictionary_dummy_unit"):SetLevel(1)
  dummy:SetHullRadius(0) -- don't give it collision.
  table.insert(self.visionDummies, dummy)
  
  -- move the dummy up to the ground on next frame.
  Timers:CreateTimer(function()
    local ground = GetGroundPosition(dummy:GetAbsOrigin(), dummy)
    FindClearSpaceForUnit(dummy, ground, true)
  end)
end

---------------------------------------------------------------------------
-- Simple scoreboard using debug text
---------------------------------------------------------------------------
function Pictionary:UpdateScoreboard()
  if FreestyleMode then
    return
  end

  local sorted = {}

  for i,v in ipairs (Players) do
    table.insert(sorted, {name = v.playerName, plyID = v:GetPlayerID(), score = v.score})
  end
  -- reverse-sort by score
  table.sort( sorted, function(a,b) return ( a.score > b.score ) end )

  CurrentWinner = sorted[1]

  UTIL_ResetMessageTextAll()
  UTIL_MessageTextAll( "#ScoreboardTitle", 204, 0, 102, 255 )

  for _, vals in pairs( sorted ) do
    local clr = self:ColorForPlayer( vals.plyID )
    UTIL_MessageTextAll(vals.name .. self.whitespace[vals.name] .. vals.score, clr[1], clr[2], clr[3], 255)
  end
end

---------------------------------------------------------------------------
-- Get the color associated with a given teamID
---------------------------------------------------------------------------
function Pictionary:ColorForPlayer( plyID )
  local color = self.m_TeamColors[ plyID ]
  if color == nil then
    color = { 255, 255, 255 } -- default to white
  end
  return color
end

function Pictionary:PlayMusic(  )
  -- roll a random song for everyone
  CurrentSong = Songs[math.random(#Songs)]

  for i,v in ipairs(Players) do
    if not v.musicOn then
      EmitSoundOnClient(CurrentSong, v:GetPlayerOwner())
      v.musicOn = true
    end
  end
end

function Pictionary:StopMusic(  )
  for i,v in ipairs(Players) do
    if v.musicOn then
      StopSoundEvent(CurrentSong, v:GetPlayerOwner())
      v.musicOn = false
    end
  end
end

