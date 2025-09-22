"use client"

export const trackEvent = (eventName: string, properties?: Record<string, any>) => {
  // Vercel Analytics
  if (typeof window !== "undefined" && (window as any).va) {
    ;(window as any).va("track", eventName, properties)
  }

  // Custom analytics (opcional)
  if (process.env.NODE_ENV === "production") {
    fetch("/api/analytics", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        event: eventName,
        properties,
        timestamp: new Date().toISOString(),
        url: window.location.href,
        referrer: document.referrer,
      }),
    }).catch(console.error)
  }
}

export const trackPageView = (page: string) => {
  trackEvent("page_view", { page })
}

export const trackVideoPlay = (videoId: string, title: string) => {
  trackEvent("video_play", { videoId, title })
}

export const trackNewsRead = (newsId: string, title: string) => {
  trackEvent("news_read", { newsId, title })
}
