"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { X, Plus, Send, Save } from "lucide-react"
import { toast } from "sonner"

interface NoticiaFormProps {
  noticia?: {
    id?: string
    titulo: string
    conteudo: string
    autor: string
    imagem_opcional?: string
    tags?: string[]
    data_publicacao?: string
  }
  onSuccess?: () => void
}

export default function NoticiaForm({ noticia, onSuccess }: NoticiaFormProps) {
  const [formData, setFormData] = useState({
    titulo: noticia?.titulo || "",
    conteudo: noticia?.conteudo || "",
    autor: noticia?.autor || "",
    imagem_opcional: noticia?.imagem_opcional || "",
    tags: noticia?.tags || [],
  })

  const [newTag, setNewTag] = useState("")
  const [loading, setLoading] = useState(false)
  const [publishLoading, setPublishLoading] = useState(false)

  const isEditing = !!noticia?.id
  const isPublished = !!noticia?.data_publicacao

  const handleInputChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  const addTag = () => {
    if (newTag.trim() && !formData.tags.includes(newTag.trim())) {
      setFormData((prev) => ({
        ...prev,
        tags: [...prev.tags, newTag.trim()],
      }))
      setNewTag("")
    }
  }

  const removeTag = (tagToRemove: string) => {
    setFormData((prev) => ({
      ...prev,
      tags: prev.tags.filter((tag) => tag !== tagToRemove),
    }))
  }

  const handleSubmit = async (publicar = false) => {
    if (!formData.titulo || !formData.conteudo || !formData.autor) {
      toast.error("Preencha todos os campos obrigatórios")
      return
    }

    const loadingSetter = publicar ? setPublishLoading : setLoading
    loadingSetter(true)

    try {
      const url = isEditing ? `/api/noticias/${noticia.id}` : "/api/noticias"
      const method = isEditing ? "PUT" : "POST"

      const payload = {
        ...formData,
        ...(publicar && { publicar_agora: true }),
      }

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
      })

      const result = await response.json()

      if (!response.ok) {
        throw new Error(result.error || "Erro ao salvar notícia")
      }

      toast.success(result.message || "Notícia salva com sucesso!")
      onSuccess?.()
    } catch (error) {
      console.error("Erro:", error)
      toast.error(error instanceof Error ? error.message : "Erro ao salvar notícia")
    } finally {
      loadingSetter(false)
    }
  }

  return (
    <Card className="w-full max-w-4xl mx-auto">
      <CardHeader>
        <CardTitle className="flex items-center gap-2">
          {isEditing ? "Editar Notícia" : "Nova Notícia"}
          {isPublished && (
            <Badge variant="secondary" className="bg-green-100 text-green-800">
              Publicada
            </Badge>
          )}
        </CardTitle>
      </CardHeader>

      <CardContent className="space-y-6">
        {/* Título */}
        <div className="space-y-2">
          <label className="text-sm font-medium">Título *</label>
          <Input
            value={formData.titulo}
            onChange={(e) => handleInputChange("titulo", e.target.value)}
            placeholder="Digite o título da notícia..."
            className="w-full"
          />
        </div>

        {/* Autor */}
        <div className="space-y-2">
          <label className="text-sm font-medium">Autor *</label>
          <Input
            value={formData.autor}
            onChange={(e) => handleInputChange("autor", e.target.value)}
            placeholder="Nome do autor..."
            className="w-full"
          />
        </div>

        {/* Imagem */}
        <div className="space-y-2">
          <label className="text-sm font-medium">URL da Imagem</label>
          <Input
            value={formData.imagem_opcional}
            onChange={(e) => handleInputChange("imagem_opcional", e.target.value)}
            placeholder="https://exemplo.com/imagem.jpg"
            className="w-full"
          />
        </div>

        {/* Tags */}
        <div className="space-y-2">
          <label className="text-sm font-medium">Tags</label>
          <div className="flex gap-2 mb-2">
            <Input
              value={newTag}
              onChange={(e) => setNewTag(e.target.value)}
              placeholder="Digite uma tag..."
              className="flex-1"
              onKeyPress={(e) => e.key === "Enter" && (e.preventDefault(), addTag())}
            />
            <Button type="button" onClick={addTag} size="sm">
              <Plus className="w-4 h-4" />
            </Button>
          </div>
          <div className="flex flex-wrap gap-2">
            {formData.tags.map((tag) => (
              <Badge key={tag} variant="secondary" className="flex items-center gap-1">
                {tag}
                <X className="w-3 h-3 cursor-pointer hover:text-red-500" onClick={() => removeTag(tag)} />
              </Badge>
            ))}
          </div>
        </div>

        {/* Conteúdo */}
        <div className="space-y-2">
          <label className="text-sm font-medium">Conteúdo *</label>
          <Textarea
            value={formData.conteudo}
            onChange={(e) => handleInputChange("conteudo", e.target.value)}
            placeholder="Escreva o conteúdo da notícia..."
            className="min-h-[300px] w-full"
          />
        </div>

        {/* Botões */}
        <div className="flex gap-3 pt-4">
          <Button
            onClick={() => handleSubmit(false)}
            disabled={loading || publishLoading}
            variant="outline"
            className="flex items-center gap-2"
          >
            <Save className="w-4 h-4" />
            {loading ? "Salvando..." : "Salvar Rascunho"}
          </Button>

          {(!isPublished || isEditing) && (
            <Button
              onClick={() => handleSubmit(true)}
              disabled={loading || publishLoading}
              className="flex items-center gap-2 bg-green-600 hover:bg-green-700"
            >
              <Send className="w-4 h-4" />
              {publishLoading ? "Publicando..." : isEditing ? "Publicar Agora" : "Publicar e Notificar"}
            </Button>
          )}
        </div>

        {/* Aviso sobre notificações */}
        {!isPublished && (
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
            <p className="text-sm text-blue-800">
              <strong>📧 Notificações automáticas:</strong> Quando você publicar esta notícia, todos os assinantes do
              newsletter receberão um email automaticamente com o conteúdo.
            </p>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
