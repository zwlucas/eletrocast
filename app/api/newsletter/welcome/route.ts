import { type NextRequest, NextResponse } from "next/server"
import { sendWelcomeEmail } from "@/lib/notifications"

export async function POST(request: NextRequest) {
  try {
    const { email, nome } = await request.json()

    await sendWelcomeEmail({ email, nome })

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Erro ao enviar email de boas-vindas:", error)
    return NextResponse.json({ error: "Erro ao enviar email" }, { status: 500 })
  }
}
