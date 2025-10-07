"use client"

import { useState, useEffect } from "react"
import { supabase } from "@/lib/supabase"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import {
  BarChart,
  LineChart,
  PieChart,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  Bar,
  Line,
  Pie,
  Cell,
  ResponsiveContainer,
} from "recharts"
import { ChartContainer, ChartTooltip, ChartTooltipContent } from "@/components/ui/chart"
import { Eye, FileText, Users } from "lucide-react"

interface AnalyticsEvent {
  id: string
  event: string
  properties: any
  timestamp: string
  url: string
  referrer: string
  user_agent: string
  ip: string
}

interface PageViewCount {
  url: string
  count: number
}

interface EventCount {
  event: string
  count: number
}

interface DailyStats {
  date: string
  pageViews: number
  newsReads: number
  videoPlays: number
}

const COLORS = ["#0088FE", "#00C49F", "#FFBB28", "#FF8042", "#8884d8", "#82ca9d"]

export default function AdminAnalytics() {
  const [loading, setLoading] = useState(true)
  const [pageViews, setPageViews] = useState<PageViewCount[]>([])
  const [eventCounts, setEventCounts] = useState<EventCount[]>([])
  const [dailyStats, setDailyStats] = useState<DailyStats[]>([])
  const [totalPageViews, setTotalPageViews] = useState(0)
  const [totalNewsReads, setTotalNewsReads] = useState(0)
  const [totalVideoPlays, setTotalVideoPlays] = useState(0)
  const [activeTab, setActiveTab] = useState("overview")
  const [timeRange, setTimeRange] = useState("7d")

  useEffect(() => {
    fetchAnalyticsData()
  }, [timeRange])

  const fetchAnalyticsData = async () => {
    setLoading(true)

    try {
      // Get date range based on selected time range
      const now = new Date()
      const startDate = new Date()

      if (timeRange === "7d") {
        startDate.setDate(now.getDate() - 7)
      } else if (timeRange === "30d") {
        startDate.setDate(now.getDate() - 30)
      } else if (timeRange === "90d") {
        startDate.setDate(now.getDate() - 90)
      }

      const startDateStr = startDate.toISOString()

      // Fetch analytics events
      const { data: events, error } = await supabase
        .from("analytics_events")
        .select("*")
        .gte("timestamp", startDateStr)
        .order("timestamp", { ascending: false })

      if (error) {
        console.error("Error fetching analytics:", error)
        return
      }

      // Process data for different charts
      processAnalyticsData(events || [])
    } catch (error) {
      console.error("Error:", error)
    } finally {
      setLoading(false)
    }
  }

  const processAnalyticsData = (events: AnalyticsEvent[]) => {
    // Count page views by URL
    const pageViewsMap = new Map<string, number>()
    const eventsMap = new Map<string, number>()
    const dailyStatsMap = new Map<string, { pageViews: number; newsReads: number; videoPlays: number }>()

    let pageViewCount = 0
    let newsReadCount = 0
    let videoPlayCount = 0

    events.forEach((event) => {
      // Count events by type
      const eventType = event.event
      eventsMap.set(eventType, (eventsMap.get(eventType) || 0) + 1)

      // Count page views
      if (eventType === "page_view") {
        pageViewCount++
        const url = event.url || event.properties?.page || "unknown"
        const shortUrl = url.replace(/^https?:\/\/[^/]+/, "").split("?")[0] || "/"
        pageViewsMap.set(shortUrl, (pageViewsMap.get(shortUrl) || 0) + 1)
      }

      // Count news reads
      if (eventType === "news_read") {
        newsReadCount++
      }

      // Count video plays
      if (eventType === "video_play") {
        videoPlayCount++
      }

      // Group by date for time series
      const date = new Date(event.timestamp).toISOString().split("T")[0]
      const dailyData = dailyStatsMap.get(date) || { pageViews: 0, newsReads: 0, videoPlays: 0 }

      if (eventType === "page_view") {
        dailyData.pageViews++
      } else if (eventType === "news_read") {
        dailyData.newsReads++
      } else if (eventType === "video_play") {
        dailyData.videoPlays++
      }

      dailyStatsMap.set(date, dailyData)
    })

    // Convert maps to arrays for charts
    const pageViewsArray = Array.from(pageViewsMap.entries())
      .map(([url, count]) => ({ url, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 10)

    const eventsArray = Array.from(eventsMap.entries())
      .map(([event, count]) => ({ event, count }))
      .sort((a, b) => b.count - a.count)

    // Create daily stats array with all dates in range
    const dailyStatsArray: DailyStats[] = []
    const startDate = new Date()
    startDate.setDate(startDate.getDate() - (timeRange === "7d" ? 7 : timeRange === "30d" ? 30 : 90))

    const endDate = new Date()
    const currentDate = new Date(startDate)

    while (currentDate <= endDate) {
      const dateStr = currentDate.toISOString().split("T")[0]
      const stats = dailyStatsMap.get(dateStr) || { pageViews: 0, newsReads: 0, videoPlays: 0 }

      dailyStatsArray.push({
        date: dateStr,
        pageViews: stats.pageViews,
        newsReads: stats.newsReads,
        videoPlays: stats.videoPlays,
      })

      currentDate.setDate(currentDate.getDate() + 1)
    }

    // Update state with processed data
    setPageViews(pageViewsArray)
    setEventCounts(eventsArray)
    setDailyStats(dailyStatsArray)
    setTotalPageViews(pageViewCount)
    setTotalNewsReads(newsReadCount)
    setTotalVideoPlays(videoPlayCount)
  }

  const formatDate = (dateString: string) => {
    const date = new Date(dateString)
    return date.toLocaleDateString("pt-BR", { day: "2-digit", month: "2-digit" })
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="flex justify-between items-center">
            <div>
              <CardTitle>Analytics do Site</CardTitle>
              <CardDescription>Métricas e estatísticas de uso</CardDescription>
            </div>
            <div>
              <select
                value={timeRange}
                onChange={(e) => setTimeRange(e.target.value)}
                className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
              >
                <option value="7d">Últimos 7 dias</option>
                <option value="30d">Últimos 30 dias</option>
                <option value="90d">Últimos 90 dias</option>
              </select>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
            <TabsList className="grid grid-cols-3 mb-6">
              <TabsTrigger value="overview">Visão Geral</TabsTrigger>
              <TabsTrigger value="pages">Páginas</TabsTrigger>
              <TabsTrigger value="events">Eventos</TabsTrigger>
            </TabsList>

            <TabsContent value="overview">
              {loading ? (
                <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
                  {Array.from({ length: 3 }).map((_, i) => (
                    <div key={i} className="animate-pulse bg-gray-200 dark:bg-gray-700 h-32 rounded-lg"></div>
                  ))}
                </div>
              ) : (
                <>
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-8">
                    <Card>
                      <CardContent className="pt-6">
                        <div className="flex items-center gap-4">
                          <div className="p-2 bg-blue-100 dark:bg-blue-900 rounded-full">
                            <Eye className="h-6 w-6 text-blue-600 dark:text-blue-400" />
                          </div>
                          <div>
                            <p className="text-sm text-gray-500 dark:text-gray-400">Visualizações de Página</p>
                            <h3 className="text-2xl font-bold">{totalPageViews}</h3>
                          </div>
                        </div>
                      </CardContent>
                    </Card>

                    <Card>
                      <CardContent className="pt-6">
                        <div className="flex items-center gap-4">
                          <div className="p-2 bg-yellow-100 dark:bg-yellow-900 rounded-full">
                            <FileText className="h-6 w-6 text-yellow-600 dark:text-yellow-400" />
                          </div>
                          <div>
                            <p className="text-sm text-gray-500 dark:text-gray-400">Notícias Lidas</p>
                            <h3 className="text-2xl font-bold">{totalNewsReads}</h3>
                          </div>
                        </div>
                      </CardContent>
                    </Card>

                    <Card>
                      <CardContent className="pt-6">
                        <div className="flex items-center gap-4">
                          <div className="p-2 bg-green-100 dark:bg-green-900 rounded-full">
                            <Users className="h-6 w-6 text-green-600 dark:text-green-400" />
                          </div>
                          <div>
                            <p className="text-sm text-gray-500 dark:text-gray-400">Vídeos Assistidos</p>
                            <h3 className="text-2xl font-bold">{totalVideoPlays}</h3>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  </div>

                  <Card className="mb-8">
                    <CardHeader>
                      <CardTitle>Atividade Diária</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <ChartContainer
                        config={{
                          pageViews: {
                            label: "Visualizações",
                            color: "hsl(var(--chart-1))",
                          },
                          newsReads: {
                            label: "Notícias",
                            color: "hsl(var(--chart-2))",
                          },
                          videoPlays: {
                            label: "Vídeos",
                            color: "hsl(var(--chart-3))",
                          },
                        }}
                        className="h-[300px]"
                      >
                        <ResponsiveContainer width="100%" height="100%">
                          <LineChart data={dailyStats}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="date" tickFormatter={formatDate} />
                            <YAxis />
                            <ChartTooltip content={<ChartTooltipContent />} />
                            <Legend />
                            <Line
                              type="monotone"
                              dataKey="pageViews"
                              stroke="var(--color-pageViews)"
                              name="Visualizações"
                              strokeWidth={2}
                            />
                            <Line
                              type="monotone"
                              dataKey="newsReads"
                              stroke="var(--color-newsReads)"
                              name="Notícias"
                              strokeWidth={2}
                            />
                            <Line
                              type="monotone"
                              dataKey="videoPlays"
                              stroke="var(--color-videoPlays)"
                              name="Vídeos"
                              strokeWidth={2}
                            />
                          </LineChart>
                        </ResponsiveContainer>
                      </ChartContainer>
                    </CardContent>
                  </Card>
                </>
              )}
            </TabsContent>

            <TabsContent value="pages">
              {loading ? (
                <div className="animate-pulse bg-gray-200 dark:bg-gray-700 h-96 rounded-lg"></div>
              ) : (
                <Card>
                  <CardHeader>
                    <CardTitle>Páginas Mais Visitadas</CardTitle>
                  </CardHeader>
                  <CardContent>
                    <div className="h-[400px]">
                      <ResponsiveContainer width="100%" height="100%">
                        <BarChart
                          data={pageViews}
                          layout="vertical"
                          margin={{ top: 5, right: 30, left: 100, bottom: 5 }}
                        >
                          <CartesianGrid strokeDasharray="3 3" />
                          <XAxis type="number" />
                          <YAxis type="category" dataKey="url" width={100} tick={{ fontSize: 12 }} />
                          <Tooltip
                            formatter={(value) => [`${value} visualizações`, "Contagem"]}
                            labelFormatter={(label) => `Página: ${label}`}
                          />
                          <Bar dataKey="count" fill="#1D4ED8" name="Visualizações">
                            {pageViews.map((entry, index) => (
                              <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                            ))}
                          </Bar>
                        </BarChart>
                      </ResponsiveContainer>
                    </div>
                  </CardContent>
                </Card>
              )}
            </TabsContent>

            <TabsContent value="events">
              {loading ? (
                <div className="animate-pulse bg-gray-200 dark:bg-gray-700 h-96 rounded-lg"></div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <Card>
                    <CardHeader>
                      <CardTitle>Distribuição de Eventos</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="h-[300px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <PieChart>
                            <Pie
                              data={eventCounts}
                              cx="50%"
                              cy="50%"
                              labelLine={false}
                              outerRadius={100}
                              fill="#8884d8"
                              dataKey="count"
                              nameKey="event"
                              label={({ name, percent }) => `${name}: ${(percent * 100).toFixed(0)}%`}
                            >
                              {eventCounts.map((entry, index) => (
                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                              ))}
                            </Pie>
                            <Tooltip
                              formatter={(value) => [`${value} eventos`, "Contagem"]}
                              labelFormatter={(label) => `Tipo: ${label}`}
                            />
                            <Legend />
                          </PieChart>
                        </ResponsiveContainer>
                      </div>
                    </CardContent>
                  </Card>

                  <Card>
                    <CardHeader>
                      <CardTitle>Contagem de Eventos</CardTitle>
                    </CardHeader>
                    <CardContent>
                      <div className="h-[300px]">
                        <ResponsiveContainer width="100%" height="100%">
                          <BarChart data={eventCounts} margin={{ top: 5, right: 30, left: 20, bottom: 5 }}>
                            <CartesianGrid strokeDasharray="3 3" />
                            <XAxis dataKey="event" />
                            <YAxis />
                            <Tooltip
                              formatter={(value) => [`${value} eventos`, "Contagem"]}
                              labelFormatter={(label) => `Tipo: ${label}`}
                            />
                            <Bar dataKey="count" name="Eventos">
                              {eventCounts.map((entry, index) => (
                                <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                              ))}
                            </Bar>
                          </BarChart>
                        </ResponsiveContainer>
                      </div>
                    </CardContent>
                  </Card>
                </div>
              )}
            </TabsContent>
          </Tabs>
        </CardContent>
      </Card>
    </div>
  )
}
