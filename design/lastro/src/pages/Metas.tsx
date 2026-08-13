import { Bloco, PageView } from '../components/PageView'
import { GoalCard } from '../components/GoalCard'
import { METAS } from '../data/goals'

export function Metas({ direcao }: { direcao: number }) {
  return (
    <PageView titulo="Metas" legenda="três em andamento" direcao={direcao}>
      {METAS.map((m, i) => (
        <Bloco key={m.nome} style={i > 0 ? { marginTop: 14 } : undefined}>
          <GoalCard meta={m} ordem={i} />
        </Bloco>
      ))}
    </PageView>
  )
}
