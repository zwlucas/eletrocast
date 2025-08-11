import { supabase } from "@/lib/supabase"

export interface CacheEntry {
  id: number
  cache_key: string
  data: any
  expires_at: string
  created_at: string
  updated_at: string
}

export class YouTubeCache {
  private supabase = supabase
  // Tempos de cache em minutos
  private static CACHE_TIMES = {
    live_stream: 2, // 2 minutos para live streams (mais dinâmico)
    latest_video: 30, // 30 minutos para último vídeo
    premier_video: 15, // 15 minutos para premiers
    podcast_videos: 60, // 1 hora para lista de podcasts
  }

  async get<T>(key: string): Promise<T | null> {
    try {
      // Limpar cache expirado primeiro
      await this.cleanExpired()

      const { data, error } = await this.supabase
        .from("youtube_cache")
        .select("*")
        .eq("cache_key", key)
        .gt("expires_at", new Date().toISOString())
        .single()

      if (error || !data) {
        return null
      }

      return data.data as T
    } catch (error) {
      console.error("Error getting cache:", error)
      return null
    }
  }

  async set(key: string, data: any, cacheType: keyof typeof YouTubeCache.CACHE_TIMES): Promise<void> {
    try {
      const expiresAt = new Date()
      expiresAt.setMinutes(expiresAt.getMinutes() + YouTubeCache.CACHE_TIMES[cacheType])

      const { error } = await this.supabase.from("youtube_cache").upsert(
        {
          cache_key: key,
          data: data,
          expires_at: expiresAt.toISOString(),
        },
        {
          onConflict: "cache_key",
        },
      )

      if (error) {
        console.error("Error setting cache:", error)
      }
    } catch (error) {
      console.error("Error setting cache:", error)
    }
  }

  async invalidate(key: string): Promise<void> {
    try {
      await this.supabase.from("youtube_cache").delete().eq("cache_key", key)
    } catch (error) {
      console.error("Error invalidating cache:", error)
    }
  }

  async invalidateAll(): Promise<void> {
    try {
      await this.supabase.from("youtube_cache").delete().neq("id", 0) // Delete all
    } catch (error) {
      console.error("Error invalidating all cache:", error)
    }
  }

  private async cleanExpired(): Promise<void> {
    try {
      await this.supabase.rpc("clean_expired_youtube_cache")
    } catch (error) {
      console.error("Error cleaning expired cache:", error)
    }
  }

  // Método para obter estatísticas do cache
  async getStats(): Promise<{
    total_entries: number
    expired_entries: number
    cache_hit_potential: string
  }> {
    try {
      const { data: total } = await this.supabase.from("youtube_cache").select("id", { count: "exact" })

      const { data: expired } = await this.supabase
        .from("youtube_cache")
        .select("id", { count: "exact" })
        .lt("expires_at", new Date().toISOString())

      return {
        total_entries: total?.length || 0,
        expired_entries: expired?.length || 0,
        cache_hit_potential: `${Math.round((((total?.length || 0) - (expired?.length || 0)) / Math.max(total?.length || 1, 1)) * 100)}%`,
      }
    } catch (error) {
      console.error("Error getting cache stats:", error)
      return {
        total_entries: 0,
        expired_entries: 0,
        cache_hit_potential: "0%",
      }
    }
  }
}

export const youtubeCache = new YouTubeCache()
