import { animated, useSpring } from '@react-spring/web'
import { useReducedMotion } from '../lib/useReducedMotion'

/**
 * Valor que chega por mola, não por easing: ao trocar de conta o saldo
 * "assenta" em vez de saltar. A formatação acontece a cada quadro, então o
 * separador de milhar aparece durante a contagem.
 */
export function AnimatedNumber({
  valor,
  fmt,
  className,
}: {
  valor: number
  fmt: (v: number) => string
  className?: string
}) {
  const semMovimento = useReducedMotion()
  const { n } = useSpring({
    n: valor,
    from: { n: 0 },
    immediate: semMovimento,
    config: { tension: 170, friction: 27 },
  })

  return <animated.span className={className}>{n.to((v) => fmt(v))}</animated.span>
}
