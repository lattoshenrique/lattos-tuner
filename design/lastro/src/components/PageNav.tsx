import { motion } from 'framer-motion'
import { useLayoutEffect, useRef, useState } from 'react'
import { NavLink, useLocation } from 'react-router-dom'
import { ROTAS, indiceDaRota } from '../routes'
import { useMedia } from '../lib/useReducedMotion'

/**
 * Desktop: abas no topo com um indicador que desliza entre elas.
 * Mobile: barra fixa no rodapé, ao alcance do polegar (ver global.css).
 *
 * O indicador é medido do DOM em vez de calculado, porque a largura de cada aba
 * depende da fonte que o sistema acabou carregando.
 */
export function PageNav() {
  const { pathname } = useLocation()
  const ativo = indiceDaRota(pathname)
  const mobile = useMedia('(max-width: 900px)')
  const refs = useRef<(HTMLAnchorElement | null)[]>([])
  const [ind, setInd] = useState({ left: 0, width: 0 })

  useLayoutEffect(() => {
    const medir = () => {
      const el = refs.current[ativo]
      if (el) setInd({ left: el.offsetLeft, width: el.offsetWidth })
    }
    medir()
    window.addEventListener('resize', medir)
    return () => window.removeEventListener('resize', medir)
  }, [ativo])

  return (
    <nav className="nav" aria-label="Seções">
      <div className="nav-scroll">
        {ROTAS.map((r, i) => (
          <NavLink key={r.path} to={r.path} ref={(el) => (refs.current[i] = el)}>
            <span className="nav-glyph" aria-hidden="true">
              {r.glifo}
            </span>
            {r.nome}
          </NavLink>
        ))}
      </div>
      {!mobile && (
        <motion.span
          className="nav-ind"
          animate={{ left: ind.left, width: ind.width }}
          transition={{ type: 'spring', stiffness: 320, damping: 34 }}
        />
      )}
    </nav>
  )
}
