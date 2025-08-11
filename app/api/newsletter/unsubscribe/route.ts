import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const { email } = await request.json()

    if (!email) {
      return NextResponse.json({ error: "Email é obrigatório" }, { status: 400 })
    }

    // Desativar a inscrição
    const { error } = await supabase
      .from("newsletter_subscribers")
      .update({ is_active: false, unsubscribed_at: new Date().toISOString() })
      .eq("email", email)

    if (error) {
      throw error
    }

    return NextResponse.json({
      success: true,
      message: "Inscrição cancelada com sucesso!",
    })
  } catch (error) {
    console.error("Erro ao cancelar inscrição:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const email = searchParams.get("email")

    if (!email) {
      return NextResponse.json({ error: "Email é obrigatório" }, { status: 400 })
    }

    // Desativar a inscrição
    const { error } = await supabase
      .from("newsletter_subscribers")
      .update({ is_active: false, unsubscribed_at: new Date().toISOString() })
      .eq("email", email)

    if (error) {
      throw error
    }

    return NextResponse.json({
      success: true,
      message: "Inscrição cancelada com sucesso!",
    })
  } catch (error) {
    console.error("Erro ao cancelar inscrição:", error)
    return NextResponse.json({ error: "Erro interno do servidor" }, { status: 500 })
  }
}
