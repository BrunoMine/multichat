--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
	Ajuste no comando /msg
	
  ]]


local som_avisar = multichat.som_avisar

-- Enviar mensagem para jogador
local enviar_msg = function(name, msg, falante)
	local player = minetest.get_player_by_name(name)
	local status = player:get_attribute("multichat_status")
	
	-- Verifica se o jogador está no bate-papo público
	if status == nil or status == "pub" then
		minetest.chat_send_player(name, "* "..falante.." "..msg)
		
		-- Evita avisar a si mesmo
		if name ~= falante then 
			som_avisar(name, msg)
		else
			som_avisar(name)
		end
		
	-- Verificar se está desativado
	elseif status == "off" then
		return
	
	-- Verifica se jogador está ouvindo apenas seu grupo
	elseif status == "grupo" and multichat.grupos[name] then
	
		-- Verifica se falante está no grupo
		if multichat.grupos[name][falante] then
			minetest.chat_send_player(name, "* "..falante.." "..msg)
			som_avisar(name, msg)
		end
	end
	
end

local old_func = minetest.chatcommands.me.func

function minetest.chatcommands.me.func(name, param)
	
	-- Enviar chamada em todos os jogadores
	for _,player in ipairs(minetest.get_connected_players()) do
		local np = player:get_player_name()
		enviar_msg(np, param, name)
	end
	
end
