# Script de Compresión de Imágenes para Windows (Sin dependencias externas)
# Usa .NET Framework integrado en Windows

param(
    [int]$Quality = 85,
    [int]$MaxWidth = 800,
    [string]$InputFolder = "images",
    [string]$OutputFolder = "images-compressed"
)

Add-Type -AssemblyName System.Drawing

Write-Host "🖼️  Compresión de Imágenes del Catálogo" -ForegroundColor Green
Write-Host "Calidad: $Quality%" -ForegroundColor Cyan
Write-Host "Ancho máximo: $MaxWidth px" -ForegroundColor Cyan
Write-Host "Entrada: $InputFolder" -ForegroundColor Cyan
Write-Host "Salida: $OutputFolder" -ForegroundColor Cyan

# Crear carpeta de salida
if (!(Test-Path $OutputFolder)) {
    New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    Write-Host "📁 Carpeta creada: $OutputFolder" -ForegroundColor Green
}

# Función para comprimir imagen individual
function Compress-Image {
    param(
        [string]$InputPath,
        [string]$OutputPath,
        [int]$Quality,
        [int]$MaxWidth
    )
    
    try {
        # Cargar imagen original
        $originalImage = [System.Drawing.Image]::FromFile($InputPath)
        
        # Calcular nuevas dimensiones manteniendo proporción
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
        
        # Configurar calidad de redimensionamiento
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.CompositingHint = [System.Drawing.Drawing2D.CompositingHint]::AssumeLinear
        
        # Dibujar imagen redimensionada
        $graphics.DrawImage($originalImage, 0, 0, $newWidth, $newHeight)
        
        # Configurar codec JPEG con calidad específica
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
    
    $success = Compress-Image -InputPath $inputPath -OutputPath $outputPath -Quality $Quality -MaxWidth $MaxWidth
    
    if ($success -and (Test-Path $outputPath)) {
        $compressedSize = (Get-Item $outputPath).Length
        $totalSizeCompressed += $compressedSize
        $reduction = [math]::Round((($originalSize - $compressedSize) / $originalSize) * 100, 1)
        
        $originalKB = [math]::Round($originalSize / 1KB, 1)
        $compressedKB = [math]::Round($compressedSize / 1KB, 1)
        
        Write-Host "   ✅ $($image.Name) - $originalKB KB → $compressedKB KB (-$reduction%)" -ForegroundColor Green
        $processedCount++
    }
}

# Mostrar estadísticas finales
if ($totalSizeOriginal -gt 0) {
    $totalReduction = [math]::Round((($totalSizeOriginal - $totalSizeCompressed) / $totalSizeOriginal) * 100, 1)
    $originalSizeMB = [math]::Round($totalSizeOriginal / 1MB, 2)
    $compressedSizeMB = [math]::Round($totalSizeCompressed / 1MB, 2)
    $savedMB = [math]::Round(($totalSizeOriginal - $totalSizeCompressed) / 1MB, 2)

    Write-Host "`n📊 RESUMEN DE COMPRESIÓN" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
    Write-Host "Imágenes procesadas: $processedCount/$($images.Count)" -ForegroundColor Cyan
    Write-Host "Tamaño original: $originalSizeMB MB" -ForegroundColor Cyan
    Write-Host "Tamaño comprimido: $compressedSizeMB MB" -ForegroundColor Cyan
    Write-Host "Espacio ahorrado: $savedMB MB" -ForegroundColor Green
    Write-Host "Reducción total: $totalReduction%" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

    Write-Host "`n🔄 PASOS SIGUIENTES:" -ForegroundColor Yellow
    Write-Host "1. Respalda la carpeta 'images' original (renómbrala a 'images-backup')" -ForegroundColor White
    Write-Host "2. Renombra 'images-compressed' a 'images'" -ForegroundColor White
    Write-Host "3. Tu catálogo ahora usará las imágenes optimizadas automáticamente" -ForegroundColor White
    
    Write-Host "`n⚡ BENEFICIOS:" -ForegroundColor Cyan
    Write-Host "• Carga $totalReduction% más rápida del catálogo" -ForegroundColor White
    Write-Host "• Mejor experiencia para usuarios con conexión lenta" -ForegroundColor White
    Write-Host "• Menor uso de ancho de banda" -ForegroundColor White
    Write-Host "• Las imágenes mantendrán buena calidad visual" -ForegroundColor White
} else {
    Write-Host "`n❌ No se pudieron procesar las imágenes" -ForegroundColor Red
}

Write-Host "`n🏁 Compresión completada!" -ForegroundColor Green
