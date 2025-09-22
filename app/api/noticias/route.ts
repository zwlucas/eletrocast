import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"
import { sendNewPostNotification } from "@/lib/notifications"

export async function GET() {
  try {
    const { data: noticias, error } = await supabase
      .from("noticias")
      .select("*")
      .order("data_publicacao", { ascending: false })

    if (error) {
      throw error
    }

    return NextResponse.json({ noticias })
  } catch (error) {
    console.error("Erro ao buscar notícias:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { titulo, conteudo, autor, imagem_opcional, tags } = body

    // Validação básica
    if (!titulo || !conteudo || !autor) {
      return NextResponse.json({ error: "Título, conteúdo e autor são obrigatórios" }, { status: 400 })
    }

    // Inserir nova notícia
    const { data: noticia, error } = await supabase
      .from("noticias")
      .insert([
        {
          titulo,
          conteudo,
          autor,
          imagem_opcional,
          tags: tags || [],
          data_publicacao: new Date().toISOString(),
        },
      ])
      .select()
      .single()

    if (error) {
      throw error
    }

    // Enviar notificação por email para todos os subscribers
    try {
      await sendNewPostNotification({
        titulo: noticia.titulo,
        conteudo: noticia.conteudo,
        id: noticia.id,
      })
      console.log(`Notificações enviadas para nova notícia: ${noticia.titulo}`)
    } catch (emailError) {
      console.error("Erro ao enviar notificações por email:", emailError)
      // Não falha a criação da notícia se o email falhar
    }

    return NextResponse.json({
      success: true,
      noticia,
      message: "Notícia criada e notificações enviadas com sucesso!",
    })
  } catch (error) {
    console.error("Erro ao criar notícia:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}
