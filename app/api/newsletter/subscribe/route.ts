import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { email, nome } = body

    // Validação básica
    if (!email || !nome) {
      return NextResponse.json({ error: "Email e nome são obrigatórios" }, { status: 400 })
    }

    // Validação de email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    if (!emailRegex.test(email)) {
      return NextResponse.json({ error: "Email inválido" }, { status: 400 })
    }

    // Validação de nome
    if (nome.length < 2) {
      return NextResponse.json({ error: "Nome deve ter pelo menos 2 caracteres" }, { status: 400 })
    }

    // Verificar se já existe
    const { data: existing } = await supabase
      .from("newsletter_subscribers")
      .select("email, is_active")
      .eq("email", email.toLowerCase())
      .single()

    if (existing) {
      if (existing.is_active) {
        return NextResponse.json({ error: "Este e-mail já está cadastrado!" }, { status: 409 })
      } else {
        // Reativar inscrição existente
        const { error: updateError } = await supabase
          .from("newsletter_subscribers")
          .update({
            nome: nome.trim(),
            is_active: true,
            subscribed_at: new Date().toISOString(),
            unsubscribed_at: null,
          })
          .eq("email", email.toLowerCase())

        if (updateError) {
          console.error("Erro ao reativar inscrição:", updateError)
          throw updateError
        }
      }
    } else {
      // Criar nova inscrição
      const { error: insertError } = await supabase.from("newsletter_subscribers").insert([
        {
          email: email.toLowerCase(),
          nome: nome.trim(),
          subscribed_at: new Date().toISOString(),
          is_active: true,
        },
      ])

      if (insertError) {
        console.error("Erro ao criar inscrição:", insertError)
        throw insertError
      }
    }

    // Enviar email de boas-vindas (não bloquear se falhar)
    try {
      await fetch(`${process.env.NEXT_PUBLIC_SITE_URL || request.nextUrl.origin}/api/newsletter/welcome`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: email.toLowerCase(), nome: nome.trim() }),
      })
    } catch (emailError) {
      console.error("Erro ao enviar email de boas-vindas:", emailError)
      // Não falhar a inscrição se o email não for enviado
    }

    return NextResponse.json({
      success: true,
      message: "Inscrição realizada com sucesso!",
    })
  } catch (error: any) {
    console.error("Erro ao processar inscrição:", error)

    // Tratar erros específicos do Supabase
    if (error.code === "23505") {
      return NextResponse.json({ error: "Este e-mail já está cadastrado!" }, { status: 409 })
    }

    return NextResponse.json(
      {
        error: "Erro interno do servidor. Tente novamente em alguns instantes.",
      },
      { status: 500 },
    )
  }
}
