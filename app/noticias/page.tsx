"use client"

import { useState, useEffect } from "react"
import { supabase, type Noticia } from "@/lib/supabase"
import NoticiaCard from "@/components/NoticiaCard"
import SearchBar from "@/components/SearchBar"
import Newsletter from "@/components/Newsletter"
import { NewsListSkeleton } from "@/components/SkeletonLoader"
import { FadeIn, StaggerContainer, StaggerItem } from "@/components/AnimatedComponents"

export default function NoticiasPage() {
  const [noticias, setNoticias] = useState<Noticia[]>([])
  const [filteredNoticias, setFilteredNoticias] = useState<Noticia[]>([])
  const [loading, setLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")

  useEffect(() => {
    fetchNoticias()
  }, [])

  useEffect(() => {
    if (searchQuery) {
      const filtered = noticias.filter(
        (noticia) =>
          noticia.titulo.toLowerCase().includes(searchQuery.toLowerCase()) ||
          noticia.conteudo.toLowerCase().includes(searchQuery.toLowerCase()) ||
          noticia.tags?.some((tag) => tag.toLowerCase().includes(searchQuery.toLowerCase())),
      )
      setFilteredNoticias(filtered)
    } else {
      setFilteredNoticias(noticias)
    }
  }, [searchQuery, noticias])

  const fetchNoticias = async () => {
    const { data, error } = await supabase.from("noticias").select("*").order("data_publicacao", { ascending: false })

    if (!error && data) {
      setNoticias(data)
      setFilteredNoticias(data)
    }
    setLoading(false)
  }

  const handleSearch = (query: string) => {
    setSearchQuery(query)
  }

  return (
    <FadeIn>
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
        {/* Conteúdo existente com SearchBar */}
        <SearchBar onSearch={handleSearch} />

        {loading ? (
          <NewsListSkeleton />
        ) : (
          <StaggerContainer>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredNoticias.map((noticia) => (
                <StaggerItem key={noticia.id}>
                  <NoticiaCard noticia={noticia} />
                </StaggerItem>
              ))}
            </div>
          </StaggerContainer>
        )}

        {/* Newsletter no final */}
        <div className="mt-16">
          <Newsletter />
        </div>
      </div>
    </FadeIn>
  )
}
