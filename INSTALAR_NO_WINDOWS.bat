@echo off
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo ERRO: Flutter nao encontrado no PATH.
  pause
  exit /b 1
)
echo Preparando estrutura Android na versao do seu Flutter...
call flutter create --platforms=android --project-name cameralocalizacaoflutter .
if errorlevel 1 goto erro
echo Instalando dependencias...
call flutter pub get
if errorlevel 1 goto erro
echo Conecte seu tablet Android com depuracao USB e execute: flutter run
call flutter devices
pause
exit /b 0
:erro
echo Falha ao preparar o projeto. Confira a mensagem acima.
pause
exit /b 1
