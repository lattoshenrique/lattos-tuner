import { AnimatePresence } from 'framer-motion'
import { Suspense, lazy, useEffect, useRef } from 'react'
import { Navigate, Route, Routes, useLocation } from 'react-router-dom'
import { TopBar } from './components/TopBar'
import { PageNav } from './components/PageNav'
import { Pager } from './components/Pager'
import { Notes } from './components/Notes'
import { Carteira } from './pages/Carteira'
import { Gastos } from './pages/Gastos'
import { Extrato } from './pages/Extrato'
import { Metas } from './pages/Metas'
import { indiceDaRota } from './routes'
import { ActiveAccountProvider } from './state/ActiveAccount'

/**
 * Só o Fluxo desenha gráfico, e o Recharts responde pela maior parte do bundle.
 * Fora do pacote inicial ele não atrasa a primeira tela; o prefetch logo abaixo
 * busca o pedaço enquanto o usuário ainda está olhando a Carteira, então a
 * navegação continua instantânea e o fallback quase nunca aparece.
 */
const Fluxo = lazy(() => import('./pages/Fluxo').then((m) => ({ default: m.Fluxo })))

/**
 * Cada view é uma rota de verdade: a URL muda, voltar e avançar funcionam, e
 * um link para /gastos abre em Gastos.
 *
 * A direção da transição vem da diferença entre o índice da rota nova e o da
 * anterior — sem isso, voltar animaria igual a avançar e o gesto perderia o
 * sentido de lugar.
 */
export default function App() {
  const location = useLocation()
  const indice = indiceDaRota(location.pathname)
  const anterior = useRef(indice)

  const direcao = indice > anterior.current ? 1 : indice < anterior.current ? -1 : 0

  useEffect(() => {
    const idle = window.requestIdleCallback ?? ((cb: () => void) => window.setTimeout(cb, 300))
    idle(() => void import('./pages/Fluxo'))
  }, [])

  useEffect(() => {
    anterior.current = indice
    // trocar de view começa do topo; sem isto, entrar num Extrato longo vindo
    // do fim de Metas cairia no meio da lista
    window.scrollTo({ top: 0, behavior: 'instant' as ScrollBehavior })
  }, [indice])

  return (
    <ActiveAccountProvider>
      <div className="shell">
        <TopBar />
        <PageNav />

        <main className="stage">
          {/* mode="wait" deixa a saída terminar antes da entrada: com as duas
              páginas girando ao mesmo tempo o 3D vira sopa */}
          <AnimatePresence mode="wait" custom={direcao} initial={false}>
            <Suspense fallback={null}>
              <Routes location={location} key={location.pathname}>
              <Route path="/" element={<Navigate to="/carteira" replace />} />
              <Route path="/carteira" element={<Carteira direcao={direcao} />} />
              <Route path="/fluxo" element={<Fluxo direcao={direcao} />} />
              <Route path="/gastos" element={<Gastos direcao={direcao} />} />
              <Route path="/extrato" element={<Extrato direcao={direcao} />} />
              <Route path="/metas" element={<Metas direcao={direcao} />} />
                <Route path="*" element={<Navigate to="/carteira" replace />} />
              </Routes>
            </Suspense>
          </AnimatePresence>
        </main>

        <Pager />
        <Notes />
        <footer className="fine">
          Lastro é um produto fictício — artefato de inspiração de design. Valores ilustrativos.
        </footer>
      </div>
    </ActiveAccountProvider>
  )
}
