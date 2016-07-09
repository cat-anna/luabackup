-- part of lua-backup project
-- mysql database input 

--mysqldump --hex-blob --order-by-primary --opt -c --triggers --dump-date --add-drop-database wikidb > /home/banshee/dump.mysql

Input_mysql = inheritsFrom(InputInterface)

function Input_mysql:new(config) 
	local inst = Input_mysql:create()
	inst:init(config)
	return inst
end

function Input_mysql:init(config) 
	self.name = "Mysql"
	InputInterface.init(self, config)	
	if not self.static.repos then
		self.static.repos = { }
	end
	if not config.databases then
		self.config.databases = { }
	end
	
--	self.CmdConf = {
--		["defaults-file"] = config.ConfigFile,
--		"hex-blob",
--		"order-by-primary",
--		"opt",
--		"c",
--		"triggers",
--		"dump-date",
--		"add-drop-databas",
--	}
end

function Input_mysql:log_info()
	return string.format("Input-Mysql(%s)", self:getName())
end

function Input_mysql:QuerryDBs()
	local confname = self:Write_config("input_dbquerry", "client")

	local cmd = string.format("mysql --defaults-file=%s -s --raw -e 'show databases;'", confname)
	local output = shell.linesOf(cmd)
	
	return output
end

function Input_mysql:Write_config(iname, section)
	local fname = backup.tmpPath .. self.name .. "_" .. iname .. "_" .. section .. ".conf"

	local f = io.open(fname, "w")
	
	f:write("[" .. section .. "]\n" )
	
	for k,v in pairs(self.config.connection) do 
		f:write(k .. "=" .. v .. "\n")
	end
	
	f:close()
	
	backup:RegisterTempFile(fname)
	return fname
end

function Input_mysql:ProcessDb(dbname)
	log:info(self, "Processing database " .. dbname)
	local confname = self:Write_config(dbname, "mysqldump")

	local name = self.name .. "." .. dbname
	
	outfile = backup:buildBaseFileName(name) .. ".sql"
	backup:RegisterTempFile(outfile)
	
	local options = "--hex-blob --order-by-primary --opt -c --triggers --dump-date --add-drop-database"
	local cmd = string.format("mysqldump --defaults-file=%s %s %s > %s", confname, options, dbname, outfile)
	
	shell.WetExecute(cmd)
	
	return {
		file = outfile,
		name = name,
	}
end

function Input_mysql:getPaths()	

	local dbs
	if self.config.alltables  then
		dbs = self:QuerryDBs()
	else
		dbs = self.config.databases
	end
	
	if not dbs or #dbs == 0 then
		log:warning(self, "No databases specified to export")
		return { }
	end
	
	local skipmap = { }
	for i,v in ipairs(self.config.SkipDatabases) do
		skipmap[v] = 1
	end
	
	local i, v
	local dbdump = {}
	for i,v in ipairs(dbs) do
		if skipmap[v] then
			log:info(self, "Skipping database '" .. v .. "' due to configuration")
		else
			local db = self:ProcessDb(v)
			if db then
				dbdump[#dbdump + 1] = db
			end		
		end
	end
	
    return dbdump;
end
