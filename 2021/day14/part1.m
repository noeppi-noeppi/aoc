#import <Foundation/Foundation.h>

#define STEPS 10

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

int main(int argc, char* argv[]) {
    char start[30];
    scanf("%s\n", start);
    
    int inpLen = strlen(start);
    int maxLen = inpLen;
    int stepSize = 1;
    for (int i = 0; i < STEPS; i++) {
        maxLen += (maxLen - 1);
        stepSize *= 2;
    }
    char chain[maxLen + 1];
    for (int i = 0; i < maxLen; i++) {
        chain[i] = ' ';
    }
    chain[maxLen] = 0;
    for (int i = 0; i < inpLen; i++) {
        chain[i * stepSize] = start[i];
    }
    
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
    
    int nextStep;
    for (int i = 0; i < STEPS; i++) {
        nextStep = stepSize / 2;
        for (int j = 0; j < maxLen - stepSize; j += stepSize) {
            for (int k = 0; k < replacesLen; k++) {
                Chars chars = replaces[k];
                if (chain[j] == chars.left && chain[j + stepSize] == chars.right) {
                    chain[j + nextStep] = chars.replace;
                    goto after_loop;
                }
            }
            after_loop:;
        }
        stepSize = nextStep;
    }
    
    int count[26];
    for (int i = 0; i < 26; i++) {
        count[i] = 0;
    }
    for (int i = 0; i < maxLen; i++) {
        count[chain[i] - 65] += 1;
    }
    
    int max = 0;
    int min = 1 << 30;
    for (int i = 0; i < 26; i++) {
        if (count[i] > max) max = count[i];
        if (count[i] != 0 && count[i] < min) min = count[i];
    }

    printf("%d\n", max - min);

    return 0;
}
