-- part of lua-backup project
-- filesystem output

Output_fs = inheritsFrom(OutputInterface)

function Output_fs:new(config) 
	local inst = Output_fs:create()
	inst:init(config)
	return inst
end

function Output_fs:init(config) 
	self.name = "fs"
	OutputInterface.init(self, config)
	shell.createDirectory(self.config.dir)
	
	if config.triggers then
		self.triggers = config.triggers
	else
		self.triggers = { }
	end
end

function Output_fs:processFile(file, islog)
	local outdir
	local outfile
	if self.config.dir then
		outdir = self.config.dir .. "/"
	else
		outdir = "./"
	end
			
	local index = file:find("/[^/]*$")
	outfile = outdir .. file:sub(index+1)		
		
	if self.config.move then
		shell.move(file, outfile)
	else
		shell.copy(file, outfile)
	end 
	
	if islog and self.triggers.logFile then
		self.triggers.logFile(outfile)
	end
end

function Output_fs:put(file)
	self:processFile(file, false)
end

function OutputInterface:putLog(file)
	self:processFile(file, true)
end
