-- examples on how to do things:
--abil:ApplyDataDrivenModifier(GlobalDummy, unit, "no_collision", {})

--[[
       MODULE LOADERS STUFF
]]

BASE_LOG_PREFIX   = '[P]'
LOG_FILE = "log/Pictionary.txt"

InitLogFile(LOG_FILE, "[[ Pictionary ]]")

function log(msg)
  print(BASE_LOG_PREFIX .. msg)
  AppendToLogFile(LOG_FILE, msg .. '\n')
end

function err(msg)
  display('[X] '..msg, COLOR_RED)
end

function warning(msg)
  display('[W] '..msg, COLOR_DYELLOW)
end

function display(text, color)
  color = color or COLOR_LGREEN

  log('> '..text)

  Say(nil, color..text, false)
end

--[[
       END OF MODULE LOADERS STUFF
]]

function tableContains( list, element )
  if list == nil then return false end
  for k,v in pairs(list) do
    if k == element then
      return true
    end
  end
  return false
end

function getIndex(list, element)
  if list == nil then return false end
  for i=1,#list do
    if list[i] == element then
      return i
    end
  end
  return -1
end

function VectorString(v)
  return 'x: ' .. v.x .. ' y: ' .. v.y .. ' z: ' .. v.z
end

function AddAbilityToUnit(hUnit, sName)
  if not hUnit then return end
  
  if not hUnit:HasAbility(sName) then
   hUnit:AddAbility(sName)
 end
  local abil = hUnit:FindAbilityByName(sName)
  abil:SetLevel(1)

  return abil
end

function RotateVector2D(v,theta)
  local xp = v.x*math.cos(theta)-v.y*math.sin(theta)
  local yp = v.x*math.sin(theta)+v.y*math.cos(theta)
  return Vector(xp,yp,v.z):Normalized()
end

function getOppositeTeam( unit )
  if unit:GetTeam() == DOTA_TEAM_GOODGUYS then
    return DOTA_TEAM_BADGUYS
  else
    return DOTA_TEAM_GOODGUYS
  end
end

function isPointWithinSquare(p, sqCenter)
  --if math.pow(player.hero:GetAbsOrigin().x,2) + math.pow(player.hero:GetAbsOrigin().y,2) <= math.pow(platformRadius-20,2)
  if (p.x > sqCenter.x-64 and p.x < sqCenter.x+64) and (p.y > sqCenter.y-64 and p.y < sqCenter.y+64) then
    return true
  else
    return false
  end
end

function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function DotProduct(v1,v2)
  return (v1.x*v2.x)+(v1.y*v2.y)
end

--[[
  Continuous collision algorithm, see
  http://www.gvu.gatech.edu/people/official/jarek/graphics/material/collisionFitzgeraldForsthoefel.pdf
  
  body1 and body2 are tables that contain:
  v: velocity
  c: center
  r: radius
  Returns the time-till-collision.
]]
function TimeTillCollision(body1,body2)
  local W = body2.v-body1.v
  local D = body2.c-body1.c
  local A = DotProduct(W,W)
  local B = 2*DotProduct(D,W)
  local C = DotProduct(D,D)-(body1.r+body2.r)*(body1.r+body2.r)
  local d = B*B-(4*A*C)
  if d>=0 then
    local t1=(-B-math.sqrt(d))/(2*A)
    if t1<0 then t1=2 end
    local t2=(-B+math.sqrt(d))/(2*A)
    if t2<0 then t2=2 end
    local m = math.min(t1,t2)
    --if ((-0.02<=m) and (m<=1.02)) then
    return m
      --end
  end
  return 2
end

function coinFlipHeads()
  return math.random() < .5 
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function ColorIt( sStr, sColor )
  --Default is cyan.
  local color = "00FFFF"

  if sColor == "green" then
    color = "ADFF2F"
  elseif sColor == "purple" then
    color = "EE82EE"
  elseif sColor == "blue" then
    color = "00BFFF"
  elseif sColor == "orange" then
    color = "FFA500"
  elseif sColor == "pink" then
    color = "DDA0DD"
  elseif sColor == "red" then
    color = "FF6347"
  elseif sColor == "cyan" then
    color = "00FFFF"
  elseif sColor == "yellow" then
    color = "FFFF00"
  elseif sColor == "brown" then 
    color = "A52A2A"
  elseif sColor == "magenta" then
    color = "FF00FF"
  elseif sColor == "teal" then
    color = "008080"
  end

  return "<font color='#" .. color .. "'>" .. sStr .. "</font>"
end

function string_split( str )
  local split = {}
  for i in string.gmatch(str, "%S+") do
    table.insert(split, i)
  end
  return split
end