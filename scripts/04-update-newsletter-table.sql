-- Atualizar tabela de newsletter subscribers
ALTER TABLE newsletter_subscribers 
ADD COLUMN IF NOT EXISTS subscribed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS unsubscribed_at TIMESTAMP WITH TIME ZONE;

-- Criar índices para performance
CREATE INDEX IF NOT EXISTS idx_newsletter_subscribers_email ON newsletter_subscribers(email);
CREATE INDEX IF NOT EXISTS idx_newsletter_subscribers_active ON newsletter_subscribers(is_active);
CREATE INDEX IF NOT EXISTS idx_newsletter_subscribers_subscribed_at ON newsletter_subscribers(subscribed_at);

-- Atualizar registros existentes
UPDATE newsletter_subscribers 
SET is_active = true, subscribed_at = NOW() 
WHERE is_active IS NULL;

-- Adicionar constraint para email único
ALTER TABLE newsletter_subscribers 
ADD CONSTRAINT unique_active_email UNIQUE(email);

-- Comentários para documentação
COMMENT ON TABLE newsletter_subscribers IS 'Tabela para gerenciar inscrições do newsletter';
COMMENT ON COLUMN newsletter_subscribers.is_active IS 'Indica se a inscrição está ativa';
COMMENT ON COLUMN newsletter_subscribers.subscribed_at IS 'Data e hora da inscrição';
COMMENT ON COLUMN newsletter_subscribers.unsubscribed_at IS 'Data e hora do cancelamento da inscrição';
