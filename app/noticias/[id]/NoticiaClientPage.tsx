"use client"

import { useState, useEffect } from "react"
import { supabase } from "@/lib/supabase"
import Image from "next/image"
import Link from "next/link"
import { notFound } from "next/navigation"
import ShareButtons from "@/components/ShareButtons"
import Comments from "@/components/Comments"
import { FadeIn } from "@/components/AnimatedComponents"
import { trackNewsRead } from "@/lib/analytics"

interface NoticiaPageProps {
  params: {
    id: string
  }
}

export default function NoticiaClientPage({ params }: NoticiaPageProps) {
  const [noticia, setNoticia] = useState<any>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<any>(null)

  useEffect(() => {
    const fetchNoticia = async () => {
      try {
        const { data, error } = await supabase.from("noticias").select("*").eq("id", params.id).single()

        if (error) {
          setError(error)
          return
        }

        if (!data) {
          notFound()
        }

        setNoticia(data)

        // Track analytics after noticia is loaded
        if (data) {
          trackNewsRead(data.id, data.titulo)
        }
      } catch (err) {
        setError(err)
      } finally {
        setLoading(false)
      }
    }

    fetchNoticia()
  }, [params.id])

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "long",
      year: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  if (loading) {
    return (
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-300 dark:bg-gray-700 rounded w-1/4 mb-6"></div>
          <div className="aspect-video bg-gray-300 dark:bg-gray-700 rounded mb-8"></div>
          <div className="h-12 bg-gray-300 dark:bg-gray-700 rounded w-3/4 mb-6"></div>
          <div className="space-y-4">
            <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded"></div>
            <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-5/6"></div>
            <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-4/6"></div>
          </div>
        </div>
      </div>
    )
  }

  if (error) {
    return (
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="text-center">
          <h1 className="text-2xl font-bold text-red-600 mb-4">Erro ao carregar notícia</h1>
          <p className="text-gray-600 dark:text-gray-400 mb-4">
            Ocorreu um erro ao carregar esta notícia. Tente novamente mais tarde.
          </p>
          <Link
            href="/noticias"
            className="inline-flex items-center text-blue-600 hover:text-blue-700 font-medium transition-colors"
          >
            <svg className="mr-2 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            Voltar para notícias
          </Link>
        </div>
      </div>
    )
  }

  if (!noticia) {
    return null
  }

  return (
    <FadeIn>
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <div className="mb-8">
          <Link
            href="/noticias"
            className="inline-flex items-center text-blue-600 hover:text-blue-700 font-medium transition-colors mb-6"
          >
            <svg className="mr-2 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
            </svg>
            Voltar para notícias
          </Link>
        </div>

        <article className="bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden">
          {noticia.imagem_opcional && (
            <div className="aspect-video relative">
              <Image
                src={noticia.imagem_opcional || "/placeholder.svg"}
                alt={noticia.titulo}
                fill
                className="object-cover"
              />
            </div>
          )}

          <div className="p-8">
            <div className="mb-6">
              <span className="bg-yellow-400 dark:bg-yellow-500 text-yellow-900 dark:text-yellow-100 px-3 py-1 rounded-full text-sm font-medium">
                {formatDate(noticia.data_publicacao)}
              </span>
            </div>

            {noticia.tags && noticia.tags.length > 0 && (
              <div className="flex flex-wrap gap-2 mb-6">
                {noticia.tags.map((tag: string, index: number) => (
                  <span
                    key={index}
                    className="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-1 rounded-full text-xs"
                  >
                    #{tag}
                  </span>
                ))}
              </div>
            )}

            <h1 className="text-3xl font-bold text-blue-900 dark:text-blue-100 mb-6">{noticia.titulo}</h1>

            <div className="prose prose-lg max-w-none">
              <div className="text-gray-700 dark:text-gray-300 leading-relaxed whitespace-pre-wrap">
                {noticia.conteudo}
              </div>
            </div>
          </div>
        </article>

        <ShareButtons
          url={`/noticias/${noticia.id}`}
          title={noticia.titulo}
          description={noticia.conteudo.substring(0, 160)}
        />

        <Comments noticiaId={noticia.id} />
      </div>
    </FadeIn>
  )
}
