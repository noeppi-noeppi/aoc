#include <iostream>
#include <regex>
#include <signal.h>

typedef std::map<uint64_t, uint64_t> memory;
typedef std::pair<uint64_t, uint64_t> mask;

std::pair<uint64_t, uint64_t> parseMask(std::string);
void applyMask(mask mask, uint64_t address, uint64_t value, memory *memory);
void applyAll(uint64_t floating, uint64_t base_addres, int bit, uint64_t value, memory *memory);

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
            applyMask(mask, idx, value, &memory);
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
    uint64_t mask_x = 0;

    for (int i = 0; i < 36; i++) {
        char chr = mask_string.at(35 - i);
        if (chr == '1') {
            mask_or |= (uint64_t) 1 << i;
        } else if (chr == 'X') {
            mask_x |= (uint64_t) 1 << i;
        }
    }
    
    return std::make_pair(mask_or, mask_x);
}

void applyMask(mask mask, uint64_t address, uint64_t value, memory *memory) {
    uint64_t base_address = address | mask.first;
    applyAll(mask.second, base_address, 0, value, memory);
}

void applyAll(uint64_t floating, uint64_t base_address, int bit, uint64_t value, memory *memory) {
    if (bit < 36) {
        if ((floating & ((uint64_t) 1 << bit)) != 0) {
            applyAll(floating, base_address & ~((uint64_t) 1 << bit), bit + 1, value, memory);
            applyAll(floating, base_address | ((uint64_t) 1 << bit), bit + 1, value, memory);
        } else {
            applyAll(floating, base_address, bit + 1, value, memory);
        }
    } else {
        (*memory)[base_address] = value;
    }
}