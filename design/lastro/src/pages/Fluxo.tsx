import { Bloco, PageView } from '../components/PageView'
import { BalanceChart } from '../components/BalanceChart'
import { StatTile } from '../components/StatTile'
import { useActiveAccount } from '../state/ActiveAccount'

export function Fluxo({ direcao }: { direcao: number }) {
  const { conta } = useActiveAccount()

  return (
    <PageView titulo="Fluxo" legenda={`${conta.apelido} · últimos 30 dias`} direcao={direcao}>
      <Bloco className="tiles">
        <StatTile rotulo="Entradas · agosto" valor={9120.5} delta="▲ +12% vs. julho" direcao="up" />
        <StatTile rotulo="Saídas · agosto" valor={6284.2} delta="▼ +5% vs. julho" direcao="down" />
        <StatTile
          rotulo="Guardado no mês"
          valor={1500}
          delta="▲ meta de R$ 1.200 batida"
          direcao="up"
        />
      </Bloco>

      <Bloco className="panel" style={{ marginTop: 14 }}>
        <div className="panel-head">
          <h3>Saldo — {conta.apelido}</h3>
          <span className="mono">30 dias</span>
        </div>
        <BalanceChart conta={conta} />
      </Bloco>
    </PageView>
  )
}
