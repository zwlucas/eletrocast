import { getPodcastVideos } from "@/lib/youtube"
import Image from "next/image"

export const revalidate = 3600 // Revalidar a cada 1 hora

export default async function PodcastPage() {
  const videos = await getPodcastVideos(12)

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString("pt-BR", {
      day: "2-digit",
      month: "2-digit",
      year: "numeric",
    })
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-blue-900 dark:text-blue-100 mb-4">🎧 Episódios do Podcast</h1>
        <p className="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
          Todos os episódios do Eletrocast em um só lugar
        </p>
      </div>

      {videos.length > 0 ? (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {videos.map((video) => (
            <article
              key={video.id}
              className="bg-white dark:bg-gray-800 rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow duration-300"
            >
              <div className="aspect-video relative">
                <Image
                  src={video.thumbnails.high.url || "/placeholder.svg"}
                  alt={video.title}
                  fill
                  className="object-cover"
                />
                <div className="absolute inset-0 bg-black bg-opacity-0 hover:bg-opacity-20 transition-all duration-300 flex items-center justify-center">
                  <div className="opacity-0 hover:opacity-100 transition-opacity duration-300">
                    <div className="bg-red-600 rounded-full p-4">
                      <svg className="w-8 h-8 text-white ml-1" fill="currentColor" viewBox="0 0 24 24">
                        <path d="M8 5v14l11-7z" />
                      </svg>
                    </div>
                  </div>
                </div>
              </div>

              <div className="p-6">
                <div className="mb-3">
                  <span className="bg-yellow-400 dark:bg-yellow-500 text-yellow-900 dark:text-yellow-100 px-2 py-1 rounded-full text-xs font-medium">
                    {formatDate(video.publishedAt)}
                  </span>
                </div>

                <h2 className="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-3 line-clamp-2">
                  {video.title}
                </h2>

                <p className="text-gray-600 dark:text-gray-400 mb-4 line-clamp-2 text-sm">{video.description}</p>

                <div className="flex gap-2">
                  <a
                    href={`https://www.youtube.com/watch?v=${video.id}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex-1 bg-red-600 hover:bg-red-700 text-white text-center py-2 px-4 rounded-md transition-colors duration-200 text-sm font-medium"
                  >
                    Assistir no YouTube
                  </a>
                </div>
              </div>
            </article>
          ))}
        </div>
      ) : (
        <div className="text-center py-12">
          <h2 className="text-2xl font-semibold text-gray-700 dark:text-gray-300 mb-4">Nenhum episódio encontrado</h2>
          <p className="text-gray-600 dark:text-gray-400">Em breve teremos novos episódios para você!</p>
        </div>
      )}
    </div>
  )
}
