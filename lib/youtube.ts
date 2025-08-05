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

export async function checkLiveStream(): Promise<LiveStream | null> {
  if (!YOUTUBE_API_KEY || !CHANNEL_ID) {
    console.error("YouTube API key or Channel ID not configured")
    return null
  }

  try {
    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&eventType=live&type=video&key=${YOUTUBE_API_KEY}`,
    )

    const data = await response.json()

    if (data.items && data.items.length > 0) {
      const liveVideo = data.items[0]
      return {
        id: liveVideo.id.videoId,
        title: liveVideo.snippet.title,
        description: liveVideo.snippet.description,
        isLive: true,
      }
    }

    return null
  } catch (error) {
    console.error("Error checking live stream:", error)
    return null
  }
}

export async function getLatestVideo(): Promise<YouTubeVideo | null> {
  if (!YOUTUBE_API_KEY || !CHANNEL_ID) {
    console.error("YouTube API key or Channel ID not configured")
    return null
  }

  try {
    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&order=date&type=video&maxResults=1&key=${YOUTUBE_API_KEY}`,
    )

    const data = await response.json()

    if (data.items && data.items.length > 0) {
      const video = data.items[0]
      return {
        id: video.id.videoId,
        title: video.snippet.title,
        description: video.snippet.description,
        publishedAt: video.snippet.publishedAt,
        thumbnails: video.snippet.thumbnails,
      }
    }

    return null
  } catch (error) {
    console.error("Error fetching latest video:", error)
    return null
  }
}

export async function checkPremierVideo(): Promise<PremierVideo | null> {
  if (!YOUTUBE_API_KEY || !CHANNEL_ID) {
    console.error("YouTube API key or Channel ID not configured")
    return null
  }

  try {
    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&eventType=upcoming&type=video&key=${YOUTUBE_API_KEY}&maxResults=1`,
    )

    const data = await response.json()

    if (data.items && data.items.length > 0) {
      const premierVideo = data.items[0]

      // Get more details about the video
      const detailsResponse = await fetch(
        `https://www.googleapis.com/youtube/v3/videos?part=liveStreamingDetails,snippet&id=${premierVideo.id.videoId}&key=${YOUTUBE_API_KEY}`,
      )

      const detailsData = await detailsResponse.json()

      if (detailsData.items && detailsData.items.length > 0) {
        const videoDetails = detailsData.items[0]
        return {
          id: premierVideo.id.videoId,
          title: premierVideo.snippet.title,
          description: premierVideo.snippet.description,
          scheduledStartTime: videoDetails.liveStreamingDetails?.scheduledStartTime || premierVideo.snippet.publishedAt,
          isPremier: true,
        }
      }
    }

    return null
  } catch (error) {
    console.error("Error checking premier video:", error)
    return null
  }
}

export async function getPodcastVideos(maxResults = 10): Promise<YouTubeVideo[]> {
  if (!YOUTUBE_API_KEY || !CHANNEL_ID) {
    console.error("YouTube API key or Channel ID not configured")
    return []
  }

  try {
    const response = await fetch(
      `https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=${CHANNEL_ID}&order=date&type=video&maxResults=${maxResults}&key=${YOUTUBE_API_KEY}`,
    )

    const data = await response.json()

    if (data.items) {
      return data.items.map((video: any) => ({
        id: video.id.videoId,
        title: video.snippet.title,
        description: video.snippet.description,
        publishedAt: video.snippet.publishedAt,
        thumbnails: video.snippet.thumbnails,
      }))
    }

    return []
  } catch (error) {
    console.error("Error fetching podcast videos:", error)
    return []
  }
}
