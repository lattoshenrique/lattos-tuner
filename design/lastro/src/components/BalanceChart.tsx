import { Area, AreaChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import { DIAS, type Account } from '../data/accounts'
import { compact } from '../lib/format'
import './balance-chart.css'

/**
 * Uma série só, então sem legenda: o título do painel já diz o que está plotado.
 * As cores saem dos tokens via `var(--chart-1)`, para o gráfico virar junto com
 * o tema em vez de carregar hex fixo.
 */
/**
 * Ticks em números redondos. Deixar o Recharts escolher produz rótulos como
 * "12,8 mil", que ninguém lê como referência — o eixo existe para dar âncora,
 * e âncora quebrada não ancora nada.
 */
function ticksRedondos(min: number, max: number, alvo = 4) {
  const passoBruto = (max - min) / alvo
  const mag = Math.pow(10, Math.floor(Math.log10(passoBruto)))
  const passo = [1, 2, 2.5, 5, 10].map((m) => m * mag).find((p) => p >= passoBruto) ?? mag * 10
  const ticks: number[] = []
  for (let v = Math.ceil(min / passo) * passo; v <= max; v += passo) ticks.push(v)
  return ticks
}

export function BalanceChart({ conta }: { conta: Account }) {
  const dados = conta.serie.map((valor, i) => ({ dia: DIAS[i], valor }))
  const min = Math.min(...conta.serie)
  const max = Math.max(...conta.serie)
  const piso = min * 0.94
  const teto = max * 1.04
  const ticks = ticksRedondos(piso, teto)

  return (
    <div className="chart-wrap">
      <ResponsiveContainer width="100%" height={230}>
        <AreaChart data={dados} margin={{ top: 10, right: 12, bottom: 4, left: 0 }}>
          <CartesianGrid stroke="var(--grid)" vertical={false} />
          <XAxis
            dataKey="dia"
            tickLine={false}
            tickMargin={8}
            axisLine={{ stroke: 'var(--hairline-2)' }}
            tick={{ fill: 'var(--ink-3)', fontSize: 10.5 }}
            interval="preserveStartEnd"
            ticks={[DIAS[0], DIAS[DIAS.length - 1]]}
          />
          <YAxis
            width={62}
            tickLine={false}
            axisLine={false}
            tickMargin={6}
            tick={{ fill: 'var(--ink-3)', fontSize: 10.5 }}
            tickFormatter={compact}
            domain={[piso, teto]}
            ticks={ticks}
          />
          <Tooltip
            cursor={{ stroke: 'var(--hairline-2)', strokeWidth: 1 }}
            content={({ active, payload, label }) =>
              active && payload?.length ? (
                <div className="chart-tt">
                  <span className="chart-tt-date">{label}</span>
                  <b className="num">{conta.fmt(payload[0].value as number)}</b>
                </div>
              ) : null
            }
          />
          <Area
            type="monotone"
            dataKey="valor"
            stroke="var(--chart-1)"
            strokeWidth={2}
            fill="var(--chart-1-dim)"
            activeDot={{ r: 5, fill: 'var(--chart-1)', stroke: 'var(--surface)', strokeWidth: 2 }}
            animationDuration={520}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  )
}
