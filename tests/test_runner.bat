@echo off
setlocal enabledelayedexpansion

set "TEST_DIR=test_env"
set "CLEANUP_BAT=%~dp0..\src\cleanup.bat"

echo ==========================================
echo Запуск теста 1: Заполнение ниже порога
echo ==========================================
if exist "%TEST_DIR%" rd /s /q "%TEST_DIR%"
mkdir "%TEST_DIR%\log" "%TEST_DIR%\backup"
fsutil file createnew "%TEST_DIR%\log\file1.log" 209715200 >nul
fsutil file createnew "%TEST_DIR%\log\file2.log" 209715200 >nul
fsutil file createnew "%TEST_DIR%\log\file3.log" 209715200 >nul
echo Создано файлов на 600 MB (требование >= 0.5 GB соблюдено)

call "%CLEANUP_BAT%" "%TEST_DIR%\log" 70 "%TEST_DIR%\backup" 1200

for /f %%A in ('dir /b "%TEST_DIR%\backup" 2^>nul ^| find /c /v ""') do set "BCOUNT=%%A"
if not "%BCOUNT%"=="0" (
    echo Ошибка: архив не должен был создаваться!
    exit /b 1
)
if not exist "%TEST_DIR%\log\file1.log" (
    echo Ошибка: файлы не должны были удаляться!
    exit /b 1
)
echo Тест 1 успешно пройден!

echo ==========================================
echo Запуск теста 2: Заполнение выше порога (tar.gz)
echo ==========================================
if exist "%TEST_DIR%" rd /s /q "%TEST_DIR%"
mkdir "%TEST_DIR%\log" "%TEST_DIR%\backup"
fsutil file createnew "%TEST_DIR%\log\app_old.log" 188743680 >nul
timeout /t 2 /nobreak >nul
fsutil file createnew "%TEST_DIR%\log\app_mid1.log" 125829120 >nul
timeout /t 2 /nobreak >nul
fsutil file createnew "%TEST_DIR%\log\app_mid2.log" 262144000 >nul
timeout /t 2 /nobreak >nul
fsutil file createnew "%TEST_DIR%\log\app_new.log" 314572800 >nul
echo Создано файлов на 850 MB (требование >= 0.5 GB соблюдено)

call "%CLEANUP_BAT%" "%TEST_DIR%\log" 70 "%TEST_DIR%\backup" 1000

if exist "%TEST_DIR%\log\app_old.log" (
    echo Ошибка: старый файл не был удален!
    exit /b 1
)
if not exist "%TEST_DIR%\log\app_mid1.log" (
    echo Ошибка: свежие файлы были ошибочно удалены!
    exit /b 1
)
echo Тест 2 успешно пройден!

echo ==========================================
echo Запуск теста 3: Удаление нескольких файлов по возрасту
echo ==========================================
if exist "%TEST_DIR%" rd /s /q "%TEST_DIR%"
mkdir "%TEST_DIR%\log" "%TEST_DIR%\backup"
fsutil file createnew "%TEST_DIR%\log\log_1.log" 157286400 >nul
timeout /t 2 /nobreak >nul
fsutil file createnew "%TEST_DIR%\log\log_2.log" 209715200 >nul
timeout /t 2 /nobreak >nul
fsutil file createnew "%TEST_DIR%\log\log_3.log" 262144000 >nul
timeout /t 2 /nobreak >nul
fsutil file createnew "%TEST_DIR%\log\log_4.log" 314572800 >nul
echo Создано файлов на 900 MB (требование >= 0.5 GB соблюдено)

call "%CLEANUP_BAT%" "%TEST_DIR%\log" 60 "%TEST_DIR%\backup" 1000

if exist "%TEST_DIR%\log\log_1.log" (
    echo Ошибка: log_1.log не удален!
    exit /b 1
)
if exist "%TEST_DIR%\log\log_2.log" (
    echo Ошибка: log_2.log не удален!
    exit /b 1
)
if not exist "%TEST_DIR%\log\log_3.log" (
    echo Ошибка: log_3.log был ошибочно удален!
    exit /b 1
)
echo Тест 3 успешно пройден!

echo ==========================================
echo Запуск теста 4 (на 9-10 баллов): LZMA сжатие
echo ==========================================
if exist "%TEST_DIR%" rd /s /q "%TEST_DIR%"
mkdir "%TEST_DIR%\log" "%TEST_DIR%\backup"
fsutil file createnew "%TEST_DIR%\log\data_old.log" 209715200 >nul
timeout /t 2 /nobreak >nul
fsutil file createnew "%TEST_DIR%\log\data_new.log" 629145600 >nul
echo Создано файлов на 800 MB (требование >= 0.5 GB соблюдено)

set "LAB1_MAX_COMPRESSION=1"
call "%CLEANUP_BAT%" "%TEST_DIR%\log" 70 "%TEST_DIR%\backup" 1000
set "LAB1_MAX_COMPRESSION="

if not exist "%TEST_DIR%\backup\*.tar.lzma" (
    echo Ошибка: архив tar.lzma не найден!
    exit /b 1
)
if exist "%TEST_DIR%\log\data_old.log" (
    echo Ошибка: старый файл не удален!
    exit /b 1
)
echo Тест 4 успешно пройден!

if exist "%TEST_DIR%" rd /s /q "%TEST_DIR%"

echo ==========================================
echo Все тесты для Windows успешно пройдены!
echo ==========================================
