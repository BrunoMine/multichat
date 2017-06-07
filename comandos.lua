--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Comandos
	
  ]]

minetest.register_chatcommand("chat", {
	description = "Abrir painel do bate-papo",
	privs = {},
	func = function(name)
		multichat.acessar_menu(name)
	end,
})
