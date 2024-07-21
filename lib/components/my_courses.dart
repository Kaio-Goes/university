import 'package:flutter/material.dart';
import 'package:university/components/type_courses.dart';
import 'package:university/core/utilities/styles.constants.dart';

class MyCourses extends StatelessWidget {
  final bool isSmallScreen;
  const MyCourses({super.key, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
            left:
                isSmallScreen ? 0 : MediaQuery.of(context).size.height * 0.25),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Conheça os nossos Cursos', style: textSubTitle),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  TypeCourses(
                    image: 'assets/images/tecEnfemagem.jpg',
                    presencialOrHibrid: 'Presencial',
                    isEad: 'EAD',
                    titleCourse: 'Técnico de Enfermagem',
                    msgCourse:
                        'Torne-se um profissional que trabalha com o objetivo de prestar cuidados de saúde fundamentais e assistir na recuperação de pacientes, potencializando a qualidade dos serviços de saúde.',
                    semesters: '8 Semestres',
                    typeFormatCourse: 'Tecnólogico',
                    aboutTheCourse:
                        'Nosso curso técnico em Enfermagem tem como objetivo formar profissionais capacitados para atuar na promoção, prevenção, recuperação e reabilitação da saúde. Os técnicos de enfermagem são essenciais para o funcionamento eficiente de qualquer instituição de saúde, pois auxiliam no atendimento direto aos pacientes, aplicam tratamentos prescritos e colaboram com a equipe multidisciplinar para garantir o bem-estar dos pacientes.\n\nAlém disso, durante o curso, o aluno desenvolverá habilidades práticas e teóricas que o prepararão para enfrentar os desafios diários da profissão, sempre mantendo um olhar humanizado e ético no cuidado com o próximo. O objetivo é preparar profissionais prontos para contribuir significativamente para a saúde e qualidade de vida da população.',
                  ),
                  TypeCourses(
                    image: 'assets/images/heart.jpg',
                    presencialOrHibrid: 'Presencial',
                    isEad: 'EAD',
                    titleCourse: 'Especialização em Sala Vermelha',
                    msgCourse:
                        'Torne-se um profissional especializado em Sala Vermelha, capacitado para atuar em situações de emergência e alta complexidade, garantindo atendimento rápido e eficiente para salvar vidas.',
                    semesters: '8 Semestres',
                    typeFormatCourse: 'Tecnólogico',
                    aboutTheCourse:
                        'Nossa especialização em Sala Vermelha tem como objetivo capacitar profissionais da saúde para atuarem de maneira eficiente e segura em situações de emergência e atendimento crítico. Este curso é projetado para preparar os alunos para lidar com pacientes em estado grave, onde o tempo e a precisão são cruciais para a sobrevivência e recuperação.\n\nOs profissionais especializados em Sala Vermelha são treinados para executar procedimentos avançados de suporte à vida, utilizar equipamentos de alta tecnologia e tomar decisões rápidas e eficazes sob pressão. Durante o curso, os alunos desenvolverão habilidades práticas e conhecimentos teóricos fundamentais para enfrentar os desafios de um ambiente de alta complexidade, sempre com foco no atendimento humanizado e ético.\n\nNosso objetivo é formar especialistas prontos para agir com competência e confiança, contribuindo para a melhoria dos serviços de urgência e emergência e, consequentemente, para a saúde e bem-estar da comunidade.',
                  ),
                  TypeCourses(
                    image: 'assets/images/oconlogia.jpg',
                    presencialOrHibrid: 'Presencial',
                    isEad: 'EAD',
                    titleCourse: 'Especialização em Oncologia',
                    msgCourse:
                        'Torne-se um profissional especializado em Oncologia, capacitado para oferecer cuidados integrados e avançados no tratamento e na recuperação de pacientes com câncer, promovendo qualidade de vida e suporte contínuo.',
                    semesters: '8 Semestres',
                    typeFormatCourse: 'Tecnólogico',
                    aboutTheCourse:
                        'Nossa especialização em Oncologia tem como objetivo preparar profissionais da saúde para atuar de maneira especializada e abrangente no cuidado de pacientes com câncer. Este curso oferece uma formação aprofundada nas diversas áreas da oncologia, incluindo diagnóstico, tratamento, cuidados paliativos e pesquisa, com ênfase na abordagem multidisciplinar e personalizada do paciente oncológico.\n\nOs profissionais especializados em Oncologia serão capacitados para compreender as complexidades da doença, aplicar tratamentos inovadores e fornecer suporte emocional e psicológico tanto para os pacientes quanto para suas famílias. Durante o curso, os alunos desenvolverão habilidades práticas e teóricas que os prepararão para enfrentar os desafios diários da oncologia, sempre com foco na ética, empatia e excelência no cuidado.\n\nNosso objetivo é formar especialistas prontos para atuar com competência e sensibilidade, contribuindo significativamente para o avanço dos tratamentos oncológicos e a melhoria da qualidade de vida dos pacientes.',
                  ),
                  TypeCourses(
                    image: 'assets/images/hemodialise.jpg',
                    presencialOrHibrid: 'Presencial',
                    isEad: 'EAD',
                    titleCourse: 'Especialização em Hemodiálise',
                    msgCourse:
                        'Torne-se um profissional especializado em Hemodiálise, capacitado para realizar tratamentos de diálise com precisão e cuidado, contribuindo para a saúde e bem-estar de pacientes com insuficiência renal.',
                    semesters: '8 Semestres',
                    typeFormatCourse: 'Tecnólogico',
                    aboutTheCourse:
                        'Nossa especialização em Hemodiálise tem como objetivo capacitar profissionais da saúde para atuar com expertise e precisão no manejo de pacientes com insuficiência renal crônica que necessitam de tratamento dialítico. Este curso proporciona uma formação aprofundada nas técnicas e procedimentos de hemodiálise, incluindo a utilização de equipamentos especializados, monitoramento do paciente e manejo de complicações.\n\nOs profissionais formados nesta especialização serão treinados para realizar a hemodiálise de forma segura e eficaz, gerenciar o acesso vascular, interpretar exames laboratoriais e oferecer suporte contínuo aos pacientes durante todo o tratamento. Além disso, o curso enfatiza a importância da comunicação empática e do cuidado humanizado, promovendo um ambiente de apoio e compreensão para os pacientes e suas famílias.\n\nNosso objetivo é preparar especialistas prontos para enfrentar os desafios do tratamento dialítico com competência técnica e sensibilidade, contribuindo para a melhoria da qualidade de vida dos pacientes com insuficiência renal.',
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
