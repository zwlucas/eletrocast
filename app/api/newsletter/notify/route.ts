import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"
import { sendNewsletterNotification } from "@/lib/notifications"

export async function POST(request: NextRequest) {
  try {
    const { noticiaId } = await request.json()

    if (!noticiaId) {
      return NextResponse.json({ error: "ID da notícia é obrigatório" }, { status: 400 })
    }

    // Buscar a notícia
    const { data: noticia, error: noticiaError } = await supabase
      .from("noticias")
      .select("*")
      .eq("id", noticiaId)
      .single()

    if (noticiaError || !noticia) {
      return NextResponse.json({ error: "Notícia não encontrada" }, { status: 404 })
    }

    // Buscar todos os subscribers ativos
    const { data: subscribers, error: subscribersError } = await supabase
      .from("newsletter_subscribers")
      .select("email, nome")
      .eq("is_active", true)

    if (subscribersError) {
      throw subscribersError
    }

    if (!subscribers || subscribers.length === 0) {
      return NextResponse.json({
        success: true,
        message: "Nenhum subscriber ativo encontrado",
        sent: 0,
      })
    }

    // Enviar emails para todos os subscribers
    const emailPromises = subscribers.map((subscriber: any) =>
      sendNewsletterNotification({ noticia, subscriber }).catch((error) => {
        console.error(`Erro ao enviar email para ${subscriber.email}:`, error)
        return null
      }),
    )

    await Promise.all(emailPromises)

    return NextResponse.json({
      success: true,
      message: `Notificações enviadas para ${subscribers.length} subscribers`,
      sent: subscribers.length,
    })
  } catch (error) {
    console.error("Erro ao enviar notificações:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}
