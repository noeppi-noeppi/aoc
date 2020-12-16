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

rate = 0
for _, ticket in ipairs(others) do
    for _, value in ipairs(ticket) do
        if not any_valid(value, rules) then
            rate = rate + value
        end
    end
end

print(rate)