# Script de Compresión de Imágenes Simplificado
# Versión compatible con PowerShell/Windows

param(
    [int]$Quality = 85,
    [int]$MaxWidth = 800,
    [string]$InputFolder = "images",
    [string]$OutputFolder = "images-compressed"
)

Add-Type -AssemblyName System.Drawing

Write-Host "🖼️  Compresión de Imágenes del Catálogo (Versión Simplificada)" -ForegroundColor Green
Write-Host "Calidad: $Quality%" -ForegroundColor Cyan
Write-Host "Ancho máximo: $MaxWidth px" -ForegroundColor Cyan

# Crear carpeta de salida
if (!(Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    Write-Host "📁 Carpeta creada: $OutputFolder" -ForegroundColor Green
}

# Función para comprimir imagen individual (versión simplificada)
function Compress-ImageSimple {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Quality,
        [int]$MaxWidth
    )
    
    try {
        # Cargar imagen original
        $originalImage = [System.Drawing.Image]::FromFile($InputPath)
        
        # Calcular nuevas dimensiones
        $originalWidth = $originalImage.Width
        $originalHeight = $originalImage.Height
        
        if ($originalWidth -le $MaxWidth) {
            $newWidth = $originalWidth
            $newHeight = $originalHeight
        } else {
            $newWidth = $MaxWidth
            $newHeight = [int]($originalHeight * $MaxWidth / $originalWidth)
        }
        
        # Crear imagen redimensionada
        $resizedImage = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
        $graphics = [System.Drawing.Graphics]::FromImage($resizedImage)
        
        # Configuración básica de calidad
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        
        # Dibujar imagen
        $graphics.DrawImage($originalImage, 0, 0, $newWidth, $newHeight)
        
        # Configurar codec JPEG
        $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
        $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
        $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, $Quality)
        
        # Guardar imagen comprimida
        $resizedImage.Save($OutputPath, $jpegCodec, $encoderParams)
        
        # Limpiar recursos
        $graphics.Dispose()
        $resizedImage.Dispose()
        $originalImage.Dispose()
        
        return $true
    }
    catch {
        Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Obtener imágenes
$images = Get-ChildItem -Path $InputFolder -Filter "*.jpg" -File
Write-Host "🔍 Encontradas $($images.Count) imágenes para comprimir" -ForegroundColor Cyan

$totalOriginal = 0
$totalCompressed = 0
$processed = 0

foreach ($image in $images) {
    $inputPath = $image.FullName
    $outputPath = Join-Path $OutputFolder $image.Name
    
    $originalSize = (Get-Item $inputPath).Length
    $totalOriginal += $originalSize
    
    Write-Host "🔄 Procesando: $($image.Name)" -ForegroundColor Yellow
    
    $success = Compress-ImageSimple -InputPath $inputPath -OutputPath $outputPath -Quality $Quality -MaxWidth $MaxWidth
    
    if ($success -and (Test-Path $outputPath)) {
        $compressedSize = (Get-Item $outputPath).Length
        $totalCompressed += $compressedSize
        $reduction = [math]::Round((($originalSize - $compressedSize) / $originalSize) * 100, 1)
        
        $originalKB = [math]::Round($originalSize / 1KB, 1)
        $compressedKB = [math]::Round($compressedSize / 1KB, 1)
        
        Write-Host "   ✅ $originalKB KB → $compressedKB KB (-$reduction%)" -ForegroundColor Green
        $processed++
    }
}

# Estadísticas finales
if ($totalOriginal -gt 0) {
    $totalReduction = [math]::Round((($totalOriginal - $totalCompressed) / $totalOriginal) * 100, 1)
    $originalMB = [math]::Round($totalOriginal / 1MB, 2)
    $compressedMB = [math]::Round($totalCompressed / 1MB, 2)
    $savedMB = [math]::Round(($totalOriginal - $totalCompressed) / 1MB, 2)

    Write-Host "`n📊 RESUMEN FINAL" -ForegroundColor Green
    Write-Host "Procesadas: $processed/$($images.Count) imágenes" -ForegroundColor Cyan
    Write-Host "Original: $originalMB MB → Comprimido: $compressedMB MB" -ForegroundColor Cyan
    Write-Host "Ahorrado: $savedMB MB (Reducción: $totalReduction%)" -ForegroundColor Green
}

Write-Host "`n🏁 ¡Compresión completada!" -ForegroundColor Green
