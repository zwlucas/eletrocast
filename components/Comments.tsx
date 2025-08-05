"use client"

import type React from "react"
import { useState, useEffect, useCallback } from "react"
import { supabase } from "@/lib/supabase"
import { motion, AnimatePresence } from "framer-motion"
import { MessageCircle, Send } from "lucide-react"

interface Comment {
  id: string
  nome: string
  comentario: string
  created_at: string
}

interface CommentsProps {
  noticiaId: string
}

export default function Comments({ noticiaId }: CommentsProps) {
  const [comments, setComments] = useState<Comment[]>([])
  const [loading, setLoading] = useState(true)
  const [submitting, setSubmitting] = useState(false)
  const [formData, setFormData] = useState({
    nome: "",
    email: "",
    comentario: "",
  })

  const fetchComments = useCallback(async () => {
    if (!noticiaId) return

    try {
      const { data, error } = await supabase
        .from("comentarios")
        .select("id, nome, comentario, created_at")
        .eq("noticia_id", noticiaId)
        // .eq("aprovado", true)
        .order("created_at", { ascending: false })

      if (!error && data) {
        setComments(data)
      }

      console.log(data)
    } catch (error) {
      console.error("Error fetching comments:", error)
    } finally {
      setLoading(false)
    }
  }, [noticiaId])

  useEffect(() => {
    fetchComments()
  }, [fetchComments])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!noticiaId || submitting) return

    setSubmitting(true)

    try {
      const { error } = await supabase.from("comentarios").insert([
        {
          noticia_id: noticiaId,
          ...formData,
        },
      ])

      if (error) {
        alert("Erro ao enviar comentário: " + error.message)
      } else {
        //alert("Comentário enviado! Será publicado após aprovação.")
        alert("Comentário enviado!")
        setFormData({ nome: "", email: "", comentario: "" })
      }
    } catch (error) {
      console.error("Error submitting comment:", error)
      alert("Erro ao enviar comentário. Tente novamente.")
    } finally {
      setSubmitting(false)
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

  const handleInputChange = (field: string, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }))
  }

  return (
    <div className="mt-12 bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
      <div className="flex items-center gap-2 mb-6">
        <MessageCircle className="h-5 w-5 text-blue-600 dark:text-blue-400" />
        <h3 className="text-xl font-semibold text-gray-900 dark:text-gray-100">Comentários ({comments.length})</h3>
      </div>

      {/* Formulário de comentário */}
      <form onSubmit={handleSubmit} className="mb-8 p-4 bg-gray-50 dark:bg-gray-700 rounded-lg">
        <div className="grid md:grid-cols-2 gap-4 mb-4">
          <input
            type="text"
            placeholder="Seu nome"
            value={formData.nome}
            onChange={(e) => handleInputChange("nome", e.target.value)}
            className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
          <input
            type="email"
            placeholder="Seu e-mail (não será publicado)"
            value={formData.email}
            onChange={(e) => handleInputChange("email", e.target.value)}
            className="px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500"
            required
          />
        </div>

        <textarea
          placeholder="Deixe seu comentário..."
          value={formData.comentario}
          onChange={(e) => handleInputChange("comentario", e.target.value)}
          rows={4}
          className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-800 text-gray-900 dark:text-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 mb-4"
          required
        />

        <button
          type="submit"
          disabled={submitting}
          className="flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-md transition-colors disabled:opacity-50"
        >
          <Send className="h-4 w-4" />
          {submitting ? "Enviando..." : "Enviar Comentário"}
        </button>
      </form>

      {/* Lista de comentários */}
      {loading ? (
        <div className="space-y-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <div key={i} className="animate-pulse">
              <div className="h-4 bg-gray-300 dark:bg-gray-600 rounded w-1/4 mb-2"></div>
              <div className="h-16 bg-gray-300 dark:bg-gray-600 rounded"></div>
            </div>
          ))}
        </div>
      ) : (
        <AnimatePresence>
          <div className="space-y-4">
            {comments.map((comment) => (
              <motion.div
                key={comment.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                className="border-l-4 border-blue-500 pl-4 py-2"
              >
                <div className="flex items-center gap-2 mb-2">
                  <span className="font-medium text-gray-900 dark:text-gray-100">{comment.nome}</span>
                  <span className="text-sm text-gray-500 dark:text-gray-400">{formatDate(comment.created_at)}</span>
                </div>
                <p className="text-gray-700 dark:text-gray-300 leading-relaxed">{comment.comentario}</p>
              </motion.div>
            ))}

            {comments.length === 0 && (
              <p className="text-center text-gray-500 dark:text-gray-400 py-8">Seja o primeiro a comentar!</p>
            )}
          </div>
        </AnimatePresence>
      )}
    </div>
  )
}
