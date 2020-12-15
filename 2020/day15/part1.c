#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

struct entry {
    int idx;
    int idx2;
    int value;
};
typedef struct entry entry;

static int last_said_length = 0;
static entry *last_said;

void setLastSaid(int, int);
int getLastSaid(int, bool);

int main() {
    char *input = NULL;
    size_t input_length;
    getline(&input, &input_length, stdin);

    char *tok = strtok(input, ",");
    int last_spoken;
    int idx = 0;
    
    while(tok != NULL) {
        last_spoken = atol(tok);
        setLastSaid(last_spoken, idx);
        idx += 1;
        tok = strtok(NULL, ",");
    }
    
    while (idx < 2020) {
        int last = getLastSaid(last_spoken, false);
        int last2 = getLastSaid(last_spoken, true);
        if (last < 0 || last2 < 0) {
            last_spoken = 0;
        } else {
            last_spoken = abs(last - last2);
        }
        setLastSaid(last_spoken, idx);
        idx += 1;
    }
    
    printf("%d\n", last_spoken);
}

void setLastSaid(int value, int idx) {
    for (int i = 0; i < last_said_length; i++) {
        if (last_said[i].value == value) {
            last_said[i].idx2 = last_said[i].idx;
            last_said[i].idx = idx;
            return;
        }
    }
    if (last_said_length == 0) {
        last_said_length = 1;
        last_said = malloc(last_said_length * sizeof(entry));
    } else {
        last_said_length += 1;
        last_said = realloc(last_said, last_said_length * sizeof(entry));
    }
    
    entry entry = { idx, -1, value };
    last_said[last_said_length - 1] = entry;
}

int getLastSaid(int value, bool second) {
    for (int i = 0; i < last_said_length; i++) {
        if (last_said[i].value == value) {
            if (second) {
                return last_said[i].idx2;
            } else {
                return last_said[i].idx;
            }
        }
    }
    return -1;
}