REM Run when the dependencies need to be fetched or updated; use make.cmd to simply rebuild the DLL
if exist include\openssl rmdir /S /Q include\openssl
if exist include\mongoose rmdir /S /Q include\mongoose
if not exist include mkdir include
cd include

REM See https://github.com/openssl/openssl/blob/master/NOTES-WINDOWS.md
git clone https://github.com/openssl/openssl --recursive
cd openssl
perl Configure VC-WIN64A no-shared
nmake
nmake test
dir

cd ..
git clone https://github.com/cesanta/mongoose
dir
REM Now ready to make mongoose.dll from the root directory (run make.cmd)
