import { AnimatedNumber } from './AnimatedNumber'
import { brl } from '../lib/format'

export function StatTile({
  rotulo,
  valor,
  delta,
  direcao,
}: {
  rotulo: string
  valor: number
  delta: string
  direcao: 'up' | 'down'
}) {
  return (
    <div className="tile">
      <span className="mono">{rotulo}</span>
      <AnimatedNumber className="tile-val num" valor={valor} fmt={brl} />
      <div className={`tile-delta ${direcao}`}>{delta}</div>
    </div>
  )
}
