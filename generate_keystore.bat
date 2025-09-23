@echo off
setlocal enabledelayedexpansion

REM ==== CONFIGURASI ====
set KEYSTORE_NAME=my-release-key.keystore
set ALIAS_NAME=my-key-alias
set VALIDITY_DAYS=10000
set KEYSTORE_PASS=hvac_password
set KEY_PASS=hvac_password

echo ========================================
echo Membuat Android Keystore untuk Play Store
echo ========================================

REM === Generate Keystore ===
keytool -genkey -v ^
 -keystore %KEYSTORE_NAME% ^
 -alias %ALIAS_NAME% ^
 -keyalg RSA ^
 -keysize 2048 ^
 -validity %VALIDITY_DAYS% ^
 -storepass %KEYSTORE_PASS% ^
 -keypass %KEY_PASS% ^
 -dname "CN=HVAC, OU=Dev, O=Company, L=City, S=Province, C=ID"

echo.
echo [✓] Keystore berhasil dibuat: %KEYSTORE_NAME%

REM === Encode Base64 ===
echo.
echo Mengubah keystore menjadi base64...
certutil -encode %KEYSTORE_NAME% keystore.txt >nul

echo [✓] File base64 tersimpan di: keystore.txt
echo.
echo ========================================
echo Upload isi file keystore.txt ke GitHub Secrets
echo Jangan commit file %KEYSTORE_NAME% ke GitHub!
echo ========================================

pause
