-- Atualizar tabela de newsletter subscribers
ALTER TABLE newsletter_subscribers 
ADD COLUMN IF NOT EXISTS subscribed_at TIMESTAMP DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;

-- Atualizar registros existentes
UPDATE newsletter_subscribers 
SET subscribed_at = NOW(), is_active = true 
WHERE subscribed_at IS NULL;

-- Criar índice para melhor performance
CREATE INDEX IF NOT EXISTS idx_newsletter_active ON newsletter_subscribers(is_active);
CREATE INDEX IF NOT EXISTS idx_newsletter_email ON newsletter_subscribers(email);
