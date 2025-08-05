import Link from "next/link"
import Image from "next/image"
import type { Noticia } from "@/lib/supabase"

interface NoticiaCardProps {
  noticia: Noticia
}

export default function NoticiaCard({ noticia }: NoticiaCardProps) {
  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    })
  }

  const getExcerpt = (content: string, maxLength = 150) => {
    if (content.length <= maxLength) return content
    return content.substring(0, maxLength) + "..."
  }

  return (
    <article className="bg-white dark:bg-gray-800 rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300">
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

      <div className="p-6">
        <div className="flex items-center gap-2 mb-3">
          <span className="bg-yellow-400 dark:bg-yellow-500 text-yellow-900 dark:text-yellow-100 px-2 py-1 rounded-full text-xs font-medium">
            {formatDate(noticia.data_publicacao)}
          </span>
        </div>

        {noticia.tags && noticia.tags.length > 0 && (
          <div className="flex flex-wrap gap-1 mb-3">
            {noticia.tags.slice(0, 3).map((tag, index) => (
              <span
                key={index}
                className="bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 px-2 py-1 rounded-full text-xs"
              >
                #{tag}
              </span>
            ))}
            {noticia.tags.length > 3 && (
              <span className="text-gray-500 dark:text-gray-400 text-xs px-2 py-1">+{noticia.tags.length - 3}</span>
            )}
          </div>
        )}

        <h2 className="text-xl font-semibold text-blue-900 dark:text-blue-100 mb-3 line-clamp-2">
          <Link
            href={`/noticias/${noticia.id}`}
            className="hover:text-blue-700 dark:hover:text-blue-300 transition-colors"
          >
            {noticia.titulo}
          </Link>
        </h2>

        <p className="text-gray-600 dark:text-gray-400 mb-4 line-clamp-3">{getExcerpt(noticia.conteudo)}</p>

        <Link
          href={`/noticias/${noticia.id}`}
          className="inline-flex items-center text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium transition-colors"
        >
          Ler mais
          <svg className="ml-1 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5l7 7-7 7" />
          </svg>
        </Link>
      </div>
    </article>
  )
}
