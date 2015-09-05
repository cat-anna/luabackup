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
end

function Output_fs:put(file)
	local outdir = self.config.dir or "."
	if self.config.move then
		shell.move(file, outdir)
	else
		shell.copy(file, outdir)
	end 
end
