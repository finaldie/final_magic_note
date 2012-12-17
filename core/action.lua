
top_dir = nil
index_valuemd5_mapping_tbl = {}
valuemd5_index_mapping_tbl = {}
DEBUG = false

function debug_print(fmt, ...)
    local t = {...}
    if DEBUG then
        print(fmt, unpack(t))
    end
end

function dump_indexs()
    for key, md5_tbl in pairs(index_valuemd5_mapping_tbl) do
        print(string.format("%s %s", key, table.concat(md5_tbl, ",")))
    end
end

function add_note(tagname, md5)
    local function update_mapping(array, value)
        local need_insert = true
        for _, v in pairs(array) do
            if v == value then
                need_insert = false
            end
        end

        if need_insert then
            table.insert(array, value)
        end
    end

    index_valuemd5_mapping_tbl[tagname] = index_valuemd5_mapping_tbl[tagname] or {}
    update_mapping(index_valuemd5_mapping_tbl[tagname], md5)

    valuemd5_index_mapping_tbl[md5] = valuemd5_index_mapping_tbl[md5] or {}
    update_mapping(valuemd5_index_mapping_tbl[md5], tagname)

    if DEBUG then
        table.print(index_valuemd5_mapping_tbl)
        table.print(valuemd5_index_mapping_tbl)
    end
end

function rm_note(tagname, md5)
    local function update_mapping(array, value)
        local need_remove = 0
        for idx, v in ipairs(array) do
            if v == value then
                need_remove = idx
                break
            end
        end

        if need_remove > 0 then
            table.remove(array, need_remove)
        end
    end

    index_valuemd5_mapping_tbl[tagname] = index_valuemd5_mapping_tbl[tagname] or {}
    update_mapping(index_valuemd5_mapping_tbl[tagname], md5)

    valuemd5_index_mapping_tbl[md5] = valuemd5_index_mapping_tbl[md5] or {}
    update_mapping(valuemd5_index_mapping_tbl[md5], tagname)
end

function load_indexs(base, index_filename)
    debug_print("index filename=", index_filename, base, type(base))
    local filename = base .. "/" .. index_filename
    debug_print("filename=", filename)
    local f = io.open(filename)
    assert(f)

    for line in f:lines() do
        debug_print("line data:", line)
        local key_values = string.split(line, " ")
        local key = key_values[1]
        local md5_strings = key_values[2]
        if key and md5_strings then
            local md5_tbl = string.split(md5_strings, ",")

            -- fill index -- values mapping
            index_valuemd5_mapping_tbl[key] = md5_tbl

            -- fill md5 values -- index mapping
            for _, md5 in pairs(md5_tbl) do
                valuemd5_index_mapping_tbl[md5] = valuemd5_index_mapping_tbl[md5] or {}
                table.insert(valuemd5_index_mapping_tbl[md5], key)
            end
        end
    end

    if DEBUG then
        table.print(index_valuemd5_mapping_tbl)
        table.print(valuemd5_index_mapping_tbl)
    end
    io.close(f)
end

function foreach_note(base, cb, ...)
    if not base and not cb then
        return
    end

    for tagname, md5_tbl in pairs(index_valuemd5_mapping_tbl) do
        for index, md5 in ipairs(md5_tbl) do
            local content, raw_tbl = load_file(base .. "/note_" .. md5)
            if content and raw_tbl then
                cb(tagname, md5, index, content, raw_tbl, ...)
            end
        end
    end
end

--function list_note(base, tagname, output_func, ...)
--    local function default_output(content, index)
--        print(string.format("%s", content))
--    end
--
--    local function hook_line(line, lineno, index)
--        if lineno == 1 then
--            return string.format("  |- @%d #%d: %s", index, lineno, line)
--        else
--            return string.format("  |-    #%d: %s", lineno, line)
--        end
--    end
--
--    local md5_tbl = index_valuemd5_mapping_tbl[tagname]
--    if not md5_tbl then
--        return
--    end
--
--    print(string.format("%s", tagname))
--    for index, md5 in ipairs(md5_tbl) do
--        local content = load_file(base .. "/note_" .. md5, hook_line, index)
--        if content then
--            if output_func then
--                output_func(content, index, ...)
--            else
--                default_output(content, index)
--            end
--        end
--    end
--end

function create_note_tbl(index, md5, content, raw_tbl)
    return {
        index = index,
        md5 = md5,
        content = content,
        raw_tbl = raw_tbl,
    }
end

function list_notes(base, tagname)
    local notes_tbl = {}
    local md5_tbl = index_valuemd5_mapping_tbl[tagname]
    if not md5_tbl then
        return
    end

    for index, md5 in ipairs(md5_tbl) do
        local content, raw_tbl = load_file(base .. "/note_" .. md5)
        if content then
            local note_tbl = create_note_tbl(index, md5, content, raw_tbl)
            table.insert(notes_tbl, note_tbl)
        end
    end

    return notes_tbl
end

function list_all_notes(base)
    local result_tbl = {}
    for key, md5_tbl in pairs(index_valuemd5_mapping_tbl) do
        local note_tbl = list_notes(base, key)
        result_tbl[key] = note_tbl
    end

    return result_tbl
end

function searchkey(file_sign)
    local file_and_location = string.split(file_sign, "@")
    if table.size(file_and_location) == 2 then
        local tag = file_and_location[1]
        local target_idx = tonumber(file_and_location[2])
        if not target_idx or target_idx < 1 then
            return
        end

        local md5_tbl = index_valuemd5_mapping_tbl[tag]
        if md5_tbl and not table.empty(md5_tbl) then
            for index, md5 in ipairs(md5_tbl) do
                if index == target_idx then
                    return tag, md5
                end
            end
        end
    end
