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

	-- Verifica se está em grupo da guilda
	elseif status == "guilda" then

		-- Verifica se o recurso esta ativo
		if multichat.guild == false then return end

		-- Mod manipulus
		if multichat.mod_guild == "manipulus" then
			-- Guilda do ouvinte
			local my_guild = manipulus.get_player_grupo(name)
			-- Verifica se guilda ainda existe
			if my_guild == nil or manipulus.existe_grupo(my_guild) == false then return end
			-- Guilda do falante
			local you_guild = manipulus.get_player_grupo(falante)
			-- Verifica se guilda ainda existe
			if you_guild == nil or manipulus.existe_grupo(you_guild) == false then return end
			-- Envia mensagem
			minetest.chat_send_player(name, "* "..falante.." "..msg)
			som_avisar(name, msg)
		end

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
