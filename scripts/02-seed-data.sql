-- Inserir algumas notícias de exemplo
INSERT INTO noticias (titulo, conteudo, data_publicacao) VALUES
(
  'Bem-vindos ao nosso novo site!',
  'Estamos muito felizes em apresentar nosso novo site com integração ao YouTube e sistema de notícias. Aqui você pode acompanhar nossos últimos vídeos e ficar por dentro de todas as novidades do canal.',
  NOW() - INTERVAL '1 day'
),
(
  'Novo episódio do podcast já disponível',
  'Acabamos de lançar um novo episódio do nosso podcast! Neste episódio, conversamos sobre as últimas tendências em tecnologia e desenvolvimento web. Não deixe de conferir e nos dar seu feedback.',
  NOW() - INTERVAL '2 days'
),
(
  'Live especial nesta sexta-feira',
  'Não percam nossa live especial desta sexta-feira às 20h! Vamos falar sobre Next.js, React e muito mais. Preparem suas perguntas que responderemos tudo ao vivo.',
  NOW() - INTERVAL '3 days'
);
