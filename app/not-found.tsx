import Link from "next/link"
import { FadeIn } from "@/components/AnimatedComponents"

export default function NotFound() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-yellow-50 dark:from-gray-900 dark:to-gray-800">
      <FadeIn>
        <div className="text-center px-4">
          <div className="mb-8">
            <h1 className="text-9xl font-bold text-blue-600 dark:text-blue-400 mb-4">404</h1>
            <div className="text-6xl mb-4">⚡</div>
          </div>

          <h2 className="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-4">Ops! Nada por aqui...</h2>

          <p className="text-xl text-gray-600 dark:text-gray-400 mb-8 max-w-md mx-auto">
            A página que você está procurando não existe. Que tal assistir nosso último podcast?
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Link
              href="/"
              className="inline-flex items-center bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-lg transition-colors"
            >
              🏠 Voltar ao início
            </Link>

            <Link
              href="/podcast"
              className="inline-flex items-center bg-yellow-400 hover:bg-yellow-500 text-yellow-900 font-semibold px-6 py-3 rounded-lg transition-colors"
            >
              🎧 Ver Podcasts
            </Link>

            <Link
              href="/noticias"
              className="inline-flex items-center border-2 border-gray-300 dark:border-gray-600 hover:border-gray-400 dark:hover:border-gray-500 text-gray-700 dark:text-gray-300 font-semibold px-6 py-3 rounded-lg transition-colors"
            >
              📰 Ler Notícias
            </Link>
          </div>
        </div>
      </FadeIn>
    </div>
  )
}
