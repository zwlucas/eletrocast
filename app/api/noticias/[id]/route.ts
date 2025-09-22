import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"
import { sendNewPostNotification } from "@/lib/notifications"

interface RouteParams {
  params: {
    id: string
  }
}

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const { data: noticia, error } = await supabase.from("noticias").select("*").eq("id", params.id).single()

    if (error) {
      throw error
    }

    if (!noticia) {
      return NextResponse.json({ error: "Notícia não encontrada" }, { status: 404 })
    }

    return NextResponse.json({ noticia })
  } catch (error) {
    console.error("Erro ao buscar notícia:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}

export async function PUT(request: NextRequest, { params }: RouteParams) {
  try {
    const body = await request.json()
    const { titulo, conteudo, autor, imagem_opcional, tags, publicar_agora } = body

    // Validação básica
    if (!titulo || !conteudo || !autor) {
      return NextResponse.json({ error: "Título, conteúdo e autor são obrigatórios" }, { status: 400 })
    }

    // Buscar notícia atual para verificar se já foi publicada
    const { data: noticiaAtual, error: fetchError } = await supabase
      .from("noticias")
      .select("data_publicacao")
      .eq("id", params.id)
      .single()

    if (fetchError) {
      throw fetchError
    }

    const updateData: any = {
      titulo,
      conteudo,
      autor,
      imagem_opcional,
      tags: tags || [],
    }

    // Se publicar_agora for true e a notícia ainda não foi publicada
    const jaPublicada = noticiaAtual?.data_publicacao
    if (publicar_agora && !jaPublicada) {
      updateData.data_publicacao = new Date().toISOString()
    }

    // Atualizar notícia
    const { data: noticia, error } = await supabase
      .from("noticias")
      .update(updateData)
      .eq("id", params.id)
      .select()
      .single()

    if (error) {
      throw error
    }

    // Se a notícia foi publicada agora, enviar notificações
    if (publicar_agora && !jaPublicada) {
      try {
        await sendNewPostNotification({
          titulo: noticia.titulo,
          conteudo: noticia.conteudo,
          id: noticia.id,
        })
        console.log(`Notificações enviadas para notícia publicada: ${noticia.titulo}`)
      } catch (emailError) {
        console.error("Erro ao enviar notificações por email:", emailError)
        // Não falha a atualização se o email falhar
      }
    }

    return NextResponse.json({
      success: true,
      noticia,
      message:
        publicar_agora && !jaPublicada
          ? "Notícia publicada e notificações enviadas com sucesso!"
          : "Notícia atualizada com sucesso!",
    })
  } catch (error) {
    console.error("Erro ao atualizar notícia:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const { error } = await supabase.from("noticias").delete().eq("id", params.id)

    if (error) {
      throw error
    }

    return NextResponse.json({
      success: true,
      message: "Notícia deletada com sucesso!",
    })
  } catch (error) {
    console.error("Erro ao deletar notícia:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}
