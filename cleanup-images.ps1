# Script para eliminar imágenes no utilizadas en el catálogo

# Lista de imágenes que SÍ estamos utilizando
$imagenesUtilizadas = @(
    # Sillas
    "silla-tiffany-blanca.jpg",
    "silla-crossback-café.jpg", 
    "silla-bamboo.jpg",
    "silla-especial-chocolate.jpg",
    "silla-especial-vintage.jpg",
    
    # Mesas
    "mesa-vintage-wash-redonda.jpg",
    "mesa-vintage-wash-rectangular.jpg",
    "mesa-napa-cuadrada.jpg",
    "mesa-napa-rectangular.jpg",
    "mesa-napa-redonda.jpg",
    "periquera-cuadrada.jpg",
    "periquera-rectangular.jpg",
    
    # Manteles
    "mantel-olas-blanco.jpg",
    "mantel-grecas-blanco.jpg",
    "mantel-beige-redondo.jpg",
    "mantel-gris-redondo.jpg",
    "mantel-talavera-redondo.jpg",
    "mantel-beige-cuadrado.jpg",
    "mantel-olas-cuadrado.jpg",
    "mantel-dorado-redondo.jpg",
    "mantel-aperlado-doble-vista.jpg",
    
    # Caminos de Mesa
    "camino-de-mesa-gris.jpeg",
    "camino-de-mesa-beige.jpeg",
    "camino-de-mesa-talavera.jpeg",
    "camino-de-mesa-dorado.jpeg",
    
    # Loza
    "loza-blanca-cuadrada.jpg",
    "loza-blanca-kosher.jpg",
    "loza-lcm.jpg",
    "loza-talavera-las-mañanitas.jpg",
    
    # Servilletas
    "sevilleta-blanca.jpg",
    "servilleta-beige.jpg",
    
    # Bajo Plato
    "bajo-plato-pewter.jpg",
    
    # Copas
    "copas-agua-y-vino.jpg",
    
    # Sala
    "sala-de-mimbre.jpeg",
    
    # Mesas Especiales
    "mesa-de-dulces.jpeg",
    "mesa-especial-novios-tallada.jpg",
    
    # Sillas Especiales
    "silla-luis-xv-verde-olivo.jpeg",
    "silla-luis-xv-beige.jpeg"
)

# Obtener todas las imágenes en la carpeta
$todasLasImagenes = Get-ChildItem -Path ".\images\" -File | Where-Object { $_.Extension -match '\.(jpg|jpeg|png|gif|webp)$' }

# Encontrar imágenes no utilizadas
$imagenesNoUtilizadas = $todasLasImagenes | Where-Object { $_.Name -notin $imagenesUtilizadas }

Write-Host "=== IMÁGENES A ELIMINAR ===" -ForegroundColor Yellow
Write-Host "Total de imágenes en la carpeta: $($todasLasImagenes.Count)" -ForegroundColor Cyan
Write-Host "Imágenes utilizadas: $($imagenesUtilizadas.Count)" -ForegroundColor Green
Write-Host "Imágenes NO utilizadas: $($imagenesNoUtilizadas.Count)" -ForegroundColor Red
Write-Host ""

if ($imagenesNoUtilizadas.Count -gt 0) {
    Write-Host "Las siguientes imágenes se eliminarán:" -ForegroundColor Red
    $imagenesNoUtilizadas | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Gray }
    Write-Host ""
    
    $confirmacion = Read-Host "¿Deseas proceder con la eliminación? (S/N)"
    
    if ($confirmacion -eq 'S' -or $confirmacion -eq 's' -or $confirmacion -eq 'Y' -or $confirmacion -eq 'y') {
        $eliminadas = 0
        $errores = 0
        
        foreach ($imagen in $imagenesNoUtilizadas) {
            try {
                Remove-Item $imagen.FullName -Force
                Write-Host "  ✓ Eliminada: $($imagen.Name)" -ForegroundColor Green
                $eliminadas++
            }
            catch {
                Write-Host "  ✗ Error eliminando: $($imagen.Name) - $($_.Exception.Message)" -ForegroundColor Red
                $errores++
            }
        }
        
        Write-Host ""
        Write-Host "=== RESULTADO ===" -ForegroundColor Yellow
        Write-Host "Imágenes eliminadas exitosamente: $eliminadas" -ForegroundColor Green
        if ($errores -gt 0) {
            Write-Host "Errores: $errores" -ForegroundColor Red
        }
        
        # Mostrar espacio liberado
        $espacioLiberado = ($imagenesNoUtilizadas | Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "Espacio liberado aproximado: $([math]::Round($espacioLiberado, 2)) MB" -ForegroundColor Cyan
    }
    else {
        Write-Host "Operación cancelada." -ForegroundColor Yellow
    }
}
else {
    Write-Host "¡Perfecto! No hay imágenes no utilizadas para eliminar." -ForegroundColor Green
}

Write-Host ""
Write-Host "=== IMÁGENES UTILIZADAS (conservadas) ===" -ForegroundColor Green
$imagenesUtilizadas | ForEach-Object { 
    if (Test-Path ".\images\$_") {
        Write-Host "  ✓ $_" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $_ (archivo faltante)" -ForegroundColor Red
    }
}
