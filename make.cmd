@echo OFF
cl /nologo /LD /O2 /I include\mongoose /I include\openssl\include /DMG_ENABLE_MD5 /DMG_ENABLE_IPV6 /DMG_ENABLE_LINES /DMG_ENABLE_OPENSSL include\mongoose\mongoose.c -o mongoose.dll /link /DEF:mongoose.def WS2_32.LIB include\openssl\libssl.lib include\openssl\libcrypto.lib GDI32.LIB ADVAPI32.LIB CRYPT32.LIB USER32.LIB

REM Some optional cleanup to save disk space and de-clutter the repository
if exist *.obj del *.obj
if exist *.exp del *.exp
@REM if exist *.lib del *.lib