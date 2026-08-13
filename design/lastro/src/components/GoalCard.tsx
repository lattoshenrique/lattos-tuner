import { motion } from 'framer-motion'
import type { Meta } from '../data/goals'
import { brl } from '../lib/format'
import { useReducedMotion } from '../lib/useReducedMotion'
import './goal-card.css'

export function GoalCard({ meta, ordem }: { meta: Meta; ordem: number }) {
  const semMovimento = useReducedMotion()
  const pct = (meta.guardado / meta.alvo) * 100

  return (
    <div className="panel">
      <div className="panel-head">
        <h3>{meta.nome}</h3>
        <span className="mono">{Math.round(pct)}%</span>
      </div>

      <span className="meter">
        <motion.span
          className="meter-fill"
          initial={semMovimento ? false : { width: 0 }}
          animate={{ width: `${pct}%` }}
          transition={{ type: 'spring', stiffness: 150, damping: 26, delay: 0.1 + ordem * 0.08 }}
        />
      </span>

      <div className="goal-figs num">
        <span>{brl(meta.guardado)}</span>
        <span>de {brl(meta.alvo)}</span>
      </div>
      <p className="goal-note">{meta.nota}</p>
    </div>
  )
}
