-- Tabela para comentários
CREATE TABLE IF NOT EXISTS comentarios (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  noticia_id UUID REFERENCES noticias(id) ON DELETE CASCADE,
  nome TEXT NOT NULL,
  email TEXT NOT NULL,
  comentario TEXT NOT NULL,
  aprovado BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS para comentários
ALTER TABLE comentarios ENABLE ROW LEVEL SECURITY;

-- Política para leitura de comentários aprovados
/* CREATE POLICY "Permitir leitura de comentários aprovados" ON comentarios
  FOR SELECT USING (aprovado = true); */

-- Política para inserção de comentários (qualquer um pode comentar)
CREATE POLICY "Permitir inserção de comentários" ON comentarios
  FOR INSERT WITH CHECK (true);

-- Política para aprovação de comentários (apenas admins)
CREATE POLICY "Permitir aprovação para admins" ON comentarios
  FOR UPDATE USING (auth.role() = 'authenticated');

-- Tabela para assinantes de newsletter
CREATE TABLE IF NOT EXISTS newsletter_subscribers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  nome TEXT,
  ativo BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE newsletter_subscribers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir inserção de assinantes" ON newsletter_subscribers
  FOR INSERT WITH CHECK (true);
