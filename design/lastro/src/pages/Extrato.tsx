import { Bloco, PageView } from '../components/PageView'
import { TransactionList } from '../components/TransactionList'
import { useActiveAccount } from '../state/ActiveAccount'

export function Extrato({ direcao }: { direcao: number }) {
  const { conta } = useActiveAccount()

  return (
    <PageView titulo="Extrato" legenda={conta.apelido} direcao={direcao}>
      <Bloco className="panel">
        <TransactionList conta={conta} />
      </Bloco>
    </PageView>
  )
}
