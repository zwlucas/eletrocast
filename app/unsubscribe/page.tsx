"use client"

import { useState, useEffect } from "react"
import { useSearchParams } from "next/navigation"
import { CheckCircle, XCircle, Mail, ArrowLeft } from "lucide-react"
import Link from "next/link"

export default function UnsubscribePage() {
  const [status, setStatus] = useState<"loading" | "success" | "error">("loading")
  const [message, setMessage] = useState("")
  const searchParams = useSearchParams()
  const email = searchParams.get("email")

  useEffect(() => {
    if (!email) {
      setStatus("error")
      setMessage("Email não fornecido")
      return
    }

    const unsubscribe = async () => {
      try {
        const response = await fetch(`/api/newsletter/unsubscribe?email=${encodeURIComponent(email)}`)
        const data = await response.json()

        if (response.ok) {
          setStatus("success")
          setMessage(data.message)
        } else {
          setStatus("error")
          setMessage(data.error || "Erro ao cancelar inscrição")
        }
      } catch (error) {
        setStatus("error")
        setMessage("Erro de conexão")
      }
    }

    unsubscribe()
  }, [email])

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center p-4">
      <div className="max-w-md w-full bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 text-center">
        {status === "loading" && (
          <>
            <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mx-auto mb-4"></div>
            <h1 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">Processando...</h1>
            <p className="text-gray-600 dark:text-gray-400">Cancelando sua inscrição no newsletter</p>
          </>
        )}

        {status === "success" && (
          <>
            <CheckCircle className="h-12 w-12 text-green-600 mx-auto mb-4" />
            <h1 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">Inscrição Cancelada</h1>
            <p className="text-gray-600 dark:text-gray-400 mb-6">{message}</p>
            <p className="text-sm text-gray-500 dark:text-gray-400 mb-6">
              Você não receberá mais emails do nosso newsletter.
            </p>
          </>
        )}

        {status === "error" && (
          <>
            <XCircle className="h-12 w-12 text-red-600 mx-auto mb-4" />
            <h1 className="text-xl font-semibold text-gray-900 dark:text-white mb-2">Erro</h1>
            <p className="text-gray-600 dark:text-gray-400 mb-6">{message}</p>
          </>
        )}

        <div className="space-y-3">
          <Link
            href="/"
            className="inline-flex items-center gap-2 bg-blue-600 hover:bg-blue-700 text-white px-6 py-2 rounded-md transition-colors"
          >
            <ArrowLeft className="h-4 w-4" />
            Voltar ao Site
          </Link>

          {status === "success" && (
            <div className="pt-4 border-t border-gray-200 dark:border-gray-700">
              <p className="text-sm text-gray-500 dark:text-gray-400 mb-3">Mudou de ideia?</p>
              <Link
                href="/"
                className="inline-flex items-center gap-2 text-blue-600 hover:text-blue-700 dark:text-blue-400 dark:hover:text-blue-300 text-sm"
              >
                <Mail className="h-4 w-4" />
                Inscrever-se novamente
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
