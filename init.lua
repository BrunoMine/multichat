--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
  ]]

minetest.register_privilege("chat_moderador", "Usar char como moderador")
minetest.register_privilege("chat_admin", "Usar char como administrador")

-- Variavel global
multichat = {}

-- Emitir som de aviso
local som_avisar = function(name)
	local player = minetest.get_player_by_name(name)
	minetest.sound_play("multichat_aviso", {
		   object = player,
		   gain = 0.5,
		   max_hear_distance = 1,
		   loop = false,
	})
end


