import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:university/core/utilities/api_constants.dart';

class SendEmail {
  Future sendEmail(
      {required String name,
      required String email,
      required String phone,
      required String modality,
      required String course,
      required String unit}) async {
    var url = "${ApiConstants.baseUrl}/mail";

    Map params = {
      "fields": {
        "to": {"stringValue": "annanerybsb@gmail.com"},
        "message": {
          "mapValue": {
            "fields": {
              "subject": {"stringValue": "Interesse do aluno $name"},
              "html": {
                "stringValue":
                    "Interesse do possível aluno <strong>$name</strong> <br> <strong>Email</strong>: $email <br> <strong>Celular</strong>: $phone <br> <strong>Modalidade</strong>: $modality <br> <strong>Curso</strong>: $course <br> <strong>Unidade</strong>: $unit"
              }
            }
          }
        }
      }
    };

    var body = json.encode(params);

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

  Future sendEmailCreateTeacher({
    required String email,
    required String password,
    required String name,
    required String surname,
    required String cpf,
    required String phone,
  }) async {
    var url = "${ApiConstants.baseUrl}/mail";

    Map params = {
      "fields": {
        "to": {"stringValue": email},
        "message": {
          "mapValue": {
            "fields": {
              "subject": {
                "stringValue":
                    "Seu Perfil de Professor foi criado na AnnaNery Sr(a) $name"
              },
              "html": {
                "stringValue": """
                    <p>Prezado(a) <strong>$name $surname</strong>,</p>
                    <p>Estamos felizes em informá-lo(a) que seu perfil de professor foi criado com sucesso na <strong>AnnaNery</strong>.</p>
                    <p>Abaixo estão os detalhes da sua conta:</p>
                    <ul>
                      <li><strong>Email:</strong> $email</li>
                      <li><strong>Senha:</strong> $password</li>
                      <li><strong>CPF:</strong> $cpf</li>
                      <li><strong>Telefone:</strong> $phone</li>
                    </ul>
                    <p>Por favor, faça login no sistema utilizando as credenciais acima e complete seu perfil.</p>
                    <p>Se você tiver qualquer dúvida ou precisar de assistência, não hesite em nos contatar.</p>
                    <p>Atenciosamente,<br>Equipe AnnaNery</p>
                    """
              }
            }
          }
        }
      }
    };
    var body = json.encode(params);

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return response;
  }

  Future sendEmailCreateStudent({
    required String email,
    required String password,
    required String name,
    required String rg,
    required String cpf,
    required String phone,
  }) async {
    var url = "${ApiConstants.baseUrl}/mail";

    Map params = {
      "fields": {
        "to": {"stringValue": email},
        "message": {
          "mapValue": {
            "fields": {
              "subject": {
                "stringValue":
                    "Seu Perfil de Estudante foi criado na AnnaNery Aluno(a) $name"
              },
              "html": {
                "stringValue": """
                    <p>Prezado(a) <strong>$name</strong>,</p>
                    <p>Estamos felizes em informá-lo(a) que seu perfil de estudante foi criado com sucesso na <strong>AnnaNery</strong>.</p>
                    <p>Abaixo estão os detalhes da sua conta:</p>
                    <ul>
                      <li><strong>Email:</strong> $email</li>
                      <li><strong>Senha:</strong> $password</li>
                      <li><strong>CPF:</strong> $cpf</li>
                      <li><strong>RG:</strong> $rg</li>
                      <li><strong>Telefone:</strong> $phone</li>
                    </ul>
                    <p>Por favor, faça login no sistema utilizando as credenciais acima e complete seu perfil.</p>
                    <p>Se você tiver qualquer dúvida ou precisar de assistência, não hesite em nos contatar.</p>
                    <p>Atenciosamente,<br>Equipe AnnaNery</p>
                    """
              }
            }
          }
        }
      }
    };
    var body = json.encode(params);

    var response = await http.post(
      Uri.parse(url),
      body: body,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    return response;
  }
}
