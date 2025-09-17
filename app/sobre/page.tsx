import { Mail, Youtube, Twitter, Instagram } from "lucide-react"

export default function SobrePage() {
  return (
    <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-blue-900 dark:text-blue-100 mb-4">Sobre o Eletrocast ⚡</h1>
        <p className="text-xl text-gray-600 dark:text-gray-400">Conheça mais sobre nosso projeto e nossa missão</p>
      </div>

      <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-8 mb-12">
        <h2 className="text-2xl font-semibold text-blue-900 dark:text-blue-100 mb-6">Nossa História</h2>

        <div className="prose prose-lg max-w-none text-gray-700 dark:text-gray-300">
          <p className="mb-4">
            O <strong>Eletrocast</strong> surgiu de uma ideia de dus amigas em 2023, e que por um impulso fizemos
            surgir um dos maiores projetos da Eletrô. Mas nem sempre foi como vocês veem, no começo a gambiarra rolava
            solta no nosso estúdio e mesmo assim fizemos algo que muitos adoraram, as pessoas adoraram e recebemos a
            ajuda da Eletrô para comprar os equipamentos.
          </p>

          <p className="mb-4">
            Em 2024 nosso sonho deu um grande passo: microfones de qualidade, uma mesa de som boa e grande determinação
            para fazer o projeto desse ano dar certo e no final deu! Nossos esforços tiveram mais reconhecimento e ganhamos
            mais forças.
          </p>

          <p>
            2025 conquistamos nosso próprio estúdio e o projeto desse ano será o melhor dentre esses anos!
          </p>
        </div>
      </div>

      <div className="grid md:grid-cols-2 gap-8 mb-8">
        <div className="bg-white dark:bg-gray-800 rounded-lg shadow-lg p-6">
          <h3 className="text-xl font-semibold text-blue-900 dark:text-blue-100 mb-4">Nossa Missão</h3>
          <p className="text-gray-700 dark:text-gray-300">
            Fazer as pessoas reconhecerem a escola e saberem que sua criatividade pode fluir como a nossa fluiu e
            não é só isso, compartilhar experiências de estudantes do 3° ano e algumas boas curiosidades sobre os cursos.
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
                contato@eletrocast.tech 
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
                href="https://youtube.com/@eletrocast2024"
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2 text-red-600 hover:text-red-700 transition-colors"
              >
                <Youtube className="h-5 w-5" />
                YouTube
              </a>
              {/* <a
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
              </a> */}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
