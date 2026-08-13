import { motion } from 'framer-motion'
import type { ReactNode } from 'react'
import { useReducedMotion } from '../lib/useReducedMotion'

/**
 * Envelope de uma view de rota.
 *
 * A troca de página gira no eixo Y e recua no Z: a que sai vai para longe, a que
 * entra chega do lado oposto. `direcao` é o sinal da diferença de índice entre as
 * rotas, então voltar não repete a mesma animação de avançar.
 *
 * Os filhos marcados com `variants={blocoVariants}` entram escalonados — a
 * profundidade também aparece na chegada do conteúdo, não só na troca de tela.
 */
export const blocoVariants = {
  entra: { opacity: 1, y: 0, z: 0, rotateX: 0 },
  inicial: { opacity: 0, y: 16, z: -70, rotateX: 7 },
}

type Props = {
  titulo: string
  legenda?: string
  direcao: number
  children: ReactNode
}

export function PageView({ titulo, legenda, direcao, children }: Props) {
  const semMovimento = useReducedMotion()

  const variants = semMovimento
    ? { inicial: { opacity: 0 }, entra: { opacity: 1 }, sai: { opacity: 0 } }
    : {
        inicial: (d: number) => ({ opacity: 0, x: `${d * 42}%`, z: -260, rotateY: d * -20 }),
        entra: { opacity: 1, x: '0%', z: 0, rotateY: 0 },
        sai: (d: number) => ({ opacity: 0, x: `${d * -42}%`, z: -260, rotateY: d * 20 }),
      }

  return (
    <motion.section
      className="page"
      custom={direcao}
      variants={variants}
      initial="inicial"
      animate="entra"
      exit="sai"
      /* troca de tela precisa ser rápida: com mola mais mole a página fica
         quase 1,5s no ar e a navegação parece travada */
      transition={{ type: 'spring', stiffness: 260, damping: 32, mass: 0.75 }}
    >
      <div className="page-head">
        <h2>{titulo}</h2>
        {legenda && <span className="mono">{legenda}</span>}
      </div>

      <motion.div
        initial="inicial"
        animate="entra"
        variants={semMovimento ? undefined : { entra: { transition: { staggerChildren: 0.055 } } }}
      >
        {children}
      </motion.div>
    </motion.section>
  )
}

/** Bloco filho que participa do stagger da página. */
export function Bloco({
  children,
  className,
  style,
}: {
  children: ReactNode
  className?: string
  style?: React.CSSProperties
}) {
  const semMovimento = useReducedMotion()
  return (
    <motion.div
      className={className}
      style={style}
      variants={semMovimento ? undefined : blocoVariants}
      transition={{ type: 'spring', stiffness: 180, damping: 24 }}
    >
      {children}
    </motion.div>
  )
}
