const NOTAS = [
  {
    t: 'react-router-dom',
    c: (
      <>
        Cada view é uma rota (<code>/carteira</code>, <code>/fluxo</code>…), então voltar, avançar e
        deep link funcionam. A direção da transição vem da diferença entre os índices das rotas.
      </>
    ),
  },
  {
    t: 'framer-motion',
    c: (
      <>
        <code>AnimatePresence mode="wait"</code> com variantes que animam <code>rotateY</code> e{' '}
        <code>z</code>. Dentro da página, <code>staggerChildren</code> traz os blocos em
        profundidade — não é só opacidade.
      </>
    ),
  },
  {
    t: '@use-gesture/react',
    c: (
      <>
        <code>useDrag</code> no cartão da frente, com rubber-band depois de 180px. A decisão de
        ciclar olha a <code>velocity</code>, então um flick curto e rápido conta tanto quanto um
        arrasto longo.
      </>
    ),
  },
  {
    t: '@react-spring/web',
    c: (
      <>
        Seis molas por cartão (x, y, z e três rotações) e uma para o saldo. O número assenta em vez
        de saltar, e a formatação em BRL acontece a cada quadro.
      </>
    ),
  },
  {
    t: 'recharts',
    c: (
      <>
        Área com crosshair e tooltip próprio. As cores saem de <code>var(--chart-1)</code>, então o
        gráfico vira junto com o tema em vez de carregar hex fixo.
      </>
    ),
  },
  {
    t: 'CSS 3D, não WebGL',
    c: (
      <>
        As views giram num espaço com <code>perspective: 1500px</code>. Com{' '}
        <code>react-three-fiber</code> o texto viraria textura e perderia nitidez e leitura de tela
        — para interface, o 3D do compositor é a escolha certa.
      </>
    ),
  },
]

export function Notes() {
  return (
    <section className="notes" aria-label="Notas de design">
      <h2>Receita técnica</h2>
      <p>
        Cinco views, cada uma no seu arquivo, sobre um roteador de verdade. No celular a barra de
        abas desce para o rodapé e cada rota rola por conta própria.
      </p>
      <div className="notes-grid">
        {NOTAS.map((n) => (
          <div className="note" key={n.t}>
            <b>{n.t}</b>
            {n.c}
          </div>
        ))}
      </div>
    </section>
  )
}
