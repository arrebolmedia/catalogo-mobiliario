# Script para subir el proyecto a GitHub
# Ejecutar después de crear el repositorio en GitHub

Write-Host "=== CONFIGURACIÓN DE GITHUB ===" -ForegroundColor Cyan
Write-Host ""

# Verificar que Git esté configurado
Write-Host "Verificando configuración de Git..." -ForegroundColor Green
$gitUser = git config --global user.name
$gitEmail = git config --global user.email

if (-not $gitUser -or -not $gitEmail) {
    Write-Host "⚠️  Git no está configurado globalmente" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Configura tu usuario de Git primero:" -ForegroundColor Yellow
    Write-Host "git config --global user.name `"Tu Nombre`"" -ForegroundColor White
    Write-Host "git config --global user.email `"tu@email.com`"" -ForegroundColor White
    Write-Host ""
    Write-Host "Después ejecuta este script nuevamente." -ForegroundColor Yellow
    exit 1
} else {
    Write-Host "  ✓ Usuario: $gitUser" -ForegroundColor Green
    Write-Host "  ✓ Email: $gitEmail" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== INSTRUCCIONES PARA GITHUB ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "1️⃣  CREAR REPOSITORIO EN GITHUB:" -ForegroundColor Yellow
Write-Host "   • Ve a https://github.com" -ForegroundColor White
Write-Host "   • Haz clic en 'New repository' o '+' -> 'New repository'" -ForegroundColor White
Write-Host "   • Nombre sugerido: catalogo-mobiliario" -ForegroundColor White
Write-Host "   • Descripción: Catálogo de Mobiliario - Casanueva by Las Mañanitas" -ForegroundColor White
Write-Host "   • Selecciona 'Public' o 'Private' según prefieras" -ForegroundColor White
Write-Host "   • ❌ NO marques 'Add a README file'" -ForegroundColor Red
Write-Host "   • ❌ NO marques 'Add .gitignore'" -ForegroundColor Red
Write-Host "   • ❌ NO marques 'Choose a license'" -ForegroundColor Red
Write-Host "   • Haz clic en 'Create repository'" -ForegroundColor White
Write-Host ""

Write-Host "2️⃣  COPIA LA URL DEL REPOSITORIO:" -ForegroundColor Yellow
Write-Host "   • En la página del repositorio recién creado" -ForegroundColor White
Write-Host "   • Copia la URL que aparece (algo como:" -ForegroundColor White
Write-Host "     https://github.com/TuUsuario/catalogo-mobiliario.git)" -ForegroundColor Gray
Write-Host ""

$repoUrl = Read-Host "3️⃣  PEGA AQUÍ LA URL DEL REPOSITORIO"

if (-not $repoUrl) {
    Write-Host "❌ No se proporcionó URL. Saliendo..." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configurando repositorio remoto..." -ForegroundColor Green
try {
    git remote add origin $repoUrl
    Write-Host "  ✓ Remote 'origin' agregado: $repoUrl" -ForegroundColor Green
} catch {
    Write-Host "  ⚠️  Remote ya existe o error: $($_.Exception.Message)" -ForegroundColor Yellow
    Write-Host "  Intentando actualizar remote..." -ForegroundColor Yellow
    git remote set-url origin $repoUrl
    Write-Host "  ✓ Remote actualizado" -ForegroundColor Green
}

Write-Host ""
Write-Host "Subiendo código a GitHub..." -ForegroundColor Green
try {
    git push -u origin master
    Write-Host "  ✓ Código subido exitosamente!" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Error al subir: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Si es la primera vez, puede que necesites autenticarte." -ForegroundColor Yellow
    Write-Host "GitHub ya no acepta contraseñas, necesitas un Personal Access Token:" -ForegroundColor Yellow
    Write-Host "https://github.com/settings/tokens" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "=== ¡PROYECTO SUBIDO A GITHUB! ===" -ForegroundColor Green
Write-Host ""
Write-Host "🎉 Tu catálogo está ahora disponible en:" -ForegroundColor Cyan
Write-Host "$repoUrl" -ForegroundColor White
Write-Host ""
Write-Host "📋 Próximos pasos sugeridos:" -ForegroundColor Yellow
Write-Host "  • Visita tu repositorio en GitHub" -ForegroundColor White
Write-Host "  • Verifica que todos los archivos se subieron correctamente" -ForegroundColor White
Write-Host "  • Puedes habilitar GitHub Pages para vista previa" -ForegroundColor White
Write-Host "  • Configura releases para versiones" -ForegroundColor White
Write-Host ""
Write-Host "¡Listo para compartir con el programador! 🚀" -ForegroundColor Green
