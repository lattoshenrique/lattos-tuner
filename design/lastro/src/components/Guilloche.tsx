import { useEffect, useRef } from 'react'
import { rng } from '../lib/format'

/**
 * Gravura de cédula desenhada em canvas: uma rosácea hipotrocoidal por conta.
 *
 * O detalhe que faz a figura fechar é `rr = R / n` — com a razão inteira a curva
 * completa em 2π. Com razão qualquer ela nunca fecha e vai preenchendo o miolo
 * até virar uma mancha escura. As camadas concêntricas fazem o moiré.
 *
 * Em canvas (e não SVG ou imagem) porque o padrão é paramétrico por conta e
 * precisa sair nítido em qualquer densidade de tela.
 */
export function Guilloche({ seed, cor }: { seed: number; cor: string }) {
  const ref = useRef<HTMLCanvasElement>(null)

  useEffect(() => {
    const cv = ref.current
    if (!cv) return

    const desenhar = () => {
      const rect = cv.getBoundingClientRect()
      if (!rect.width) return
      const dpr = Math.min(window.devicePixelRatio || 1, 2)
      cv.width = rect.width * dpr
      cv.height = rect.height * dpr
      const ctx = cv.getContext('2d')
      if (!ctx) return

      ctx.scale(dpr, dpr)
      ctx.strokeStyle = cor
      ctx.lineWidth = 0.6

      const r = rng(seed * 7)
      const cx = rect.width * 0.74
      const cy = rect.height * 0.46
      const n = 9 + Math.floor(r() * 6)
      const base = rect.width * 0.44
      const dRatio = 0.48 + r() * 0.16

      for (let l = 0; l < 13; l++) {
        const R = base - l * (base * 0.042)
        const rr = R / n
        const braco = R - rr
        const d = rr * dRatio
        const fase = l * 0.14
        ctx.beginPath()
        for (let t = 0; t <= Math.PI * 2 + 0.04; t += 0.03) {
          const x = cx + braco * Math.cos(t + fase) + d * Math.cos((n - 1) * (t + fase))
          const y = cy + braco * Math.sin(t + fase) - d * Math.sin((n - 1) * (t + fase))
          if (t === 0) ctx.moveTo(x, y)
          else ctx.lineTo(x, y)
        }
        ctx.closePath()
        ctx.stroke()
      }
    }

    const raf = requestAnimationFrame(desenhar)
    const ro = new ResizeObserver(desenhar)
    ro.observe(cv)
    return () => {
      cancelAnimationFrame(raf)
      ro.disconnect()
    }
  }, [seed, cor])

  return <canvas ref={ref} className="card-canvas" aria-hidden="true" />
}
