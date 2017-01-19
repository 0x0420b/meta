local function rotation()
--------------------------
--- Havoc: CuteOne ---
--------------------------

-- Locals
	local addsIn = 999
	local bladeDanceVar
	local chaleave
	local flood
    local prepared
	local poolForBladeDance
	local poolForMeta
    local poolForChaosStrike
    local aoeCount = 1

-- Prepared Numeric Return
    if buff.exists('player',buff.prepared) then prepared = 1 else prepared = 0 end

-- First Blood Numeric Return
	if talent.firstBlood then flood = 1 else flood = 0 end

-- Chaos Cleave Numeric Return
	if talent.chaosCleave then chaleave = 1 else chaleave = 0 end

-- Variable Blade Dance
	-- variable,name=blade_dance,value=talent.first_blood.enabled|spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*2)
	if talent.firstBlood or #enemies.inRange('player',8) >= aoeCount + chaleave then bladeDanceVar = true else bladeDanceVar = false end

-- Pool For Metamorphosis
	-- variable,name=pooling_for_meta,value=cooldown.metamorphosis.ready&(!talent.demonic.enabled|!cooldown.eye_beam.ready)&(!talent.chaos_blades.enabled|cooldown.chaos_blades.ready)&(!talent.nemesis.enabled|debuff.nemesis.up|cooldown.nemesis.ready)
	if spell.cd(metamorphosis) and (not talent.demonic or spell.cd(eyeBeam) > 0) and (not talent.chaosBlades or spell.cd(chaosBlades) == 0) 
		and (not talent.nemesis or debuff.exists('player',debuff.nemesis,enemies.target(5,true),'player') or spell.cd(nemesis) == 0)
	then
		poolForMeta = true
	else
		poolForMeta = false
	end

-- Pool For Blade Dance
	-- variable,name=pooling_for_blade_dance,value=variable.blade_dance&fury-40<35-talent.first_blood.enabled*20&(spell_targets.blade_dance1>=3+(talent.chaos_cleave.enabled*2))
	if fury:amount() - 40 < 35 - flood * 20 and #enemies.inRange('player',8) >= aoeCount + (chaleave * 2) then poolForBladeDance = true else poolForBladeDance = false end

-- Pool For Chaos Strike
    -- variable,name=pooling_for_chaos_strike,value=talent.chaos_cleave.enabled&fury.deficit>40&!raid_event.adds.up&raid_event.adds.in<2*gcd
    if talent.chaosCleave and fury:deficit() > 40 then poolForChaosStrike = true else poolForChaosStrike = false end

-- Functions
-- Cancel Fel Rush
	function cancelRushAnimation()
        if cast.check(felRush) then
            MoveBackwardStart()
            JumpOrAscendStart()
            cast.felRush()
            MoveBackwardStop()
            AscendStop()
        end
        return
    end
-- Action List: Cooldowns
	function actionList_Cooldowns()
		if unit.isBoss(enemies.target(5,true)) and unit.distance(enemies.target(5,true)) < 5 then
	-- Metamorphosis
			-- metamorphosis,if=variable.pooling_for_meta&fury.deficit<30
			if cast.check(metamorphosis) and poolForMeta and fury:deficit() < 30 then
				cast.metamorphosis()
			end
		end 
	end

