_addon.name = 'AR' _addon.author = 'yksala, zerodragoon' _addon.version = '1.0' _addon.command = 'ar' _addon.commands = {'c'}

windower.send_command('alias toggle_ws ar toggle_ws')
windower.send_command('alias toggle_autows ar toggle_autows') 
windower.send_command('alias toggle_autohalt ar toggle_autohalt')  
windower.send_command('alias toggle_mode ar toggle_mode') 
windower.send_command('alias toggle_tp_percent ar toggle_tp_percent')

res = require('resources')

locked = false
auto_ws = false
auto_halt = false
auto_halt_and_resume = false
tick = 0 
ws_selected = "last stand" 
mode = "off" 
ws_array = {'Last Stand', 'Wildfire', 'Leaden Salute', 'Trueflight', 'Coronach'}
tp_points = {1000, 1250, 1500, 1750, 2000, 2500, 2750, 3000} 
tp_selector = 1 
tp_percent = tp_points[tp_selector]

function toggle_ws()
	if ws_selected == 'last stand' then
		ws_selected= 'wildfire'
		windower.add_to_chat(207, 'Toggle WS:  Last_Stand [Wildfire] Leaden_Salute Trueflight Coronach')
	elseif ws_selected == 'wildfire' then
		ws_selected = 'leaden salute'
		windower.add_to_chat(207, 'Toggle WS:  Last_Stand Wildfire [Leaden_Salute] Trueflight Coronach') 
	elseif ws_selected == 'leaden salute' then
		ws_selected = 'trueflight'
		windower.add_to_chat(207, 'Toggle WS:  Last_Stand Wildfire Leaden_Salute [Trueflight] Coronach')
	elseif ws_selected == 'trueflight' then
		ws_selected = 'coronach'
		windower.add_to_chat(207, 'Toggle WS:  Last_Stand Wildfire Leaden_Salute Trueflight [Coronach]')
	elseif ws_selected == 'coronach' then
		ws_selected = 'last stand'
		windower.add_to_chat(207, 'Toggle WS:  [Last_Stand] Wildfire Leaden_Salute Trueflight Coronach')
	end
end

function toggle_mode() 
	if mode == "off" then 
		mode = "on" 
		windower.add_to_chat(207, 'Toggle Mode: AR is now turned [ON]') 
	elseif mode == "on" then 
		mode = "off" 
		windower.add_to_chat(207, 'Toggle Mode: AR is now turned [OFF]') 
	end 
end

function toggle_autows() 
	if auto_ws == false then 
		auto_ws = true
		windower.add_to_chat(207, 'Toggle Mode: AutoWS is now turned [ON]') 
	elseif auto_ws == true then 
		auto_ws = false
		windower.add_to_chat(207, 'Toggle Mode: AutoWS is now turned [OFF]') 
	end 
end

function toggle_autohalt() 
	if auto_halt == false then 
		auto_halt = true
		windower.add_to_chat(207, 'Toggle Mode: AutoHalt is now turned [ON]') 
	elseif auto_halt == true then 
		auto_halt = false
		windower.add_to_chat(207, 'Toggle Mode: AutoHalt is now turned [OFF]') 
	end 
end

function toggle_autohaltandresume() 
	if auto_halt_and_resume == false then 
		auto_halt_and_resume = true
		auto_halt = true
		windower.add_to_chat(207, 'Toggle Mode: AutoHaltAndResume is now turned [ON]') 
	elseif auto_halt_and_resume == true then 
		auto_halt_and_resume = false
		auto_halt = false
		windower.add_to_chat(207, 'Toggle Mode: AutoHaltAndResume is now turned [OFF]') 
	end 
end


function toggle_tp_percent()
	if tp_selector >=1 and tp_selector <= 7 then
		tp_selector = tp_selector + 1
	else
		tp_selector = 1
	end
	tp_percent =  tp_points[tp_selector]
	windower.add_to_chat(207, 'toggle_tp_percent:  Auto weaponskill:  ' .. tp_percent)
end

function getTableSize(table) 
	local size = 0 
	for k, v in pairs(table) 
	do 
	 --print(k, v[1], v[2], v[3]) 
		size = size + 1 
	end 
	 --print(size) 
	 return size 
end

