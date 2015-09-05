-- part of lua-backup project
-- ccrypt stage

Stage_ccrypt = inheritsFrom(Stage)

function Stage_ccrypt:new(config) 
	local inst = Stage_ccrypt:create()
	inst:init(config)
	return inst
end

function Stage_ccrypt:init(config) 
	self.name = "ccrypt"
	Stage.init(self, config)
end

function Stage_ccrypt:execute(files, fname)
	local cmd = "ccrypt -e"
	local cfg = self.config
	
	if cfg.key then
		cmd = string.format("%s --key %s", cmd, cfg.key)
		log:warning(self, "Using key in command line is UNSAFE")
	end
	
	if cfg.keyfile then
		cmd = string.format("%s --keyfile %s", cmd, cfg.keyfile)
	end
	
	local r = { }
	for i,v in ipairs(files) do
		local fcmd = string.format("%s %s", cmd, v)
		shell.execute(fcmd)
		r[#r + 1] = v .. ".cpt"
	end
	fname = fname .. ".cpt"
	return r, fname
end

--[[
ccrypt 1.10. Secure encryption and decryption of files and streams.

Usage: ccrypt [mode] [options] [file...]
       ccencrypt [options] [file...]
       ccdecrypt [options] [file...]
       ccat [options] file...

Modes:
    -e, --encrypt         encrypt
    -d, --decrypt         decrypt
    -c, --cat             cat; decrypt files to stdout
    -x, --keychange       change key
    -u, --unixcrypt       decrypt old unix crypt files

Options:
    -h, --help            print this help message and exit
    -V, --version         print version info and exit
    -L, --license         print license info and exit
    -v, --verbose         print progress information to stderr
    -q, --quiet           run quietly; suppress warnings
    -f, --force           overwrite existing files without asking
    -m, --mismatch        allow decryption with non-matching key
    -E, --envvar var      read keyword from environment variable (unsafe)
    -K, --key key         give keyword on command line (unsafe)
    -k, --keyfile file    read keyword(s) as first line(s) from file
    -P, --prompt prompt   use this prompt instead of default
    -S, --suffix .suf     use suffix .suf instead of default .cpt
    -s, --strictsuffix    refuse to encrypt files which already have suffix
    -F, --envvar2 var     as -E for second keyword (for keychange mode)
    -H, --key2 key        as -K for second keyword (for keychange mode)
    -Q, --prompt2 prompt  as -P for second keyword (for keychange mode)
    -t, --timid           prompt twice for encryption keys (default)
    -b, --brave           prompt only once for encryption keys
    -y, --keyref file     encryption key must match this encrypted file
    -r, --recursive       recurse through directories
    -R, --rec-symlinks    follow symbolic links as subdirectories
    -l, --symlinks        dereference symbolic links
    -T, --tmpfiles        use temporary files instead of overwriting (unsafe)
    --                    end of options, filenames follow
]]
