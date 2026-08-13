# Lastro

Peça de **inspiração de design**: a home de um banco digital fictício, com um baralho
de cartões 3D e cinco views sobre um roteador de verdade. Não faz parte do app do
afinador — mora aqui só para ficar versionada junto.

```bash
npm install
npm run dev        # http://localhost:5173
npm run build      # dist/
npm run typecheck
SINGLE=1 npm run build   # dist-single/index.html — tudo embutido num arquivo
```

## Views

Cada tela é uma rota, num arquivo próprio em `src/pages/`. A URL muda, voltar e
avançar funcionam, e um link para `#/gastos` abre direto em Gastos.

| Rota | Arquivo | Conteúdo |
|---|---|---|
| `/carteira` | `pages/Carteira.tsx` | baralho 3D, saldo da conta ativa, ações |
| `/fluxo` | `pages/Fluxo.tsx` | entradas/saídas e o gráfico de 30 dias |
| `/gastos` | `pages/Gastos.tsx` | categorias e variação contra o mês anterior |
| `/extrato` | `pages/Extrato.tsx` | movimentações agrupadas por dia |
| `/metas` | `pages/Metas.tsx` | três metas com medidor e projeção |

`src/routes.ts` é a fonte única dessa lista — a navegação, o indicador, o rodapé e a
direção da transição derivam dela.

## Decisões que valem explicação

**A conta ativa mora acima do `<Routes>`.** Ela é escolhida na Carteira e lida por
Fluxo e Extrato, ou seja, atravessa rotas: um estado dentro de uma página se perderia
na navegação. Fica em `state/ActiveAccount.tsx`.

**A direção da transição vem da diferença entre os índices das rotas.** Sem isso,
voltar animaria igual a avançar e o movimento perderia o sentido de lugar.

**CSS 3D, não WebGL.** As views giram num espaço com `perspective`. Com
`react-three-fiber` o texto viraria textura e perderia nitidez e leitura de tela.

**HashRouter, não BrowserRouter.** A mesma build abre por `file://`, num preview
estático ou no GitHub Pages sem precisar de rewrite no servidor.

**O gráfico está fora do bundle inicial.** Só o Fluxo usa Recharts, que respondia por
metade do pacote; com `lazy` + prefetch no idle o inicial caiu de 748 kB para 363 kB
e a navegação continua instantânea.

**No celular a barra de abas desce para o rodapé** e cada rota rola por conta própria
— o padrão de app nativo, ao alcance do polegar.

## Cores

Tudo sai de tokens em `styles/tokens.css`, dark-first. As cores de série do gráfico
foram validadas para daltonismo contra as duas superfícies, e são lidas como
`var(--chart-1)` dentro do Recharts para o gráfico virar junto com o tema.

Valores e transações são ilustrativos.
