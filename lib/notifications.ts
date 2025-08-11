import { Resend } from "resend"

const resend = new Resend(process.env.RESEND_API_KEY)

export async function sendWelcomeEmail({ email, nome }: { email: string; nome: string }) {
  if (!process.env.RESEND_API_KEY) {
    console.log("Resend API key not configured")
    return
  }

  try {
    const { data, error } = await resend.emails.send({
      from: "Eletrocast <eletroeletrocast2024@gmail.com>",
      to: [email],
      subject: "🎉 Bem-vindo ao Eletrocast!",
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8f9fa;">
          <div style="background: linear-gradient(135deg, #1D4ED8, #FACC15); padding: 30px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px;">⚡ Eletrocast</h1>
            <p style="color: white; margin: 10px 0 0 0; opacity: 0.9;">Tecnologia e Inovação</p>
          </div>
          
          <div style="padding: 40px 30px; background: white; margin: 0;">
            <h2 style="color: #1D4ED8; margin-bottom: 20px; font-size: 24px;">Olá, ${nome}! 👋</h2>
            
            <p style="color: #666; line-height: 1.6; margin-bottom: 20px; font-size: 16px;">
              Seja muito bem-vindo(a) à nossa comunidade! Agora você receberá em primeira mão:
            </p>
            
            <ul style="color: #666; line-height: 1.8; margin-bottom: 30px; padding-left: 20px;">
              <li>📰 Últimas notícias sobre tecnologia</li>
              <li>🎙️ Novos episódios do nosso podcast</li>
              <li>💡 Insights exclusivos sobre inovação</li>
              <li>🔥 Conteúdos especiais para assinantes</li>
            </ul>
            
            <div style="text-align: center; margin: 30px 0;">
              <a href="${process.env.NEXT_PUBLIC_SITE_URL}" 
                 style="background: #FACC15; color: #1D4ED8; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block; font-size: 16px;">
                Explorar o Site
              </a>
            </div>
            
            <p style="color: #999; font-size: 14px; text-align: center; margin-top: 30px;">
              Fique ligado! Em breve você receberá nossas novidades.
            </p>
          </div>
          
          <div style="padding: 20px; text-align: center; color: #999; font-size: 12px; background: #f8f9fa;">
            <p>Você está recebendo este e-mail porque se inscreveu no newsletter do Eletrocast.</p>
            <p>© 2024 Eletrocast. Todos os direitos reservados.</p>
          </div>
        </div>
      `,
    })

    if (error) {
      console.error("Error sending welcome email:", error)
    } else {
      console.log("Welcome email sent successfully:", data)
    }
  } catch (error) {
    console.error("Error sending welcome email:", error)
  }
}

export async function sendNewsletterNotification({
  noticia,
  subscriber,
}: {
  noticia: any
  subscriber: { email: string; nome: string }
}) {
  if (!process.env.RESEND_API_KEY) {
    console.log("Resend API key not configured")
    return
  }

  try {
    const { data, error } = await resend.emails.send({
      from: "Eletrocast <eletroeletrocast2024@gmail.com>",
      to: [subscriber.email],
      subject: `📰 Nova notícia: ${noticia.titulo}`,
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; background: #f8f9fa;">
          <div style="background: linear-gradient(135deg, #1D4ED8, #FACC15); padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 24px;">⚡ Eletrocast</h1>
          </div>
          
          <div style="padding: 30px; background: white;">
            <p style="color: #666; margin-bottom: 20px;">Olá, ${subscriber.nome}!</p>
            
            <h2 style="color: #1D4ED8; margin-bottom: 20px; line-height: 1.3;">${noticia.titulo}</h2>
            
            ${
              noticia.imagem_url
                ? `
              <img src="${noticia.imagem_url}" 
                   alt="${noticia.titulo}" 
                   style="width: 100%; height: 200px; object-fit: cover; border-radius: 8px; margin-bottom: 20px;" />
            `
                : ""
            }
            
            <p style="color: #666; line-height: 1.6; margin-bottom: 30px; font-size: 16px;">
              ${noticia.conteudo.substring(0, 300)}...
            </p>
            
            <div style="text-align: center;">
              <a href="${process.env.NEXT_PUBLIC_SITE_URL}/noticias/${noticia.id}" 
                 style="background: #FACC15; color: #1D4ED8; padding: 15px 30px; text-decoration: none; border-radius: 8px; font-weight: bold; display: inline-block; font-size: 16px;">
                Ler notícia completa
              </a>
            </div>
            
            <div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 8px;">
              <p style="color: #666; margin: 0; font-size: 14px; text-align: center;">
                💡 <strong>Dica:</strong> Não perca nenhuma novidade! Siga-nos nas redes sociais.
              </p>
            </div>
          </div>
          
          <div style="padding: 20px; text-align: center; color: #999; font-size: 12px;">
            <p>Você está recebendo este e-mail porque se inscreveu nas notificações do Eletrocast.</p>
            <p>
              <a href="${process.env.NEXT_PUBLIC_SITE_URL}/unsubscribe?email=${subscriber.email}" 
                 style="color: #999; text-decoration: underline;">
                Cancelar inscrição
              </a>
            </p>
          </div>
        </div>
      `,
    })

    if (error) {
      console.error("Error sending newsletter notification:", error)
    } else {
      console.log("Newsletter notification sent successfully to:", subscriber.email)
    }
  } catch (error) {
    console.error("Error sending newsletter notification:", error)
  }
}

export async function sendNewPostNotification(noticia: {
  titulo: string
  conteudo: string
  id: string
}) {
  // Trigger newsletter notification for all subscribers
  try {
    await fetch(`${process.env.NEXT_PUBLIC_SITE_URL}/api/newsletter/notify`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ noticiaId: noticia.id }),
    })
  } catch (error) {
    console.error("Error triggering newsletter notifications:", error)
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
