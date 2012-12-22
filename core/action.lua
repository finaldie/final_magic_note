
index_valuemd5_mapping_tbl = {}
valuemd5_index_mapping_tbl = {}
DEBUG = false
DISPLAY_BYTES = 120
NOTE_PREFIX = "note_"
INDEX_FILENAME = "index"

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

-- add multi tag mapping to one note
function add_notes(tagnames, md5)
    local tagname_tbl = string.split(tagnames, " ")
    for _, tagname in ipairs(tagname_tbl) do
        add_note(tagname, md5)
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
            if not table.empty(md5_tbl) then
                index_valuemd5_mapping_tbl[key] = md5_tbl
            end

            -- fill md5 values -- index mapping
            for _, md5 in pairs(md5_tbl) do
                if md5 and string.len(md5) > 0 then
                    valuemd5_index_mapping_tbl[md5] = valuemd5_index_mapping_tbl[md5] or {}
                    table.insert(valuemd5_index_mapping_tbl[md5], key)
                end
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
            local content, raw_tbl = getnote(base, md5)
            if content and raw_tbl then
                cb(tagname, md5, index, content, raw_tbl, ...)
            end
        end
    end
end

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
        return notes_tbl
    end

    for index, md5 in ipairs(md5_tbl) do
        local content, raw_tbl = getnote(base, md5)
        if content and raw_tbl then
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

-- the format: tag@idx1#line, e.g. "ssh@1" or "ssh@1#2"
function split_file_sign(file_sign)
    local file_and_location = string.split(file_sign, "@")

    if table.size(file_and_location) ~= 2 then
        return
    end

    local tag = file_and_location[1]
    local target_tbl = string.split(file_and_location[2], "#")
    local target_idx = tonumber(target_tbl[1])
    local target_line = tonumber(target_tbl[2]) -- this may be missed

    if not target_idx or target_idx < 1 then
        return
    end

    return tag, target_idx, target_line
end

function searchkey(tag, target_idx)
    if not tag or not target_idx then
        return
    end

    local md5_tbl = index_valuemd5_mapping_tbl[tag]
    if md5_tbl and not table.empty(md5_tbl) then
        for index, md5 in ipairs(md5_tbl) do
            if index == target_idx then
                return md5
            end
        end
    end
end

function getnote(base, md5)
    if base and md5 then
        local content, raw_tbl = load_file(base .. "/" .. NOTE_PREFIX .. md5)
        return content, raw_tbl
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
            local note_tbl = create_note_tbl(index, md5, content, raw_tbl)
            table.insert(result_tbl[tagname], note_tbl)
        end
    end

    foreach_note(base, each_note_process)
    return result_tbl
end

function is_empty_line(line)
    local trimed_line = string.trim(line)
    if string.len(trimed_line) == 0 then
        return true
    end
    return false
end

function is_valid_line(line)
    if is_empty_line(line) then
        return false
    end

    local trimed_line = string.trim(line)
    local location = string.find(trimed_line, "#")
    if location ~= 1 then
        return true
    end

    return false
end

function dump_note_tbl(note_tbl)
    local index = note_tbl.index
    local content = note_tbl.content
    local raw_tbl = note_tbl.raw_tbl

    local real_lineno = 0
    local valid_lineno = 0
    local index_sign = ""
    for lineno, line in ipairs(raw_tbl) do
        if not is_empty_line(line) then
            valid_lineno = valid_lineno + 1
            if valid_lineno == 1 then
                index_sign = string.format("@%d", index)
            else
                index_sign = "  "
            end

            if is_valid_line(line) then
                real_lineno = real_lineno + 1
                local display = string.format("  |- %s #%d: %s", index_sign, real_lineno, line)
                if DISPLAY_BYTES > 0 and string.len(display) > DISPLAY_BYTES then
                    display = string.sub(display, 1, DISPLAY_BYTES) .. "..."
                end
                print(display)
            else
                print(string.format("  |- %s   : %s", index_sign, line))
            end
        end
    end
end

function dump_notes_tbl(tagname, notes_tbl)
    if not table.empty(notes_tbl) then
        -- print tagname
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

function dump_raw_info_all(content, raw_tbl, target_lineno)
    print(string.format("%s", content))
end

function dump_raw_info_byline(raw_tbl, target_lineno)
    local real_lineno = 0
    for _, line in ipairs(raw_tbl) do
        if is_valid_line(line) then
            -- this is a valid line, which can run in the shell
            real_lineno = real_lineno + 1
            if real_lineno == target_lineno then
                print(string.format("%s", line))
            end
        end
    end
end

function dump_raw_info(content, raw_tbl, target_lineno)
    if target_lineno and target_lineno >= 1 then
        return dump_raw_info_byline(raw_tbl, target_lineno)
    end

    return dump_raw_info_all(content)
