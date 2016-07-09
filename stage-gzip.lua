-- part of lua-backup project
-- gzip compression stage

Stage_gzip = inheritsFrom(Stage)

function Stage_gzip:new(config) 
	local inst = Stage_gzip:create()
	inst:init(config)
	return inst
end

function Stage_gzip:init(config) 
	self.name = "gzip"
	Stage.init(self, config)
end

function Stage_gzip:execute(files, fname)
	local r = { }
	for i,v in ipairs(files) do
		local cmd = string.format("gzip %s", v)
		shell.WetExecute(cmd)
		r[#r + 1] = v .. ".gz"
	end
	fname = fname .. ".gz"
	return r, fname
end

--[[
BusyBox v1.22.1 (2014-09-21 11:14:01 CEST) multi-call binary.

Usage: gzip [-cfd] [FILE]...

Compress FILEs (or stdin)

        -d      Decompress
        -c      Write to stdout
        -f      Force

]]
