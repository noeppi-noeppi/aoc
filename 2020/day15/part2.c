#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

#define max(X, Y) (((X) > (Y)) ? (X) : (Y))

static int last_said_length = 0;
static int *last_said;

void setLastSaid(int, int);
int getLastSaid(int);

int main() {
    char *input = NULL;
    size_t input_length;
    getline(&input, &input_length, stdin);

    char *tok = strtok(input, ",");
    int last_spoken;
    int idx = 0;
    bool first = true;
    
    while(tok != NULL) {
        if (first) {
            first = false;
        } else {
            setLastSaid(last_spoken, idx - 1);
        }
        last_spoken = atol(tok);
        idx += 1;
        tok = strtok(NULL, ",");
    }
    
    while (idx < 30000000) {
        int last = getLastSaid(last_spoken);
        setLastSaid(last_spoken, idx - 1);
        if (last < 0) {
            last_spoken = 0;
        } else {
            last_spoken = abs((idx - 1) - last);
        }
        idx += 1;
    }
    
    printf("%d\n", last_spoken);
}

void setLastSaid(int value, int idx) {
    if (value < last_said_length) {
        last_said[value] = idx;
    } else if (last_said_length == 0) {
        last_said_length = value + 1;
        last_said = malloc(last_said_length * sizeof(int));
        for (int i = 0; i < last_said_length; ++i) {
            last_said[i] = -1;
        }
        last_said[value] = idx;
    } else {
        int old_length = last_said_length;
        last_said_length = max(last_said_length, value + 1);
        last_said = realloc(last_said, last_said_length * sizeof(int));
        for (int i = old_length; i < last_said_length; ++i) {
            last_said[i] = -1;
        }
        last_said[value] = idx;
    }
}

int getLastSaid(int value) {
    if (value < last_said_length) {
        return last_said[value];
    }
    return -1;
}