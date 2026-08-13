import { motion } from 'framer-motion'
import { CATEGORIAS } from '../data/spending'
import { brl } from '../lib/format'
import { useReducedMotion } from '../lib/useReducedMotion'
import './category-bars.css'

const maior = Math.max(...CATEGORIAS.map((c) => c.valor))

export function CategoryBars() {
  const semMovimento = useReducedMotion()

  return (
    <div className="cats">
      {CATEGORIAS.map((c, i) => {
        const pct = (c.valor / maior) * 100
        return (
          <div className="cat" key={c.nome}>
            <span className="cat-name">{c.nome}</span>
            <span className="cat-track">
              <motion.span
                className="cat-bar"
                initial={semMovimento ? false : { width: 0 }}
                animate={{ width: `${pct}%` }}
                transition={{ type: 'spring', stiffness: 150, damping: 26, delay: 0.08 + i * 0.06 }}
              />
            </span>
            <span className="cat-val num">{brl(c.valor)}</span>
            <span className={`cat-chg num ${c.variacao > 0 ? 'up' : c.variacao < 0 ? 'down' : ''}`}>
              {c.variacao === 0
                ? 'estável'
                : `${c.variacao > 0 ? '▲ +' : '▼ '}${c.variacao}%`}
            </span>
          </div>
        )
      })}
    </div>
  )
}
