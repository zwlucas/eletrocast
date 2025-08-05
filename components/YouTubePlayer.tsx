interface YouTubePlayerProps {
  videoId: string
  title: string
  isLive?: boolean
}

export default function YouTubePlayer({ videoId, title, isLive = false }: YouTubePlayerProps) {
  return (
    <div className="bg-white rounded-lg shadow-lg overflow-hidden">
      <div className="aspect-video">
        <iframe
          src={`https://www.youtube.com/embed/${videoId}${isLive ? "?autoplay=1" : ""}`}
          title={title}
          className="w-full h-full"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowFullScreen
        />
      </div>

      <div className="p-6">
        <div className="flex items-center gap-2 mb-2">
          {isLive && (
            <span className="bg-red-500 text-white px-2 py-1 rounded-full text-xs font-medium animate-pulse">
              AO VIVO
            </span>
          )}
          <h2 className="text-xl font-semibold text-gray-900 line-clamp-2">{title}</h2>
        </div>
      </div>
    </div>
  )
}
