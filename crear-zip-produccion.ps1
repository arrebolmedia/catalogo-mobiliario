# Script para empaquetar el catálogo de mobiliario en un ZIP
# Para enviar al programador y subir al servidor

$fechaHoy = Get-Date -Format "yyyy-MM-dd"
$nombreZip = "Catalogo-Mobiliario-$fechaHoy.zip"
$rutaZip = ".\$nombreZip"

Write-Host "=== EMPAQUETANDO CATÁLOGO DE MOBILIARIO ===" -ForegroundColor Cyan
Write-Host "Fecha: $fechaHoy" -ForegroundColor Yellow
Write-Host "Archivo de salida: $nombreZip" -ForegroundColor Yellow
Write-Host ""

# Verificar que los archivos principales existan
$archivosRequeridos = @(
    ".\index.html",
    ".\images\"
)

Write-Host "Verificando archivos requeridos..." -ForegroundColor Green
$todoOk = $true

foreach ($archivo in $archivosRequeridos) {
    if (Test-Path $archivo) {
        Write-Host "  ✓ $archivo" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $archivo (FALTANTE)" -ForegroundColor Red
        $todoOk = $false
    }
}

if (-not $todoOk) {
    Write-Host "Error: Faltan archivos requeridos. No se puede continuar." -ForegroundColor Red
    exit 1
}

# Contar archivos en images
$cantidadImagenes = (Get-ChildItem -Path ".\images\" -File | Measure-Object).Count
Write-Host "  ✓ Carpeta images contiene $cantidadImagenes archivos" -ForegroundColor Green
Write-Host ""

# Eliminar ZIP anterior si existe
if (Test-Path $rutaZip) {
    Write-Host "Eliminando archivo ZIP anterior..." -ForegroundColor Yellow
    Remove-Item $rutaZip -Force
}

# Crear el archivo ZIP
Write-Host "Creando archivo ZIP..." -ForegroundColor Green
try {
    # Crear carpeta temporal con el contenido
    $tempFolder = ".\temp-catalogo"
    if (Test-Path $tempFolder) {
        Remove-Item $tempFolder -Recurse -Force
    }
    New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
    
    # Copiar archivos al folder temporal
    Copy-Item ".\index.html" "$tempFolder\" -Force
    Copy-Item ".\images\" "$tempFolder\images\" -Recurse -Force
    
    # Crear README para el programador
    $readmeContent = @"
CATÁLOGO DE MOBILIARIO - CASANUEVA BY LAS MAÑANITAS
==================================================

Fecha de creación: $fechaHoy
Versión: Producción

CONTENIDO:
----------
- index.html: Archivo principal del catálogo (SPA completa)
- images/: Carpeta con todas las imágenes optimizadas ($cantidadImagenes archivos)

CARACTERÍSTICAS TÉCNICAS:
------------------------
- Single Page Application (SPA) en HTML5 + JavaScript vanilla
- Framework CSS: Tailwind CDN
- Iconos: Font Awesome 6.5.1
- Fuentes: Google Fonts (Montserrat + Playfair Display)
- Responsive design para móviles y desktop
- Modal con zoom para imágenes
- Filtros por categorías
- Conserva estado al refrescar (localStorage)

PRODUCTOS INCLUIDOS:
-------------------
- 41 productos reales organizados en 10 categorías
- Todas las imágenes están optimizadas y comprimidas
- Mapeo completo de imágenes sin conflictos

INSTRUCCIONES DE INSTALACIÓN:
----------------------------
1. Subir TODOS los archivos al servidor web
2. Mantener la estructura de carpetas exactamente como está
3. El archivo index.html debe estar en la raíz del dominio/subdirectorio
4. La carpeta 'images' debe estar al mismo nivel que index.html
5. No se requiere configuración adicional - funciona inmediatamente

COMPATIBILIDAD:
--------------
- Navegadores modernos (Chrome, Firefox, Safari, Edge)
- Dispositivos móviles y tablets
- No requiere base de datos ni servidor backend

CONTACTO TÉCNICO:
----------------
Cualquier duda técnica consultar con el desarrollador original.

¡Listo para producción!
"@
    
    $readmeContent | Out-File "$tempFolder\README.txt" -Encoding UTF8
    
    # Crear el ZIP
    Compress-Archive -Path "$tempFolder\*" -DestinationPath $rutaZip -Force
    
    # Limpiar carpeta temporal
    Remove-Item $tempFolder -Recurse -Force
    
    Write-Host "  ✓ Archivo ZIP creado exitosamente" -ForegroundColor Green
    
} catch {
    Write-Host "  ✗ Error creando el ZIP: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Verificar el ZIP creado
if (Test-Path $rutaZip) {
    $tamaño = [math]::Round((Get-Item $rutaZip).Length / 1MB, 2)
    Write-Host ""
    Write-Host "=== EMPAQUETADO COMPLETADO ===" -ForegroundColor Green
    Write-Host "Archivo: $nombreZip" -ForegroundColor Cyan
    Write-Host "Tamaño: $tamaño MB" -ForegroundColor Cyan
    Write-Host "Ubicación: $(Resolve-Path $rutaZip)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "CONTENIDO DEL ZIP:" -ForegroundColor Yellow
    Write-Host "  ✓ index.html (archivo principal)" -ForegroundColor Green
    Write-Host "  ✓ images/ ($cantidadImagenes archivos optimizados)" -ForegroundColor Green
    Write-Host "  ✓ README.txt (instrucciones para el programador)" -ForegroundColor Green
    Write-Host ""
    Write-Host "¡El archivo está listo para enviar al programador!" -ForegroundColor Green
    Write-Host "Instrucciones completas incluidas en README.txt" -ForegroundColor Yellow
} else {
    Write-Host "Error: No se pudo crear el archivo ZIP" -ForegroundColor Red
    exit 1
}
