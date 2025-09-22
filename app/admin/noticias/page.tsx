"use client"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Input } from "@/components/ui/input"
import { Plus, Search, Edit, Trash2, Eye, Send } from "lucide-react"
import { toast } from "sonner"
import NoticiaForm from "@/components/admin/NoticiaForm"
import { supabase, type Noticia } from "@/lib/supabase"

export default function AdminNoticiasPage() {
  const [noticias, setNoticias] = useState<Noticia[]>([])
  const [filteredNoticias, setFilteredNoticias] = useState<Noticia[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const [showForm, setShowForm] = useState(false)
  const [editingNoticia, setEditingNoticia] = useState<Noticia | null>(null)

  useEffect(() => {
    fetchNoticias()
  }, [])

  useEffect(() => {
    if (searchQuery) {
      const filtered = noticias.filter(
        (noticia) =>
          noticia.titulo.toLowerCase().includes(searchQuery.toLowerCase()) ||
          noticia.autor.toLowerCase().includes(searchQuery.toLowerCase()) ||
          noticia.tags?.some((tag) => tag.toLowerCase().includes(searchQuery.toLowerCase())),
      )
      setFilteredNoticias(filtered)
    } else {
      setFilteredNoticias(noticias)
    }
  }, [searchQuery, noticias])

  const fetchNoticias = async () => {
    try {
      const { data, error } = await supabase.from("noticias").select("*").order("created_at", { ascending: false })

      if (error) throw error

      setNoticias(data || [])
      setFilteredNoticias(data || [])
    } catch (error) {
      console.error("Erro ao buscar notícias:", error)
      toast.error("Erro ao carregar notícias")
    } finally {
      setLoading(false)
    }
  }

  const handleDelete = async (id: string) => {
    if (!confirm("Tem certeza que deseja deletar esta notícia?")) return

    try {
      const response = await fetch(`/api/noticias/${id}`, {
        method: "DELETE",
      })

      if (!response.ok) {
        throw new Error("Erro ao deletar notícia")
      }

      toast.success("Notícia deletada com sucesso!")
      fetchNoticias()
    } catch (error) {
      console.error("Erro:", error)
      toast.error("Erro ao deletar notícia")
    }
  }

  const handlePublishNow = async (noticia: Noticia) => {
    if (noticia.data_publicacao) {
      toast.info("Esta notícia já foi publicada")
      return
    }

    try {
      const response = await fetch(`/api/noticias/${noticia.id}`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...noticia,
          publicar_agora: true,
        }),
      })

      const result = await response.json()

      if (!response.ok) {
        throw new Error(result.error || "Erro ao publicar notícia")
      }

      toast.success("Notícia publicada e notificações enviadas!")
      fetchNoticias()
    } catch (error) {
      console.error("Erro:", error)
      toast.error("Erro ao publicar notícia")
    }
  }

  const handleFormSuccess = () => {
    setShowForm(false)
    setEditingNoticia(null)
    fetchNoticias()
  }

  if (showForm) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="mb-6">
          <Button
            onClick={() => {
              setShowForm(false)
              setEditingNoticia(null)
            }}
            variant="outline"
          >
            ← Voltar
          </Button>
        </div>
        <NoticiaForm noticia={editingNoticia} onSuccess={handleFormSuccess} />
      </div>
    )
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold">Gerenciar Notícias</h1>
          <p className="text-gray-600 mt-2">
            Crie, edite e publique notícias. As notificações são enviadas automaticamente.
          </p>
        </div>
        <Button onClick={() => setShowForm(true)} className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Nova Notícia
        </Button>
      </div>

      {/* Busca */}
      <div className="mb-6">
        <div className="relative">
          <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-4 h-4" />
          <Input
            placeholder="Buscar notícias..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="pl-10"
          />
        </div>
      </div>

      {/* Lista de Notícias */}
      {loading ? (
        <div className="text-center py-8">Carregando...</div>
      ) : (
        <div className="grid gap-6">
          {filteredNoticias.map((noticia) => (
            <Card key={noticia.id}>
              <CardHeader>
                <div className="flex justify-between items-start">
                  <div className="flex-1">
                    <CardTitle className="text-xl mb-2">{noticia.titulo}</CardTitle>
                    <div className="flex items-center gap-4 text-sm text-gray-600">
                      <span>Por: {noticia.autor}</span>
                      <span>
                        {noticia.data_publicacao
                          ? `Publicado em ${new Date(noticia.data_publicacao).toLocaleDateString("pt-BR")}`
                          : "Rascunho"}
                      </span>
                    </div>
                  </div>
                  <div className="flex items-center gap-2">
                    {noticia.data_publicacao ? (
                      <Badge className="bg-green-100 text-green-800">Publicada</Badge>
                    ) : (
                      <Badge variant="secondary">Rascunho</Badge>
                    )}
                  </div>
                </div>
              </CardHeader>

              <CardContent>
                <p className="text-gray-600 mb-4 line-clamp-2">{noticia.conteudo.substring(0, 200)}...</p>

                {noticia.tags && noticia.tags.length > 0 && (
                  <div className="flex flex-wrap gap-2 mb-4">
                    {noticia.tags.map((tag) => (
                      <Badge key={tag} variant="outline" className="text-xs">
                        {tag}
                      </Badge>
                    ))}
                  </div>
                )}

                <div className="flex gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => window.open(`/noticias/${noticia.id}`, "_blank")}
                    className="flex items-center gap-1"
                  >
                    <Eye className="w-4 h-4" />
                    Ver
                  </Button>

                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => {
                      setEditingNoticia(noticia)
                      setShowForm(true)
                    }}
                    className="flex items-center gap-1"
                  >
                    <Edit className="w-4 h-4" />
                    Editar
                  </Button>

                  {!noticia.data_publicacao && (
                    <Button
                      size="sm"
                      onClick={() => handlePublishNow(noticia)}
                      className="flex items-center gap-1 bg-green-600 hover:bg-green-700"
                    >
                      <Send className="w-4 h-4" />
                      Publicar e Notificar
                    </Button>
                  )}

                  <Button
                    size="sm"
                    variant="destructive"
                    onClick={() => handleDelete(noticia.id)}
                    className="flex items-center gap-1"
                  >
                    <Trash2 className="w-4 h-4" />
                    Deletar
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}

          {filteredNoticias.length === 0 && (
            <div className="text-center py-8 text-gray-500">
              {searchQuery ? "Nenhuma notícia encontrada" : "Nenhuma notícia cadastrada"}
            </div>
          )}
        </div>
      )}
    </div>
  )
}
