import { useMedia } from '../lib/useReducedMotion'

const HOJE = new Date(2026, 7, 13)

export function TopBar() {
  const estreito = useMedia('(max-width: 620px)')
  const data = HOJE.toLocaleDateString(
    'pt-BR',
    estreito
      ? { day: '2-digit', month: 'short' }
      : { weekday: 'short', day: '2-digit', month: 'long' },
  )

  return (
    <header className="top">
      <div className="brand">
        <h1 className="serif">Lastro</h1>
        <span className="mono">banco de gravura</span>
      </div>
      <div className="top-right">
        <span>{data}</span>
        <div className="avatar" aria-hidden="true">
          LH
        </div>
      </div>
    </header>
  )
}
