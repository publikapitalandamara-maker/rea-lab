// Lesson 1 practice target: a tiny "ticket validator".
// Goal: find the valid ticket code WITHOUT reading this source file.
// Build: gcc -O0 -o crackme crackme.c && strip -o crackme-stripped crackme
#include <stdio.h>
#include <string.h>

static int check_ticket(const char *code) {
    // The code is built at runtime so it doesn't show up directly in `strings`.
    char expected[16];
    const char parts[] = {'G', 'O', 'L', '-', '2', '0', '2', '6'};
    for (int i = 0; i < 8; i++) expected[i] = parts[i];
    expected[8] = '\0';
    return strcmp(code, expected) == 0;
}

int main(int argc, char **argv) {
    if (argc != 2) {
        printf("Usage: %s <ticket-code>\n", argv[0]);
        return 1;
    }
    if (check_ticket(argv[1])) {
        puts("ACCESS GRANTED - enjoy the match!");
        return 0;
    }
    puts("INVALID TICKET");
    return 1;
}
