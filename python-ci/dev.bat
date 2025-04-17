@echo off
REM ============================================
REM Setup dan jalankan Flask app di Windows
REM ============================================

REM Cek apakah folder venv sudah ada
IF NOT EXIST "venv\" (
    echo Membuat virtual environment...
    python -m venv venv
)

REM Upgrade pip di dalam virtualenv
echo Meng-upgrade pip...
venv\Scripts\python.exe -m ensurepip --upgrade
venv\Scripts\python.exe -m pip install --upgrade pip

REM Install dependencies
echo Meng-install dependensi...
venv\Scripts\pip.exe install -r requirements.txt

REM test application
echo Testing application...
venv\Scripts\pytest.exe > result.log 2>&1

IF %ERRORLEVEL% NEQ 0 (
    echo Testing failed. Check result.log for details.
    exit /b %ERRORLEVEL%
) ELSE (
    echo Testing passed.
)
echo Testing complete.


REM Jalankan aplikasi Flask
echo Menjalankan aplikasi...
venv\Scripts\python.exe app.py

pause
