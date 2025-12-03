@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"

:: ===========================================================================
:: TWITCH VOD DOWNLOADER & CHAT RENDERER
:: Version: 1.0 Public Release
:: Author:  RX32555
:: Github:  https://github.com/rx32555
:: License: MIT
:: ===========================================================================

title Twitch VOD Downloader v1.0 ^| by RX32555

:: ===========================================================================
:: 0. CONFIGURACIÓN
:: ===========================================================================
set "LOG_FILE=DescargarVOD_Twitch_log.txt"
echo [INICIO SESION] %date% %time% > "%LOG_FILE%"

:: Rutas
set "ROOT_DIR=%~dp0"
if "%ROOT_DIR:~-1%"=="\" set "ROOT_DIR=%ROOT_DIR:~0,-1%"

set "DIR_TOOLS=%ROOT_DIR%\ScriptFiles"
set "DIR_USER=%ROOT_DIR%\userinfo"
set "DIR_OUT=%ROOT_DIR%\output"
set "DIR_DOTNET=%DIR_TOOLS%\dotnet"
set "DIR_TEMP=%DIR_TOOLS%\temp"

:: Limpieza inicial
call :Cleanup

:: Crear directorios
if not exist "%DIR_TEMP%" mkdir "%DIR_TEMP%"
if not exist "%DIR_OUT%" mkdir "%DIR_OUT%"
if not exist "%DIR_USER%" mkdir "%DIR_USER%"

:: Archivos Ejecutables
set "EXE_7ZA=%DIR_TOOLS%\7za.exe"
set "EXE_TD=%DIR_TOOLS%\TwitchDownloaderCLI.exe"
set "EXE_YT=%DIR_TOOLS%\yt-dlp.exe"
set "EXE_FFMPEG=%DIR_TOOLS%\ffmpeg.exe"
set "EXE_MPV=%DIR_TOOLS%\mpv.exe"
set "EXE_MPVNET=%DIR_TOOLS%\mpvnet.exe"
set "EXE_DOTNET=%DIR_DOTNET%\dotnet.exe"

:: URLs
set "URL_7ZA=https://www.7-zip.org/a/7za920.zip"
set "URL_TD=https://github.com/lay295/TwitchDownloader/releases/download/1.56.2/TwitchDownloaderCLI-1.56.2-Windows-x64.zip"
set "URL_YT=https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp.exe"
set "URL_MPVNET=https://github.com/mpvnet-player/mpv.net/releases/download/v7.1.1.0/mpv.net-v7.1.1.0-portable.zip"
set "URL_DOTNET_SCRIPT=https://dotnet.microsoft.com/download/dotnet/scripts/v1/dotnet-install.ps1"

:: Archivos Usuario
set "FILE_COOKIES=%DIR_USER%\www.twitch.tv_cookies.txt"
set "FILE_TOKEN=%DIR_USER%\www.twitch.tv_OAUTH_TOKEN.txt"
set "FILE_VODID=%DIR_USER%\www.twitch.tv_url_VOD_ID.txt"
set "FILE_CHANNEL=%DIR_USER%\www.twitch.tv_url_channel.txt"
set "FILE_CFG=%DIR_USER%\DescargarVOD_list_Twitch_cfg.txt"

:: ===========================================================================
:: 1. MONITOREO Y PRESENTACIÓN
:: ===========================================================================
cls
set "DISK_LETTER=%~d0"
for /f "usebackq delims=" %%a in (`powershell -NoProfile -Command "[math]::Round((Get-PSDrive '%DISK_LETTER:~0,1%').Free / 1GB)"`) do set "FREE_GB=%%a"

echo.
echo ========================================================
echo  TWITCH VOD DOWNLOADER
echo  v1.0 Public Release
echo.
echo  Dev:    RX32555
echo  Github: https://github.com/rx32555
echo ========================================================
echo.
echo  SISTEMA: %date% %time%
echo  ALMACENAMIENTO: %DISK_LETTER% (Libre: !FREE_GB! GB)
echo.
call :Print INFO "Iniciando verificacion de sistema..."
echo.

