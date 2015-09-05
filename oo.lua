-- part of lua-backup project
-- object-oriented support for lua

function inheritsFrom( base )
    local class = {}
    local mt = { __index = class }

    function class:create()
        return setmetatable( { } , mt )
    end

    if base then
        setmetatable( class, { __index = base } )
    end

    return class
end
