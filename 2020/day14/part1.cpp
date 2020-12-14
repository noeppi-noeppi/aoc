#include <iostream>
#include <regex>
#include <signal.h>

typedef std::map<uint64_t, uint64_t> memory;
typedef std::pair<uint64_t, uint64_t> mask;

std::pair<uint64_t, uint64_t> parseMask(std::string);
uint64_t applyMask(std::pair<uint64_t, uint64_t>, uint64_t);

int main() {
    signal(SIGHUP, SIG_IGN);
    
    std::regex r_mem { "^\\s*mem\\[(\\d+)\\]\\s*=\\s*(\\d+)\\s*$" };
    std::regex r_mask { "^\\s*mask\\s*=\\s*([X01]+)\\s*$" };
    
    memory memory;
    mask mask = parseMask("XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX");

    std::string line;
    while (std::getline(std::cin, line)) {
        std::smatch match;
        if (std::regex_match(line, match, r_mem)) {
            uint64_t idx = std::stol(match[1].str());
            uint64_t value = std::stol(match[2].str());
            memory[idx] = applyMask(mask, value);
        } else if (std::regex_match(line, match, r_mask)) {
            mask = parseMask(match[1].str());
        } else {
            std::cout << "Invalid Line" << std::endl;
        }
    }
    
    uint64_t sum = 0;
    for (std::pair<uint64_t , uint64_t> itr : memory) {
        sum += itr.second;
    }
    std::cout << sum << std::endl;
}

mask parseMask(std::string mask_string) {
    uint64_t mask_or = 0;
    uint64_t mask_and = ((uint64_t) 1 << 36) - 1;

    for (int i = 0; i < 36; i++) {
        char chr = mask_string.at(35 - i);
        if (chr == '1') {
            mask_or |= (uint64_t) 1 << i;
        } else if (chr == '0') {
            mask_and &= ~((uint64_t) 1 << i);
        }
    }
    
    return std::make_pair(mask_or, mask_and);
}

uint64_t applyMask(mask mask, uint64_t value) {
    return (value & mask.second) | mask.first;
}