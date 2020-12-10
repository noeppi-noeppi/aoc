import std.stdio;
import std.string;
import std.conv;

struct passport {
    long byr = -1;
    long iyr = -1;
    long eyr = -1;
    long hgt = -1;
    string hgt_x = "";
    string hcl = "";
    string ecl = "";
    string pid = "";
    long cid = -1;
}

void main() {
    int valid = 0;
    while (!stdin.eof()) {
        passport p;
        readPassport(&p);
        if (p.byr >= 1920 && p.byr <= 2002
          && p.iyr >= 2010 && p.iyr <= 2020
          && p.eyr >= 2020 && p.eyr <= 2030
          && ((p.hgt_x == "cm" && p.hgt >= 150 && p.hgt <= 193) || (p.hgt_x == "in" && p.hgt >= 59 && p.hgt <= 76))
          && p.hcl.startsWith("#") && p.hcl[1 .. $].toLower().indexOfNeither("0123456789abcdef") == -1 && p.hcl.length == 7
          && (p.ecl == "amb" || p.ecl == "blu" || p.ecl == "brn" || p.ecl == "gry" || p.ecl == "grn" || p.ecl == "hzl" || p.ecl == "oth")
          && p.pid.isNumeric() && p.pid.length == 9) {
            valid += 1;
        }
    }
    writefln("Valid Passports: %s", valid);
}

void readPassport(passport *p) {
    if (stdin.eof()) {
        return;
    }
    string line = stdin.readln().strip();
    while (!line.empty()) {
        string[] parts = line.split(" ");
        foreach (string part; parts) {
            string[] kv = part.strip().split(":");
            if (kv.length != 2) {
                throw new Exception("Invalid Input");
            }
            string key = kv[0].toLower();
            string value = kv[1].toLower();

            if (key == "hcl"  || key == "ecl"  || key == "pid") {
                switch (key) {
                    case "hcl": p.hcl = value; break;
                    case "ecl": p.ecl = value; break;
                    case "pid": p.pid = value; break;
                    default: break;
                }
            } else {
                long lastNum = value.lastIndexOfAny("0123456789");
                string value_x = value[lastNum + 1 .. $].toLower().strip();
                value = value[0 .. lastNum + 1];
                if (!value.empty() && value.isNumeric()) {
                    long num = to!long(value);
                    switch (key) {
                        case "byr": p.byr = num; break;
                        case "iyr": p.iyr = num; break;
                        case "eyr": p.eyr = num; break;
                        case "hgt": p.hgt = num; p.hgt_x = value_x; break;
                        case "cid": p.cid = num; break;
                        default: break;
                   }
                }
            }
        }
        if (stdin.eof()) {
            return;
        }
        line = stdin.readln().strip();
    }
}
