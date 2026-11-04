# PracticaGit - Taller de Git y GitHub

Proyecto Java sencillo para practicar Git desde NetBeans y automatizar los commits, ramas y merge del taller.

## Proyecto
- Tipo: Java Application with Ant (NetBeans)
- Clase: `Carro`
- Paquete: predeterminado
- Archivo principal: `src/Carro.java`

## Automatización
En Windows, abre PowerShell dentro de esta carpeta y ejecuta:

```powershell
powershell -ExecutionPolicy Bypass -File .\completar_taller.ps1
```

El script configura Git con la identidad indicada en el taller, crea commits, demuestra la restauración de una versión anterior, crea y fusiona `rama-frenar`, y trata de publicar el repositorio en GitHub usando GitHub CLI (`gh`).

Para publicar en GitHub, debes iniciar sesión cuando GitHub CLI lo solicite. El script no guarda contraseñas ni tokens.
