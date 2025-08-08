/**
 * Sistema de Compresión de Imágenes Web
 * Comprime automáticamente las imágenes antes de mostrarlas
 */

class ImageCompressor {
    constructor(options = {}) {
        this.quality = options.quality || 0.8;
        this.maxWidth = options.maxWidth || 800;
        this.maxHeight = options.maxHeight || 600;
        this.format = options.format || 'image/jpeg';
    }

    /**
     * Comprime una imagen desde una URL
     */
    async compressFromUrl(imageUrl) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            img.crossOrigin = 'anonymous';
            
            img.onload = () => {
                try {
                    const compressedDataUrl = this.compressImage(img);
                    resolve(compressedDataUrl);
                } catch (error) {
                    reject(error);
                }
            };
            
            img.onerror = () => reject(new Error('Error loading image'));
            img.src = imageUrl;
        });
    }

    /**
     * Comprime un elemento de imagen
     */
    compressImage(img) {
        const canvas = document.createElement('canvas');
        const ctx = canvas.getContext('2d');

        // Calcular dimensiones manteniendo proporción
        const { width, height } = this.calculateDimensions(img.naturalWidth, img.naturalHeight);
        
        canvas.width = width;
        canvas.height = height;

        // Dibujar imagen redimensionada
        ctx.drawImage(img, 0, 0, width, height);

        // Retornar imagen comprimida como Data URL
        return canvas.toDataURL(this.format, this.quality);
    }

    /**
     * Calcula dimensiones optimizadas manteniendo proporción
     */
    calculateDimensions(originalWidth, originalHeight) {
        let width = originalWidth;
        let height = originalHeight;

        // Redimensionar si excede límites
        if (width > this.maxWidth) {
            height = (height * this.maxWidth) / width;
            width = this.maxWidth;
        }

        if (height > this.maxHeight) {
            width = (width * this.maxHeight) / height;
            height = this.maxHeight;
        }

        return { width: Math.round(width), height: Math.round(height) };
    }

    /**
     * Optimiza múltiples imágenes en paralelo
     */
    async compressMultiple(imageUrls, onProgress = null) {
        const results = [];
        const total = imageUrls.length;
        let completed = 0;

        for (const url of imageUrls) {
            try {
                const compressed = await this.compressFromUrl(url);
                results.push({ url, compressed, success: true });
            } catch (error) {
                results.push({ url, error: error.message, success: false });
            }
            
            completed++;
            if (onProgress) {
                onProgress(completed, total);
            }
        }

        return results;
    }
}

// Función para aplicar compresión al catálogo existente
function enableImageCompression() {
    const compressor = new ImageCompressor({
        quality: 0.85,
        maxWidth: 800,
        maxHeight: 600
    });

    // Interceptar la carga de imágenes en renderFurnitureCards
    const originalRenderFunction = window.renderFurnitureCards;
    
    window.renderFurnitureCards = function(furniture) {
        // Llamar función original pero interceptar imágenes
        const originalCreateElement = document.createElement;
        
        document.createElement = function(tagName) {
            const element = originalCreateElement.call(document, tagName);
            
            if (tagName.toLowerCase() === 'img') {
                const originalSetSrc = Object.getOwnPropertyDescriptor(HTMLImageElement.prototype, 'src').set;
                
                Object.defineProperty(element, 'src', {
                    set: async function(value) {
                        // Mostrar placeholder mientras comprime
                        this.style.filter = 'blur(5px)';
                        
                        try {
                            // Comprimir imagen
                            const compressedUrl = await compressor.compressFromUrl(value);
                            originalSetSrc.call(this, compressedUrl);
                            
                            // Remover blur cuando termine
                            this.onload = () => {
                                this.style.filter = 'none';
                                this.style.transition = 'filter 0.3s ease';
                            };
                        } catch (error) {
                            console.warn('Error comprimiendo imagen:', value, error);
                            originalSetSrc.call(this, value);
                            this.style.filter = 'none';
                        }
                    },
                    get: function() {
                        return Object.getOwnPropertyDescriptor(HTMLImageElement.prototype, 'src').get.call(this);
                    }
                });
            }
            
            return element;
        };
        
        // Ejecutar función original
        originalRenderFunction.call(this, furniture);
        
        // Restaurar createElement
        document.createElement = originalCreateElement;
    };
}

// Auto-inicializar si se incluye el script
if (typeof window !== 'undefined') {
    document.addEventListener('DOMContentLoaded', () => {
        console.log('🖼️ Sistema de compresión de imágenes iniciado');
        enableImageCompression();
    });
}

export { ImageCompressor, enableImageCompression };
