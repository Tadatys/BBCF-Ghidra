-- lua scripts for cheat enging

-- log stack trace
function print_stack_trace()
    local base = getAddress("BBCF.exe")
    local ln = (string.format("%08x ", EIP - base))
    local bp = EBP
    for i = 1, 10 do
        local ip = readInteger(bp+4)
        ln = ln .. (string.format("%08x ", ip - base))
        bp = readInteger(bp)
        if bp == 0 or ip == 0 or ip - base == 0x3a5675 then
            break
        end
    end
    print ("stack: " .. ln)
    print (string.format("EAX %08x  EBX %08x  ECX %08x  EDX %08x", EAX, EBX, ECX, EDX))
    print (string.format("ESI %08x  EDI %08x  EBP %08x  ESP %08x", ESI, EDI, EBP, ESP))
    print ()
end


-- log vftables in task list
function print_tasks()
    local base = getAddress("BBCF.exe")
    local manager = readInteger(base + 0x008929c8)
    local app = readInteger(manager + 4)
    local node = readInteger(app + 12)
    while node ~= 0 do
        print (string.format("%08x -> bbcf.exe + %08x, p=%08x", node, readInteger(node) - base, readInteger(node+16)))
        node = readInteger(node + 4)
    end
end


-- change scene?
function change_scene(mode, scene)
    local base = getAddress("BBCF.exe")
    local scene = readInteger(base + 0x008903b0 + 0x2604)
    writeInteger(base + 0x008903b0 + 0x108, mode) -- set GameMode
    writeInteger(base + 0x008903b0 + 0x110, scene) -- set next GameScene
    writeInteger(scene + 0x2c, 11) -- skip status 10
    writeInteger(scene + 0x14, 2) -- set node for removal
end

--[[ modes:
6, 6 -- char select
6, 14 -- vs info
6, 15 -- battle
11, 15 -- replay theater battle
11, 26 -- replay theater list
13, 0x18 -- story select
13, 0x1B -- main menu
13, 0x1D -- library

intro -> replay theater segfaults, but title -> replay theater seems ok. but then segfaults on replay start?
]]

-- export labels for ghidra
function export_labels()
    local al = getAddressList()
    local base = getAddress("BBCF.exe")
    for i = 0, al.Count-1 do
        -- TODO: handle pointer types
        if al[i].CurrentAddress ~= 0 then
            print (string.format('(0x%x, "CE_%s"),', al[i].CurrentAddress - base, al[i].Description))
        end
    end
end
