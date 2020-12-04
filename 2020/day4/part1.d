import std.stdio;
import std.string;
import std.conv;

struct passport {
    bool byr = false;
    bool iyr = false;
    bool eyr = false;
    bool hgt = false;
    bool hcl = false;
    bool ecl = false;
    bool pid = false;
    bool cid = false;
}

void main() {
    int valid = 0;
    while (!stdin.eof()) {
        passport p;
        readPassport(&p);
        if (p.byr && p.iyr && p.eyr && p.hgt && p.hcl && p.ecl && p.pid) {
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
            
            switch (key) {
                case "byr": p.byr = true; break;
                case "iyr": p.iyr = true; break;
                case "eyr": p.eyr = true; break;
                case "hgt": p.hgt = true; break;
                case "pid": p.pid = true; break;
                case "cid": p.cid = true; break;
                case "hcl": p.hcl = true; break;
                case "ecl": p.ecl = true; break;
                default: break;
            }
        }
        if (stdin.eof()) {
            return;
        }
        line = stdin.readln().strip();
    }
}
