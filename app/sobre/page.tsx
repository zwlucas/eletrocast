import { Mail, Youtube, Twitter, Instagram } from "lucide-react"

export default function SobrePage() {
  const teamMembers = [
    {
      id: 1,
      name: "Ana Marcela",
      role: "Fundadora & Apresentadora",
      image: "/.jpg",
      personalText:
        "Apaixonado por tecnologia desde os 12 anos, criei o Eletrocast para compartilhar conhecimento e conectar pessoas. Acredito que a tecnologia pode transformar vidas!",
      email: "anamarcela@eletrocast.tech",
      instagram: "@anaamprado",
    },
    {
      id: 2,
      name: "Carol",
      role: "Co-Fundadora & Apresentadora",
      image: "/professional-woman-tech-expert-smiling.jpg",
      personalText:
        "Doutora em Ciência da Computação, dedico minha vida a tornar a IA mais acessível. No Eletrocast, traduzo conceitos complexos em linguagem simples.",
      email: "carol@eletrocast.tech",
      instagram: "@carola.mp3",
    },
    {
      id: 3,
      name: "Lucas Faria",
      role: "Operador de Som & Desenvolvedor",
      image: "/.jpg",
      personalText:
        "Transformo ideias em experiências visuais incríveis. Cada episódio é uma nova oportunidade de criar algo único e envolvente para nossa comunidade.",
      email: "lucas@eletrocast.tech",
      instagram: "@lucas.fariamo",
    },
    {
      id: 4,
      name: "Yves",
      role: "Produtor de Vídeo",
      image: "/professional-woman-content-creator-laptop.jpg",
      personalText:
        "Sou a ponte entre as ideias e o público. Pesquiso, organizo e estruturo cada episódio para entregar o melhor conteúdo possível.",
      email: "yves@eletrocast.tech",
      instagram: "@yves_mariano_",
    },
    {
      id: 5,
      name: "Arnaldo",
      role: "Designer",
      image: "/developer-man-coding-programming.jpg",
      personalText:
        "Código é poesia em movimento. Desenvolvo as soluções técnicas que mantêm o Eletrocast funcionando e sempre buscando inovações.",
      email: "arnaldo@eletrocast.tech",
      instagram: "@arnaldojuunior",
    },
    {
      id: 6,
      name: "Pietro",
      role: "Auxiliar de som e vídeo",
      image: "/social-media-manager-woman-smartphone.jpg",
      personalText:
        "Nossa comunidade é minha paixão! Cuido de cada interação, resposta e conexão. Vocês são o coração do Eletrocast!",
      email: "pietro@eletrocast.tech",
      instagram: "@brazzpe",
    },
    {
      id: 7,
      name: "Miguel",
      role: "Auxiliar de som e vídeo",
      image: "/533006893_18062474882350457_1105685139142315192_n.jpg",
      personalText:
        "O som perfeito é minha obsessão. Cada palavra, cada música, cada efeito é cuidadosamente ajustado para proporcionar a melhor experiência auditiva.",
      email: "miguel@eletrocast.tech",
      instagram: "@mduartez_",
    },
  ]
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

      {/* Seção Quem Somos */}
      <div className="mb-12">
        <h2 className="text-3xl font-bold text-blue-900 dark:text-blue-100 mb-8 text-center">Quem Somos</h2>
        <p className="text-lg text-gray-600 dark:text-gray-400 text-center mb-12 max-w-3xl mx-auto">
          Conheça a equipe apaixonada por tecnologia que trabalha todos os dias para trazer o melhor conteúdo para você
        </p>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
          {teamMembers.map((member) => (
            <div
              key={member.id}
              className="group relative bg-white dark:bg-gray-800 rounded-xl shadow-lg overflow-hidden hover:shadow-2xl transition-all duration-300 transform hover:-translate-y-2"
            >
              {/* Foto do membro */}
              <div className="relative overflow-hidden">
                <img
                  src={member.image || "/placeholder.svg"}
                  alt={member.name}
                  className="w-full h-64 object-cover transition-transform duration-300 group-hover:scale-110"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
              </div>

              {/* Informações básicas */}
              <div className="p-6">
                <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">{member.name}</h3>
                <p className="text-blue-600 dark:text-blue-400 font-medium mb-4">{member.role}</p>

                {/* Contatos */}
                <div className="flex items-center justify-center gap-4">
                  <a
                    href={`mailto:${member.email}`}
                    className="flex items-center justify-center w-10 h-10 bg-gray-100 dark:bg-gray-700 rounded-full hover:bg-blue-100 dark:hover:bg-blue-900 transition-colors duration-200"
                    title={`Email: ${member.email}`}
                  >
                    <Mail className="h-5 w-5 text-gray-600 dark:text-gray-400 hover:text-blue-600 dark:hover:text-blue-400" />
                  </a>
                  <a
                    href={`https://instagram.com/${member.instagram.replace("@", "")}`}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex items-center justify-center w-10 h-10 bg-gray-100 dark:bg-gray-700 rounded-full hover:bg-pink-100 dark:hover:bg-pink-900 transition-colors duration-200"
                    title={`Instagram: ${member.instagram}`}
                  >
                    <Instagram className="h-5 w-5 text-gray-600 dark:text-gray-400 hover:text-pink-600 dark:hover:text-pink-400" />
                  </a>
                </div>
              </div>

              {/* Texto pessoal - aparece no hover */}
              <div className="absolute inset-0 bg-blue-900/95 dark:bg-blue-800/95 backdrop-blur-sm opacity-0 group-hover:opacity-100 transition-all duration-300 flex items-center justify-center p-6">
                <div className="text-center">
                  <h4 className="text-white font-bold text-lg mb-3">{member.name}</h4>
                  <p className="text-blue-100 text-sm leading-relaxed">{member.personalText}</p>

                  {/* Contatos no hover */}
                  <div className="flex items-center justify-center gap-4 mt-6">
                    <a
                      href={`mailto:${member.email}`}
                      className="flex items-center justify-center w-10 h-10 bg-white/20 rounded-full hover:bg-white/30 transition-colors duration-200"
                      title={`Email: ${member.email}`}
                    >
                      <Mail className="h-5 w-5 text-white" />
                    </a>
                    <a
                      href={`https://instagram.com/${member.instagram.replace("@", "")}`}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="flex items-center justify-center w-10 h-10 bg-white/20 rounded-full hover:bg-white/30 transition-colors duration-200"
                      title={`Instagram: ${member.instagram}`}
                    >
                      <Instagram className="h-5 w-5 text-white" />
                    </a>
                  </div>
                </div>
              </div>
            </div>
          ))}
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
