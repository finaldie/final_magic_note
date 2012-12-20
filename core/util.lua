
function string.split( line, sep, maxsplit )
    if string.len(line) == 0 then
        return {}
    end
    sep = sep or ' '
    maxsplit = maxsplit or 0
    local retval = {}
    local pos = 1
    local step = 0
    while true do
        local from, to = string.find(line, sep, pos, true)
        step = step + 1
        if (maxsplit ~= 0 and step > maxsplit) or from == nil then
            local item = string.sub(line, pos)
            table.insert( retval, item )
            break
        else
            local item = string.sub(line, pos, from-1)
            table.insert( retval, item )
            pos = to + 1
        end
    end
    return retval
end

function string.trim(str)
    --return str:gsub("^%s+", ""):gsub("%s+$", "")
    return str:match("^%s*(.-)%s*$")
end

function table.print(root)
    local print = print
    local tconcat = table.concat
    local tinsert = table.insert
    local srep = string.rep
    local type = type
    local pairs = pairs
    local tostring = tostring
    local next = next

    local cache = {  [root] = "." }
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                tinsert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                tinsert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. srep(" ",#key),new_key))
            else
                tinsert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return tconcat(temp,"\n"..space)
    end
    print(_dump(root, "",""))
end

function table.empty(tbl)
    for _, _ in pairs(tbl) do
        return false
    end
    return true
end

function table.size(tbl)
    local size = 0
    for _, _ in pairs(tbl) do
        size = size + 1
    end

    return size
end

-- when hook_line is valid, call hook_line() with line string and line number,
-- then we use the return value as new line string
function load_file(filename, hook_line, ...)
    local f = io.open(filename)
    if not f then
        return
    end

    local note_content_tbl = {}
    local lineno = 0
    for line in f:lines() do
        lineno = lineno + 1
        if hook_line then
            line = hook_line(line, lineno, ...)
        end
        table.insert(note_content_tbl, line)
    end

    io.close(f)

    return table.concat(note_content_tbl, "\n"), note_content_tbl
end
