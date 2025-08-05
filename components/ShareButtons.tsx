"use client"

import { Share2, MessageCircle, Twitter, Facebook, Link2 } from "lucide-react"
import { useState } from "react"

interface ShareButtonsProps {
  url: string
  title: string
  description?: string
}

export default function ShareButtons({ url, title, description }: ShareButtonsProps) {
  const [copied, setCopied] = useState(false)

  const shareUrl = `${process.env.NEXT_PUBLIC_SITE_URL}${url}`
  const encodedTitle = encodeURIComponent(title)
  const encodedDescription = encodeURIComponent(description || "")

  const shareLinks = {
    whatsapp: `https://wa.me/?text=${encodedTitle}%20${shareUrl}`,
    twitter: `https://twitter.com/intent/tweet?text=${encodedTitle}&url=${shareUrl}`,
    facebook: `https://www.facebook.com/sharer/sharer.php?u=${shareUrl}`,
  }

  const copyToClipboard = async () => {
    try {
      await navigator.clipboard.writeText(shareUrl)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch (error) {
      console.error("Failed to copy:", error)
    }
  }

  return (
    <div className="flex items-center gap-2 p-4 bg-gray-50 dark:bg-gray-800 rounded-lg mt-5">
      <Share2 className="h-4 w-4 text-gray-600 dark:text-gray-400" />
      <span className="text-sm text-gray-600 dark:text-gray-400 mr-2">Compartilhar:</span>

      <div className="flex gap-2">
        <a
          href={shareLinks.whatsapp}
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-1 bg-green-500 hover:bg-green-600 text-white px-3 py-1 rounded-full text-xs transition-colors"
        >
          <MessageCircle className="h-3 w-3" />
          WhatsApp
        </a>

        <a
          href={shareLinks.twitter}
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-1 bg-blue-500 hover:bg-blue-600 text-white px-3 py-1 rounded-full text-xs transition-colors"
        >
          <Twitter className="h-3 w-3" />
          Twitter
        </a>

        <a
          href={shareLinks.facebook}
          target="_blank"
          rel="noopener noreferrer"
          className="flex items-center gap-1 bg-blue-700 hover:bg-blue-800 text-white px-3 py-1 rounded-full text-xs transition-colors"
        >
          <Facebook className="h-3 w-3" />
          Facebook
        </a>

        <button
          onClick={copyToClipboard}
          className="flex items-center gap-1 bg-gray-600 hover:bg-gray-700 text-white px-3 py-1 rounded-full text-xs transition-colors"
        >
          <Link2 className="h-3 w-3" />
          {copied ? "Copiado!" : "Copiar"}
        </button>
      </div>
    </div>
  )
}