:: ===========================================================================
:: 2. DEPENDENCIAS
:: ===========================================================================
if not exist "%DIR_TOOLS%" mkdir "%DIR_TOOLS%"

:: 1. 7-Zip
call :CheckTool "7-Zip" "%EXE_7ZA%"
if !errorlevel! NEQ 0 (
    call :Print WARN "Descargando 7za..."
    curl -L -o "%DIR_TOOLS%\temp_7za.zip" "%URL_7ZA%" --ssl-no-revoke
    if exist "%DIR_TOOLS%\temp_7za.zip" (
        powershell -NoProfile -Command "Expand-Archive -Path '%DIR_TOOLS%\temp_7za.zip' -DestinationPath '%DIR_TOOLS%' -Force"
        del "%DIR_TOOLS%\temp_7za.zip"
    )
)

:: 2. TwitchDownloaderCLI
call :CheckTool "TwitchDownloader" "%EXE_TD%"
if !errorlevel! NEQ 0 (
    if exist "%EXE_7ZA%" (
        call :Print WARN "Descargando TD..."
        curl -L -o "%DIR_TOOLS%\temp_td.zip" "%URL_TD%" --ssl-no-revoke
        if exist "%DIR_TOOLS%\temp_td.zip" (
            "%EXE_7ZA%" e "%DIR_TOOLS%\temp_td.zip" -o"%DIR_TOOLS%" -y >nul
            del "%DIR_TOOLS%\temp_td.zip"
        )
    )
)

:: 3. yt-dlp
call :CheckTool "yt-dlp" "%EXE_YT%"
if !errorlevel! NEQ 0 (
    call :Print WARN "Descargando yt-dlp..."
    curl -L -o "%EXE_YT%" "%URL_YT%" --ssl-no-revoke
)

:: 4. FFmpeg
call :CheckTool "FFmpeg" "%EXE_FFMPEG%"
if !errorlevel! NEQ 0 (
    if exist "%EXE_TD%" (
        call :Print WARN "Instalando FFmpeg..."
        pushd "%DIR_TOOLS%"
        TwitchDownloaderCLI.exe ffmpeg --download
        popd
    )
)

:: 5. MPV Player
set "HAS_PLAYER=0"
if exist "%EXE_MPV%" set "HAS_PLAYER=1"
if exist "%EXE_MPVNET%" set "HAS_PLAYER=1"

if !HAS_PLAYER! EQU 0 (
    call :Print WARN "Descargando mpv.net..."
    if exist "%EXE_7ZA%" (
        curl -L -o "%DIR_TOOLS%\temp_mpvnet.zip" "%URL_MPVNET%" --ssl-no-revoke
        if exist "%DIR_TOOLS%\temp_mpvnet.zip" (
             "%EXE_7ZA%" e "%DIR_TOOLS%\temp_mpvnet.zip" -o"%DIR_TOOLS%" -y >nul
             del "%DIR_TOOLS%\temp_mpvnet.zip"
        )
    )
)

:: 6. .NET 6.0 (Runtime Base + Desktop)
set "DOTNET_OK=0"
if exist "%EXE_DOTNET%" (
    if exist "%DIR_DOTNET%\shared\Microsoft.WindowsDesktop.App\6.0.*" set "DOTNET_OK=1"
)

if !DOTNET_OK! EQU 0 (
    call :Print WARN "Instalando .NET 6.0 Completo (Base + Desktop)..."
    if not exist "%DIR_TOOLS%\dotnet-install.ps1" (
        curl -L -o "%DIR_TOOLS%\dotnet-install.ps1" "%URL_DOTNET_SCRIPT%" --ssl-no-revoke
    )
    
    :: Paso 1: Instalar 'dotnet' (El Host dotnet.exe)
    call :Print INFO "Descargando .NET Host..."
    powershell -NoProfile -ExecutionPolicy Bypass -File "%DIR_TOOLS%\dotnet-install.ps1" -Channel 6.0 -Runtime dotnet -InstallDir "%DIR_DOTNET%"
    
    :: Paso 2: Instalar 'windowsdesktop' (Librerias GUI)
    call :Print INFO "Descargando .NET Desktop Runtime..."
    powershell -NoProfile -ExecutionPolicy Bypass -File "%DIR_TOOLS%\dotnet-install.ps1" -Channel 6.0 -Runtime windowsdesktop -InstallDir "%DIR_DOTNET%"
)

