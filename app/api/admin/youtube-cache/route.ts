import { type NextRequest, NextResponse } from "next/server"
import { invalidateYouTubeCache, getYouTubeCacheStats } from "@/lib/youtube"

export async function GET() {
  try {
    const stats = await getYouTubeCacheStats()

    return NextResponse.json({
      success: true,
      stats,
    })
  } catch (error) {
    console.error("Error getting cache stats:", error)
    return NextResponse.json({ success: false, error: "Failed to get cache stats" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const type = searchParams.get("type") as
      | "live_stream"
      | "latest_video"
      | "premier_video"
      | "podcast_videos"
      | "all"
      | null

    await invalidateYouTubeCache(type || "all")

    return NextResponse.json({
      success: true,
      message: `Cache ${type || "all"} invalidated successfully`,
    })
  } catch (error) {
    console.error("Error invalidating cache:", error)
    return NextResponse.json({ success: false, error: "Failed to invalidate cache" }, { status: 500 })
  }
}
