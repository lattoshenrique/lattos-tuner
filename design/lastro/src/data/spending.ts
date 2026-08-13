export type Categoria = {
  nome: string
  valor: number
  /** variação percentual contra o mês anterior; 0 = estável */
  variacao: number
}

export const CATEGORIAS: Categoria[] = [
  { nome: 'Moradia', valor: 1900, variacao: 0 },
  { nome: 'Mercado', valor: 1224.5, variacao: -6 },
  { nome: 'Viagem', valor: 980, variacao: 187 },
  { nome: 'Lazer', valor: 612.3, variacao: -14 },
  { nome: 'Assinaturas', valor: 289.8, variacao: 3 },
]

export const TOTAL_GASTO = CATEGORIAS.reduce((s, c) => s + c.valor, 0)