-- Begin Rotations
	if unit.valid('target') and not unit.casting('player') then
	-- Start Attack
        -- actions=auto_attack
        startAttack()
    -- Blur
    	-- blur,if=artifact.demon_speed.enabled&cooldown.fel_rush.charges_fractional<0.5&cooldown.vengeful_retreat.remains-buff.momentum.remains>4
    	if cast.check(blur) and artifact.demonSpeed and spell.chargesFrac(felRush) < 0.5 and spell.cd(vengefulRetreat) - buff.remain('player',buff.momentum) > 4 then
    		cast.blur()
    	end
    -- Cooldowns
    	-- call_action_list,name=cooldown
    	actionList_Cooldowns()
    -- Fel Rush
    	-- fel_rush,animation_cancel=1,if=time=0
    	-- TODO
    -- Vengeful Retreat
    	-- vengeful_retreat,if=(talent.prepared.enabled|talent.momentum.enabled)&buff.prepared.down&buff.momentum.down
    	if cast.check(vengefulRetreat) and (talent.prepared or talent.momentum) and not buff.exists('player',buff.prepared) 
    		and not buff.exists('player',buff.momentum) and unit.distance(enemies.target(5,true)) < 5 and unit.facing('player',enemies.target(5,true)) 
    	then
    		cast.vengefulRetreat()
    	end
    -- Fel Rush
    	-- fel_rush,if=(talent.momentum.enabled|talent.fel_mastery.enabled)&(!talent.momentum.enabled|(charges=2|cooldown.vengeful_retreat.remains>4)&buff.momentum.down)&(!talent.fel_mastery.enabled|fury.deficit>=25)&(charges=2|(raid_event.movement.in>10&raid_event.adds.in>10))
    	if cast.check(felRush) and (talent.momentum or talent.felMastery) and (not talent.momentum or ((spell.charges(felRush) == 2 or spell.cd(vengefulRetreat) > 4) 
    		and not buff.exists('player',buff.momentum))) and (not talent.felMastery or fury:deficit() >= 25) and (spell.charges(felRush) == 2 or addsIn > 10)
    		and unit.facing('player',enemies.target(5,true),10)
    	then
    		if unit.distance('target') >= 10 then
    			cast.felRush()
    		else
    			cancelRushAnimation()
    		end
    	end
    -- Fel Barrage
    	-- fel_barrage,if=charges>=5&(buff.momentum.up|!talent.momentum.enabled)&((active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>30)
    	if cast.check(felBarrage) and spell.charges >= 5 and (not talent.momentum or buff.exists('player',buff.momentum)) and (#enemies.inRange('player',20) > aoeCount or addsIn > 30) then
    		cast.felBarrage()
    	end
    -- Throw Glaive
    	-- throw_glaive,if=talent.bloodlet.enabled&(!talent.momentum.enabled|buff.momentum.up)&charges=2
    	if cast.check(throwGlaive) and talent.bloodlet and (not talent.momentum or buff.exists('player',buff.momentum)) and spell.charges(throwGlaive) == 2 and unit.facing('player',enemies.target(30,true)) then
    		cast.throwGlaive()
    	end
    -- Fel Eruption
    	-- fel_eruption
    	if cast.check(felEruption) then
    		cast.felEruption()
    	end
    -- Fury of the Illidari
    	-- fury_of_the_illidari,if=(active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>55&(!talent.momentum.enabled|buff.momentum.up)
    	if cast.check(furyOfTheIllidari) and (#enemies.inRange('player',8) > aoeCount or (addsIn > 55 and (not talent.momentum or buff.exists('player',buff.momentum)))) and unit.distance(enemies.target(5,true)) < 5 then
    		cast.furyOfTheIllidari()
    	end
    -- Eye Beam
    	-- eye_beam,if=talent.demonic.enabled&(talent.demon_blades.enabled|talent.blind_fury.enabled|(!talent.blind_fury.enabled&fury.deficit<30))&((active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>30)
    	if cast.check(eyeBeam) and talent.demonic and (talent.demonBlades or talent.blindFury or (not talent.blindFury and fury:deficit() < 30)) 
    		and (#enemies.inRange('player',8) > aoeCount or addsIn > 30) and unit.distance(enemies.target(8,true)) < 8 and unit.facing('player',enemies.target(8,true))
    	then
    		cast.eyeBeam()
    	end
    -- Death Sweep
    	-- death_sweep,if=variable.blade_dance
    	if cast.check(bladeDance) and bladeDanceVar and buff.exists('player',buff.metamorphosis) then
    		cast.bladeDance()
    	end
    -- Blade Dance
    	-- blade_dance,if=variable.blade_dance
    	if cast.check(bladeDance) and bladeDanceVar and not buff.exists('player',buff.metamorphosis) then
    		cast.bladeDance()
    	end
    -- Throw Glaive
    	-- throw_glaive,if=talent.bloodlet.enabled&spell_targets>=2&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&(spell_targets>=3|raid_event.adds.in>recharge_time+cooldown)
    	if cast.check(throwGlaive) and talent.bloodlet and #enemies.inRange('player',30) >= 2 
    		and (not talent.masterOfTheGlaive or not talent.momentum or buff.exists('player',buff.momentum)) and (#enemies.inRange('player',30) >= 3 or addsIn > spell.recharge(throwGlaive) + spell.cd(throwGlaive))
    		and unit.facing('player',enemies.target(30,true)) 
    	then
    		cast.throwGlaive()
    	end
    -- Felblade
    	-- felblade,if=fury.deficit>=30+buff.prepared.up*8
    	if cast.check(felblade) and fury:deficit() >= 30 + prepared * 8 then
    		cast.felblade()
    	end
    -- Eye Beam
    	-- eye_beam,if=talent.blind_fury.enabled&(spell_targets.eye_beam_tick>desired_targets|fury.deficit>=35)
    	if cast.check(eyeBeam) and talent.blindFury and (#enemies.inRange('player',8) > aoeCount or fury:deficit() >= 35) then
    		cast.eyeBeam()
    	end
   	-- Annihilation
   		-- annihilation,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8|buff.metamorphosis.remains<5)&!variable.pooling_for_blade_dance
   		if cast.check(chaosStrike) and buff.exists('player',buff.metamorphosis) and (talent.demonBlades or not talent.momentum or buff.exists('player',buff.momentum) 
   			or fury:deficit() < 30 + prepared * 8 or buff.remain('player',buff.metamorphosis) < 5) and not poolForBladeDance 
   		then
   			cast.chaosStrike()
   		end
    -- Throw Glaive
    	-- throw_glaive,if=talent.bloodlet.enabled&(!talent.master_of_the_glaive.enabled|!talent.momentum.enabled|buff.momentum.up)&raid_event.adds.in>recharge_time+cooldown
    	if cast.check(throwGlaive) and talent.bloodlet and (not talent.masterOfTheGlaive or not talent.momentum or buff.exists('player',buff.momentum)) 
    		and addsIn > spell.recharge(throwGlaive) + spell.cd(throwGlaive) and unit.facing('player',enemies.target(30,true)) 
    	then
    		cast.throwGlaive()
    	end
    -- Eye Beam
    	-- eye_beam,if=!talent.demonic.enabled&!talent.blind_fury.enabled&((spell_targets.eye_beam_tick>desired_targets&active_enemies>1)|(raid_event.adds.in>45&!variable.pooling_for_meta&buff.metamorphosis.down&(artifact.anguish_of_the_deceiver.enabled|active_enemies>1)&!talent.chaos_cleave.enabled))
    	if cast.check(eyeBeam) then
    		if not talent.demonic and not talent.blindFury and (#enemies.inRange('player',20) >= aoeCount 
    				or (addsIn > 45 and not poolForMeta and not buff.exists('player',buff.metamorphosis) and (artifact.anguishOfTheDeceiver or #enemies.inRange('player',20) > 1) and not talent.chaosCleave))
    			and unit.distance(enemies.target(8,true)) < 8 and unit.facing("player",enemies.target(5,true),45)
    		then
    			cast.eyeBeam()
    		end
    	end
    -- Demon's Bite
    	-- demons_bite,if=talent.demonic.enabled&!talent.blind_fury.enabled&buff.metamorphosis.down&cooldown.eye_beam.remains<gcd&fury.deficit>=20
    	if cast.check(demonsBite) and talent.demonic and not talent.blindFury and not buff.exists('player',buff.metamorphosis) and spell.cd(eyeBeam) < spell.gcd() and fury:deficit() >= 20 then
    		cast.demonsBite()
    	end
    	-- demons_bite,if=talent.demonic.enabled&!talent.blind_fury.enabled&buff.metamorphosis.down&cooldown.eye_beam.remains<2*gcd&fury.deficit>=45
    	if cast.check(demonsBite) and talent.demonic and not talent.blindFury and not buff.exists('player',buff.metamorphosis) and spell.cd(eyeBeam) < 2 * spell.gcd() and fury:deficit() >= 45 then
    		cast.demonsBite()
    	end
    -- Throw Glaive
    	-- throw_glaive,if=buff.metamorphosis.down&spell_targets>=2
    	if cast.check(throwGlaive) and not buff.exists('player',buff.metamorphosis) and #enemies.inRange('player',30) >= 2 and unit.facing('player',enemies.target(30,true)) then
    		cast.throwGlaive()
    	end
    -- Chaos Strike
    	-- chaos_strike,if=(talent.demon_blades.enabled|!talent.momentum.enabled|buff.momentum.up|fury.deficit<30+buff.prepared.up*8)&!variable.pooling_for_chaos_strike&!variable.pooling_for_meta&!variable.pooling_for_blade_dance&(!talent.demonic.enabled|!cooldown.eye_beam.ready|(talent.blind_fury.enabled&fury.deficit<35))
    	if cast.check(chaosStrike) and not buff.exists('player',buff.metamorphosis) then
    		if (talent.demonBlades or not talent.momentum or buff.exists('player',buff.momentum) or fury:deficit() < 30 + prepared * 8) 
    			and not poolForChaosStrike and not poolForMeta and not poolForBladeDance and (not talent.demonic or spell.cd(eyeBeam) > 0 or (talent.blindFury and fury:deficit() < 35)) 
    		then
    			cast.chaosStrike()
    		end
    	end
    -- Fel Barrage
    	-- fel_barrage,if=charges=4&buff.metamorphosis.down&(buff.momentum.up|!talent.momentum.enabled)&((active_enemies>desired_targets&active_enemies>1)|raid_event.adds.in>30)
    	if cast.check(felBarrage) and not buff.exists('player',buff.metamorphosis) and (buff.exists('player',buff.momentum) or not talent.momentum) and (#enemies.inRange('player',20) > aoeCount or addsIn > 30) then
    		cast.felBarrage()
    	end
    -- Fel Rush
    	-- fel_rush,animation_cancel=1,if=!talent.momentum.enabled&raid_event.movement.in>charges*10
    	if cast.check(felRush) and unit.facing('player','target',10) and not talent.momentum then
    		if unit.distance('target') >= 10 then
    			cast.felRush()
    		else
    			cancelRushAnimation()
    		end
    	end
	-- Demon's Bite
        -- demons_bite
        if cast.check(demonsBite) then
        	cast.demonsBite()
        end
    -- Throw Glaive
        -- throw_glaive,if=buff.out_of_range.up
        if cast.check(throwGlaive) and unit.distance('target') >= 15 and unit.facing('player','target') then
        	cast.throwGlaive()
        end
    -- Felblade
    	-- felblade,if=movement.distance|buff.out_of_range.up
    	if cast.check(felblade) and unit.distance('target') >= 15 then
    		cast.felblade()
    	end
    -- Fel Rush
    	--fel_rush,if=movement.distance>15|(buff.out_of_range.up&!talent.momentum.enabled)
    	if cast.check(felRush) and unit.facing('player','target',10) then
    		if unit.distance('target') >= 10 then
    			cast.felRush()
    		else
    			cancelRushAnimation()
    		end
    	end
	end
end

local HavocCuteOne = {
    profileID = 577,
    profileName = "CuteOne",
    rotation = rotation
}

-- Return Profile
return HavocCuteOne