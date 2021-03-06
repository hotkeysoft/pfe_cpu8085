#pragma once

#include "..\include\common.h"

class CVariables
{
public:
	CVariables(void);
	~CVariables(void);

	static void Set(BYTE tag[2], BYTE *);
	static void Get(BYTE tag[2], BYTE *);

	static StackID GetType(BYTE tag[2]);

	static void Dump();

	static void Empty() {HiAutoVars = LoAutoVars;}

protected:
	static BYTE *internalGet(BYTE tag[2]);
	static BYTE *New(BYTE tag[2]);
};
