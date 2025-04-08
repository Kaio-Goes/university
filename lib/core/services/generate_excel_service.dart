import 'dart:developer';
import 'dart:io' as io;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:university/core/models/note.dart';
import 'package:university/core/models/subject_module.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

import 'package:university/core/models/user_firebase.dart';
import 'package:university/core/models/user_note.dart';

Future<void> generateExcel({
  List<UserFirebase>? users,
  SubjectModule? subject,
  required String classTitle,
  required String teacherName,
  required String daysWeeksSubject,
  required String stardDateClass,
  required String endDateClass,
  List<Note>? listNotes,
  Map<String, Map<DateTime, String>>? presencaMap,
  List<UserNote>? listUserNote,
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
    'Módulo: ${subject?.module}',
    'Professor(a) : $teacherName',
    'Matéria: ${subject?.title}',
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

// Ajuste de largura das colunas principais
  sheet.getRangeByName('A1').columnWidth = 5;
  sheet.getRangeByName('B1').columnWidth = 15;
  sheet.getRangeByName('C1').columnWidth = 30;

  // Aqui entra o novo ajuste
  if (listNotes != null) {
    for (int i = 0; i < listNotes.length; i++) {
      final colIndex = 4 + datasFiltradas.length + i;
      sheet.getRangeByIndex(1, colIndex).columnWidth = 13;
    }
  }

// Define as bordas do cabeçalho inteiro (superior e inferior)
  for (int i = 0; i < headers.length; i++) {
    final cell = sheet.getRangeByIndex(headersRowIndex, i + 1);
    cell.setText(headers[i]);
    final style = cell.cellStyle
      ..bold = true
      ..fontSize = 8
      ..hAlign = xlsio.HAlignType.center
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

  final xlsio.Style matriculaStyle =
      sheet.workbook.styles.add('matriculaStyle');
  matriculaStyle.hAlign = xlsio.HAlignType.center;
  matriculaStyle.fontSize = 8; // (se quiser manter o tamanho também)

  for (int i = 0; i < users!.length; i++) {
    final user = users[i];
    final row = headersRowIndex + i + 1;

    sheet.getRangeByIndex(row, 1).setNumber(i + 1);
    // Dentro do for, onde preenche os dados dos usuários:
    sheet.getRangeByIndex(row, 2)
      ..setText(user.registration ?? '')
      ..cellStyle = matriculaStyle;
    sheet.getRangeByIndex(row, 3).setText(user.name);

    // 👇 Loop pelas datas
    for (int j = 0; j < datasFiltradas.length; j++) {
      final data = datasFiltradas[j];

      // Coluna da presença: começa em 4 (D), então soma o offset `j`
      final col = 4 + j;

      // Busca no map de presenças
      final status = presencaMap?[user.uid]?[data] ?? '';

      sheet.getRangeByIndex(row, col).setText(status);
    }

    int notaStartCol = 4 + datasFiltradas.length;
    int notaFinalCol = notaStartCol + (listNotes?.length ?? 0);

// Mapa para armazenar as notas do aluno atual (usando o título da nota como chave)
    Map<String, double> notasDoAluno = {};

// Percorre todas as userNote e associa as notas do aluno atual
    for (var i = 0; i < (listUserNote?.length ?? 0); i++) {
      final userNote = listUserNote![i];

      if (userNote.userId == user.uid && userNote.subjectId == subject?.uid) {
        // Procurar o note correspondente sem usar firstWhere
        for (var j = 0; j < (listNotes?.length ?? 0); j++) {
          final note = listNotes![j];

          if (note.uid == userNote.noteId) {
            notasDoAluno[note.title] = double.parse(userNote.value);
            break; // achou, pode parar esse for
          }
        }
      }
    }
    const numberFormat = '#,##0.00';

// Agora vamos preencher as colunas de nota
    for (var n = 0; n < (listNotes?.length ?? 0); n++) {
      final note = listNotes![n];
      final col = notaStartCol + n;

      if (notasDoAluno.containsKey(note.title)) {
        final valor = notasDoAluno[note.title]!;
        final cell = sheet.getRangeByIndex(row, col);
        cell.setNumber(valor);
        cell.numberFormat = numberFormat;
        cell.cellStyle.fontSize = 8;
      } else {
        sheet.getRangeByIndex(row, col).setText('');
      }
    }

// Soma das notas como nota final (em vez da média)
    if (notasDoAluno.isNotEmpty) {
      double soma = 0;

      for (var valor in notasDoAluno.values) {
        soma += valor;
      }

      final cell = sheet.getRangeByIndex(row, notaFinalCol);
      cell.setNumber(soma);
      cell.numberFormat = numberFormat;
      cell.cellStyle.fontSize = 8;
    } else {
      sheet.getRangeByIndex(row, notaFinalCol).setText('');
    }

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
          "diario_classe_${subject?.title.replaceAll(' ', '_')}.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);
    log("Arquivo Excel gerado para download (Web)");
  } else {
    final directory = await getApplicationDocumentsDirectory();
    final path =
        '${directory.path}/diario_classe_${subject?.title.replaceAll(' ', '_')}.xlsx';
    final file = io.File(path);
    await file.writeAsBytes(bytes, flush: true);
    log("Arquivo Excel gerado com sucesso em: $path");
  }
}

// 🔧 Função para carregar a imagem
Future<Uint8List> _loadLogoImage() async {
  try {
    final byteData = await rootBundle.load('assets/images/logo_anna_nery.png');
    return byteData.buffer.asUint8List();
  } catch (e) {
    Exception('Erro ao carregar a imagem: $e');
    return Uint8List(0);
  }
}
