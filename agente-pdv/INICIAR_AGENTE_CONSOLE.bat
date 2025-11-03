@echo off
echo ========================================
echo INICIAR AGENTE PDV (Modo Console)
echo ========================================
echo.
echo IMPORTANTE: Deixe esta janela aberta
echo O agente estara rodando neste console
echo Pressione Ctrl+C para parar
echo.
echo ========================================
echo.

cd /d "C:\Solis\AgentePDV"
set ASPNETCORE_ENVIRONMENT=Production
Solis.AgentePDV.exe
