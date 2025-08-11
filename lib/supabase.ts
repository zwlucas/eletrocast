import { createClient } from "@supabase/supabase-js"

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export type Noticia = {
  id: string
  titulo: string
  conteudo: string
  data_publicacao: string
  imagem_opcional?: string
  tags?: string[]
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
}

export { createClient }
