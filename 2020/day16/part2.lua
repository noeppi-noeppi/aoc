#!/usr/bin/env lua

rules = {}
own = {}
others = {}

parsedRules = false
parsedOwn = false

for line in io.lines() do
    line = string.gsub(line, "^%s*(.-)%s*$", "%1")
    if line ~= nil and line ~= "" then
        if not parsedRules then
            if line == "your ticket:" then
                parsedRules = true
            else
                local name, min1, max1, min2, max2 = string.match(line, "(.+):%s*(%d+)-(%d+)%s*or%s*(%d+)-(%d+)")
                rules[name] = {
                    min1 = tonumber(min1),
                    max1 = tonumber(max1),
                    min2 = tonumber(min2),
                    max2 = tonumber(max2)
                }
            end
        elseif not parsedOwn then
            if line == "nearby tickets:" then
                parsedOwn = true
            else
                own = {}
                for n in string.gmatch(line, "[^,]+") do
                    table.insert(own, tonumber(n))
                end
            end
        else
            local ticket = {}
            for n in string.gmatch(line, "[^,]+") do
                table.insert(ticket, tonumber(n))
            end
            table.insert(others, ticket);
        end
    end
end

function rule_valid(value, rule)
    return (value >= rule.min1 and value <= rule.max1) or (value >= rule.min2 and value <= rule.max2)
end

function any_valid(value, rules)
    for _, rule in pairs(rules) do
        if rule_valid(value, rule) then
            return true
        end
    end
    return false
end

function check_index(matched, tickets, rule)
    local idx = nil
    for check, _ in ipairs(own) do
        local is_possibly_valid = true
        for _, taken in pairs(matched) do
            if check == taken then
                is_possibly_valid = false
            end
        end
        if is_possibly_valid then
            for _, ticket in ipairs(tickets) do
                if not rule_valid(ticket[check], rule) then
                    is_possibly_valid = false
                    break
                end
            end
        end
        if is_possibly_valid then
            if idx ~= nil then
                return nil
            else
                idx = check
            end
        end
    end
    return idx
end

valids = {}
for _, ticket in ipairs(others) do
    local valid = true
    for _, value in ipairs(ticket) do
        if not any_valid(value, rules) then
            valid = false
        end
    end
    if valid then
        table.insert(valids, ticket)
    end
end

matched = {}

while true do
    local any_left = false
    for name, rule in pairs(rules) do
        if rule ~= nil then
            any_left = true
            local idx = check_index(matched, valids, rule)
            if idx ~= nil then
                matched[name] = idx
                rules[name] = nil
            end
        end
    end
    if not any_left then
        break
    end
end

departure_product = 1
for name, idx in pairs(matched) do
    if string.sub(name, 1, #"departure") == "departure" then
        departure_product = departure_product * own[idx]
    end
end

print(departure_product)