echo.
call :Print OK "Dependencias verificadas."
echo.

:: ===========================================================================
:: 3. CARGA Y CONFIRMACIÓN DE USUARIO
:: ===========================================================================
:LoadConfig
:: Leer Token
set "CURRENT_TOKEN=[VACIO]"
if exist "%FILE_TOKEN%" (
    for %%A in ("%FILE_TOKEN%") do if %%~zA GTR 0 set "CURRENT_TOKEN=[OK]"
)

:: Leer Canal
set "CURRENT_CHANNEL=[NO DEFINIDO]"
if exist "%FILE_CHANNEL%" (
    set /p TMP_CH=<"%FILE_CHANNEL%"
    if not "!TMP_CH!"=="" set "CURRENT_CHANNEL=!TMP_CH!"
)

:: Leer Configuración Chat (Default 1)
set "CHAT_DL=1"
if exist "%FILE_CFG%" set /p CHAT_DL=<"%FILE_CFG%"
set "TXT_CHAT=[SI]"
if "!CHAT_DL!"=="0" set "TXT_CHAT=[NO]"

:: --- PANTALLA DE INICIO ---
echo ========================================================
powershell -NoProfile -Command "Write-Host ' CANAL ACTUAL: ' -NoNewline; Write-Host '!CURRENT_CHANNEL!' -ForegroundColor Green"
echo  Token OAuth:  !CURRENT_TOKEN!
echo  Chat DL:      !TXT_CHAT!
echo ========================================================
echo.
echo  La configuracion parece correcta, pero puede cambiarla presionando:
echo   [M]odificar configuracion
echo   [C]ontinuar ahora
echo.
powershell -NoProfile -Command "Write-Host ' Iniciando en 10 segundos revision de VODs...' -ForegroundColor Green"
echo.

choice /C MC /N /T 10 /D C /M ">> Seleccione opcion o espere... "

if errorlevel 2 goto :ValidationCheck
if errorlevel 1 goto :ShowConfigMenu

goto :ValidationCheck

:: --- MENU DE MODIFICACIÓN ---
:ShowConfigMenu
echo.
echo ---------------------------
echo   MENU DE CONFIGURACION
echo ---------------------------
echo  1. Cambiar Token OAuth
echo  2. Cambiar Canal
echo  3. Chat Download/Render: !TXT_CHAT!
echo  4. Volver / Continuar
echo.
choice /C 1234 /M ">> Seleccione opcion: "

if errorlevel 4 goto :ValidationCheck
if errorlevel 3 goto :ToggleChat
if errorlevel 2 goto :ForceChannelEdit
if errorlevel 1 goto :ForceTokenEdit

:ToggleChat
if "!CHAT_DL!"=="1" (
    set "CHAT_DL=0"
) else (
    set "CHAT_DL=1"
)
echo !CHAT_DL!> "%FILE_CFG%"
goto :LoadConfig

:ForceTokenEdit
call :TokenWizard
goto :LoadConfig

:ForceChannelEdit
call :ChannelWizard
goto :LoadConfig

:: --- VALIDACIÓN FINAL ---
:ValidationCheck
if "!CURRENT_TOKEN!"=="[VACIO]" (
    call :Print WARN "Falta Token. Iniciando asistente..."
    call :TokenWizard
)
if "!CURRENT_CHANNEL!"=="[NO DEFINIDO]" (
    call :Print WARN "Falta Canal. Iniciando asistente..."
    call :ChannelWizard
)

set /p OAUTH_TOKEN=<"%FILE_TOKEN%"
set /p RAW_CHANNEL_INPUT=<"%FILE_CHANNEL%"
if exist "%FILE_CFG%" set /p CHAT_DL=<"%FILE_CFG%"

goto :StartSearch

