# Script para comprimir imágenes del catálogo
# Requiere ImageMagick instalado: https://imagemagick.org/script/download.php#windows

param(
    [int]$Quality = 85,
    [int]$MaxWidth = 800,
    [string]$InputFolder = "images",
    [string]$OutputFolder = "images-compressed"
)

Write-Host "🖼️  Compresión de Imágenes del Catálogo" -ForegroundColor Green
Write-Host "Calidad: $Quality%" -ForegroundColor Cyan
Write-Host "Ancho máximo: $MaxWidth px" -ForegroundColor Cyan

# Verificar si ImageMagick está instalado
try {
    $null = Get-Command "magick" -ErrorAction Stop
    Write-Host "✅ ImageMagick encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ ImageMagick no encontrado. Instalando..." -ForegroundColor Red
    Write-Host "Descargando desde: https://imagemagick.org/script/download.php#windows" -ForegroundColor Yellow
    Write-Host "Después de instalar, reinicia PowerShell y ejecuta este script nuevamente." -ForegroundColor Yellow
    Start-Process "https://imagemagick.org/script/download.php#windows"
    exit
}

# Crear carpeta de salida
if (!(Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    Write-Host "📁 Carpeta creada: $OutputFolder" -ForegroundColor Green
}

# Obtener todas las imágenes JPG
$images = Get-ChildItem -Path $InputFolder -Filter "*.jpg" -File

Write-Host "🔍 Encontradas $($images.Count) imágenes para comprimir" -ForegroundColor Cyan

$totalSizeOriginal = 0
$totalSizeCompressed = 0
$processedCount = 0

foreach ($image in $images) {
    $inputPath = $image.FullName
    $outputPath = Join-Path $OutputFolder $image.Name
    
    # Obtener tamaño original
    $originalSize = (Get-Item $inputPath).Length
    $totalSizeOriginal += $originalSize
    
    Write-Host "🔄 Procesando: $($image.Name)" -ForegroundColor Yellow
    
    try {
        # Comprimir imagen con ImageMagick
        $magickArgs = @(
            $inputPath
            "-resize", "${MaxWidth}x${MaxWidth}>"
            "-quality", $Quality
            "-strip"
            $outputPath
        )
        
        & magick @magickArgs
        
        if (Test-Path $outputPath) {
            $compressedSize = (Get-Item $outputPath).Length
            $totalSizeCompressed += $compressedSize
            $reduction = [math]::Round((($originalSize - $compressedSize) / $originalSize) * 100, 1)
            
            Write-Host "   ✅ $($image.Name) - Reducción: $reduction%" -ForegroundColor Green
            $processedCount++
        } else {
            Write-Host "   ❌ Error procesando $($image.Name)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Mostrar estadísticas finales
$totalReduction = [math]::Round((($totalSizeOriginal - $totalSizeCompressed) / $totalSizeOriginal) * 100, 1)
$originalSizeMB = [math]::Round($totalSizeOriginal / 1MB, 2)
$compressedSizeMB = [math]::Round($totalSizeCompressed / 1MB, 2)

Write-Host "`n📊 RESUMEN DE COMPRESIÓN" -ForegroundColor Green
Write-Host "Imágenes procesadas: $processedCount/$($images.Count)" -ForegroundColor Cyan
Write-Host "Tamaño original: $originalSizeMB MB" -ForegroundColor Cyan
Write-Host "Tamaño comprimido: $compressedSizeMB MB" -ForegroundColor Cyan
Write-Host "Reducción total: $totalReduction%" -ForegroundColor Green

Write-Host "`n🔄 Para usar las imágenes comprimidas:" -ForegroundColor Yellow
Write-Host "1. Respalda la carpeta 'images' original" -ForegroundColor White
Write-Host "2. Reemplaza el contenido de 'images' con 'images-compressed'" -ForegroundColor White
Write-Host "3. O cambia las rutas en el código para usar 'images-compressed'" -ForegroundColor White
