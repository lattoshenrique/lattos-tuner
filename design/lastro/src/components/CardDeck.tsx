import { animated, to, useSprings } from '@react-spring/web'
import { useDrag } from '@use-gesture/react'
import { useCallback, useEffect, useRef } from 'react'
import { ACCOUNTS } from '../data/accounts'
import { useActiveAccount } from '../state/ActiveAccount'
import { useMedia, useReducedMotion } from '../lib/useReducedMotion'
import { Guilloche } from './Guilloche'
import './card-deck.css'

/**
 * Baralho de cartões em 3D.
 *
 * Os cartões de trás recuam no eixo Z em vez de encolherem por `scale`: quem
 * diminui é a perspectiva, e é isso que dá volume de baralho de verdade.
 */
function posicaoDoSlot(slot: number, estreito: boolean) {
  return {
    x: slot * 7,
    y: -slot * (estreito ? 20 : 26),
    z: -slot * 58,
    rx: slot * 1.6,
    ry: 0,
    rz: slot * 1.2,
  }
}

const CONFIG = { tension: 180, friction: 24 }

export function CardDeck() {
  const { ordem, ciclar, promover } = useActiveAccount()
  const estreito = useMedia('(max-width: 620px)')
  const semMovimento = useReducedMotion()
  /** distingue um toque de um arrasto que terminou em cima do botão */
  const arrastou = useRef(false)

  const alvoDe = useCallback(
    (indiceDoCartao: number) => {
      const slot = ordem.indexOf(indiceDoCartao)
      return { ...posicaoDoSlot(slot, estreito), zIndex: ACCOUNTS.length - slot }
    },
    [ordem, estreito],
  )

  const [springs, api] = useSprings(ACCOUNTS.length, (i) => {
    const alvo = alvoDe(i)
    return {
      ...alvo,
      from: { ...alvo, y: alvo.y - 40, z: alvo.z - 220, rx: alvo.rx + 14 },
      config: CONFIG,
    }
  })

  // toda mudança de ordem reacomoda o baralho
  useEffect(() => {
    api.start((i) => ({ ...alvoDe(i), config: CONFIG, immediate: semMovimento }))
  }, [api, alvoDe, semMovimento])

  const bind = useDrag(
    ({ args, down, movement: [mx, my], velocity: [vx], last, tap }) => {
      const indiceDoCartao = args[0] as number
      if (ordem[0] !== indiceDoCartao || tap) return

      if (down) {
        if (Math.abs(mx) > 6 || Math.abs(my) > 6) arrastou.current = true
        // resistência depois de 180px: o cartão segue o dedo, mas devagar
        const LIM = 180
        const a = Math.abs(mx)
        const sx = a <= LIM ? mx : Math.sign(mx) * (LIM + (a - LIM) * 0.45)
        api.start((i) =>
          i === indiceDoCartao
            ? {
                x: sx,
                y: my * 0.3,
                z: Math.min(a, 200) * 0.5,
                ry: sx * 0.09,
                rz: sx * 0.035,
                rx: -my * 0.05,
                immediate: true,
              }
            : {},
        )
        return
      }

      if (last) {
        // a decisão olha a velocidade, não só a distância — um flick curto e rápido conta
        const arremessou = Math.abs(mx) > 90 || vx > 0.55
        if (arremessou) ciclar(1)
        else api.start((i) => (i === indiceDoCartao ? { ...alvoDe(i), config: CONFIG } : {}))
        setTimeout(() => (arrastou.current = false), 0)
      }
    },
    { filterTaps: true, pointer: { touch: true } },
  )

  return (
    <>
      <div className="deck">
        {springs.map((s, i) => {
          const conta = ACCOUNTS[i]
          const daFrente = ordem[0] === i
          return (
            <animated.button
              key={conta.id}
              type="button"
              className="card"
              {...bind(i)}
              onClick={() => {
                if (!arrastou.current) promover(i)
              }}
              tabIndex={daFrente ? 0 : -1}
              aria-hidden={!daFrente}
              aria-label={`${conta.apelido} — trazer para frente`}
              style={{
                zIndex: s.zIndex,
                color: conta.tinta,
                background: `linear-gradient(150deg, ${conta.fundo[0]}, ${conta.fundo[1]})`,
                transform: to(
                  [s.x, s.y, s.z, s.rx, s.ry, s.rz],
                  (x, y, z, rx, ry, rz) =>
                    `translate3d(${x}px, ${y}px, ${z}px) rotateX(${rx}deg) rotateY(${ry}deg) rotateZ(${rz}deg)`,
                ),
              }}
            >
              <Guilloche seed={conta.seed} cor={conta.gravura} />
              <span className="card-sheen" />
              <span className="card-content">
                <span className="card-row">
                  <span>
                    <span className="mono">Lastro</span>
                    <span className="card-nick">{conta.apelido}</span>
                  </span>
                  <span className="card-chip" />
                </span>
                <span className="card-num">{conta.numero}</span>
                <span className="card-foot">
                  <span>
                    <span className="card-bal-label">saldo</span>
                    <span className="card-bal num">{conta.fmt(conta.saldo)}</span>
                  </span>
                  <span className="card-mark" aria-hidden="true">
                    <i />
                    <i />
                  </span>
                </span>
              </span>
            </animated.button>
          )
        })}
      </div>

      <div className="deck-dots" role="tablist" aria-label="Selecionar cartão">
        {ACCOUNTS.map((c, i) => (
          <button
            key={c.id}
            type="button"
            role="tab"
            aria-label={c.apelido}
            aria-selected={ordem[0] === i}
            onClick={() => promover(i)}
          >
            <i />
          </button>
        ))}
      </div>
    </>
  )
}
