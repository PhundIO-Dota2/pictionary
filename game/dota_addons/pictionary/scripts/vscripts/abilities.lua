function backspace( keys )
	local caster = keys.caster
	if caster.particles ~= nil and #caster.particles > 0 then
		-- get the last created particle.
		local p = caster.particles[#caster.particles]
		ParticleManager:DestroyParticle(p, true)
		table.remove(caster.particles, #caster.particles)
	end

end

function clear( keys )
	if keys.caster ~= Drawer then
		return
	end
	
	for i,v in ipairs(Drawer.particles) do
		ParticleManager:DestroyParticle(v, true)
	end
	Drawer.particles = {}
end

--[[Author: Amused/D3luxe
	Used by: Pizzalol
	Date: 17.12.2014.
	Blinks the target to the target point, if the point is beyond max blink range then blink the maximum range]]
function Blink(keys)
	--PrintTable(keys)
	local point = keys.target_points[1]
	local caster = keys.caster
	local casterPos = caster:GetAbsOrigin()
	local pid = caster:GetPlayerID()
	local difference = point - casterPos
	local ability = keys.ability
	local range = ability:GetLevelSpecialValueFor("blink_range", (ability:GetLevel() - 1))

	if difference:Length2D() > range then
		point = casterPos + (point - casterPos):Normalized() * range
	end

	FindClearSpaceForUnit(caster, point, false)	
end

function turn_on_pen( keys )
	if keys.caster ~= Drawer then
		return
	end
	keys.caster.penOn = true

	keys.caster:RemoveAbility("turn_on_pen")
	keys.caster:AddAbility("turn_off_pen")
	keys.caster:FindAbilityByName("turn_off_pen"):SetLevel(1)
end

function turn_off_pen( keys )
	if keys.caster ~= Drawer then
		return
	end
	keys.caster.penOn = false

	keys.caster:RemoveAbility("turn_off_pen")
	keys.caster:AddAbility("turn_on_pen")
	keys.caster:FindAbilityByName("turn_on_pen"):SetLevel(1)
end