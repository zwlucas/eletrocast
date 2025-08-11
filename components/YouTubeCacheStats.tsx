"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"

interface CacheStats {
  total_entries: number
  expired_entries: number
  cache_hit_potential: string
}

export default function YouTubeCacheStats() {
  const [stats, setStats] = useState<CacheStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [invalidating, setInvalidating] = useState<string | null>(null)

  const fetchStats = async () => {
    try {
      const response = await fetch("/api/admin/youtube-cache")
      const data = await response.json()
      if (data.success) {
        setStats(data.stats)
      }
    } catch (error) {
      console.error("Error fetching cache stats:", error)
    } finally {
      setLoading(false)
    }
  }

  const invalidateCache = async (type: string) => {
    setInvalidating(type)
    try {
      const url = type === "all" ? "/api/admin/youtube-cache" : `/api/admin/youtube-cache?type=${type}`

      const response = await fetch(url, { method: "DELETE" })
      const data = await response.json()

      if (data.success) {
        await fetchStats() // Refresh stats
        alert(`Cache ${type} invalidado com sucesso!`)
      } else {
        alert("Erro ao invalidar cache")
      }
    } catch (error) {
      console.error("Error invalidating cache:", error)
      alert("Erro ao invalidar cache")
    } finally {
      setInvalidating(null)
    }
  }

  useEffect(() => {
    fetchStats()
  }, [])

  if (loading) {
    return (
      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
        <h3 className="text-lg font-semibold mb-4">Cache do YouTube</h3>
        <div className="animate-pulse">
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-2"></div>
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded mb-2"></div>
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded"></div>
        </div>
      </div>
    )
  }

  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6">
      <div className="flex justify-between items-center mb-4">
        <h3 className="text-lg font-semibold">Cache do YouTube</h3>
        <Button onClick={fetchStats} variant="outline" size="sm">
          🔄 Atualizar
        </Button>
      </div>

      {stats && (
        <div className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div className="bg-blue-50 dark:bg-blue-900/20 p-4 rounded-lg">
              <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">{stats.total_entries}</div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Entradas no Cache</div>
            </div>

            <div className="bg-red-50 dark:bg-red-900/20 p-4 rounded-lg">
              <div className="text-2xl font-bold text-red-600 dark:text-red-400">{stats.expired_entries}</div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Entradas Expiradas</div>
            </div>

            <div className="bg-green-50 dark:bg-green-900/20 p-4 rounded-lg">
              <div className="text-2xl font-bold text-green-600 dark:text-green-400">{stats.cache_hit_potential}</div>
              <div className="text-sm text-gray-600 dark:text-gray-400">Eficiência do Cache</div>
            </div>
          </div>

          <div className="border-t pt-4">
            <h4 className="font-medium mb-3">Gerenciar Cache</h4>
            <div className="grid grid-cols-2 md:grid-cols-3 gap-2">
              {[
                { key: "live_stream", label: "Live Stream" },
                { key: "latest_video", label: "Último Vídeo" },
                { key: "premier_video", label: "Premier" },
                { key: "podcast_videos", label: "Podcasts" },
                { key: "all", label: "Tudo", variant: "destructive" as const },
              ].map(({ key, label, variant }) => (
                <Button
                  key={key}
                  onClick={() => invalidateCache(key)}
                  disabled={invalidating === key}
                  variant={variant || "outline"}
                  size="sm"
                  className="text-xs"
                >
                  {invalidating === key ? "⏳" : "🗑️"} {label}
                </Button>
              ))}
            </div>
          </div>

          <div className="text-xs text-gray-500 dark:text-gray-400 bg-gray-50 dark:bg-gray-900 p-3 rounded">
            <strong>💡 Dica:</strong> O cache reduz drasticamente o uso da API do YouTube. Live streams são atualizados
            a cada 2 min, vídeos a cada 30 min, e podcasts a cada 1 hora.
          </div>
        </div>
      )}
    </div>
  )
}
