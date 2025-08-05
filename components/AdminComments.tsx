"use client"

import { useState, useEffect } from "react"
import { supabaseBypass } from "@/lib/supabase"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Check, X, AlertTriangle } from "lucide-react"
import { Badge } from "@/components/ui/badge"

interface Comment {
  id: string
  noticia_id: string
  nome: string
  email: string
  comentario: string
  aprovado: boolean
  created_at: string
  noticia_titulo?: string
}

interface AdminCommentsProps {
  onApprove?: () => void
}

export default function AdminComments({ onApprove }: AdminCommentsProps) {
  const [pendingComments, setPendingComments] = useState<Comment[]>([])
  const [approvedComments, setApprovedComments] = useState<Comment[]>([])
  const [loading, setLoading] = useState(true)
  const [activeTab, setActiveTab] = useState("pendentes")

  useEffect(() => {
    fetchComments()
  }, [activeTab])

  const fetchComments = async () => {
    setLoading(true)

    try {
      // Determine if we want pending (false) or approved (true) comments
      const aprovado = activeTab === "aprovados"

      console.log("Fetching comments for tab:", activeTab, "aprovado:", aprovado)

      // Fetch comments with join to get noticia title
      const { data: comments, error } = await supabaseBypass
        .from("comentarios")
        .select(`
          *,
          noticias (
            titulo
          )
        `)
        .eq("aprovado", aprovado)
        .order("created_at", { ascending: false })

      if (error) {
        console.error("Error fetching comments:", error)
        return
      }

      console.log("Fetched comments:", comments?.length || 0)

      // Transform data to include noticia_titulo
      const formattedComments =
        comments?.map((comment) => ({
          ...comment,
          noticia_titulo: (comment as any).noticias?.titulo,
        })) || []

      if (activeTab === "pendentes") {
        setPendingComments(formattedComments)
      } else {
        setApprovedComments(formattedComments)
      }
    } catch (error) {
      console.error("Error:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleApprove = async (id: string) => {
    const { error } = await supabaseBypass.from("comentarios").update({ aprovado: true }).eq("id", id)

    if (!error) {
      setPendingComments(pendingComments.filter((comment) => comment.id !== id))
      if (onApprove) onApprove()
      alert("Comentário aprovado com sucesso!")
    } else {
      alert("Erro ao aprovar comentário: " + error.message)
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm("Tem certeza que deseja excluir este comentário?")) return

    const { error } = await supabaseBypass.from("comentarios").delete().eq("id", id)

    if (!error) {
      setPendingComments(pendingComments.filter((comment) => comment.id !== id))
      setApprovedComments(approvedComments.filter((comment) => comment.id !== id))
      if (onApprove) onApprove()
      alert("Comentário excluído com sucesso!")
    } else {
      alert("Erro ao excluir comentário: " + error.message)
    }
  }

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Gerenciamento de Comentários</CardTitle>
        <CardDescription>Aprove ou rejeite comentários dos usuários</CardDescription>
      </CardHeader>
      <CardContent>
        <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
          <TabsList className="grid grid-cols-2 mb-6">
            <TabsTrigger value="pendentes" className="flex items-center gap-2">
              <AlertTriangle className="h-4 w-4" />
              <span>Pendentes</span>
              {pendingComments.length > 0 && <Badge variant="destructive">{pendingComments.length}</Badge>}
            </TabsTrigger>
            <TabsTrigger value="aprovados">
              <Check className="h-4 w-4 mr-2" />
              <span>Aprovados</span>
            </TabsTrigger>
          </TabsList>

          <TabsContent value="pendentes">
            {loading ? (
              <div className="space-y-4">
                {Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} className="animate-pulse">
                    <div className="h-4 bg-gray-300 dark:bg-gray-600 rounded w-1/4 mb-2"></div>
                    <div className="h-16 bg-gray-300 dark:bg-gray-600 rounded"></div>
                  </div>
                ))}
              </div>
            ) : pendingComments.length === 0 ? (
              <div className="text-center py-8 text-gray-500 dark:text-gray-400">
                Não há comentários pendentes de aprovação.
              </div>
            ) : (
              <div className="space-y-4">
                {pendingComments.map((comment) => (
                  <div key={comment.id} className="border border-gray-200 dark:border-gray-700 rounded-lg p-4">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h3 className="font-medium text-gray-900 dark:text-gray-100">{comment.nome}</h3>
                        <p className="text-sm text-gray-500 dark:text-gray-400">{comment.email}</p>
                      </div>
                      <div className="text-sm text-gray-500 dark:text-gray-400">{formatDate(comment.created_at)}</div>
                    </div>

                    <div className="mb-3">
                      <Badge variant="outline" className="mb-2">
                        Notícia: {comment.noticia_titulo || "Desconhecida"}
                      </Badge>
                      <p className="text-gray-700 dark:text-gray-300 bg-gray-50 dark:bg-gray-800 p-3 rounded-md">
                        {comment.comentario}
                      </p>
                    </div>

                    <div className="flex gap-2 justify-end">
                      <button
                        onClick={() => handleApprove(comment.id)}
                        className="flex items-center gap-1 bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded-md text-sm transition-colors"
                      >
                        <Check className="h-4 w-4" />
                        Aprovar
                      </button>
                      <button
                        onClick={() => handleDelete(comment.id)}
                        className="flex items-center gap-1 bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded-md text-sm transition-colors"
                      >
                        <X className="h-4 w-4" />
                        Excluir
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </TabsContent>

          <TabsContent value="aprovados">
            {loading ? (
              <div className="space-y-4">
                {Array.from({ length: 3 }).map((_, i) => (
                  <div key={i} className="animate-pulse">
                    <div className="h-4 bg-gray-300 dark:bg-gray-600 rounded w-1/4 mb-2"></div>
                    <div className="h-16 bg-gray-300 dark:bg-gray-600 rounded"></div>
                  </div>
                ))}
              </div>
            ) : approvedComments.length === 0 ? (
              <div className="text-center py-8 text-gray-500 dark:text-gray-400">Não há comentários aprovados.</div>
            ) : (
              <div className="space-y-4">
                {approvedComments.map((comment) => (
                  <div key={comment.id} className="border border-gray-200 dark:border-gray-700 rounded-lg p-4">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <h3 className="font-medium text-gray-900 dark:text-gray-100">{comment.nome}</h3>
                        <p className="text-sm text-gray-500 dark:text-gray-400">{comment.email}</p>
                      </div>
                      <div className="text-sm text-gray-500 dark:text-gray-400">{formatDate(comment.created_at)}</div>
                    </div>

                    <div className="mb-3">
                      <Badge variant="outline" className="mb-2">
                        Notícia: {comment.noticia_titulo || "Desconhecida"}
                      </Badge>
                      <p className="text-gray-700 dark:text-gray-300 bg-gray-50 dark:bg-gray-800 p-3 rounded-md">
                        {comment.comentario}
                      </p>
                    </div>

                    <div className="flex gap-2 justify-end">
                      <button
                        onClick={() => handleDelete(comment.id)}
                        className="flex items-center gap-1 bg-red-500 hover:bg-red-600 text-white px-3 py-1 rounded-md text-sm transition-colors"
                      >
                        <X className="h-4 w-4" />
                        Excluir
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </TabsContent>
        </Tabs>
      </CardContent>
    </Card>
  )
}
