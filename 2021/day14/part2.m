#import <Foundation/Foundation.h>

@interface CharsImpl : NSObject<NSCopying> {
    char left;
    char right;
    char replace;
}
@property char left;
@property char right;
@property char replace;
- init: (char) x between: (char) l and: (char) r;
+ (CharsImpl*) replace: (char) x between: (char) l and: (char) r;
@end

@implementation CharsImpl
@synthesize left;
@synthesize right;
@synthesize replace;
+ (CharsImpl*) replace: (char) x between: (char) l and: (char) r {
    return [[CharsImpl alloc] init: x between: l and: r];
}

- init: (char) x between: (char) l and: (char) r {
    self = [super init];
    if (self) {
        left = l;
        right = r;
        replace = x;
    }
    return self;
}

- (id) copyWithZone: (NSZone*)zone {
    return [CharsImpl replace: self.replace between: self.left and: self.right];
}
@end

typedef CharsImpl* Chars;

#define CACHE_ID(l, r, t) (l - 65) + (26 * (r - 65)) + (26 * 26 * (t - 1))

long cache[26 * 26 * 40];

void reset() {
    for (int i = 0; i < 26 * 26 * 40; i++) {
        cache[i] = -1;
    }
}

long additionals(char l, char r, int t, char z, Chars *replaces, int replacesLen) {
    if (t == 0) {
        return 0;
    }
    if (cache[CACHE_ID(l, r, t)] == -1) {
        char rep = 0;
        for (int i = 0; i < replacesLen; i++) {
            Chars chars = replaces[i];
            if (l == chars.left && r == chars.right) {
                rep = chars.replace;
                goto after_loop;
            }
        }
        after_loop:
        if (rep == 0) {
            cache[CACHE_ID(l, r, t)] = 0;
        } else {
            cache[CACHE_ID(l, r, t)] = (rep == z ? 1 : 0) + additionals(l, rep, t - 1, z, replaces, replacesLen) + additionals(rep, r, t - 1, z, replaces, replacesLen);
        }
    }
    return cache[CACHE_ID(l, r, t)];
}

int main(int argc, char* argv[]) {
    char start[30];
    scanf("%s\n", start);
    
    int inpLen = strlen(start);
    
    char left;
    char right;
    char replace;
    Chars replaces[200];
    int replacesLen = 0;
    while (scanf("%c%c -> %c\n", &left, &right, &replace) != EOF) {
        replaces[replacesLen] = [CharsImpl replace:replace between:left and:right];
        replacesLen += 1;
        replace = -1;
    }
    
    long max = 0;
    long min = 1l << 62;
    for (int i = 0; i < 26; i++) {
        reset();
        long c = 0;
        for (int j = 0; j < inpLen - 1; j++) {
            if (start[j] == 65 + i) c += 1;
            c += additionals(start[j], start[j + 1], 40, 65 + i, replaces, replacesLen);
        }
        if (start[inpLen - 1] == 65 + i) c += 1;
        if (c > max) max = c;
        if (c != 0 && c < min) min = c;
    }

    printf("%ld\n", max - min);

    return 0;
}