:: --- SUBRUTINAS DE ASISTENTE ---
:TokenWizard
echo.
echo ===============================================================================
echo        CONFIGURACION TOKEN
echo ===============================================================================
echo  1. Descarga extension 'Get cookies.txt LOCALLY' en Chrome.
echo  2. Inicia sesion en Twitch.tv.
echo  3. Busca 'auth-token' y copia valor.
echo     EJEMPLO: knsMcq59y9n0qj4hZo9u92hs8p06rn
echo.
echo  Se abrira el archivo. PEGA EL TOKEN Y GUARDE.
echo ===============================================================================
pause
if not exist "%FILE_TOKEN%" type nul > "%FILE_TOKEN%"
start notepad "%FILE_TOKEN%"
echo.
call :Print INFO "Esperando archivo..."
pause
exit /b

:ChannelWizard
echo.
call :Print WARN "Configurar Canal"
set /p "USER_INPUT_CH=Ingrese nombre del canal (ej. ibai): "
set "FINAL_URL=https://www.twitch.tv/%USER_INPUT_CH%"
echo !FINAL_URL!> "%FILE_CHANNEL%"
set "USER_INPUT_CH="
exit /b


:: ===========================================================================
:: 4. BÚSQUEDA Y SELECCIÓN
:: ===========================================================================
:StartSearch
echo.
echo ========================================================
echo  BUSCANDO CONTENIDO...
echo ========================================================

set "URL_VODS=!RAW_CHANNEL_INPUT!/videos?filter=archives&sort=time"

if exist "list_temp.txt" del "list_temp.txt"
"%EXE_YT%" --lazy-playlist --playlist-end 10 --print "%%(id)s|%%(upload_date)s|%%(title)s" "!URL_VODS!" --no-warnings > "list_temp.txt" 2>nul

if not exist "list_temp.txt" goto :ErrorVODs
for %%A in ("list_temp.txt") do if %%~zA==0 goto :ErrorVODs

:: Mostrar Lista
echo.
powershell -NoProfile -Command "Write-Host ' VODs RECIENTES' -ForegroundColor Yellow"
echo --------------------------------------------------------
set count=0
powershell -NoProfile -Command ^
    "$c=0; Get-Content 'list_temp.txt' | ForEach-Object { $c++; $p=$_.Split('|'); $id=$p[0]; $date=$p[1]; $rawTitle=$p[2]; " ^
    "$cleanTitle=$rawTitle.Replace(\"'\",\"\").Substring(0, [math]::Min(90, $rawTitle.Length)); " ^
    "$dShow='----'; if($date -ne 'NA'){ $dShow=$date.Substring(0,4)+'-'+$date.Substring(4,2)+'-'+$date.Substring(6,2) }; " ^
    "Write-Host \" $c. \" -NoNewline -ForegroundColor Cyan; " ^
    "Write-Host \"[$dShow] \" -NoNewline -ForegroundColor Gray; " ^
    "Write-Host \"$cleanTitle... \" -NoNewline; " ^
    "Write-Host \"(ID: $id)\" -ForegroundColor DarkGray }"

for /f %%C in ('type "list_temp.txt" ^| find /c /v ""') do set "count=%%C"
echo --------------------------------------------------------
powershell -NoProfile -Command "Write-Host ' [C] Configurar   ' -NoNewline -ForegroundColor Yellow; Write-Host '|   by RX32555' -ForegroundColor DarkGray"
echo --------------------------------------------------------
echo.

:AskSelection
set "SELECTION="
set /p "SELECTION=>> Ingrese NUMERO (1-!count!) o [C]onfigurar: "

if /i "!SELECTION!"=="C" goto :ShowConfigMenu

if "!SELECTION!"=="" goto :AskSelection
if !SELECTION! GTR !count! goto :AskSelection
if !SELECTION! LSS 1 goto :AskSelection

:: Recuperar ID
for /f "usebackq" %%I in (`powershell -NoProfile -Command "$lines=Get-Content 'list_temp.txt'; ($lines[%SELECTION%-1] -split '\|')[0]"`) do set "VOD_ID=%%I"
set "VOD_ID=!VOD_ID:v=!"
call :Print OK "VOD Seleccionado ID: !VOD_ID!"
echo !VOD_ID!> "%FILE_VODID%"
del "list_temp.txt"

