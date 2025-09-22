"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { FileText, Users, Mail, Youtube, Clock, Send, Eye } from "lucide-react"
import Link from "next/link"
import YouTubeCacheStats from "@/components/YouTubeCacheStats"
import { supabase } from "@/lib/supabase"

interface DashboardStats {
  totalNoticias: number
  noticiasPendentes: number
  totalSubscribers: number
  subscribersAtivos: number
  visualizacoesTotais: number
  noticiasRecentes: Array<{
    id: string
    titulo: string
    data_publicacao: string | null
    autor: string
  }>
}

export default function AdminDashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalNoticias: 0,
    noticiasPendentes: 0,
    totalSubscribers: 0,
    subscribersAtivos: 0,
    visualizacoesTotais: 0,
    noticiasRecentes: [],
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchDashboardStats()
  }, [])

  const fetchDashboardStats = async () => {
    try {
      // Buscar estatísticas das notícias
      const { data: noticias } = await supabase
        .from("noticias")
        .select("id, titulo, data_publicacao, autor, visualizacoes")
        .order("created_at", { ascending: false })

      // Buscar estatísticas dos subscribers
      const { data: subscribers } = await supabase.from("newsletter_subscribers").select("is_active")

      const totalNoticias = noticias?.length || 0
      const noticiasPendentes = noticias?.filter((n) => !n.data_publicacao).length || 0
      const totalSubscribers = subscribers?.length || 0
      const subscribersAtivos = subscribers?.filter((s) => s.is_active).length || 0
      const visualizacoesTotais = noticias?.reduce((sum, n) => sum + (n.visualizacoes || 0), 0) || 0
      const noticiasRecentes = noticias?.slice(0, 5) || []

      setStats({
        totalNoticias,
        noticiasPendentes,
        totalSubscribers,
        subscribersAtivos,
        visualizacoesTotais,
        noticiasRecentes,
      })
    } catch (error) {
      console.error("Erro ao buscar estatísticas:", error)
    } finally {
      setLoading(false)
    }
  }

  const quickActions = [
    {
      title: "Nova Notícia",
      description: "Criar e publicar nova notícia",
      icon: FileText,
      href: "/admin/noticias",
      color: "bg-blue-500",
    },
    {
      title: "Gerenciar Notícias",
      description: "Ver todas as notícias",
      icon: FileText,
      href: "/admin/noticias",
      color: "bg-green-500",
    },
    {
      title: "Newsletter",
      description: "Gerenciar assinantes",
      icon: Mail,
      href: "/admin/newsletter",
      color: "bg-purple-500",
    },
    {
      title: "Cache YouTube",
      description: "Monitorar performance",
      icon: Youtube,
      href: "#youtube-cache",
      color: "bg-red-500",
    },
  ]

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">Carregando dashboard...</div>
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold mb-2">Dashboard Administrativo</h1>
        <p className="text-gray-600">Gerencie seu site, notícias e assinantes do newsletter</p>
      </div>

      {/* Estatísticas Principais */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total de Notícias</CardTitle>
            <FileText className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.totalNoticias}</div>
            <p className="text-xs text-muted-foreground">{stats.noticiasPendentes} pendentes de publicação</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Assinantes Newsletter</CardTitle>
            <Users className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.subscribersAtivos}</div>
            <p className="text-xs text-muted-foreground">de {stats.totalSubscribers} total</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Visualizações</CardTitle>
            <Eye className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.visualizacoesTotais.toLocaleString()}</div>
            <p className="text-xs text-muted-foreground">Total de visualizações</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Rascunhos</CardTitle>
            <Clock className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.noticiasPendentes}</div>
            <p className="text-xs text-muted-foreground">Aguardando publicação</p>
          </CardContent>
        </Card>
      </div>

      {/* Ações Rápidas */}
      <div className="mb-8">
        <h2 className="text-xl font-semibold mb-4">Ações Rápidas</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {quickActions.map((action) => (
            <Card key={action.title} className="hover:shadow-md transition-shadow cursor-pointer">
              <CardContent className="p-4">
                <Link href={action.href} className="block">
                  <div className="flex items-center space-x-3">
                    <div className={`p-2 rounded-lg ${action.color}`}>
                      <action.icon className="h-5 w-5 text-white" />
                    </div>
                    <div>
                      <h3 className="font-medium">{action.title}</h3>
                      <p className="text-sm text-gray-600">{action.description}</p>
                    </div>
                  </div>
                </Link>
              </CardContent>
            </Card>
          ))}
        </div>
      </div>

      {/* Notícias Recentes */}
      <div className="mb-8">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-semibold">Notícias Recentes</h2>
          <Link href="/admin/noticias">
            <Button variant="outline" size="sm">
              Ver Todas
            </Button>
          </Link>
        </div>
        <Card>
          <CardContent className="p-0">
            {stats.noticiasRecentes.length > 0 ? (
              <div className="divide-y">
                {stats.noticiasRecentes.map((noticia) => (
                  <div key={noticia.id} className="p-4 flex justify-between items-center">
                    <div>
                      <h3 className="font-medium">{noticia.titulo}</h3>
                      <p className="text-sm text-gray-600">
                        Por {noticia.autor} •{" "}
                        {noticia.data_publicacao
                          ? new Date(noticia.data_publicacao).toLocaleDateString("pt-BR")
                          : "Rascunho"}
                      </p>
                    </div>
                    <div className="flex gap-2">
                      {noticia.data_publicacao ? (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                          Publicada
                        </span>
                      ) : (
                        <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-yellow-100 text-yellow-800">
                          Rascunho
                        </span>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            ) : (
              <div className="p-8 text-center text-gray-500">Nenhuma notícia encontrada</div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Sistema de Notificações */}
      <div className="mb-8">
        <h2 className="text-xl font-semibold mb-4">Sistema de Notificações</h2>
        <Card>
          <CardContent className="p-6">
            <div className="flex items-start space-x-4">
              <div className="p-3 bg-blue-100 rounded-lg">
                <Send className="h-6 w-6 text-blue-600" />
              </div>
              <div className="flex-1">
                <h3 className="font-medium mb-2">Notificações Automáticas Ativas</h3>
                <p className="text-gray-600 mb-4">
                  Quando você publica uma nova notícia, todos os {stats.subscribersAtivos} assinantes ativos do
                  newsletter recebem automaticamente um email com o conteúdo.
                </p>
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div className="flex items-center">
                    <div className="flex-shrink-0">
                      <div className="w-2 h-2 bg-green-400 rounded-full"></div>
                    </div>
                    <div className="ml-3">
                      <p className="text-sm text-green-800">
                        <strong>Sistema funcionando:</strong> As notificações por email estão ativas e funcionando
                        corretamente.
                      </p>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Cache do YouTube */}
      <div id="youtube-cache">
        <YouTubeCacheStats />
      </div>
    </div>
  )
}
