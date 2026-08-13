/**
 * Fonte única das views. A navegação, o indicador, o rodapé e a direção da
 * transição 3D derivam desta ordem — nada de listas paralelas para dessincronizar.
 */
export type Rota = {
  path: string
  nome: string
  /** glifo da barra inferior no mobile */
  glifo: string
}

export const ROTAS: Rota[] = [
  { path: '/carteira', nome: 'Carteira', glifo: '▤' },
  { path: '/fluxo', nome: 'Fluxo', glifo: '∿' },
  { path: '/gastos', nome: 'Gastos', glifo: '◪' },
  { path: '/extrato', nome: 'Extrato', glifo: '≡' },
  { path: '/metas', nome: 'Metas', glifo: '◎' },
]

export const indiceDaRota = (pathname: string) => {
  const i = ROTAS.findIndex((r) => pathname.startsWith(r.path))
  return i === -1 ? 0 : i
}
