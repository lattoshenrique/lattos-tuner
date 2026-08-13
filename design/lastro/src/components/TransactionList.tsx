import type { Account } from '../data/accounts'
import { signed } from '../lib/format'
import './transaction-list.css'

/** Agrupa por dia preservando a ordem em que as transações vieram. */
function porDia(conta: Account) {
  const grupos: { dia: string; itens: Account['extrato'] }[] = []
  for (const t of conta.extrato) {
    const ultimo = grupos[grupos.length - 1]
    if (ultimo && ultimo.dia === t.dia) ultimo.itens.push(t)
    else grupos.push({ dia: t.dia, itens: [t] })
  }
  return grupos
}

export function TransactionList({ conta }: { conta: Account }) {
  return (
    <div>
      {porDia(conta).map((g) => (
        <section key={g.dia}>
          <h4 className="day-label mono">{g.dia}</h4>
          {g.itens.map((t, i) => (
            <div className="tx" key={`${t.nome}-${i}`}>
              <span className="tx-ico" aria-hidden="true">
                {t.glifo}
              </span>
              <span className="tx-main">
                <span className="tx-name">{t.nome}</span>
                <span className="tx-meta">{t.meta}</span>
              </span>
              <span className={`tx-val num ${t.valor > 0 ? 'in' : ''}`}>
                {signed(t.valor, conta.fmt)}
              </span>
            </div>
          ))}
        </section>
      ))}
    </div>
  )
}
