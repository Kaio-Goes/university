import 'dart:io' as io;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:university/core/models/note.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:university/core/models/user_firebase.dart';

Future<void> generateExcel({
  List<UserFirebase>? users,
  String? subjectTitle,
  String? subjectModule,
  required String classTitle,
  required String teacherName,
  required String daysWeeksSubject,
  required String stardDateClass,
  required String endDateClass,
  List<Note>? listNotes,
}) async {
  final workbook = xlsio.Workbook();
  final sheet = workbook.worksheets[0];

  // 🔽 Carrega imagem dos assets
  final Uint8List imageBytes = await _loadLogoImage();

  // 🔽 Insere imagem no topo (linha 1, coluna G)
  if (imageBytes.isNotEmpty) {
    sheet.pictures.addStream(1, 7, imageBytes); // G1
  }

  Map<String, int> diasSemanaMap = {
    "Segunda-feira": DateTime.monday,
    "Terça-feira": DateTime.tuesday,
    "Quarta-feira": DateTime.wednesday,
    "Quinta-feira": DateTime.thursday,
    "Sexta-feira": DateTime.friday,
    "Sábado": DateTime.saturday,
    "Domingo": DateTime.sunday,
  };

  // Cabeçalho institucional (mesclado em A até F)
  final List<String> infoLines = [
    'Instituição Educacional: Escola Técnica Ana Nery',
    'Curso: $classTitle',
    'Eixo tecnológico: Ambiente e Saúde',
    'Oferta: Forma Presencial',
    'Módulo: $subjectModule',
    'Professor(a) : $teacherName',
    'Matéria: $subjectTitle',
  ];

  List<int> diasSelecionados = daysWeeksSubject
      .replaceAll('[', '')
      .replaceAll(']', '')
      .split(',') // <- aqui está o segredo
      .map((dia) => diasSemanaMap[dia.trim()])
      .whereType<int>()
      .toList();

  final DateFormat formatter = DateFormat('d/M/y');

  DateTime dataInicial = formatter.parse(stardDateClass);
  DateTime dataFinal = formatter.parse(endDateClass);

  List<DateTime> datasFiltradas = [];

  for (DateTime data = dataInicial;
      !data.isAfter(dataFinal);
      data = data.add(const Duration(days: 1))) {
    if (diasSelecionados.contains(data.weekday)) {
      datasFiltradas.add(data);
    }
  }

  for (int i = 0; i < infoLines.length; i++) {
    final row = i + 1;
    sheet.getRangeByName('A$row:F$row').merge();
    final cell = sheet.getRangeByName('A$row');
    cell.setText(infoLines[i]);
    cell.cellStyle
      ..bold = true
      ..fontSize = 10;
  }

  // Título do módulo
  final titleRowIndex = infoLines.length + 1;
  sheet.getRangeByName('A$titleRowIndex:F$titleRowIndex').merge();
  final titleCell = sheet.getRangeByName('A$titleRowIndex');
  titleCell.cellStyle
    ..bold = true
    ..hAlign = xlsio.HAlignType.center
    ..fontSize = 10;

  // final headersRowIndex = titleRowIndex + 2;
  final DateFormat dateHeaderFormat = DateFormat('dd/MM');

  final headersStartRowIndex = titleRowIndex + 1;
  final headersRowIndex = headersStartRowIndex + 1;

// Insere o rótulo "DATA" acima das datas
  sheet
      .getRangeByIndex(headersStartRowIndex, 4)
      .setText("DATA"); // Começa na 4ª coluna (índice 3)
  sheet
      .getRangeByIndex(headersStartRowIndex, 4, headersStartRowIndex,
          3 + datasFiltradas.length)
      .merge();

  final dataHeaderCell = sheet.getRangeByIndex(headersStartRowIndex, 4);
  dataHeaderCell.cellStyle
    ..bold = true
    ..hAlign = xlsio.HAlignType.center
    ..fontSize = 9
    ..backColor = '#C6EFCE' // verde claro
    ..fontColor = '#006100'; // verde escuro

  final headers = [
    'Nº',
    'MATRÍCULA',
    'NOME',
    ...datasFiltradas.map((d) => dateHeaderFormat.format(d)),
    ...?listNotes?.map((note) => note.title),
    'NOTA FINAL'
  ];

// Define as bordas do cabeçalho inteiro (superior e inferior)
  for (int i = 0; i < headers.length; i++) {
    final cell = sheet.getRangeByIndex(headersRowIndex, i + 1);
    cell.setText(headers[i]);
    final style = cell.cellStyle
      ..bold = true
      ..fontSize = 8
      ..borders.top.lineStyle = xlsio.LineStyle.thick
      ..borders.bottom.lineStyle = xlsio.LineStyle.thick
      ..borders.left.lineStyle = xlsio.LineStyle.thin
      ..borders.right.lineStyle = xlsio.LineStyle.thin;

    // Aplica cor nas colunas de datas
    if (i >= 3 && i < 3 + datasFiltradas.length) {
      style.backColor = '#C6EFCE'; // verde claro
      style.fontColor = '#006100'; // verde escuro
    }

    // Borda GROSSA somente na primeira e última coluna da seção de datas
    if (i == 3) {
      style.borders.left.lineStyle = xlsio.LineStyle.thick;
    }
    if (i == 2 + datasFiltradas.length) {
      style.borders.right.lineStyle = xlsio.LineStyle.thick;
    }
  } // Dados dos alunos
  for (int i = 0; i < users!.length; i++) {
    final user = users[i];
    final row = headersRowIndex + i + 1;

    sheet.getRangeByIndex(row, 1).setNumber(i + 1);
    sheet.getRangeByIndex(row, 2).setText(user.registration ?? '');
    sheet.getRangeByIndex(row, 3).setText(user.name);
    sheet.getRangeByIndex(row, 4).setText('');
    sheet.getRangeByIndex(row, 5).setText('');
    sheet.getRangeByIndex(row, 6).setText('');
    sheet.getRangeByIndex(row, 7).setText('');

    for (int colIndex = 1; colIndex <= 3 + datasFiltradas.length; colIndex++) {
      sheet.getRangeByIndex(row, colIndex).cellStyle.fontSize = 10;
    }
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
