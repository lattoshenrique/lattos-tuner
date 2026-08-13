import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { HashRouter } from 'react-router-dom'
import App from './App'
import './styles/global.css'

/**
 * HashRouter, e não BrowserRouter: assim a mesma build abre por file://, num
 * preview estático ou no GitHub Pages sem precisar de rewrite no servidor. As
 * URLs continuam reais (#/fluxo), com histórico e deep link.
 */
createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <HashRouter>
      <App />
    </HashRouter>
  </StrictMode>,
)
