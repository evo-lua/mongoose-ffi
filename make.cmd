@echo OFF
cl /nologo /LD /O2 mongoose/mongoose.c mongoose_ffi_bindings.c -o mongoose_ffi.dll /link /DEF:mongoose_ffi.def Ws2_32.lib
cl /nologo /O2 mongoose/mongoose.c main.c /Fe"test-mongoose.exe" /link Ws2_32.lib
cl /nologo /O2 test.c /Fe"test.exe" /link
cl /nologo /O2 utlist_test.c /Fe"utlist_test.exe" /link
cl /nologo /O2 sys_test.c /Fe"sys_test.exe" /link

REM Some optional cleanup to save disk space and de-clutter the repository
if exist *.obj del *.obj
if exist *.exp del *.exp
if exist *.lib del *.lib