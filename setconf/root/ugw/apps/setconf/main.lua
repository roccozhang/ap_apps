package.path = "./?.lua;../apshare/?.lua;" .. package.path
require("global")
local se = require("se") 
local log = require("log") 
local reset = require("reset")
local reboot = require("reboot")
local js = require("cjson.safe")  
local const = require("constant")   
local compare = require("compare")
local support = require("support") 
local memfile = require("memfile")
local blacklist = require("blacklist")
local led = require("led_ctrl")

local keys = const.keys
local mf_commit = memfile.ins("commit")

js.encode_keep_buffer(false)
local g_apid

local function read(path, func)
	func = func and func or io.open
	local fp = func(path, "rb")
	if not fp then 
		return 
	end 
	local s = fp:read("*a")
	fp:close()
	return s
end

local function get_apid()
	if not g_apid then
		local mac = read("ifconfig eth0 | grep HWaddr | awk '{print $5}'", io.popen) 
		g_apid = mac and mac:gsub("[ \t\n]", ""):lower()	assert(#g_apid == 17)
	end 
	return g_apid
end

local function get_new_cfg()
	local path = "/ugwconfig/etc/ap/ap_config.json"
	local s = read(path)
	if not s then
		log.error("read %s fail", path)
		return
	end 

	local map = js.decode(s)
	local _ = map or log.error("parse %s fail", path) 
	return map
end 

local function main() 
	log.setmodule("sf")
	log.setdebug(true) 
	log.info("start setconf") 

	g_apid = get_apid()
	support.init_band_support()

	reboot.run(g_apid, get_new_cfg()) 
	se.go(blacklist.run)
	se.go(led.run)
	local chk = compare.new_chk_file("sf")
	while true do
		if chk:check() then 
			log.debug("config change")
			local nmap = get_new_cfg()
			if nmap then 
				reset.check(nmap)
				reboot.check(nmap)
				se.go(blacklist.clear)
			end
		end
		se.sleep(1)
	end
end

se.run(main)
