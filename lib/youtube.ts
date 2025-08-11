import { youtubeCache } from "./youtube-cache"

const YOUTUBE_API_KEY = process.env.YOUTUBE_API_KEY
const CHANNEL_ID = process.env.YOUTUBE_CHANNEL_ID

export type YouTubeVideo = {
  id: string
  title: string
  description: string
  publishedAt: string
  thumbnails: {
    high: {
      url: string
    }
  }
}

export type LiveStream = {
  id: string
  title: string
  description: string
  isLive: boolean
}

export type PremierVideo = {
  id: string
  title: string
  description: string
  scheduledStartTime: string
  isPremier: boolean
}

// Função auxiliar para fazer requisições à API do YouTube
async function fetchYouTubeAPI(url: string): Promise<any> {
  if (!YOUTUBE_API_KEY || !CHANNEL_ID) {
    console.error("YouTube API key or Channel ID not configured")
    return null
  }

  try {
    const response = await fetch(url)
    if (!response.ok) {
      throw new Error(`YouTube API error: ${response.status}`)
    }
    return await response.json()
  } catch (error) {
    console.error("Error fetching from YouTube API:", error)
    throw error
  }
}

export async function checkLiveStream(): Promise<LiveStream | null> {
  const cacheKey = "live_stream"

  // Tentar obter do cache primeiro
  const cached = await youtubeCache.get<LiveStream>(cacheKey)
  if (cached) {
    console.log("✅ Live stream from cache")
    return cached
  }

  console.log("🔄 Fetching live stream from YouTube API")

  try {
    const url = `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&eventType=live&type=video&key=${YOUTUBE_API_KEY}`
    const data = await fetchYouTubeAPI(url)

    let result: LiveStream | null = null

    if (data?.items && data.items.length > 0) {
      const liveVideo = data.items[0]
      result = {
        id: liveVideo.id.videoId,
        title: liveVideo.snippet.title,
        description: liveVideo.snippet.description,
        isLive: true,
      }
    }

    // Armazenar no cache (mesmo se for null)
    await youtubeCache.set(cacheKey, result, "live_stream")

    return result
  } catch (error) {
    console.error("Error checking live stream:", error)
    return null
  }
}

export async function getLatestVideo(): Promise<YouTubeVideo | null> {
  const cacheKey = "latest_video"

  // Tentar obter do cache primeiro
  const cached = await youtubeCache.get<YouTubeVideo>(cacheKey)
  if (cached) {
    console.log("✅ Latest video from cache")
    return cached
  }

  console.log("🔄 Fetching latest video from YouTube API")

  try {
    const url = `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&order=date&type=video&maxResults=1&key=${YOUTUBE_API_KEY}`
    const data = await fetchYouTubeAPI(url)

    let result: YouTubeVideo | null = null

    if (data?.items && data.items.length > 0) {
      const video = data.items[0]
      result = {
        id: video.id.videoId,
        title: video.snippet.title,
        description: video.snippet.description,
        publishedAt: video.snippet.publishedAt,
        thumbnails: video.snippet.thumbnails,
      }
    }

    // Armazenar no cache
    await youtubeCache.set(cacheKey, result, "latest_video")

    return result
  } catch (error) {
    console.error("Error fetching latest video:", error)
    return null
  }
}

export async function checkPremierVideo(): Promise<PremierVideo | null> {
  const cacheKey = "premier_video"

  // Tentar obter do cache primeiro
  const cached = await youtubeCache.get<PremierVideo>(cacheKey)
  if (cached) {
    console.log("✅ Premier video from cache")
    return cached
  }

  console.log("🔄 Fetching premier video from YouTube API")

  try {
    const url = `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&eventType=upcoming&type=video&key=${YOUTUBE_API_KEY}&maxResults=1`
    const data = await fetchYouTubeAPI(url)

    let result: PremierVideo | null = null

    if (data?.items && data.items.length > 0) {
      const premierVideo = data.items[0]

      // Get more details about the video
      const detailsUrl = `https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails,snippet&id=${premierVideo.id.videoId}&key=${YOUTUBE_API_KEY}`
      const detailsData = await fetchYouTubeAPI(detailsUrl)

      if (detailsData?.items && detailsData.items.length > 0) {
        const videoDetails = detailsData.items[0]
        result = {
          id: premierVideo.id.videoId,
          title: premierVideo.snippet.title,
          description: premierVideo.snippet.description,
          scheduledStartTime: videoDetails.liveStreamingDetails?.scheduledStartTime || premierVideo.snippet.publishedAt,
          isPremier: true,
        }
      }
    }

    // Armazenar no cache
    await youtubeCache.set(cacheKey, result, "premier_video")

    return result
  } catch (error) {
    console.error("Error checking premier video:", error)
    return null
  }
}

export async function getPodcastVideos(maxResults = 10): Promise<YouTubeVideo[]> {
  const cacheKey = `podcast_videos_${maxResults}`

  // Tentar obter do cache primeiro
  const cached = await youtubeCache.get<YouTubeVideo[]>(cacheKey)
  if (cached) {
    console.log("✅ Podcast videos from cache")
    return cached
  }

  console.log("🔄 Fetching podcast videos from YouTube API")

  try {
    const url = `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&order=date&type=video&maxResults=${maxResults}&key=${YOUTUBE_API_KEY}`
    const data = await fetchYouTubeAPI(url)

    let result: YouTubeVideo[] = []

    if (data?.items) {
      result = data.items.map((video: any) => ({
        id: video.id.videoId,
        title: video.snippet.title,
        description: video.snippet.description,
        publishedAt: video.snippet.publishedAt,
        thumbnails: video.snippet.thumbnails,
      }))
    }

    // Armazenar no cache
    await youtubeCache.set(cacheKey, result, "podcast_videos")

    return result
  } catch (error) {
    console.error("Error fetching podcast videos:", error)
    return []
  }
}

// Função para invalidar cache manualmente (útil para admin)
export async function invalidateYouTubeCache(
  type?: "live_stream" | "latest_video" | "premier_video" | "podcast_videos" | "all",
) {
  if (!type || type === "all") {
    await youtubeCache.invalidateAll()
    console.log("🗑️ All YouTube cache invalidated")
    return
  }

  const keys = {
    live_stream: "live_stream",
    latest_video: "latest_video",
    premier_video: "premier_video",
    podcast_videos: "podcast_videos_",
  }

  if (type === "podcast_videos") {
    // Invalidar todos os caches de podcast com diferentes maxResults
    for (let i = 1; i <= 50; i++) {
      await youtubeCache.invalidate(`podcast_videos_${i}`)
    }
  } else {
    await youtubeCache.invalidate(keys[type])
  }

  console.log(`🗑️ ${type} cache invalidated`)
}

// Função para obter estatísticas do cache
export async function getYouTubeCacheStats() {
  return await youtubeCache.getStats()
}
