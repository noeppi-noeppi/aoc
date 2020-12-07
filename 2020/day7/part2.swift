import Swift
import Foundation

struct Contain {
    var type: String = ""
    var amount: Int = 0
}

struct Rule {
    var type: String = ""
    var contain: Array<Contain> = []
}


let pattern1: NSRegularExpression = try! NSRegularExpression(pattern: "^(.*?) bags? contain")
let pattern2: NSRegularExpression = try! NSRegularExpression(pattern: " (\\d+) (.*?) bags?[,.]")

let length: Int = Int(readLine(strippingNewline: true)!)!
var rules: Array<Rule> = Array(repeating: Rule(), count: length)

for i in 0 ..< length {
    let line: String = readLine(strippingNewline: true)!.lowercased()
    let match1: NSTextCheckingResult = pattern1.firstMatch(in: line, range: NSMakeRange(0, line.length))!
    let range1: NSRange = match1.range(at: 0)
    let str2: String = line.substring(from: range1.location + range1.length)

    let rangeType: NSRange = match1.range(at: 1)
    let bagType: String = String(line[String.Index(encodedOffset: rangeType.location) ..< String.Index(encodedOffset: rangeType.location + rangeType.length)])

    let matches2 = pattern2.matches(in: str2, range: NSMakeRange(0, str2.length))
    var contains: Array<Contain> = Array(repeating: Contain(), count: matches2.count)
    for mIdx in 0 ..< matches2.count {
        let match2 = matches2[mIdx]
        let rangeContainsType: NSRange = match2.range(at: 2)
        let containType: String = String(str2[String.Index(encodedOffset: rangeContainsType.location) ..< String.Index(encodedOffset: rangeContainsType.location + rangeContainsType.length)])
        let rangeContainsAmount: NSRange = match2.range(at: 1)
        let containAmount: Int = Int(String(str2[String.Index(encodedOffset: rangeContainsAmount.location) ..< String.Index(encodedOffset: rangeContainsAmount.location + rangeContainsAmount.length)]))!

        var c: Contain = Contain()
        c.type = containType
        c.amount = containAmount

        contains[mIdx] = c
    }

    var r: Rule = Rule()
    r.type = bagType
    r.contain = contains
    rules[i] = r
}

func getRequired(rule: Rule) -> Int {
    var amount = 1
    for c in rule.contain {
        for newRule in rules {
            if (newRule.type == c.type) {
                amount += c.amount * getRequired(rule: newRule)
                break
            }
        }
    }
    return amount
}

for rule in rules {
    if (rule.type == "shiny gold") {
        print(getRequired(rule: rule) - 1)
        break
    }
}