-- Criar tabela para cache dos dados do YouTube
CREATE TABLE IF NOT EXISTS youtube_cache (
  id SERIAL PRIMARY KEY,
  cache_key VARCHAR(100) UNIQUE NOT NULL,
  data JSONB NOT NULL,
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para performance
CREATE INDEX IF NOT EXISTS idx_youtube_cache_key ON youtube_cache(cache_key);
CREATE INDEX IF NOT EXISTS idx_youtube_cache_expires ON youtube_cache(expires_at);

-- Função para limpar cache expirado automaticamente
CREATE OR REPLACE FUNCTION clean_expired_youtube_cache()
RETURNS void AS $$
BEGIN
  DELETE FROM youtube_cache WHERE expires_at < NOW();
END;
$$ LANGUAGE plpgsql;

-- Trigger para atualizar updated_at
CREATE OR REPLACE FUNCTION update_youtube_cache_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER youtube_cache_updated_at
  BEFORE UPDATE ON youtube_cache
  FOR EACH ROW
  EXECUTE FUNCTION update_youtube_cache_updated_at();