:: ===========================================================================
:: 5. PROCESAMIENTO NOMBRE
:: ===========================================================================
set "COOKIE_ARG="
if exist "%FILE_COOKIES%" (
    call :Print OK "Cookies detectadas (Opcional)."
    set "COOKIE_ARG=--cookies "%FILE_COOKIES%""
)

call :Print INFO "Obteniendo metadatos..."

set "TEMP_NAME_FILE=%ROOT_DIR%\name_temp.txt"
set "PS_SCRIPT=%ROOT_DIR%\sanitize_script.ps1"
set "CLEAN_FILE=%ROOT_DIR%\clean_name.txt"

if exist "%TEMP_NAME_FILE%" del "%TEMP_NAME_FILE%"
"%EXE_YT%" https://www.twitch.tv/videos/!VOD_ID! %COOKIE_ARG% --print filename -o "%%(uploader)s - %%(upload_date)s - %%(title)s" --restrict-filenames --no-warnings > "%TEMP_NAME_FILE%" 2>nul

if not exist "%TEMP_NAME_FILE%" (
    set "FINAL_FILENAME=TwitchVOD_!VOD_ID!"
    goto :SkipNameClean
)

:: GENERAR SCRIPT PS1 DE LIMPIEZA
if exist "%PS_SCRIPT%" del "%PS_SCRIPT%"
echo $path = '%TEMP_NAME_FILE%' >> "%PS_SCRIPT%"
echo if (Test-Path $path) { >> "%PS_SCRIPT%"
echo     $n = Get-Content $path -Raw >> "%PS_SCRIPT%"
echo     $n = $n.Trim() >> "%PS_SCRIPT%"
echo     $n = $n -replace '[^^a-zA-Z0-9 \-_\.]', '_' >> "%PS_SCRIPT%"
echo     $n = $n.Replace('.mp4','').Replace('.mkv','').Replace('.webm','') >> "%PS_SCRIPT%"
echo     if ($n.Length -gt 100) { $n = $n.Substring(0, 100) } >> "%PS_SCRIPT%"
echo     $n ^| Out-File '%CLEAN_FILE%' -Encoding ascii >> "%PS_SCRIPT%"
echo } >> "%PS_SCRIPT%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_SCRIPT%"

if exist "%CLEAN_FILE%" (
    set /p FINAL_FILENAME=<"%CLEAN_FILE%"
) else (
    set "FINAL_FILENAME=TwitchVOD_!VOD_ID!"
)

:SkipNameClean
set "OUT_VIDEO=%DIR_OUT%\%FINAL_FILENAME%.mp4"
set "OUT_JSON=%DIR_OUT%\%FINAL_FILENAME%_chat.json"
set "OUT_TXT=%DIR_OUT%\%FINAL_FILENAME%_chat.txt"
set "OUT_RENDER=%DIR_OUT%\%FINAL_FILENAME%_chat_render.mp4"
set "OUT_PLAYER=%DIR_OUT%\%FINAL_FILENAME%_VER_CON_CHAT.bat"

echo.
echo [ESTADO DE DESCARGA]
echo Archivo: %FINAL_FILENAME%
echo --------------------

:: ===========================================================================
:: 6. DESCARGAS
:: ===========================================================================
if exist "%OUT_VIDEO%" (
    call :Print OK "Video ya existe."
) else (
    call :Print INFO "Descargando Video..."
    "%EXE_TD%" videodownload --id !VOD_ID! --oauth !OAUTH_TOKEN! -q Source -t 8 --ffmpeg-path "%EXE_FFMPEG%" --temp-path "%DIR_TEMP%" -o "%OUT_VIDEO%"
)

:: --- LÓGICA DE CHAT OPCIONAL ---
echo.
if "!CHAT_DL!"=="0" goto :ChatSkippedLogic
if "!CHAT_DL!"=="1" goto :ChatNormalLogic

