import { Link, useLocation } from 'react-router-dom'
import { ROTAS, indiceDaRota } from '../routes'

/** Anterior/próxima no desktop. No mobile a barra inferior já cobre isso. */
export function Pager() {
  const { pathname } = useLocation()
  const i = indiceDaRota(pathname)
  const anterior = ROTAS[i - 1]
  const proxima = ROTAS[i + 1]

  return (
    <div className="pager">
      {anterior ? (
        <Link to={anterior.path}>
          <span aria-hidden="true">←</span> {anterior.nome}
        </Link>
      ) : (
        <span className="disabled">
          <span aria-hidden="true">←</span> Anterior
        </span>
      )}

      <span>
        {i + 1} de {ROTAS.length} · {ROTAS[i].nome}
      </span>

      {proxima ? (
        <Link to={proxima.path}>
          {proxima.nome} <span aria-hidden="true">→</span>
        </Link>
      ) : (
        <span className="disabled">
          Próxima <span aria-hidden="true">→</span>
        </span>
      )}
    </div>
  )
}
