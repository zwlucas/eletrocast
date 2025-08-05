"use client"

import { useEffect } from "react"
import { FadeIn } from "@/components/AnimatedComponents"

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error(error)
  }, [error])

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-red-50 to-orange-50 dark:from-gray-900 dark:to-gray-800">
      <FadeIn>
        <div className="text-center px-4">
          <div className="mb-8">
            <div className="text-6xl mb-4">⚡💥</div>
            <h1 className="text-4xl font-bold text-red-600 dark:text-red-400 mb-4">Algo deu errado!</h1>
          </div>

          <p className="text-xl text-gray-600 dark:text-gray-400 mb-8 max-w-md mx-auto">
            Ocorreu um erro inesperado. Nossa equipe foi notificada e está trabalhando para resolver.
          </p>

          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <button
              onClick={reset}
              className="bg-blue-600 hover:bg-blue-700 text-white font-semibold px-6 py-3 rounded-lg transition-colors"
            >
              🔄 Tentar novamente
            </button>

            <a
              href="/"
              className="bg-yellow-400 hover:bg-yellow-500 text-yellow-900 font-semibold px-6 py-3 rounded-lg transition-colors"
            >
              🏠 Voltar ao início
            </a>
          </div>
        </div>
      </FadeIn>
    </div>
  )
}
