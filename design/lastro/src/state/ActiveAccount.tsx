import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'
import { ACCOUNTS, type Account } from '../data/accounts'

type Ctx = {
  /** ordem do baralho: ordem[0] é o cartão da frente */
  ordem: number[]
  conta: Account
  /** cicla o baralho — o de cima vai para o fundo (dir 1) ou vice-versa */
  ciclar: (dir: 1 | -1) => void
  /** traz um cartão específico para a frente */
  promover: (indice: number) => void
}

const AccountContext = createContext<Ctx | null>(null)

/**
 * A conta ativa é escolhida na Carteira e lida por Fluxo e Extrato — ou seja,
 * atravessa rotas. Por isso mora acima do <Routes>, e não dentro de uma página.
 */
export function ActiveAccountProvider({ children }: { children: ReactNode }) {
  const [ordem, setOrdem] = useState<number[]>(() => ACCOUNTS.map((_, i) => i))

  const ciclar = useCallback((dir: 1 | -1) => {
    setOrdem((o) => (dir > 0 ? [...o.slice(1), o[0]] : [o[o.length - 1], ...o.slice(0, -1)]))
  }, [])

  const promover = useCallback((indice: number) => {
    setOrdem((o) => (o[0] === indice ? o : [indice, ...o.filter((i) => i !== indice)]))
  }, [])

  const valor = useMemo<Ctx>(
    () => ({ ordem, conta: ACCOUNTS[ordem[0]], ciclar, promover }),
    [ordem, ciclar, promover],
  )

  return <AccountContext.Provider value={valor}>{children}</AccountContext.Provider>
}

export function useActiveAccount() {
  const ctx = useContext(AccountContext)
  if (!ctx) throw new Error('useActiveAccount precisa estar dentro de <ActiveAccountProvider>')
  return ctx
}
