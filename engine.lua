-- part of lua-backup project
-- application engine

local BackupEngine = {}
local BackupEngine_mt = { __index = BackupEngine }

local NameString = "LuaBackup"
local VersionString = "version 1.0"
local AuthorString = "by Pawel Grabas 2015"

local function BackupEngine_create()
    local new_inst = {}    -- the new instance
    setmetatable( new_inst, BackupEngine_mt ) -- all instances share the same metatable
	
	new_inst.staticData = { }
	
	new_inst.staticDataFile = "luabackup.config.lua"
	new_inst.tmpPath = ""
	new_inst.generatedFiles = { }
    return new_inst
end

function BackupEngine:getInputStaticData(name)
	local d = self.staticData.inputs[name]
	if not d then
		d = { }
		self.staticData.inputs[name] = d
	end	
	return d
end

function BackupEngine:getOutputStaticData(name)
	local d = self.staticData.outputs[name]
	if not d then
		d = { }
		self.staticData.outputs[name] = d
	end	
	return d
end

function BackupEngine:buildBaseFileName(staticName) 
	local d = os.date("*t")
	local bpath = self.tmpPath

	return string.format("%s%s.%04d%02d%02d_%02d%02d%02d", bpath, staticName, d.year, d.month, d.day, d.hour, d.min, d.sec)
end

function BackupEngine:init(staticName, temp)
	shell.init()
	temp = temp or shell.temp()
	
	if not log:isLogOpened() then
		log:openLog(temp)
	end

	log:info(NameString, " ", VersionString, " ", AuthorString)
	self.staticDataFile = staticName
	self.tmpPath = temp	
	shell.createDirectory(temp)
	
	local f = io.open(self.staticDataFile, "rb")
    local static_ok = false
    if f then
        f:close()
        self.staticData = dofile(self.staticDataFile)
        static_ok = true
		if      not self.staticData or 
				not self.staticData.inputs or
				not self.staticData.outputs then
            static_ok = false
        end
    end

    if not static_ok then
        log:error("Unable to read backup state file: " .. staticName)
        self.staticData = {
            inputs = { },
			outputs = { },
        }
    end
end

function BackupEngine:processInput(index, inp)
	local instance = inp.instance
	log:info("Starting processing input '" .. instance:getName() .. "' (" .. index .. " out of " .. input:getInputCount() .. ")")
	
	local pipeline = pipelines:get(inp.pipeline)
	if not pipeline then
		return
	end	
	
	local paths = instance:getPaths()
	if type(paths) ~= "table" then
		log:error("Input returned invalid value!")
		return
	end
	
	log:info("Input '" .. instance:getName() .. "' returned " .. #paths .. " path(s)")
	local i, v
	for i,v in ipairs(paths) do
		log:info(string.format("Processing path %d out of %d: %s (%s)", i, #paths, v.name, v.path))
		
		local files = { }

		local path_types = {
			table = function(t, path)
				local i,v
				for i,v in ipairs(path) do
					t[#t + 1] = v
				end
			end,
			string = function(t, path) 
				t[#t + 1] = path
			end
		}

		local path_func = path_types[type(v.path)]
		if path_func then
			path_func(files, v.path)
		else
			log:error("Invalid path type!")
		end
		
		local fname = self:buildBaseFileName(v.name)
		log:info("Backup file base name: ", fname, " input file(s) count: " , #files)
		
		files, fname = pipeline:execute(files, fname)
		
		local fi,fv
		for fi,fv in ipairs(files) do
			self.generatedFiles[#self.generatedFiles + 1] = {
				name = fv,
				size = shell.fsize(fv)
			}
		end
		
		output:putBackupFiles(files)
		
		for fi,fv in ipairs(files) do
			shell.removeFile(fname)
		end
	end	
end

function BackupEngine:start()
	if luabackup.debug then
		log:warning(NameString, " executed in debug mode!")
	end
	
	if luabackup.incremental then
		log:info("Incremental mode is on")
	else
		log:info("Incremental mode is off")
	end

	log:warning("Default pipeline: " .. pipelines:getDefaultPipeline())
    log:info "Backup started"
	
	output:onBeforeStart()
	input:processAll()
	output:onAfterStop()
	
	log:info "Backup finished"
	self:storeState()
	self:printSummary()
	
	log:closeLog()
	output:putLogFile(log:getLogFile())
	log:removeLogFile()
end

function BackupEngine:printSummary()
	log:info("Summary: ")
	local line = ""
	
	local i,v
	local size = 0
	for i,v in ipairs(self.generatedFiles) do
		log:info(string.format("Created file: '%s' of size %.2f kib", v.name, v.size / 1024))
		size = size + v.size 
	end
	log:info(string.format("Total: files: %d  size: %.2f Mib", #self.generatedFiles, size / 1024 / 1024))
end

function BackupEngine:storeState() 
    local f = io.open(self.staticDataFile, "w")
    if not f then
        log:error("Uable to open state file for writting")
        return
    end
	log:info("Writting backup state")
    local dump
    
    dump = function (value, loc)
        local t = type(value)
        local action = {
            table = function(value, loc)
                f:write("{\n")
                for v,k in pairs(value) do
                    for i = 1,(loc+1) do f:write("\t"); end
					local vt = type(v)
					local vkey;
					if vt == "string" then
						vkey = "\"" .. v .. "\""
					else
						vkey = v
					end
                    f:write("[", vkey, "] = ")
                    dump(k, loc+1)
                end
                for i = 1,loc do f:write("\t"); end
                f:write("}")
            end,
            number = function(value, loc)
                f:write(value)
            end,
            string = function(value, loc)
                f:write("\"", value, "\"")
            end,
            boolean = function(value, loc)
                f:write(tostring(value))
            end,
            ["nil"] = function(value, loc)
                f:write("nil")
            end,
        }
        (action[type(value)])(value, loc);
        if loc > 0 then
            f:write(",\n")
        else
            f:write("\n")
        end
    end

    f:write([[
--LuaBackup state file
--DO NOT EDIT

local state = ]])
dump(self.staticData, 0)
f:write([[

return state
]])

    f:close()
end

backup = BackupEngine_create()
