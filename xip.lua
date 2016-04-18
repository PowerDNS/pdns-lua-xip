function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

local records

domain = 'powerxip.example.com.'

function matchqtype(q, have)
    return have == q or q == "ANY"
end

function makerecord(name, type, content)
    return {domain_id=1, name=name, type=type, content=content}
end

function tryv4(qname)
    local addrstr = string.sub(qname, 1, string.len(qname)-string.len(domain)-1)
    print(string.format('addrstr=[%s]', addrstr))
    local a,b,c,d=addrstr:match('(%d+)-(%d+)-(%d+)-(%d+)')
    table.insert(records, makerecord(qname, 'A', string.format('%d.%d.%d.%d', a, b, c, d)))
end

function tryv6(qname)
    -- fixme
end

function lookup(qtype, qname, domainid)
    print("(l_lookup)", "qtype:", qtype, " qname:", qname, " domain_id:", domainid )

    records = {}

    if not qname:ends(domain) then
        return true
    end

    if matchqtype(qtype, "SOA") and qname == domain then
        table.insert(records, makerecord(qname, 'SOA', 'ns.'..domain, 'hostmaster.'..domain))
    end

    if matchqtype(qtype, "A") then
        tryv4(qname)
    end

    if matchqtype(qtype, "A") then
        tryv6(qname)
    end

    print("end of lookup, #records=", #records)
    return true    
end

function get()
    print("get, #records=", #records)

    while #records > 0 do
        print("get going to return something")
        local r = table.remove(records)
        print(r)
        for k,v in pairs(r) do print(k,v) end
        return r
    end
    
    print("get returned nothing")
end

function getsoa(name)
    print("getsoa ", name)
    if name == domain then
        records={makerecord(name, 'SOA', 'ns.'..domain, 'hostmaster.'..domain)}
    else
        records = {}
    end
    return true
end

function list(name)
    -- no
end