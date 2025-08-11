"use client"

import type React from "react"
import { useState } from "react"
import { Mail, Check, AlertCircle } from "lucide-react"
import { motion } from "framer-motion"

export default function Newsletter() {
  const [email, setEmail] = useState("")
  const [nome, setNome] = useState("")
  const [loading, setLoading] = useState(false)
  const [success, setSuccess] = useState(false)
  const [error, setError] = useState("")

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError("")

    try {
      const response = await fetch("/api/newsletter/subscribe", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, nome }),
      })

      const data = await response.json()

      if (!response.ok) {
        throw new Error(data.error || "Erro ao processar inscrição")
      }

      setSuccess(true)
      setEmail("")
      setNome("")
    } catch (err: any) {
      setError(err.message)
    } finally {
      setLoading(false)
    }
  }

  if (success) {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-6 text-center"
      >
        <Check className="h-12 w-12 text-green-600 dark:text-green-400 mx-auto mb-4" />
        <h3 className="text-lg font-semibold text-green-800 dark:text-green-200 mb-2">
          Inscrição realizada com sucesso!
        </h3>
        <p className="text-green-600 dark:text-green-400 mb-2">Você receberá nossas novidades em primeira mão.</p>
        <p className="text-sm text-green-500 dark:text-green-400">📧 Verifique seu email para confirmar a inscrição!</p>
      </motion.div>
    )
  }

  return (
    <div className="bg-gradient-to-r from-blue-600 to-blue-700 dark:from-blue-700 dark:to-blue-800 rounded-lg p-6 text-white">
      <div className="flex items-center gap-3 mb-4">
        <Mail className="h-6 w-6" />
        <h3 className="text-xl font-semibold">Newsletter do Eletrocast</h3>
      </div>

      <p className="mb-4 opacity-90">Receba nossas últimas notícias e novidades diretamente no seu e-mail!</p>

      {error && (
        <motion.div
          initial={{ opacity: 0, y: -10 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-red-500/20 border border-red-400 rounded-md p-3 mb-4 flex items-center gap-2"
        >
          <AlertCircle className="h-4 w-4 text-red-300" />
          <span className="text-red-100 text-sm">{error}</span>
        </motion.div>
      )}

      <form onSubmit={handleSubmit} className="space-y-3">
        <input
          type="text"
          placeholder="Seu nome"
          value={nome}
          onChange={(e) => setNome(e.target.value)}
          className="w-full px-4 py-2 rounded-md text-gray-900 focus:outline-none focus:ring-2 focus:ring-yellow-400"
          required
          disabled={loading}
        />

        <input
          type="email"
          placeholder="Seu melhor e-mail"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          className="w-full px-4 py-2 rounded-md text-gray-900 focus:outline-none focus:ring-2 focus:ring-yellow-400"
          required
          disabled={loading}
        />

        <button
          type="submit"
          disabled={loading}
          className="w-full bg-yellow-400 hover:bg-yellow-500 text-yellow-900 font-semibold py-2 px-4 rounded-md transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {loading ? (
            <span className="flex items-center justify-center gap-2">
              <div className="w-4 h-4 border-2 border-yellow-900 border-t-transparent rounded-full animate-spin"></div>
              Cadastrando...
            </span>
          ) : (
            "Quero receber novidades!"
          )}
        </button>
      </form>

      <p className="text-xs opacity-75 mt-3 text-center">📧 Você receberá um email de confirmação após se inscrever</p>
    </div>
  )
}
