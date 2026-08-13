import { useEffect, useState } from 'react'

const QUERY = '(prefers-reduced-motion: reduce)'

/** Respeita a preferência do sistema e reage se ela mudar durante a sessão. */
export function useReducedMotion() {
  const [reduzido, setReduzido] = useState(() => window.matchMedia(QUERY).matches)

  useEffect(() => {
    const mq = window.matchMedia(QUERY)
    const onChange = () => setReduzido(mq.matches)
    mq.addEventListener('change', onChange)
    return () => mq.removeEventListener('change', onChange)
  }, [])

  return reduzido
}

/** Mesma ideia para o corte entre o layout de desktop e o de celular. */
export function useMedia(query: string) {
  const [bate, setBate] = useState(() => window.matchMedia(query).matches)

  useEffect(() => {
    const mq = window.matchMedia(query)
    const onChange = () => setBate(mq.matches)
    mq.addEventListener('change', onChange)
    return () => mq.removeEventListener('change', onChange)
  }, [query])

  return bate
}
