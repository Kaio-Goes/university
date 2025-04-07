import 'dart:io' as io;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

Future<void> generateExcel({
  List<Map<String, String>>? users,
  String? subjectTitle,
  required String classTitle,
  required String teacherName,
}) async {
  final workbook = xlsio.Workbook();
  final sheet = workbook.worksheets[0];

  // 🔽 Carrega imagem dos assets
  final Uint8List imageBytes = await _loadLogoImage();

  // 🔽 Insere imagem no topo (linha 1, coluna G)
  if (imageBytes.isNotEmpty) {
    sheet.pictures.addStream(1, 7, imageBytes); // G1
  }

  // Cabeçalho institucional (mesclado em A até F)
  final List<String> infoLines = [
    'Instituição Educacional: Escola Técnica Ana Nery',
    'Curso: $classTitle',
    'Eixo tecnológico: Ambiente e Saúde',
    'Oferta: Forma Presencial',
    'Módulo: $subjectTitle',
    'Professor(a) : $teacherName',
  ];

  for (int i = 0; i < infoLines.length; i++) {
    final row = i + 1;
    sheet.getRangeByName('A$row:F$row').merge();
    final cell = sheet.getRangeByName('A$row');
    cell.setText(infoLines[i]);
    cell.cellStyle.bold = true;
  }

  // Título do módulo
  final titleRowIndex = infoLines.length + 1;
  sheet.getRangeByName('A$titleRowIndex:F$titleRowIndex').merge();
  final titleCell = sheet.getRangeByName('A$titleRowIndex');
  titleCell.cellStyle.bold = true;
  titleCell.cellStyle.hAlign = xlsio.HAlignType.center;

  // Cabeçalhos
  final headersRowIndex = titleRowIndex + 2;
  final headers = [
    'Nº',
    'MATRÍCULA',
    'NOME',
    '01/04',
    '08/04',
    '15/04',
    '22/04'
  ];
  for (int i = 0; i < headers.length; i++) {
    sheet.getRangeByIndex(headersRowIndex, i + 1).setText(headers[i]);
    sheet.getRangeByIndex(headersRowIndex, i + 1).cellStyle.bold = true;
  }

  // Dados dos alunos
  for (int i = 0; i < users!.length; i++) {
    final user = users[i];
    final row = headersRowIndex + i + 1;

    sheet.getRangeByIndex(row, 1).setNumber(i + 1);
    sheet.getRangeByIndex(row, 2).setText(user['matricula'] ?? '');
    sheet.getRangeByIndex(row, 3).setText(user['nome'] ?? '');
    sheet.getRangeByIndex(row, 4).setText('');
    sheet.getRangeByIndex(row, 5).setText('');
    sheet.getRangeByIndex(row, 6).setText('');
    sheet.getRangeByIndex(row, 7).setText('');
  }

  // Gerar os bytes
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  // Salvar dependendo da plataforma
  if (kIsWeb) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    // ignore: unused_local_variable
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download",
          "diario_classe_${subjectTitle?.replaceAll(' ', '_')}.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);
    print("Arquivo Excel gerado para download (Web)");
  } else {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/diario_classe_${subjectTitle?.replaceAll(' ', '_')}.xlsx';
    final file = io.File(path);
    await file.writeAsBytes(bytes, flush: true);
    print("Arquivo Excel gerado com sucesso em: $path");
  }
}

// 🔧 Função para carregar a imagem
Future<Uint8List> _loadLogoImage() async {
  try {
    final byteData = await rootBundle.load('assets/images/logo_anna_nery.png');
    return byteData.buffer.asUint8List();
  } catch (e) {
    print('Erro ao carregar a imagem: $e');
    return Uint8List(0);
  }
}