function checkPrevent()

	local prevented = false
	debuffs = windower.ffxi.get_player().buffs
	local preventDebuffs = {"stun", "sleep", "chaared", "petrifed"}
	local tableSize = getTableSize(preventDebuffs)

	for i,v in ipairs(debuffs) do

		if prevented == false then
			for j=1, tableSize do
				if res.buffs[v].en:lower() == preventDebuffs[j] then
					--print(res.buffs[v].en:lower() .. ' ' .. preventDebuffs[j])
					prevented = true
				end
			end
		end
	end

	if prevented == true or locked == true then
		--print('prevented')
		return true
	elseif prevented == false and locked == false then
		--print('not prevented')
		return false
	else
		--print('wtff')
	end
end

function checkDistance(mob_info) --print(math.sqrt(id.distance)) 
	if math.sqrt(mob_info.distance) <= 25 then 
		return true 
	else print('mob out of range') 
		return false 
	end 
end 
--[[ function closeDistance(mob_info)

	local dist_to_mob = math.sqrt(mob_info.distance)

	if dist_to_mob > 25 then
		windower.ffxi.follow(mob)
		coroutine.schedule(closeDistance()
		, 1)
	else
		windower.ffxi.follow()
	end
	end --]] 
	
function checkHp(mob) 
	if mob.hpp > 0 then 
		return true 
	else 
		--print('mob died') 
		return false 
	end 
end

function schedule_ra() 
	--print('entered schedule_ra') 
	locked = true 
	coroutine.schedule(function() windower.send_command('input /ra <t>') end, 1.2) 
end

function schedule_schedule_ra() 
	coroutine.schedule(function() schedule_ra() end, 5) 
end

function schedule_tp() 
	--print('entered schedule_tp') 
	locked = true 
	coroutine.schedule(function() 
		windower.send_command('input /ws "' .. ws_selected ..'" <t>')

		if mode == "on" then
			coroutine.schedule(function()
				windower.send_command('input /ra <t>')
			end, 5)
			--windower.add_to_chat(207, "Mode:  ON == Cntinue to keep firing after weaponskill")
		else
			--windower.add_to_chat(207, "Mode:  OFF == End firing after weaponskill")
		end
		
	end, 1.5)
end

windower.register_event('action',function (act)

	local player = windower.ffxi.get_player()
	local mob = 0
	local mob_info = 0

	--if windower.ffxi.get_mob_by_id(act.actor_id).name == player.name then
		--print('doing something?: '.. windower.ffxi.get_mob_by_id(act.actor_id).name)
		--print('================================')
	--end

	if act.actor_id == player.id and mode ~= "off" then -- actions by us

		if act.category == 12 then --Event is sent upon initiating a ranged attack
			mob = windower.ffxi.get_mob_by_target('t')

			if type(mob) ~= nil then
				mob_info = windower.ffxi.get_mob_by_id(mob.id)
			end
			--print('Targed mob_id:  ' .. mob_info.id .. ', Name:  '.. mob_info.name)
			if checkHp(mob_info) == true then

				if checkPrevent() == false then

					if checkDistance(mob_info) == true then
						--success, finished firing. need to trigger 
						locked = true
						--fire(mob_info)
					elseif checkDistance(mob_info) == false then
						windower.add_to_chat(207, "WARNING:  You are out of firing range")
					end

				end

			end

		end
		if act.category == 2 and mode ~= "off" then --Category for the execution of a ranged attack
			--print(act.targets[1].actions[1].message)
			if act.targets[1].actions[1].message > 0 then
				--print('finished ranged attack in category 2')
				--locked = false
				--print(windower.ffxi.get_player().vitals.tp)
				if windower.ffxi.get_player().vitals.tp > tp_percent and auto_ws then
					schedule_tp()
				elseif windower.ffxi.get_player().vitals.tp > tp_percent and auto_halt then
					--fall out
					if auto_halt_and_resume then
						schedule_schedule_ra()
					end
				else
					schedule_ra()
				end
				locked = false
			end
		end
		if act.category == 3 and mode ~= "off" and auto_ws then --Category for the execution of player WSs or direct damage abilities like Jump

			locked = false
			schedule_ra()

		end
	end
end)

-----this needs to be last------ 
windower.register_event('addon command', function (...) 
	local args = T{...}:map(string.lower)
	--print(args[1]) 
	--print(args[2]) 
	if args[1] == "toggle_ws" then 
		toggle_ws()
	elseif args[1] == "toggle_autows" then 
		toggle_autows() 	
	elseif args[1] == "toggle_autohalt" then 
		toggle_autohalt()
	elseif args[1] == "toggle_autohaltandresume" then 
		toggle_autohaltandresume() 
	elseif args[1] == "toggle_mode" then 
		toggle_mode()
	elseif args[1] == "toggle_tp_percent" then 
		toggle_tp_percent() 
	end
end)