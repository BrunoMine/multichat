--[[
	Mod MultiChat para Minetest
	Copyright (C) 2017 BrunoMine (https://github.com/BrunoMine)
	
	Recebeste uma cópia da GNU Lesser General
	Public License junto com esse software,
	se não, veja em <http://www.gnu.org/licenses/>. 
	
  ]]


-- Variavel global
multichat = {}

-- Notificador de Inicializador
local notificar = function(msg)
	if minetest.setting_get("log_mods") then
		minetest.debug("[MULTICHAT]"..msg)
	end
end

-- Verificar compatibilidades de versão
-- Versão do servidor
if minetest.get_version().string and string.find(minetest.get_version().string, "0.4.15") then
	minetest.log("error", "[MULTICHAT] Versao imcompativel (use 0.4.16 ou superior)")
end
-- Versão do cliente
if minetest.setting_get("strict_protocol_version_checking") ~= "true" then
	minetest.log("error", "[MULTICHAT] Incompativel com clientes inferiores a 0.4.16 (defina strict_protocol_version_checking para evitar erros)")
end


-- Modpath
local modpath = minetest.get_modpath("multichat")

-- Carregar scripts
notificar("Carregando...")
dofile(modpath.."/lib/memor/init.lua")

-- Variavel temporaria de jogadores online
multichat.online = memor.online()

dofile(modpath.."/chat.lua")
dofile(modpath.."/menu.lua")
dofile(modpath.."/msg.lua")
dofile(modpath.."/me.lua")
dofile(modpath.."/comandos.lua")
notificar("OK!")