end

function get_unuseful_files(base, file_list)
    local files_tbl = string.split(file_list, "\n")
    local mark_tbl = {}
    local unuseful = {}
    for key, filename in pairs(files_tbl) do
        mark_tbl[filename] = false
    end

    for md5, key_tbl in pairs(valuemd5_index_mapping_tbl) do
        local filename = NOTE_PREFIX..md5
        mark_tbl[filename] = true
    end

    for filename, useful in pairs(mark_tbl) do
        if not useful then
            table.insert(unuseful, filename)
        end
    end

    return unuseful
end

function dump_tags_info(result_tbl, show_detail)
    for tagname, notes_tbl in pairs(result_tbl) do
        if not table.empty(notes_tbl) then
            if show_detail then
                print(string.format("%s %d", tagname, table.size(notes_tbl)))
            else
                print(string.format("%s", tagname))
            end
        end
    end
end

if ( not arg[1] ) then
    print("missing binary top arg")
    return
end

if not arg[2] then
    print("missing action arg")
    return
end

if DEBUG then
    table.print(arg)
end

package.path = package.path .. ";" .. arg[1] .. "/?.lua"
require("magicnote_util")

if arg[2] == "add" then
    local base = arg[3]
    local index_filename = arg[4]
    local md5 = arg[5]
    local tagnames = arg[6]

    load_indexs(base, index_filename)
    add_notes(tagnames, md5)
    dump_indexs()

elseif arg[2] == "list" then
    local base = arg[3]
    local index_filename = arg[4]
    DISPLAY_BYTES = tonumber(arg[5])
    local tagname = arg[6]

    load_indexs(base, index_filename)

    if not tagname then
        local result_tbl = list_all_notes(base)
        dump_result_tbl(result_tbl)
    else
        local notes_tbl = list_notes(base, tagname)
        dump_notes_tbl(tagname, notes_tbl)
    end
elseif arg[2] == "searchkey" then
    local base = arg[3]
    local index_filename = arg[4]
    local file_sign = arg[5]

    load_indexs(base, index_filename)
    local tag, target_idx, target_line = split_file_sign(file_sign)
    local md5 = searchkey(tag, target_idx)
    if not md5 then
        return
    end

    if not target_line then
        print(string.format("%s %s", tag, md5))
    else
        print(string.format("%s %s %d", tag, md5, target_line))
    end
elseif arg[2] == "rm" then
    local base = arg[3]
    local index_filename = arg[4]
    local file_sign = arg[5]

    load_indexs(base, index_filename)
    local tag, target_idx = split_file_sign(file_sign)
    local md5 = searchkey(tag, target_idx)
    if not md5 then
        return
    end

    rm_note(tag, md5)
    dump_indexs()
elseif arg[2] == "updatemd5" then
    local base = arg[3]
    local index_filename = arg[4]
    local tagname = arg[5]
    local old_md5 = arg[6]
    local new_md5 = arg[7]

    load_indexs(base, index_filename)
    update_md5(tagname, old_md5, new_md5)
    dump_indexs()
elseif arg[2] == "find" then
    local base = arg[3]
    local index_filename = arg[4]
    DISPLAY_BYTES = tonumber(arg[5])

    local find_tags_size = table.size(arg) - 5 - 2
    if find_tags_size == 0 then
        return
    else
        local find_tags = {}
        for i=6, 6+find_tags_size-1 do
            find_tags[string.lower(arg[i])] = false -- first, mark all tags false
        end

        load_indexs(base, index_filename)
        local result_tbl = find_note(base, find_tags)
        dump_result_tbl(result_tbl)
    end
elseif arg[2] == "getnote" then
    local base = arg[3]
    local index_filename = arg[4]
    local file_sign = arg[5]

    load_indexs(base, index_filename)
    local tag, target_idx, target_line = split_file_sign(file_sign)
    local md5 = searchkey(tag, target_idx)
    if not md5 then
        return
    end

    local content, raw_tbl = getnote(base, md5)
    if content and raw_tbl then
        dump_raw_info(content, raw_tbl, target_line)
    end
elseif arg[2] == "gc" then
    local base = arg[3]
    local index_filename = arg[4]
    local file_list = arg[5]

    load_indexs(base, index_filename)
    local unuseful = get_unuseful_files(base, file_list)
    for _, filename in pairs(unuseful) do
        print(string.format("%s", filename))
    end
elseif arg[2] == "showtags" then
    local base = arg[3]
    local index_filename = arg[4]
    local show_detail = arg[5]

    load_indexs(base, index_filename)
    local result_tbl = list_all_notes(base)
    dump_tags_info(result_tbl, show_detail)
end
