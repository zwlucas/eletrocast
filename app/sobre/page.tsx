import { Mail, Youtube, Twitter, Instagram } from "lucide-react"

export default function SobrePage() {
  const teamMembers = [
    {
      id: 1,
      name: "Ana Marcela",
      role: "Fundadora & Apresentadora",
      image: "https://instagram.fpoo2-1.fna.fbcdn.net/v/t51.2885-19/433301424_968495264712448_8293533060514165419_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby43NjUuYzIifQ&_nc_ht=instagram.fpoo2-1.fna.fbcdn.net&_nc_cat=104&_nc_oc=Q6cZ2QGzYuQl_7-pEx7rv2z6hGxbOVyVkj_4SBaVEMxf-JkqNua4tGWVpA7QlfI5AjWdqos&_nc_ohc=h8NosiJcApkQ7kNvwGpclul&_nc_gid=X9dEEkcl31UEaQVO198DSQ&edm=AONqaaQBAAAA&ccb=7-5&oh=00_Afa73LqmUXpHHimvPa0NfNNCDvF_7tK0m28E2siezZA8uA&oe=68D0746A&_nc_sid=4e3341",
      personalText:
        "Apaixonado por tecnologia desde os 12 anos, criei o Eletrocast para compartilhar conhecimento e conectar pessoas. Acredito que a tecnologia pode transformar vidas!",
      email: "anamarcela@eletrocast.tech",
      instagram: "@anaamprado",
    },
    {
      id: 2,
      name: "Carol",
      role: "Co-Fundadora & Apresentadora",
      image: "https://instagram.fpoo2-1.fna.fbcdn.net/v/t51.2885-19/523554974_18061322432350836_3172836380021265341_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xMDgwLmMyIn0&_nc_ht=instagram.fpoo2-1.fna.fbcdn.net&_nc_cat=100&_nc_oc=Q6cZ2QEz7t9FylOQzvOgICaAeZNF056X3Y3MJavX8jHBwlUOOwfL2BPESEm4SSy-tEnKPDs&_nc_ohc=bnbpVOVbmh4Q7kNvwGLmdRC&_nc_gid=DtT5h4HDOLD9Zc0Ce87bZQ&edm=ACE-g0gBAAAA&ccb=7-5&oh=00_AfagmALlp4b4iygPpuWKXGZjcApboyELX9_4JC2fuR9TEQ&oe=68D076E3&_nc_sid=b15361",
      personalText:
        "Doutora em Ciência da Computação, dedico minha vida a tornar a IA mais acessível. No Eletrocast, traduzo conceitos complexos em linguagem simples.",
      email: "carol@eletrocast.tech",
      instagram: "@carola.mp3",
    },
    {
      id: 3,
      name: "Lucas Faria",
      role: "Operador de Som & Desenvolvedor",
      image: "https://instagram.fpoo2-1.fna.fbcdn.net/v/t51.2885-19/538463487_18322479460226810_1777326981917733151_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xMDgwLmMyIn0&_nc_ht=instagram.fpoo2-1.fna.fbcdn.net&_nc_cat=102&_nc_oc=Q6cZ2QGD_1ZFUVKaW8GQ1KdBqkmG2ekrWzZ-tJNXzYb9GniQ8f7QHvIXNyWUhYVscOfxch4&_nc_ohc=aLSKo9904_kQ7kNvwHpAWXs&_nc_gid=Z_Haysut_cOftafz6LIFiw&edm=AP4sbd4BAAAA&ccb=7-5&oh=00_AfZz_E7nP0jB_TmU8P9AMqsOZDAYLcdGc_E6aBQKslaZNQ&oe=68D0771D&_nc_sid=7a9f4b",
      personalText:
        "Transformo ideias em experiências visuais incríveis. Cada episódio é uma nova oportunidade de criar algo único e envolvente para nossa comunidade.",
      email: "lucas@eletrocast.tech",
      instagram: "@lucas.fariamo",
    },
    {
      id: 4,
      name: "Yves",
      role: "Produtor de Vídeo",
      image: "https://instagram.fpoo2-1.fna.fbcdn.net/v/t51.2885-19/476886861_949736070614982_6658791873360174972_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby44NjQuYzIifQ&_nc_ht=instagram.fpoo2-1.fna.fbcdn.net&_nc_cat=106&_nc_oc=Q6cZ2QHY4Tm1LAU2jjuqnaRbr-Z8PUb2GugzhQfetDJACC7bddzvYaUSfS7iKgvylTH-Xe0&_nc_ohc=cMau88O10UEQ7kNvwFTsj1S&_nc_gid=78W0DzGR3GPRcI_WGoftOA&edm=AP4sbd4BAAAA&ccb=7-5&oh=00_Afb0H_viyTnpn90PbW6YfSEe6YnXMTHG6a9xLXa9c2_s8Q&oe=68D08828&_nc_sid=7a9f4b",
      personalText:
        "Sou a ponte entre as ideias e o público. Pesquiso, organizo e estruturo cada episódio para entregar o melhor conteúdo possível.",
      email: "yves@eletrocast.tech",
      instagram: "@yves_mariano_",
    },
    {
      id: 5,
      name: "Arnaldo",
      role: "Designer",
      image: "https://instagram.fpoo2-1.fna.fbcdn.net/v/t51.2885-19/461708560_979942603933227_2358509484830806342_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xMDgwLmMyIn0&_nc_ht=instagram.fpoo2-1.fna.fbcdn.net&_nc_cat=103&_nc_oc=Q6cZ2QFMCegmBOg0O3LfMwqwmk8OQr55nJlI7xVRgsutrs2-E8xX394deEUXicERTxqbgD4&_nc_ohc=cc_XNcC0k_8Q7kNvwHFKTsV&_nc_gid=GtSLqUJetdkHb3JQhQnXyQ&edm=AP4sbd4BAAAA&ccb=7-5&oh=00_AfacZ_qk5GdCo7wGDqKL5wUbnOeBkNsp2smOXbI_vHZ34Q&oe=68D05D7C&_nc_sid=7a9f4b",
      personalText:
        "Código é poesia em movimento. Desenvolvo as soluções técnicas que mantêm o Eletrocast funcionando e sempre buscando inovações.",
      email: "arnaldo@eletrocast.tech",
      instagram: "@arnaldojuunior",
    },
    {
      id: 6,
      name: "Pietro",
      role: "Auxiliar de som e vídeo",
      image: "https://scontent-for2-2.cdninstagram.com/v/t51.2885-19/44884218_345707102882519_2446069589734326272_n.jpg?efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xNTAuYzIifQ&_nc_ht=scontent-for2-2.cdninstagram.com&_nc_cat=1&_nc_oc=Q6cZ2QFTdvoLni7ZjtwmPi-Ryjd5zbB8oMLSZee_HuArpruomO-DhtsQMRziRPnxVDhO-nw&_nc_ohc=AH7vFm8qSmMQ7kNvwE-xfCE&edm=AAAAAAABAAAA&ccb=7-5&ig_cache_key=YW5vbnltb3VzX3Byb2ZpbGVfcGlj.3-ccb7-5&oh=00_AfaW8TwcjYstMR-k4M6hDaCaxichPjPXL4pAcg72uqYnaw&oe=68D078CF&_nc_sid=328259",
      personalText:
        "Nossa comunidade é minha paixão! Cuido de cada interação, resposta e conexão. Vocês são o coração do Eletrocast!",
      email: "pietro@eletrocast.tech",
      instagram: "@brazzpe",
    },
    {
      id: 7,
      name: "Miguel",
      role: "Auxiliar de som e vídeo",
      image: "https://instagram.fpoo2-1.fna.fbcdn.net/v/t51.2885-19/533006893_18062474882350457_1105685139142315192_n.jpg?stp=dst-jpg_s150x150_tt6&efg=eyJ2ZW5jb2RlX3RhZyI6InByb2ZpbGVfcGljLmRqYW5nby4xMDgwLmMyIn0&_nc_ht=instagram.fpoo2-1.fna.fbcdn.net&_nc_cat=105&_nc_oc=Q6cZ2QFAbIb3BNm4_Fy4SrJU3HytVpsQfH8APZ46XLAy-nnv3fpkUInGZqNvRlq7PdGCy54&_nc_ohc=KBKMI-Yp3skQ7kNvwHty1EI&_nc_gid=s1xNKc1j-ZUdxc1xTsDP0w&edm=ALGbJPMBAAAA&ccb=7-5&oh=00_AfbZGDepPxLgKVZzW-ZPXWI54n6LLPmaQ4rxgv1DUqdvaw&oe=68D05D98&_nc_sid=7d3ac5",
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
                  onError={(e) => {
                    // Fallback para placeholder se a imagem do Instagram não carregar
                    e.currentTarget.src =
                      "/placeholder.svg?height=256&width=256&text=" + encodeURIComponent(member.name)
                  }}
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
