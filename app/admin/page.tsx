"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { supabase, type Noticia } from "@/lib/supabase"
import type { User } from "@supabase/supabase-js"
import TagInput from "@/components/TagInput"
import { useForm } from "react-hook-form"
import { z } from "zod"
import { zodResolver } from "@hookform/resolvers/zod"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { BarChart3, MessageSquare, FileText } from "lucide-react"
import AdminComments from "@/components/AdminComments"
import YouTubeCacheStats from "@/components/YouTubeCacheStats"

const noticiaSchema = z.object({
  titulo: z.string().min(1, "Título é obrigatório").max(200, "Título muito longo"),
  conteudo: z.string().min(1, "Conteúdo é obrigatório"),
  imagem_opcional: z.string().url("URL inválida").optional().or(z.literal("")),
})

type NoticiaFormData = z.infer<typeof noticiaSchema>

export default function AdminPage() {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [noticias, setNoticias] = useState<Noticia[]>([])
  const [showForm, setShowForm] = useState(false)
  const [editingNoticia, setEditingNoticia] = useState<Noticia | null>(null)
  const [tags, setTags] = useState<string[]>([])
  const [activeTab, setActiveTab] = useState("noticias")
  const [pendingCommentsCount, setPendingCommentsCount] = useState(0)

  const {
    register,
    handleSubmit,
    reset,
    formState: { errors, isSubmitting },
  } = useForm<NoticiaFormData>({
    resolver: zodResolver(noticiaSchema),
  })

  // Auth
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [authLoading, setAuthLoading] = useState(false)

  useEffect(() => {
    checkUser()

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event, session) => {
      setUser(session?.user ?? null)
      setLoading(false)
    })

    return () => subscription.unsubscribe()
  }, [])

  useEffect(() => {
    if (user) {
      fetchNoticias()
      fetchPendingCommentsCount()
    }
  }, [user])

  const checkUser = async () => {
    const {
      data: { user },
    } = await supabase.auth.getUser()
    setUser(user)
    setLoading(false)
  }

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    setAuthLoading(true)

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      alert("Erro no login: " + error.message)
    }

    setAuthLoading(false)
  }

  const handleLogout = async () => {
    await supabase.auth.signOut()
  }

  const fetchNoticias = async () => {
    const { data, error } = await supabase.from("noticias").select("*").order("data_publicacao", { ascending: false })

    if (error) {
      console.error("Error fetching noticias:", error)
    } else {
      setNoticias(data || [])
    }
  }

  const fetchPendingCommentsCount = async () => {
    const { count, error } = await supabase
      .from("comentarios")
      .select("*", { count: "exact", head: true })
      .eq("aprovado", false)

    if (!error && count !== null) {
      setPendingCommentsCount(count)
    }
  }

  const onSubmit = async (data: NoticiaFormData) => {
    const formData = {
      ...data,
      tags: tags.length > 0 ? tags : null,
      imagem_opcional: data.imagem_opcional || null,
    }

    if (editingNoticia) {
      const { error } = await supabase
        .from("noticias")
        .update({
          ...formData,
          updated_by: user?.id,
        })
        .eq("id", editingNoticia.id)

      if (error) {
        alert("Erro ao atualizar notícia: " + error.message)
      } else {
        alert("Notícia atualizada com sucesso!")
        resetForm()
        fetchNoticias()
      }
    } else {
      const { error } = await supabase.from("noticias").insert([
        {
          ...formData,
          created_by: user?.id,
        },
      ])

      if (error) {
        alert("Erro ao criar notícia: " + error.message)
      } else {
        alert("Notícia criada com sucesso!")
        resetForm()
        fetchNoticias()
      }
    }
  }

  const handleEdit = (noticia: Noticia) => {
    setEditingNoticia(noticia)
    reset({
      titulo: noticia.titulo,
      conteudo: noticia.conteudo,
      imagem_opcional: noticia.imagem_opcional || "",
    })
    setTags(noticia.tags || [])
    setShowForm(true)
  }

  const handleDelete = async (id: string) => {
    if (confirm("Tem certeza que deseja excluir esta notícia?")) {
      const { error } = await supabase.from("noticias").delete().eq("id", id)

      if (error) {
        alert("Erro ao excluir notícia: " + error.message)
      } else {
        alert("Notícia excluída com sucesso!")
        fetchNoticias()
      }
    }
  }

  const resetForm = () => {
    reset()
    setTags([])
    setEditingNoticia(null)
    setShowForm(false)
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-t-2 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!user) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-lg shadow-md p-8">
          <h1 className="text-2xl font-bold text-blue-900 dark:text-blue-100 mb-6 text-center">
            Painel Administrativo
          </h1>

          <form onSubmit={handleLogin} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Email</label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Senha</label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                required
              />
            </div>

            <button
              type="submit"
              disabled={authLoading}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2 px-4 rounded-md transition-colors disabled:opacity-50"
            >
              {authLoading ? "Entrando..." : "Entrar"}
            </button>
          </form>
        </div>
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="flex justify-between items-center mb-8">
        <h1 className="text-3xl font-bold text-blue-900 dark:text-blue-100">Painel Administrativo</h1>
        <button
          onClick={handleLogout}
          className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md transition-colors"
        >
          Sair
        </button>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid grid-cols-3 mb-8">
          <TabsTrigger value="noticias" className="flex items-center gap-2">
            <FileText className="h-4 w-4" />
            <span>Notícias</span>
          </TabsTrigger>
          {/* <TabsTrigger value="comentarios" className="flex items-center gap-2">
            <MessageSquare className="h-4 w-4" />
            <span>Comentários</span>
            {pendingCommentsCount > 0 && (
              <Badge variant="destructive" className="ml-1">
                {pendingCommentsCount}
              </Badge>
            )}
          </TabsTrigger> */}
          <TabsTrigger value="youtube" className="flex items-center gap-2">
            <MessageSquare className="h-4 w-4" />
            <span>Youtube Cache</span>
          </TabsTrigger>
        </TabsList>

        <TabsContent value="noticias">
          <div className="mb-8">
            <button
              onClick={() => setShowForm(!showForm)}
              className="bg-yellow-400 hover:bg-yellow-500 dark:bg-yellow-500 dark:hover:bg-yellow-600 text-yellow-900 dark:text-yellow-100 font-semibold px-6 py-3 rounded-lg transition-colors"
            >
              {showForm ? "Cancelar" : "Nova Notícia"}
            </button>
          </div>

          {showForm && (
            <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mb-8">
              <h2 className="text-xl font-semibold text-blue-900 dark:text-blue-100 mb-4">
                {editingNoticia ? "Editar Notícia" : "Nova Notícia"}
              </h2>

              <form onSubmit={handleSubmit(onSubmit)} className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Título *</label>
                  <input
                    {...register("titulo")}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  {errors.titulo && <p className="text-red-500 text-sm mt-1">{errors.titulo.message}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Conteúdo *</label>
                  <textarea
                    {...register("conteudo")}
                    rows={6}
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  {errors.conteudo && <p className="text-red-500 text-sm mt-1">{errors.conteudo.message}</p>}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                    URL da Imagem (opcional)
                  </label>
                  <input
                    {...register("imagem_opcional")}
                    type="url"
                    className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  {errors.imagem_opcional && (
                    <p className="text-red-500 text-sm mt-1">{errors.imagem_opcional.message}</p>
                  )}
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">Tags</label>
                  <TagInput tags={tags} onChange={setTags} placeholder="Digite uma tag e pressione Enter..." />
                </div>

                <div className="flex gap-4">
                  <button
                    type="submit"
                    disabled={isSubmitting}
                    className="bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md transition-colors disabled:opacity-50"
                  >
                    {isSubmitting ? "Salvando..." : editingNoticia ? "Atualizar" : "Criar"}
                  </button>

                  <button
                    type="button"
                    onClick={resetForm}
                    className="bg-gray-500 hover:bg-gray-600 text-white px-6 py-2 rounded-md transition-colors"
                  >
                    Cancelar
                  </button>
                </div>
              </form>
            </div>
          )}

          <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md overflow-hidden">
            <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
              <h2 className="text-lg font-semibold text-gray-900 dark:text-gray-100">Notícias Publicadas</h2>
            </div>

            <div className="overflow-x-auto">
              <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
                <thead className="bg-gray-50 dark:bg-gray-700">
                  <tr>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Título
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Tags
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Data
                    </th>
                    <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-300 uppercase tracking-wider">
                      Ações
                    </th>
                  </tr>
                </thead>
                <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
                  {noticias.map((noticia) => (
                    <tr key={noticia.id}>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm font-medium text-gray-900 dark:text-gray-100">{noticia.titulo}</div>
                      </td>
                      <td className="px-6 py-4">
                        <div className="flex flex-wrap gap-1">
                          {noticia.tags?.slice(0, 3).map((tag, index) => (
                            <span
                              key={index}
                              className="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-1 rounded-full text-xs"
                            >
                              #{tag}
                            </span>
                          ))}
                          {noticia.tags && noticia.tags.length > 3 && (
                            <span className="text-gray-500 dark:text-gray-400 text-xs px-2 py-1">
                              +{noticia.tags.length - 3}
                            </span>
                          )}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <div className="text-sm text-gray-500 dark:text-gray-400">
                          {new Date(noticia.data_publicacao).toLocaleDateString("pt-BR")}
                        </div>
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                        <button
                          onClick={() => handleEdit(noticia)}
                          className="text-blue-600 dark:text-blue-400 hover:text-blue-900 dark:hover:text-blue-300 mr-4"
                        >
                          Editar
                        </button>
                        <button
                          onClick={() => handleDelete(noticia.id)}
                          className="text-red-600 dark:text-red-400 hover:text-red-900 dark:hover:text-red-300"
                        >
                          Excluir
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </TabsContent>

        {/* <TabsContent value="comentarios">
          <AdminComments onApprove={fetchPendingCommentsCount} />
        </TabsContent> */}

        <TabsContent value="youtube">
          <YouTubeCacheStats />
        </TabsContent>
      </Tabs>
    </div>
  )
}
