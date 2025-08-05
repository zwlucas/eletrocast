-- Criar tabela de notícias
CREATE TABLE IF NOT EXISTS noticias (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  titulo TEXT NOT NULL,
  conteudo TEXT NOT NULL,
  data_publicacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  imagem_opcional TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Criar política RLS para permitir leitura pública das notícias
ALTER TABLE noticias ENABLE ROW LEVEL SECURITY;

-- Política para leitura pública
CREATE POLICY "Permitir leitura pública de notícias" ON noticias
  FOR SELECT USING (true);

-- Política para inserção/atualização apenas para usuários autenticados
CREATE POLICY "Permitir inserção para usuários autenticados" ON noticias
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Permitir atualização para usuários autenticados" ON noticias
  FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Permitir exclusão para usuários autenticados" ON noticias
  FOR DELETE USING (auth.role() = 'authenticated');

-- Criar bucket para imagens (se não existir)
INSERT INTO storage.buckets (id, name, public) 
VALUES ('noticias-images', 'noticias-images', true)
ON CONFLICT (id) DO NOTHING;

-- Política para o bucket de imagens
CREATE POLICY "Permitir upload de imagens para usuários autenticados" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'noticias-images' AND auth.role() = 'authenticated');

CREATE POLICY "Permitir leitura pública de imagens" ON storage.objects
  FOR SELECT USING (bucket_id = 'noticias-images');

CREATE POLICY "Permitir exclusão de imagens para usuários autenticados" ON storage.objects
  FOR DELETE USING (bucket_id = 'noticias-images' AND auth.role() = 'authenticated');
