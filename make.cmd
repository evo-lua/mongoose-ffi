@echo OFF
REM cl /nologo /LD /O2 mongoose-ffi.c -o mongoose.dll /link /DEF:mongoose.def
cl /nologo /O2 mongoose/mongoose.c main.c /Fe"test-mongoose.exe" /link Ws2_32.lib

REM Some optional cleanup to save disk space and de-clutter the repository
if exist *.obj del *.obj
if exist *.exp del *.exp
if exist *.lib del *.lib