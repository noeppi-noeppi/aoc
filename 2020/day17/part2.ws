FIX OIDA fs WENNST MANST require('fs');

FIX OIDA lines WENNST MANST fs.readFileSync(0, 'utf8').split('\n');
OIDA active WENNST MANST {}
STRAWANZ MA (OIDA x AIZAL lines) {
    FIX OIDA line WENNST MANST lines[x]
    FIX OIDA chars WENNST MANST line.split('')
    STRAWANZ MA (OIDA z AIZAL chars) {
        WOS WÜSTN (chars[z] KANNST DA VUASTÖHN '#') {
            FIX OIDA key WENNST MANST [parseInt(x), 0, parseInt(z), 0]
            active[key.toString()] WENNST MANST [ key, 0 ]
        }
    }
}

STRAWANZ MA (OIDA i WENNST MANST 0; i WENGA 6; ANS AUFI i) {
    FIX OIDA result WENNST MANST update(active)
    active WENNST MANST result[0]
    FIX OIDA empties WENNST MANST result[1]
    
    STRAWANZ MA (OIDA coords AIZAL active) {
        WOS WÜSTN (JO EH (active[coords][1] KANNST DA VUASTÖHN 2) UND ÜBRIGENS JO EH (active[coords][1] KANNST DA VUASTÖHN 3)) {
            SCHLEICH DI active[coords]
        }
    }
    STRAWANZ MA (OIDA coords AIZAL empties) {
        WOS WÜSTN (empties[coords][1] KANNST DA VUASTÖHN 3) {
            active[coords] WENNST MANST empties[coords]
        }
    }
}

OIDA amount WENNST MANST 0
STRAWANZ MA (OIDA coords AIZAL active) {
    ANS AUFI amount
}
I MAN JA NUR(amount)

HACKL AMOI WOS update(active) {
    OIDA empties WENNST MANST {}
    STRAWANZ MA (OIDA coords AIZAL active) {
        FIX OIDA result WENNST MANST neighbours(active, active[coords][0], empties)
        active[coords][1] WENNST MANST result[0]
        empties WENNST MANST result[1]
    }
    DRAH DI HAM [ active, empties ]
}

HACKL AMOI WOS neighbours(active, coords, empties) {
    OIDA amount WENNST MANST 0
    STRAWANZ MA (OIDA x WENNST MANST coords[0] - 1; x HOIT NET GRESSA coords[0] + 1; ANS AUFI x) {
        STRAWANZ MA (OIDA y WENNST MANST coords[1] - 1; y HOIT NET GRESSA coords[1] + 1; ANS AUFI y) {
            STRAWANZ MA (OIDA z WENNST MANST coords[2] - 1; z HOIT NET GRESSA coords[2] + 1; ANS AUFI z) {
                STRAWANZ MA (OIDA w WENNST MANST coords[3] - 1; w HOIT NET GRESSA coords[3] + 1; ANS AUFI w) {
                    FIX OIDA c WENNST MANST [x, y, z, w]
                    WOS WÜSTN (x KANNST DA VUASTÖHN coords[0]
                      UND ÜBRIGENS y KANNST DA VUASTÖHN coords[1]
                      UND ÜBRIGENS z KANNST DA VUASTÖHN coords[2]
                      UND ÜBRIGENS w KANNST DA VUASTÖHN coords[3]) {
                    } WOA NUA A SCHMÄH (c.toString() AIZAL active) {
                        ANS AUFI amount
                    } A SCHO WUASCHT {
                        WOS WÜSTN (JO EH (c.toString() AIZAL empties)) {
                            empties[c.toString()] WENNST MANST [ c, 0 ]
                        }
                        ANS AUFI empties[c.toString()][1]
                    }
                }
            }
        }
    }
    DRAH DI HAM [ amount, empties ]
}