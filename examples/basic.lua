
require "luabackup"

local d = os.date("*t")
local fn = string.format("%04d%02d%02d%02d%02d%02d", d.year, d.month, d.day, d.hour, d.min, d.sec)	

luabackup.incremental = incremental

backup:init("testsettings.lua")
pipelines:setDefaultPipeline("tar-gzip-ccrypt")

pipelines:register("tar-gzip-ccrypt", {
	Stage_tar:new(),
	Stage_gzip:new(),
	Stage_ccrypt:new({
		key="test-key"
	}),
})

input:add(Input_git:new{
	name="gitrepos",
	root="./..",
})

output:add(Output_fs:new{
	name="local",
	dir="~/backup/" .. fn .. "/",
	mode = { backup = "y", log = "y" },
	triggers = {
		logFile = function(f) log:info("logfile " .. f); end,
	},
})

backup:start()