:ChatSkippedLogic
powershell -NoProfile -Command "Write-Host 'Descarga VOD completada. Chat omitido por configuracion.' -ForegroundColor Yellow"
echo  Puede presionar 1 para DESCARGAR CHAT ahora.
echo  O cualquier tecla para finalizar.
choice /C 1E /N /M ">> Elija opcion: "
if errorlevel 2 goto :CreatePlayer
if errorlevel 1 goto :ProcessChat
goto :CreatePlayer

:ChatNormalLogic
powershell -NoProfile -Command "Write-Host 'Descarga VOD completada.' -ForegroundColor Green"
echo  Ahora se procedera a descargar y renderizar chat (Opcional).
echo  Es seguro cerrar la ventana si no lo necesita.
powershell -NoProfile -Command "Write-Host 'Iniciando proceso de Chat en 20 segundos...' -ForegroundColor Green"
choice /T 20 /D C /C C /N /M ">> Presione C para continuar inmediatamente..."
goto :ProcessChat

:ProcessChat
if exist "%OUT_JSON%" (
    call :Print OK "Chat JSON ya existe."
) else (
    call :Print INFO "Descargando Chat JSON..."
    "%EXE_TD%" chatdownload --id !VOD_ID! -E -o "%OUT_JSON%"
)

if not exist "%OUT_TXT%" (
    call :Print INFO "Descargando Chat TXT..."
    "%EXE_TD%" chatdownload --id !VOD_ID! -o "%OUT_TXT%"
)

if exist "%OUT_RENDER%" (
    call :Print OK "Chat Renderizado ya existe."
) else (
    if exist "%OUT_JSON%" (
        call :Print INFO "Renderizando Chat..."
        "%EXE_TD%" chatrender -i "%OUT_JSON%" -o "%OUT_RENDER%" --ffmpeg-path "%EXE_FFMPEG%" -h 1080 -w 340 --framerate 30 --update-rate 0 --font-size 18 --background-color "#00000000" --outline --generate-mask
    ) else (
        call :PrintERR "No hay JSON para renderizar chat."
    )
)

:: ===========================================================================
:: 7. GENERAR REPRODUCTOR (SIMPLIFICADO Y ROBUSTO)
:: ===========================================================================
:CreatePlayer
call :Print INFO "Actualizando lanzador..."

:: Eliminar version previa
if exist "%OUT_PLAYER%" del "%OUT_PLAYER%"

:: Generar archivo linea por linea
echo @echo off > "%OUT_PLAYER%"
echo cd /d "%%~dp0" >> "%OUT_PLAYER%"
echo set "VOD=%%~dp0%FINAL_FILENAME%.mp4" >> "%OUT_PLAYER%"
echo set "CHAT=%%~dp0%FINAL_FILENAME%_chat_render.mp4" >> "%OUT_PLAYER%"
echo set "TOOLS=%%~dp0..\ScriptFiles" >> "%OUT_PLAYER%"
echo. >> "%OUT_PLAYER%"
echo :: --- 1. Detectar y Configurar MPV.NET --- >> "%OUT_PLAYER%"
echo if exist "%%TOOLS%%\mpvnet.exe" ( >> "%OUT_PLAYER%"
echo     echo [INFO] Encontrado MPV.NET... >> "%OUT_PLAYER%"
echo     if exist "%%TOOLS%%\dotnet\dotnet.exe" ( >> "%OUT_PLAYER%"
echo         echo [INFO] Usando .NET Portable... >> "%OUT_PLAYER%"
echo         set "DOTNET_ROOT=%%TOOLS%%\dotnet" >> "%OUT_PLAYER%"
echo         set "DOTNET_MULTILEVEL_LOOKUP=0" >> "%OUT_PLAYER%"
echo         set "PATH=%%TOOLS%%\dotnet;%%PATH%%" >> "%OUT_PLAYER%"
echo     ) >> "%OUT_PLAYER%"
echo     "%%TOOLS%%\mpvnet.exe" "%%VOD%%" --external-file="%%CHAT%%" --lavfi-complex="[vid1][vid2]overlay=W-w-10:H-h-10[vo]" --force-window --keep-open >> "%OUT_PLAYER%"
echo     goto :EOF >> "%OUT_PLAYER%"
echo ) >> "%OUT_PLAYER%"
echo. >> "%OUT_PLAYER%"
echo :: --- 2. Detectar MPV Nativo --- >> "%OUT_PLAYER%"
echo if exist "%%TOOLS%%\mpv.exe" ( >> "%OUT_PLAYER%"
echo     echo [INFO] Encontrado MPV Nativo... >> "%OUT_PLAYER%"
echo     "%%TOOLS%%\mpv.exe" "%%VOD%%" --external-file="%%CHAT%%" --lavfi-complex="[vid1][vid2]overlay=W-w-10:H-h-10[vo]" --force-window --keep-open >> "%OUT_PLAYER%"
echo     goto :EOF >> "%OUT_PLAYER%"
echo ) >> "%OUT_PLAYER%"
echo. >> "%OUT_PLAYER%"
echo :: --- 3. Fallback Sistema --- >> "%OUT_PLAYER%"
echo echo [WARN] No se encontraron reproductores portables. Usando sistema... >> "%OUT_PLAYER%"
echo start "" "%%VOD%%" >> "%OUT_PLAYER%"

