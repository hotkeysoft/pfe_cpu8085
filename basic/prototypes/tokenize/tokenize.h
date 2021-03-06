#ifndef __TOKENIZE_H_INCLUDED
#define __TOKENIZE_H_INCLUDED

#include <iostream>

bool findToken(const char *in, char &token, int &length);
const char *findTokenStr(const unsigned char token);

void tokenize1(char *inout);
BYTE tokenize2(const char *in, char *out);


#endif