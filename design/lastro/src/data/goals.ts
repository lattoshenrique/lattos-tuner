export type Meta = {
  nome: string
  guardado: number
  alvo: number
  nota: string
}

export const METAS: Meta[] = [
  {
    nome: 'Reserva de seis meses',
    guardado: 28450,
    alvo: 42000,
    nota: 'No ritmo dos últimos três meses, a meta fecha em fevereiro de 2027.',
  },
  {
    nome: 'Viagem — Lisboa em março',
    guardado: 4200,
    alvo: 11000,
    nota: 'Passagens já pagas no crédito; falta a hospedagem e o câmbio.',
  },
  {
    nome: 'Troca do carro',
    guardado: 9800,
    alvo: 45000,
    nota: 'Aporte pausado em julho para cobrir o conserto. Retomado em setembro.',
  },
]
