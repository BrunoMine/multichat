--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)

	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>.

	Chat

  ]]

local S = multichat.S

minetest.register_privilege("chat_admin", S("Usar chat como administrador"))
minetest.register_privilege("chat_staff", S("Usar chat como moderador"))

-- Grupos privados de cada jogador
multichat.grupos = {}

-- Pegar prefixos
S = multichat.Sfake
multichat.admin_prefix = minetest.setting_get("multichat_admin_prefix") or S("ADMIN")
multichat.staff_prefix = minetest.setting_get("multichat_staff_prefix") or S("MODERADOR")
S = multichat.S

local tocar_som = function(player) minetest.sound_play("multichat_aviso", {object = player,gain = 0.5,max_hear_distance = 1}) end
local tocar_chamada = function(player) minetest.sound_play("multichat_chamada", {object = player,gain = 0.5,max_hear_distance = 1}) end
-- Emitir som de aviso
multichat.som_avisar = function(name, msg)
	local player = minetest.get_player_by_name(name)

	-- Verificar se vai ser som de chamada
	if msg
		and player:get_attribute("multichat_chamada") ~= "false"
		and string.find(msg, name) ~= nil
	then
		tocar_chamada(player)
	-- Verifica se vai ser som normal
	elseif player:get_attribute("multichat_som") ~= "false" then
		tocar_som(player)
	end

end
local som_avisar = multichat.som_avisar

-- Pegar prefixo
multichat.prefixo = function(name)
	if minetest.check_player_privs(name, {chat_admin=true}) then return "["..S(multichat.admin_prefix).."]" end
	if minetest.check_player_privs(name, {chat_staff=true}) then return "["..S(multichat.staff_prefix).."]" end
	return ""
end

-- Enviar mensagem para jogador
local enviar_msg = function(name, msg, falante)
	local player = minetest.get_player_by_name(name)
	if player == nil then return end
	local status = player:get_attribute("multichat_status")

	-- Verifica se o jogador está no bate-papo público
	if status == nil or status == "pub" then
		minetest.chat_send_player(name, "<"..multichat.prefixo(falante)..falante.."> "..msg)

		-- Evita avisar a si mesmo
		if name ~= falante then
			som_avisar(name, msg)
		else
			som_avisar(name)
		end

	-- Verificar se está desativado
	elseif status == "off" then
		return

	-- Verifica se o jogador está ouvindo apenas seu grupo de guilda
	elseif status == "guilda" then
		minetest.chat_send_player(name, "<"..multichat.prefixo(falante)..falante.."> "..msg)

		-- Evita avisar a si mesmo
		if name ~= falante then
			som_avisar(name, msg)
		else
			som_avisar(name)
		end

	-- Verifica se jogador está ouvindo apenas seu grupo privado
	elseif status == "grupo" and multichat.grupos[name] then

		-- Verifica se falante está no grupo
		if multichat.grupos[name][falante] then
			minetest.chat_send_player(name, "<"..multichat.prefixo(falante)..falante.."> "..msg)
			som_avisar(name, msg)
		end
	end

end

-- Chamada para envio de mensagens de jogadores
local function on_chat_message(name, msg)
	-- Verifica se tem privilegio para falar
	if msg:sub(1, 1) == "/" or not minetest.get_player_by_name(name) then
		return
	end
	if not minetest.check_player_privs(name, {shout=true}) then return true end

	local player = minetest.get_player_by_name(name)
	local status = player:get_attribute("multichat_status")

	-- Verifica se o jogador está no bate-papo público
	if status == nil or status == "pub" then

		-- Envia a mensagem para todos os jogadores
		for _,player in ipairs(minetest.get_connected_players()) do
			enviar_msg(player:get_player_name(), msg, name)
		end

		if minetest.get_modpath("irc") then
			irc.say("<" .. name.. "> " .. msg)
		end

	-- Verificar se está desativado
	elseif status == "off" then
		minetest.chat_send_player(name, "Bate-papo desativado")

	-- Verifica se jogador está falando apenas com seu grupo
	elseif status == "guilda" then

		-- Verifica se o recurso esta ativo
		if not multichat.guild then return true end

		-- Mod manipulus
		if multichat.mod_guild == "manipulus" then
			-- Guilda do ouvinte
			local mg = manipulus.get_player_grupo(name)
			-- Verifica se guilda ainda existe
			if mg == nil or not manipulus.existe_grupo(mg) then return true end
			-- Envia a mensagem para todos os jogadores
			for _,player in ipairs(minetest.get_connected_players()) do
				local n = player:get_player_name()
				if manipulus.get_player_grupo(n) == mg then
					enviar_msg(n, msg, name)
				end
			end

		end

	-- Verifica se jogador está falando apenas com seu grupo privado
	elseif status == "grupo" then

		-- Envia a mensagem para todos os jogadores do grupo
		for np,v in pairs(multichat.grupos[name] or {}) do
			enviar_msg(np, msg, name)
		end

		-- Envia a si mesmo tambem para aparecer no console
		minetest.chat_send_player(name, "<"..multichat.prefixo(name)..name.."> "..msg)
		som_avisar(name)
	end
	return true
end

if minetest.get_modpath("irc") then
	table.insert(minetest.registered_on_chat_messages, 2, on_chat_message)
	minetest.callback_origins[on_chat_message] = {
		mod  = "multichat",
		name = "on_chat_message"
	}
else
	minetest.register_on_chat_message(on_chat_message)
end

-- Verificador de jogadores offline para remover grupos
minetest.register_on_leaveplayer(function(player)
	multichat.grupos[player:get_player_name()] = nil
end)