:: Limpieza Final
call :Cleanup

echo.
echo ========================================================
call :Print OK "PROCESO COMPLETADO"
echo  Ruta de salida: %DIR_OUT%
echo ========================================================
echo.
echo  Desea ABRIR el reproductor ahora?
echo   [1] Si, reproducir
echo   [2] No, salir
echo.

choice /C 12 /N /M ">> Seleccione opcion: "

if errorlevel 2 exit /b
if errorlevel 1 (
    start "" "%OUT_PLAYER%"
    exit /b
)

:: ===========================================================================
:: MANEJO DE ERRORES
:: ===========================================================================
:ErrorVODs
echo.
call :Print ERR "No se encontraron VODs."
echo.
echo  Posibles causas:
echo   1. El canal no existe o esta mal escrito.
echo   2. El canal no tiene videos archivados.
echo.
echo  Que desea hacer?
echo   [C]ambiar Canal
echo   [R]eintentar
echo   [S]alir
echo.
choice /C CRS /M ">> Seleccione opcion: "

if errorlevel 3 exit /b
if errorlevel 2 goto :StartSearch
if errorlevel 1 (
    call :ChannelWizard
    goto :LoadConfig
)

:: ===========================================================================
:: FUNCIONES
:: ===========================================================================
:Print
set "TYPE=%~1"
set "MSG=%~2"
set "COLOR=White"
if "%TYPE%"=="OK" set "COLOR=Green"
if "%TYPE%"=="INFO" set "COLOR=Cyan"
if "%TYPE%"=="WARN" set "COLOR=Yellow"
if "%TYPE%"=="ERR" set "COLOR=Red"
set "MSG_PS=!MSG:'=''!"
powershell -NoProfile -Command "Write-Host '[%TYPE%]' -ForegroundColor %COLOR% -NoNewline; Write-Host ' %MSG_PS%'"
echo [%time:~0,8%] [%TYPE%] %MSG% >> "%LOG_FILE%"
exit /b

:PrintERR
call :Print ERR "%~1"
exit /b

:CheckTool
set "TOOL_NAME=%~1"
set "TOOL_PATH=%~2"
if exist "%TOOL_PATH%" (
    call :Print OK "ENCONTRADO: %TOOL_NAME%"
    exit /b 0
) else (
    call :Print WARN "FALTANTE: %TOOL_NAME%"
    exit /b 1
)

:Cleanup
if exist "%DIR_TEMP%" rmdir /s /q "%DIR_TEMP%" 2>nul
if exist "%ROOT_DIR%\name_temp.txt" del "%ROOT_DIR%\name_temp.txt"
if exist "%ROOT_DIR%\clean_name.txt" del "%ROOT_DIR%\clean_name.txt"
if exist "%ROOT_DIR%\sanitize_script.ps1" del "%ROOT_DIR%\sanitize_script.ps1"
exit /b