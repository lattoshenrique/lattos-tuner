export const brl = (v: number) =>
  v.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })

export const usd = (v: number) =>
  v.toLocaleString('pt-BR', { style: 'currency', currency: 'USD' })

/** Eixos e rótulos curtos: 12.847 vira "13 mil". */
export const compact = (v: number) =>
  v >= 1000
    ? `${(v / 1000).toLocaleString('pt-BR', { maximumFractionDigits: 1 })} mil`
    : String(Math.round(v))

export const signed = (v: number, fmt: (n: number) => string) =>
  `${v > 0 ? '+' : '−'}${fmt(Math.abs(v))}`

/**
 * PRNG determinístico: as séries de exemplo precisam ser estáveis entre
 * recargas, senão o gráfico "muda de história" a cada F5.
 */
export function rng(seed: number) {
  let s = seed >>> 0
  return () => (s = (s * 1664525 + 1013904223) >>> 0) / 4294967296
}
