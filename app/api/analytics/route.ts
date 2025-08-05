import { type NextRequest, NextResponse } from "next/server"
import { supabase } from "@/lib/supabase"

export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    // Salvar analytics no Supabase (opcional)
    const { error } = await supabase.from("analytics_events").insert([
      {
        event: data.event,
        properties: data.properties,
        timestamp: data.timestamp,
        url: data.url,
        referrer: data.referrer,
        user_agent: request.headers.get("user-agent"),
        ip: request.ip || request.headers.get("x-forwarded-for"),
      },
    ])

    if (error) {
      console.error("Analytics error:", error)
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Analytics API error:", error)
    return NextResponse.json({ error: "Failed to track event" }, { status: 500 })
  }
}
