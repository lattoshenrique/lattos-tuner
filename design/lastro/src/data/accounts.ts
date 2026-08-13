import { brl, rng, usd } from '../lib/format'

export type Tx = {
  dia: string
  glifo: string
  nome: string
  meta: string
  valor: number
}

export type Account = {
  id: string
  apelido: string
  rotulo: string
  sub: string
  numero: string
  saldo: number
  fmt: (v: number) => string
  seed: number
  /** duas paradas do gradiente do cartão */
  fundo: [string, string]
  tinta: string
  /** cor das linhas do guilloché, já com alfa */
  gravura: string
  delta: { dir: 'up' | 'down'; texto: string }
  extrato: Tx[]
  /** 30 pontos terminando no saldo atual — preenchido abaixo */
  serie: number[]
}

const base: Omit<Account, 'serie'>[] = [
  {
    id: 'conta',
    apelido: 'Conta Lastro',
    rotulo: 'Conta Lastro · saldo disponível',
    sub: 'Atualizado agora · agência 0001 · conta 84.213-7',
    numero: '•••• 4417',
    saldo: 12847.32,
    fmt: brl,
    seed: 11,
    fundo: ['#123B2A', '#0B2A1D'],
    tinta: '#E9F3EA',
    gravura: 'rgba(158,220,186,0.17)',
    delta: { dir: 'up', texto: '▲ +2,4% vs. julho' },
    extrato: [
      { dia: 'Hoje', glifo: '⇄', nome: 'PIX recebido — Ana M.', meta: '09:12 · transferência', valor: 850 },
      { dia: 'Hoje', glifo: '▦', nome: 'Padaria Bela Vista', meta: '07:40 · alimentação', valor: -28.5 },
      { dia: 'Ontem', glifo: '▦', nome: 'Mercado Boa Terra', meta: '19:05 · alimentação', valor: -214.6 },
      { dia: 'Ontem', glifo: '◈', nome: 'Posto Ipiranga', meta: '12:20 · transporte', valor: -180 },
      { dia: '05 de agosto', glifo: '⌂', nome: 'Aluguel — agosto', meta: 'débito automático', valor: -1900 },
      { dia: '05 de agosto', glifo: '↧', nome: 'Aporte — Reserva', meta: 'programado', valor: -1500 },
      { dia: '01 de agosto', glifo: '✳', nome: 'Salário — Latt Studio', meta: 'crédito em conta', valor: 7400 },
    ],
  },
  {
    id: 'credito',
    apelido: 'Grafite crédito',
    rotulo: 'Grafite crédito · fatura aberta',
    sub: 'Fecha em 22 ago · limite disponível R$ 8.590,00',
    numero: '•••• 9024',
    saldo: 3412.9,
    fmt: brl,
    seed: 23,
    fundo: ['#23262B', '#141619'],
    tinta: '#EDEDE8',
    gravura: 'rgba(217,164,65,0.16)',
    delta: { dir: 'down', texto: '▼ 61% do limite usado' },
    extrato: [
      { dia: 'Hoje', glifo: '♫', nome: 'Spotify Família', meta: 'assinatura', valor: -34.9 },
      { dia: 'Ontem', glifo: '▤', nome: 'Livraria da Praia', meta: 'compras', valor: -96.7 },
      { dia: '10 de agosto', glifo: '➤', nome: 'LATAM — GRU para SSA', meta: '2× sem juros · viagem', valor: -1240 },
      { dia: '09 de agosto', glifo: '▤', nome: 'Restaurante Ondina', meta: 'lazer', valor: -186.4 },
      { dia: '07 de agosto', glifo: '↺', nome: 'Estorno — Loja Kite', meta: 'crédito na fatura', valor: 320 },
      { dia: '03 de agosto', glifo: '▦', nome: 'Farmácia Sant’Ana', meta: 'saúde', valor: -72.3 },
    ],
  },
  {
    id: 'reserva',
    apelido: 'Reserva',
    rotulo: 'Reserva · rende 103% do CDI',
    sub: 'Resgate em D+0 · aporte automático todo dia 5',
    numero: '•••• 1108',
    saldo: 28450,
    fmt: brl,
    seed: 37,
    fundo: ['#EFE9D8', '#DDD4BC'],
    tinta: '#2A3327',
    gravura: 'rgba(30,90,60,0.19)',
    delta: { dir: 'up', texto: '▲ +R$ 214,08 no mês' },
    extrato: [
      { dia: '05 de agosto', glifo: '↧', nome: 'Aporte automático', meta: 'vindo da Conta Lastro', valor: 1500 },
      { dia: '01 de agosto', glifo: '％', nome: 'Rendimento — julho', meta: '103% do CDI', valor: 214.08 },
      { dia: '05 de julho', glifo: '↧', nome: 'Aporte automático', meta: 'vindo da Conta Lastro', valor: 1500 },
      { dia: '01 de julho', glifo: '％', nome: 'Rendimento — junho', meta: '103% do CDI', valor: 198.4 },
      { dia: '28 de junho', glifo: '↥', nome: 'Resgate — conserto do carro', meta: 'para a Conta Lastro', valor: -600 },
    ],
  },
  {
    id: 'usd',
    apelido: 'Câmbio USD',
    rotulo: 'Câmbio USD · conta global',
    sub: 'Cotação agora R$ 5,43 · IOF incluso no envio',
    numero: '•••• 7751',
    saldo: 1980.45,
    fmt: usd,
    seed: 53,
    fundo: ['#1B2340', '#101528'],
    tinta: '#E8ECF6',
    gravura: 'rgba(190,205,235,0.16)',
    delta: { dir: 'up', texto: '▲ dólar caiu 1,1% na semana' },
    extrato: [
      { dia: '11 de agosto', glifo: '⇄', nome: 'Conversão BRL para USD', meta: 'a R$ 5,41', valor: 400 },
      { dia: '08 de agosto', glifo: '▦', nome: 'Adobe Creative Cloud', meta: 'assinatura', valor: -54.99 },
      { dia: '02 de agosto', glifo: '▤', nome: 'Airbnb — Lisboa', meta: 'viagem', valor: -380 },
      { dia: '01 de agosto', glifo: '⇄', nome: 'Conversão BRL para USD', meta: 'a R$ 5,38', valor: 800 },
    ],
  },
]

/** Caminhada que converge para o saldo atual, com ruído estável por conta. */
function serieDe(saldo: number, seed: number): number[] {
  const r = rng(seed)
  const pts: number[] = []
  let v = saldo * (0.72 + r() * 0.2)
  for (let i = 0; i < 30; i++) {
    v += (saldo - v) * 0.09 + (r() - 0.46) * saldo * 0.055
    pts.push(Math.max(v, saldo * 0.1))
  }
  pts[29] = saldo
  return pts
}

export const ACCOUNTS: Account[] = base.map((a) => ({ ...a, serie: serieDe(a.saldo, a.seed) }))

/** Rótulos do eixo x: 30 dias terminando hoje. */
export const DIAS = Array.from({ length: 30 }, (_, i) =>
  new Date(2026, 6, 15 + i).toLocaleDateString('pt-BR', { day: '2-digit', month: 'short' }),
)
