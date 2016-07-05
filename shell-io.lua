-- part of lua-backup project
-- shell helpers

local shell = { }
_G["shell"] = shell

function shell.buildcmd(cmd, argsdict, argtable, ...)
	local t = { cmd }
	
	for k,v in pairs(argsdict or {}) do
		if k:len() > 1 then
			t[#t + 1] = "-" .. k;
		else
			t[#t + 1] = "--" .. k;
		end
		t[#t + 1] = v
	end
	
	for k,v in ipairs(argsdict or {}) do
		if k:len() > 1 then
			t[#t + 1] = "-" .. k;
		else
			t[#t + 1] = "--" .. k;
		end
	end
	
	for i,v in ipairs(argtable or {}) do
		t[#t + 1] = v
	end	
	
	for i,v in ipairs({...}) do
		t[#t + 1] = v
	end	

	return table.concat(t, " ")
end

function shell.start(cmd, argsdict, argtable, ...)
	return shell.execute(shell.buildcmd(cmd, argsdict, argtable, ...))
end

function shell.execute(cmd)
	log:os(cmd)
	local file = io.popen(cmd)
	local l
	while true do 
		l = file:read "*l"
		if not l then
			break
		end
		log:shell(l)
	end
	return file:close()
end

function shell.forEachLineOf(cmd)
	log:os(cmd)
	
	local h = io.popen(cmd)
	
	return function()
		local line = h:read "*l"
		if not line then
			h:close()
			return nil
		end
		return line
	end
end

function shell.linesOf(cmd)
	local r = { }
	local l
	for l in shell.forEachLineOf(cmd) do
		r[#r + 1] = l
	end
	return r
end

function shell.inputTo(cmd)
	log:os(cmd)
	local h = io.popen(cmd, "w")
	return h
end

function shell.fsize(fn)
	local file = io.open(fn)
	if not file then
		log:error(string.format("Unable to open file '%s' to get file size!", fn))
		return 0
	end
	local size = file:seek("end")    -- get file size
	file:close()
	return size
end

local unix = { }

function shell.init() 
	local localshell = unix
	
	local k,v
	for k,v in pairs(localshell) do
		shell[k] = v
	end
	
	log:info("Shell initialized to unix")
end

---------------------UNIX----------------------

function unix.copy(src, dst)
	local cmd = string.format("cp %s %s", src, dst)
	return shell.execute(cmd)
end

function unix.move(src, dst)
	local cmd = string.format("mv %s %s", src, dst)
	return shell.execute(cmd)
end

function unix.rename(src, dst)
	local cmd = string.format("mv %s %s", src, dst)
	return shell.execute(cmd)
end

function unix.createDirectory(path)
	local cmd = string.format("mkdir -p %s", path)
	return shell.execute(cmd)
end

function unix.removeFile(file)
	local cmd = string.format("rm %s", file)
	return shell.execute(cmd)
end

function unix.temp()
	return "/tmp/"
end
