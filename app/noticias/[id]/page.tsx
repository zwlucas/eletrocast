import { supabase } from "@/lib/supabase"
import type { Metadata } from "next"
import NoticiaClientPage from "./NoticiaClientPage"

interface NoticiaPageProps {
  params: {
    id: string
  }
}

export default async function NoticiaPage({ params }: NoticiaPageProps) {
  return <NoticiaClientPage params={params} />
}

export async function generateMetadata({ params }: NoticiaPageProps): Promise<Metadata> {
  const { data: noticia } = await supabase.from("noticias").select("*").eq("id", params.id).single()

  if (!noticia) {
    return {
      title: "Notícia não encontrada - Eletrocast",
    }
  }

  return {
    title: `${noticia.titulo} - Eletrocast`,
    description: noticia.conteudo.substring(0, 160),
    openGraph: {
      title: noticia.titulo,
      description: noticia.conteudo.substring(0, 160),
      images: noticia.imagem_opcional ? [noticia.imagem_opcional] : [],
      type: "article",
      publishedTime: noticia.data_publicacao,
    },
    twitter: {
      card: "summary_large_image",
      title: noticia.titulo,
      description: noticia.conteudo.substring(0, 160),
      images: noticia.imagem_opcional ? [noticia.imagem_opcional] : [],
    },
  }
}
