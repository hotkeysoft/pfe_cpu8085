@ECHO OFF
..\..\bin\AS8085.EXE -lo program
..\..\bin\AS8085.EXE -lo test
..\..\bin\AS8085.EXE -lo ..\common\common
..\..\bin\AS8085.EXE -lo ..\io\io
..\..\bin\AS8085.EXE -lo ..\error\error
..\..\bin\AS8085.EXE -lo ..\integer\integer
..\..\bin\AS8085.EXE -lo ..\variables\variable
..\..\bin\AS8085.EXE -lo ..\tokenize\tokenize
..\..\bin\aslink.exe -f program
..\..\bin\hexbin program.ihx
