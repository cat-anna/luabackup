-- part of lua-backup project
-- tar container stage

Stage_tar = inheritsFrom(Stage)

function Stage_tar:new(config) 
	local inst = Stage_tar:create()
	inst:init(config)
	return inst
end

function Stage_tar:init(config) 
	self.name = "tar"
	Stage.init(self, config)
	if config then
		self.compress = config.compress
	end
end

function Stage_tar:execute(files, fname)
	local cmd
	if self.compreess then
		fname = fname .. ".tar.gzip"
		cmd = string.format("tar -czf %s -T -", basename)	
	else
		fname = fname .. ".tar"
		cmd = string.format("tar -cf %s -T -", fname)
	end
	if luabackup.dryrun then
		shell.WetExecute(cmd)
	else
		local tar = shell.inputTo(cmd)
		local i,v
		for i,v in ipairs(files) do
			tar:write(v, "\n")
		end
		tar:close()	
	end

	return { fname }, fname
end

--[[
BusyBox v1.22.1 (2014-09-21 11:14:01 CEST) multi-call binary.

Usage: tar -[cxtzhvO] [-X FILE] [-T FILE] [-f TARFILE] [-C DIR] [FILE]...

Create, extract, or list files from a tar file

Operation:
        c       Create
        x       Extract
        t       List
        f       Name of TARFILE ('-' for stdin/out)
        C       Change to DIR before operation
        v       Verbose
        z       (De)compress using gzip
        O       Extract to stdout
        h       Follow symlinks
        X       File with names to exclude
        T       File with names to include

]]
