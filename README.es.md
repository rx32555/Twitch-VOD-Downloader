<div align="center">

# Twitch VOD Downloader & Chat Renderer

[![English](https://img.shields.io/badge/Lang-English-blue.svg)](README.md)
[![Español](https://img.shields.io/badge/Lang-Español-red.svg)](README.es.md)

</div>

---

Un script Batch automatizado y robusto para Windows que facilita la descarga, archivado y reproducción de VODs de Twitch junto con su chat renderizado.

##  Características

- **Descarga Automatizada**: Usa `yt-dlp` y `TwitchDownloaderCLI` para obtener video y chat.
- **Renderizado de Chat**: Convierte el chat de Twitch en un video transparente superpuesto (`.mp4`) listo para reproductores.
- **Reproductor Portátil**: Genera un lanzador `.bat` automático que sincroniza video + chat usando `mpv` o `mpv.net`.
- **Gestión de Dependencias**: Descarga y configura automáticamente todas las herramientas necesarias (`ffmpeg`, `yt-dlp`, `.NET 6`, etc.) en una carpeta local aislada.
- **Persistencia de Sesión**: Guarda tus preferencias (token, canal) localmente.

##  Requisitos Previos

- Windows 10/11 (64-bits recomendado).

##  Instalación

1. Clona este repositorio o descarga el archivo ZIP.
2. Ejecuta el archivo `Twitch-VOD-Downloader.bat`.
3. El script creará automáticamente las carpetas necesarias (`ScriptFiles`, `output`, `userinfo`).

## Configuración Inicial

Al ejecutar el script por primera vez, te pedirá:
1. **Token OAuth de Twitch**: Necesario para descargar VODs (especialmente subs-only).
   - Puedes obtenerlo usando extensiones como "Get cookies.txt LOCALLY".
   - El script te guiará en este proceso.
2. **Nombre del Canal**: El canal objetivo del cual quieres listar los VODs.

##  Uso

1. **Seleccionar VOD**: El menú mostrará los últimos 10 VODs del canal configurado.
2. **Descarga**: El script bajará el video y el chat.
3. **Opcional**: Puedes elegir si deseas renderizar el chat o solo descargar el video.
4. **Reproducción**: Al finalizar, se genera un archivo `.bat` en la carpeta `output` (ej: `Video_con_chat.bat`). Ejecútalo para ver el stream con el chat superpuesto como si fuera en vivo.

## Estructura de Carpetas

- `/src`: Código fuente del script.
- `/output`: Aquí se guardan los videos `.mp4` y los lanzadores.
- `/ScriptFiles`: Herramientas descargadas (no se suben al repo).
- `/userinfo`: Tokens y configuraciones locales (ignorado por git).

##  Contribuciones

Las contribuciones son bienvenidas. Si tienes ideas para mejorar el script, por favor abre un "Issue" o envía un "Pull Request".

## Licencia

Este proyecto está bajo la Licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---
**Nota**: Este script utiliza herramientas de terceros (`yt-dlp`, `TwitchDownloader`, `ffmpeg`, `mpv`). Todos los créditos a sus respectivos creadores.
