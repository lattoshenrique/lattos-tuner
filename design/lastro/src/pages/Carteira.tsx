import { Bloco, PageView } from '../components/PageView'
import { CardDeck } from '../components/CardDeck'
import { AnimatedNumber } from '../components/AnimatedNumber'
import { useActiveAccount } from '../state/ActiveAccount'
import './carteira.css'

const ACOES = [
  { glifo: '⇄', nome: 'Transferir' },
  { glifo: '▤', nome: 'Pagar' },
  { glifo: '↧', nome: 'Cobrar' },
  { glifo: '✳', nome: 'Investir' },
]

export function Carteira({ direcao }: { direcao: number }) {
  const { conta } = useActiveAccount()

  return (
    <PageView titulo="Carteira" legenda="quatro contas · arraste o cartão" direcao={direcao}>
      <div className="carteira-grid">
        <Bloco>
          <CardDeck />
        </Bloco>

        <div className="carteira-side">
          <Bloco className="panel">
            <span className="mono hero-label">{conta.rotulo}</span>
            <div className="hero-row">
              <AnimatedNumber className="hero-fig" valor={conta.saldo} fmt={conta.fmt} />
              <span className={`delta ${conta.delta.dir}`}>{conta.delta.texto}</span>
            </div>
            <div className="hero-sub">{conta.sub}</div>
          </Bloco>

          <Bloco className="actions">
            {ACOES.map((a) => (
              <button type="button" key={a.nome}>
                <span aria-hidden="true">{a.glifo}</span>
                {a.nome}
              </button>
            ))}
          </Bloco>
        </div>
      </div>
    </PageView>
  )
}
