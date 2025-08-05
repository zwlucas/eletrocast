import { Mail, Youtube, Twitter, Instagram } from "lucide-react"

export default function SobrePage() {
  return (
    <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-blue-900 dark:text-blue-100 mb-4">Sobre o Eletrocast ⚡</h1>
        <p className="text-xl text-gray-600 dark:text-gray-400">Conheça mais sobre nosso projeto e nossa missão</p>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 mb-8">
        <h2 className="text-2xl font-semibold text-blue-900 dark:text-blue-100 mb-6">Nossa História</h2>

        <div className="prose prose-lg max-w-none text-gray-700 dark:text-gray-300">
          <p className="mb-4">
            O <strong>Eletrocast</strong> nasceu da paixão por tecnologia e da vontade de compartilhar conhecimento de
            forma acessível e descontraída. Nosso objetivo é trazer as últimas novidades do mundo tech, discutir
            tendências e ajudar nossa comunidade a se manter atualizada.
          </p>

          <p className="mb-4">
            Através de nossos podcasts, lives e conteúdos, exploramos temas como desenvolvimento web, inteligência
            artificial, startups, carreira em tecnologia e muito mais. Sempre com uma abordagem prática e didática.
          </p>

          <p>
            Acreditamos que o conhecimento deve ser compartilhado e que juntos podemos construir uma comunidade mais
            forte e conectada no universo da tecnologia.
          </p>
        </div>
      </div>

      <div className="grid md:grid-cols-2 gap-8 mb-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
          <h3 className="text-xl font-semibold text-blue-900 dark:text-blue-100 mb-4">Nossa Missão</h3>
          <p className="text-gray-700 dark:text-gray-300">
            Democratizar o acesso ao conhecimento tecnológico através de conteúdo de qualidade, criando uma ponte entre
            iniciantes e profissionais experientes.
          </p>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
          <h3 className="text-xl font-semibold text-blue-900 dark:text-blue-100 mb-4">Nossos Valores</h3>
          <ul className="text-gray-700 dark:text-gray-300 space-y-2">
            <li>• Transparência e autenticidade</li>
            <li>• Educação acessível para todos</li>
            <li>• Inovação e curiosidade</li>
            <li>• Comunidade e colaboração</li>
          </ul>
        </div>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8">
        <h2 className="text-2xl font-semibold text-blue-900 dark:text-blue-100 mb-6 text-center">Entre em Contato</h2>

        <div className="grid md:grid-cols-2 gap-8">
          <div>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Fale Conosco</h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              Tem alguma sugestão, dúvida ou quer participar do podcast? Entre em contato conosco!
            </p>

            <div className="flex items-center gap-3 text-gray-700 dark:text-gray-300">
              <Mail className="h-5 w-5 text-blue-600 dark:text-blue-400" />
              <a
                href="mailto:contato@eletrocast.com"
                className="hover:text-blue-600 dark:hover:text-blue-400 transition-colors"
              >
                contato@eletrocast.com
              </a>
            </div>
          </div>

          <div>
            <h3 className="text-lg font-semibold text-gray-900 dark:text-gray-100 mb-4">Redes Sociais</h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              Siga-nos nas redes sociais para não perder nenhuma novidade!
            </p>

            <div className="flex gap-4">
              <a
                href="https://youtube.com/@eletrocast"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-red-600 hover:text-red-700 transition-colors"
              >
                <Youtube className="h-5 w-5" />
                YouTube
              </a>
              <a
                href="https://twitter.com/eletrocast"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-blue-500 hover:text-blue-600 transition-colors"
              >
                <Twitter className="h-5 w-5" />
                Twitter
              </a>
              <a
                href="https://instagram.com/eletrocast"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-pink-600 hover:text-pink-700 transition-colors"
              >
                <Instagram className="h-5 w-5" />
                Instagram
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
