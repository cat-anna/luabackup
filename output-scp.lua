-- part of lua-backup project
-- filesystem output

Output_scp = inheritsFrom(OutputInterface)

function Output_scp:new(config) 
	local inst = Output_fs:create()
	inst:init(config)
	return inst
end

function Output_scp:ssh(cmd) 	
	shell.start("ssh", self.argdict, self.argtable, cmd)
	self.stats.connections = self.stats.connections + 1
end

function Output_scp:scp(cmd) 	
	self.stats.connections = self.stats.connections + 1
	shell.start("ssh", self.argdict, self.argtable, cmd)
end

function Output_scp:init(config) 
	self.name = "scp"
	self.stats = {
		count = 0,
		bytes = 0,
		connections = 0,
	}
	OutputInterface.init(self, config)
	
	self.argdict = {
		p = config.connection.port,
	}
	
	self.argtable = {
		config.connection.user .. "@" .. config.connection.host
	}	
	
	self:ssh("mkdir -p '" .. config.dir .. "'")
end

function Output_scp:processFile(file, islog)
	--local outdir
	--local outfile
	--if self.config.dir then
	--	outdir = self.config.dir .. "/"
	--else
	--	outdir = "./"
	--end
	--		
	--local index = file:find("/[^/]*$")
	--outfile = outdir .. file:sub(index+1)		
	--	
	--if self.config.move then
	--	shell.move(file, outfile)
	--else
	--	shell.copy(file, outfile)
	--end 
	--
	--self.stats.count = self.stats.count + 1
	--self.stats.bytes = self.stats.bytes + shell.fsize(outfile)
	--
	--if islog and self.triggers.logFile then
	--	self.triggers.logFile(outfile)
	--end
end

function Output_scp:put(file)
	self:processFile(file, false)
end

function Output_scp:putLog(file)
	self:processFile(file, true)
end

function Output_scp:onSummary()
	OutputInterface.onSummary(self)
	log:info(self, "Total files copied: ", self.stats.count, " (", string.format("%.2f", self.stats.bytes / 1024 / 1024), " MiB ); Connections made: ", self.stats.connections)
end
