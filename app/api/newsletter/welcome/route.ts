import { type NextRequest, NextResponse } from "next/server"
import { sendWelcomeEmail } from "@/lib/notifications"

export async function POST(request: NextRequest) {
  try {
    const { email, nome } = await request.json()

    if (!email || !nome) {
      return NextResponse.json({ error: "Email e nome são obrigatórios" }, { status: 400 })
    }

    await sendWelcomeEmail({ email, nome })

    return NextResponse.json({
      success: true,
      message: "Email de boas-vindas enviado com sucesso!",
    })
  } catch (error) {
    console.error("Erro ao enviar email de boas-vindas:", error)
    return NextResponse.json({ error: "Erro ao enviar email de boas-vindas" }, { status: 500 })
  }
}
