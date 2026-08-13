import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { viteSingleFile } from 'vite-plugin-singlefile'

/**
 * SINGLE=1 gera um único .html com tudo embutido — é o formato que o preview
 * publicado exige (nenhum host externo pode ser buscado em runtime).
 * Sem a variável, o build é o normal, com os assets separados.
 */
export default defineConfig({
  base: './',
  plugins: [react(), ...(process.env.SINGLE ? [viteSingleFile()] : [])],
  build: { outDir: process.env.SINGLE ? 'dist-single' : 'dist' },
})
