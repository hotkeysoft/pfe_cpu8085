@ECHO OFF
..\..\bin\AS8085.EXE -lo expreval
..\..\bin\AS8085.EXE -lo evaluate
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\AS8085.EXE -lo ..\integer\integer
..\..\bin\AS8085.EXE -lo ..\tokenize\tokenize
..\..\bin\AS8085.EXE -lo ..\variables\variable
..\..\bin\AS8085.EXE -lo ..\strings\strings
..\..\bin\AS8085.EXE -lo ..\io\io
..\..\bin\AS8085.EXE -lo ..\error\error
..\..\bin\AS8085.EXE -lo ..\program\program
..\..\bin\aslink.exe -f expreval

