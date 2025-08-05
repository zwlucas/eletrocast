export function VideoSkeleton() {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg overflow-hidden animate-pulse">
      <div className="aspect-video bg-gray-300 dark:bg-gray-700"></div>
      <div className="p-6">
        <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-3/4 mb-2"></div>
        <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-1/2"></div>
      </div>
    </div>
  )
}

export function NewsSkeleton() {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md overflow-hidden animate-pulse">
      <div className="aspect-video bg-gray-300 dark:bg-gray-700"></div>
      <div className="p-6">
        <div className="flex gap-2 mb-3">
          <div className="h-6 bg-gray-300 dark:bg-gray-700 rounded-full w-20"></div>
        </div>
        <div className="h-6 bg-gray-300 dark:bg-gray-700 rounded w-full mb-3"></div>
        <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-full mb-2"></div>
        <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-3/4 mb-4"></div>
        <div className="h-4 bg-gray-300 dark:bg-gray-700 rounded w-24"></div>
      </div>
    </div>
  )
}

export function NewsListSkeleton() {
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      {Array.from({ length: 6 }).map((_, i) => (
        <NewsSkeleton key={i} />
      ))}
    </div>
  )
}
