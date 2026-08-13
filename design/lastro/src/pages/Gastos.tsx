import { Bloco, PageView } from '../components/PageView'
import { CategoryBars } from '../components/CategoryBars'
import { TOTAL_GASTO } from '../data/spending'
import { brl } from '../lib/format'

export function Gastos({ direcao }: { direcao: number }) {
  return (
    <PageView titulo="Gastos" legenda="agosto · todas as contas" direcao={direcao}>
      <Bloco className="panel">
        <div className="panel-head">
          <h3>Para onde foi</h3>
          <span className="mono">{brl(TOTAL_GASTO)} no mês</span>
        </div>
        <CategoryBars />
      </Bloco>

      <Bloco className="panel" style={{ marginTop: 14 }}>
        <div className="panel-head">
          <h3>O que mudou</h3>
          <span className="mono">vs. julho</span>
        </div>
        <p className="goal-note">
          Viagem subiu R$ 640 por causa das passagens de setembro — é um gasto de uma vez só, não
          uma mudança de padrão. Tirando ela, agosto fechou 4% abaixo de julho.
        </p>
      </Bloco>
    </PageView>
  )
}
