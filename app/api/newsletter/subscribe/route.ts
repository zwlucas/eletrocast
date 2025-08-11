import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const { email, nome } = await request.json()

    if (!email || !nome) {
      return NextResponse.json({ error: "Email e nome são obrigatórios" }, { status: 400 })
    }

    // Inserir subscriber no banco
    const { data, error } = await supabase
      .from("newsletter_subscribers")
      .insert([
        {
          email,
          nome,
          subscribed_at: new Date().toISOString(),
          is_active: true,
        },
      ])
      .select()

    if (error) {
      if (error.code === "23505") {
        return NextResponse.json({ error: "Este e-mail já está cadastrado!" }, { status: 409 })
      }
      throw error
    }

    // Enviar email de boas-vindas
    await fetch(`${process.env.NEXT_PUBLIC_SITE_URL}/api/newsletter/welcome`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ email, nome }),
    })

    return NextResponse.json({
      success: true,
      message: "Inscrição realizada com sucesso!",
    })
  } catch (error) {
    console.error("Erro ao processar inscrição:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}
