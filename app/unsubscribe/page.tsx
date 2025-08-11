"use client"

import { useState } from "react"
import { useSearchParams } from "next/navigation"
import { Mail, CheckCircle, XCircle } from "lucide-react"

export default function UnsubscribePage() {
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState("")
  const searchParams = useSearchParams()
  const email = searchParams.get("email")

  const handleUnsubscribe = async () => {
    if (!email) {
      setError("Email não fornecido")
      return
    }

    setLoading(true)
    try {
      const response = await fetch("/api/newsletter/unsubscribe", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email }),
      })

      if (response.ok) {
        setSuccess(true)
      } else {
        throw new Error("Erro ao cancelar inscrição")
      }
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 text-center">
          <CheckCircle className="h-16 w-16 text-green-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-4">Inscrição Cancelada</h1>
          <p className="text-gray-600 dark:text-gray-300 mb-6">
            Sua inscrição foi cancelada com sucesso. Você não receberá mais emails do Eletrocast.
          </p>
          <a
            href="/"
            className="inline-block bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 transition-colors"
          >
            Voltar ao Site
          </a>
        </div>
      </div>
    )
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
      <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
        <div className="text-center mb-6">
          <Mail className="h-16 w-16 text-blue-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white mb-2">Cancelar Inscrição</h1>
          <p className="text-gray-600 dark:text-gray-300">
            Tem certeza que deseja cancelar sua inscrição no newsletter?
          </p>
        </div>

        {email && (
          <div className="bg-gray-50 dark:bg-gray-700 rounded-md p-3 mb-6">
            <p className="text-sm text-gray-600 dark:text-gray-300">
              <strong>Email:</strong> {email}
            </p>
          </div>
        )}

        {error && (
          <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-md p-3 mb-4 flex items-center gap-2">
            <XCircle className="h-4 w-4 text-red-500" />
            <span className="text-red-700 dark:text-red-300 text-sm">{error}</span>
          </div>
        )}

        <div className="flex gap-3">
          <button
            onClick={handleUnsubscribe}
            disabled={loading || !email}
            className="flex-1 bg-red-600 text-white py-2 px-4 rounded-md hover:bg-red-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
          >
            {loading ? "Cancelando..." : "Sim, Cancelar"}
          </button>
          <a
            href="/"
            className="flex-1 bg-gray-300 dark:bg-gray-600 text-gray-700 dark:text-gray-200 py-2 px-4 rounded-md hover:bg-gray-400 dark:hover:bg-gray-500 transition-colors text-center"
          >
            Voltar
          </a>
        </div>
      </div>
    </div>
  )
}