end

function searchkey_and_note(base, file_sign)
    local tag, md5 = searchkey(file_sign)
    if tag and md5 then
        local content, raw_tbl = load_file(base .. "/note_" .. md5)
        return tag, md5, content, raw_tbl
    end
end

function update_md5(tagname, old_md5, new_md5)
    local md5_tbl = index_valuemd5_mapping_tbl[tagname]
    if not md5_tbl then
        return false
    end

    for index, md5 in ipairs(md5_tbl) do
        if md5 == old_md5 then
            md5_tbl[index] = new_md5
        end
    end
end

function clear_find_tags(find_tags_tbl)
    for tagname, ismark in pairs(find_tags_tbl) do
        find_tags_tbl[tagname] = false
    end
end

function is_all_match(find_tags_tbl)
    for _, ismark in pairs(find_tags_tbl) do
        if ismark == false then
            return false;
        end
    end
    return true
end

function is_any_match(find_tags_tbl)
    for _, ismark in pairs(find_tags_tbl) do
        if ismark == true then
            return true
        end
    end
    return false
end

function find_note(base, find_tags)
    local result_tbl = {}
    local function match_tags(content)
        for tag, is_match in pairs(find_tags) do
            local i, j = string.find(content, tag)
            if i then
                -- we match a tag, then mark this as true
                find_tags[tag] = true
            end
        end
    end

    local function each_note_process(tagname, md5, index, content, raw_tbl)
        local lower_cont = string.lower(content)
        local lower_tagname = string.lower(tagname)

        -- start match, both tagname and content
        clear_find_tags(find_tags)
        match_tags(lower_tagname)
        match_tags(lower_cont)

        if is_all_match(find_tags) then
            result_tbl[tagname] = result_tbl[tagname] or {}
            table.insert(result_tbl[tagname], {
                index = index,
                content = content,
                raw_tbl = raw_tbl,
            })
        end
    end

    foreach_note(base, each_note_process)
    return result_tbl
end

function dump_note_tbl(note_tbl)
    local index = note_tbl.index
    local content = note_tbl.content
    local raw_tbl = note_tbl.raw_tbl

    for lineno, line in ipairs(raw_tbl) do
        if lineno == 1 then
            print(string.format("  |- @%d #%d: %s", index, lineno, line))
        else
            print(string.format("  |-    #%d: %s", lineno, line))
        end
    end
end

function dump_notes_tbl(tagname, notes_tbl)
    if not table.empty(notes_tbl) then
        print(string.format("%s", tagname))

        for _, note in ipairs(notes_tbl) do
            dump_note_tbl(note)
        end
    end
end

function dump_result_tbl(result_tbl)
    for tagname, notes_tbl in pairs(result_tbl) do
        dump_notes_tbl(tagname, notes_tbl)
    end
end

function dump_raw_info(content)
    print(string.format("%s", content))
end

if ( not arg[1] ) then
    print("missing action arg")
    return
end

if DEBUG then
    table.print(arg)
end

package.path = package.path .. ";/usr/local/share/magicnote/?.lua"
require("util")

if arg[1] == "add" then
    top_dir = arg[2]
    load_indexs(arg[2], arg[3])

    local note_filename = arg[5]
    local prefix_md5 = string.split(note_filename, "_")
    local prefix = prefix_md5[1]
    local md5 = prefix_md5[2]
    add_note(arg[4], md5)
    dump_indexs()
elseif arg[1] == "list" then
    local base = arg[2]
    local index_filename = arg[3]
    local tagname = arg[4]

    load_indexs(base, index_filename)

    if not tagname then
        local result_tbl = list_all_notes(base)
        dump_result_tbl(result_tbl)
    else
        local notes_tbl = list_notes(base, tagname)
        dump_notes_tbl(tagname, notes_tbl)
    end
elseif arg[1] == "searchkey" then
    local base = arg[2]
    local index_filename = arg[3]
    local file_sign = arg[4]

    load_indexs(base, index_filename)
    local tag, md5 = searchkey(file_sign)
    if tag and md5 then
        print(string.format("%s %s", tag, md5))
    end
elseif arg[1] == "rm" then
    local base = arg[2]
    local index_filename = arg[3]
    local file_sign = arg[4]

    load_indexs(base, index_filename)
    local tag, md5 = searchkey(file_sign)

    rm_note(tag, md5)
    dump_indexs()
elseif arg[1] == "updatemd5" then
    local base = arg[2]
    local index_filename = arg[3]
    local tagname = arg[4]
    local old_md5 = arg[5]
    local new_md5 = arg[6]

    load_indexs(base, index_filename)
    update_md5(tagname, old_md5, new_md5)
    dump_indexs()
elseif arg[1] == "find" then
    local base = arg[2]
    local index_filename = arg[3]

    local find_tags_size = table.size(arg) - 3 - 2
    if find_tags_size == 0 then
        return
    else
        local find_tags = {}
        for i=4, 4+find_tags_size-1 do
            find_tags[arg[i]] = false -- first, mark all tags false
        end

        load_indexs(base, index_filename)
        local result_tbl = find_note(base, find_tags)
        dump_result_tbl(result_tbl)
    end
elseif arg[1] == "getnote" then
    local base = arg[2]
    local index_filename = arg[3]
    local file_sign = arg[4]

    load_indexs(base, index_filename)
    local tag, md5, content, raw_tbl = searchkey_and_note(base, file_sign)

    if not tag or not md5 then
        return
    end

    dump_raw_info(content)
end
