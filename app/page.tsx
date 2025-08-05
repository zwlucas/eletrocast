import { checkLiveStream, getLatestVideo, checkPremierVideo } from "@/lib/youtube"
import YouTubePlayer from "@/components/YouTubePlayer"
import CountdownTimer from "@/components/CountdownTimer"
import { VideoSkeleton } from "@/components/SkeletonLoader"
import { FadeIn, SlideIn } from "@/components/AnimatedComponents"
import { Suspense } from "react"

export const revalidate = 300 // Revalidar a cada 5 minutos

export default async function Home() {
  const [liveStream, latestVideo, premierVideo] = await Promise.all([
    checkLiveStream(),
    getLatestVideo(),
    checkPremierVideo(),
  ])

  return (
    <FadeIn>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        <SlideIn direction="down">
          <div className="text-center mb-12">
            <h1 className="text-4xl font-bold text-blue-900 dark:text-blue-100 mb-4">Bem-vindos ao Eletrocast! ⚡</h1>
            <p className="text-xl text-gray-600 dark:text-gray-400 max-w-3xl mx-auto">
              Seu podcast sobre tecnologia, inovação e o mundo digital
            </p>
          </div>
        </SlideIn>

        <div className="max-w-4xl mx-auto">
          <Suspense fallback={<VideoSkeleton />}>
            {liveStream ? (
              <div className="mb-8">
                <div className="text-center mb-6">
                  <h2 className="text-2xl font-semibold text-blue-900 dark:text-blue-100 mb-2">
                    🔴 Estamos ao vivo agora!
                  </h2>
                  <p className="text-gray-600 dark:text-gray-400">Não perca nossa transmissão ao vivo</p>
                </div>
                <YouTubePlayer videoId={liveStream.id} title={liveStream.title} isLive={true} />
              </div>
            ) : premierVideo ? (
              <div className="mb-8">
                <CountdownTimer targetDate={premierVideo.scheduledStartTime} title={premierVideo.title} />
              </div>
            ) : (
              <div className="mb-8">
                <div className="text-center mb-6">
                  <h2 className="text-2xl font-semibold text-blue-900 dark:text-blue-100 mb-2">
                    Não estamos em live, mas você pode assistir nosso último podcast
                  </h2>
                  <p className="text-gray-600 dark:text-gray-400">Confira nosso conteúdo mais recente</p>
                </div>
                {latestVideo && <YouTubePlayer videoId={latestVideo.id} title={latestVideo.title} />}
              </div>
            )}

            {latestVideo && (
              <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 mt-8">
                <h3 className="text-lg font-semibold text-blue-900 dark:text-blue-100 mb-2">
                  Último episódio publicado
                </h3>
                <p className="text-gray-700 dark:text-gray-300 mb-2">{latestVideo.title}</p>
                <p className="text-sm text-yellow-600 dark:text-yellow-400 font-medium">
                  Publicado em: {new Date(latestVideo.publishedAt).toLocaleDateString("pt-BR")}
                </p>
              </div>
            )}
          </Suspense>
        </div>

        <div className="text-center mt-16">
          <h2 className="text-3xl font-bold text-blue-900 dark:text-blue-100 mb-4">Fique por dentro das novidades</h2>
          <p className="text-gray-600 dark:text-gray-400 mb-8">
            Acesse nossa seção de notícias para não perder nenhuma atualização
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <a
              href="/noticias"
              className="inline-flex items-center bg-yellow-400 hover:bg-yellow-500 dark:bg-yellow-500 dark:hover:bg-yellow-600 text-yellow-900 dark:text-yellow-100 font-semibold px-6 py-3 rounded-lg transition-colors duration-200"
            >
              Ver Notícias
              <svg className="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 7l5 5m0 0l-5 5m5-5H6" />
              </svg>
            </a>
            <a
              href="/podcast"
              className="inline-flex items-center bg-blue-600 hover:bg-blue-700 dark:bg-blue-700 dark:hover:bg-blue-800 text-white font-semibold px-6 py-3 rounded-lg transition-colors duration-200"
            >
              Ver Podcasts
              <svg className="ml-2 w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M14.828 14.828a4 4 0 01-5.656 0M9 10h1m4 0h1m-7 4h12l-2 5H9l-2-5z"
                />
              </svg>
            </a>
          </div>
        </div>
      </div>
    </FadeIn>
  )
}
