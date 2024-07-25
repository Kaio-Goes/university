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
}
