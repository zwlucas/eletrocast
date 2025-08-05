import { Resend } from "resend"

const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendNewPostNotification(noticia: {
  titulo: string
  conteudo: string
  id: string
}) {
  if (!process.env.RESEND_API_KEY) {
    console.log("Resend API key not configured")
    return
  }

  try {
    const { data, error } = await resend.emails.send({
      from: "Eletrocast <noticias@eletrocast.tech>",
      to: ["subscribers@eletrocast.tech"], // Lista de assinantes
      subject: `📰 Nova notícia: ${noticia.titulo}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #1D4ED8, #FACC15); padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0;">⚡ Eletrocast</h1>
          </div>
          
          <div style="padding: 30px; background: #f8f9fa;">
            <h2 style="color: #1D4ED8; margin-bottom: 20px;">${noticia.titulo}</h2>
            
            <p style="color: #666; line-height: 1.6; margin-bottom: 30px;">
              ${noticia.conteudo.substring(0, 200)}...
            </p>
            
            <div style="text-align: center;">
              <a href="${process.env.NEXT_PUBLIC_SITE_URL}/noticias/${noticia.id}" 
                 style="background: #FACC15; color: #1D4ED8; padding: 12px 24px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block;">
                Ler notícia completa
              </a>
            </div>
          </div>
          
          <div style="padding: 20px; text-align: center; color: #999; font-size: 12px;">
            <p>Você está recebendo este e-mail porque se inscreveu nas notificações do Eletrocast.</p>
          </div>
        </div>
      `,
    })

    if (error) {
      console.error("Error sending email:", error)
    } else {
      console.log("Email sent successfully:", data)
    }
  } catch (error) {
    console.error("Error sending notification:", error)
  }
}

export async function sendDiscordNotification(message: string, isLive = false) {
  const webhookUrl = process.env.DISCORD_WEBHOOK_URL

  if (!webhookUrl) {
    console.log("Discord webhook not configured")
    return
  }

  try {
    const embed = {
      title: isLive ? "🔴 Estamos ao vivo!" : "📰 Nova notícia publicada",
      description: message,
      color: isLive ? 0xff0000 : 0x1d4ed8,
      timestamp: new Date().toISOString(),
      footer: {
        text: "Eletrocast ⚡",
      },
    }

    await fetch(webhookUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        embeds: [embed],
      }),
    })
  } catch (error) {
    console.error("Error sending Discord notification:", error)
  }
}
