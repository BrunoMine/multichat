--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)

	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>.

	-- Controle de jogadores online
  ]]


-- Jogadores online

multichat.online = {}

-- Adiciona jogador ao entrar
minetest.register_on_joinplayer(function(player)
	multichat.online[player:get_player_name()] = {}
end)

-- Remove nome do jogador ao sair
minetest.register_on_leaveplayer(function(player)
	multichat.online[player:get_player_name()] = nil
end)
