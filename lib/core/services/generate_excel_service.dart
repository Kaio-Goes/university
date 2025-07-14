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
  matriculaStyle.borders.left.lineStyle = xlsio.LineStyle.thin;
  matriculaStyle.borders.right.lineStyle = xlsio.LineStyle.thin;
  matriculaStyle.borders.top.lineStyle = xlsio.LineStyle.thin;
  matriculaStyle.borders.bottom.lineStyle = xlsio.LineStyle.thin;

  for (int i = 0; i < users!.length; i++) {
    final user = users[i];
    final row = headersRowIndex + i + 1;

    final lastCol = 3 + datasFiltradas.length + (listNotes?.length ?? 0) + 1;
    for (int col = 1; col <= lastCol; col++) {
      final cell = sheet.getRangeByIndex(row, col);
      cell.cellStyle.borders.left.lineStyle = xlsio.LineStyle.thin;
      cell.cellStyle.borders.right.lineStyle = xlsio.LineStyle.thin;
      cell.cellStyle.borders.top.lineStyle = xlsio.LineStyle.thin;
      cell.cellStyle.borders.bottom.lineStyle = xlsio.LineStyle.thin;
    }

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

Future<void> generateExcelBoletim({
  required UserFirebase user,
  required List<SubjectModule> listSubject,
  required List<UserNote> listUserNote,
  required List<Note> listNotes,
}) async {
  final workbook = xlsio.Workbook();
  final sheet = workbook.worksheets[0];

  final logoImage = await _loadLogoImage();
  sheet.name = 'Boletim';

  final picture = sheet.pictures.addStream(1, 1, logoImage);
  picture.width = 240;

  // 🔷 CABEÇALHO DA ESCOLA
  final infoRange = sheet.getRangeByName('B1:J6');
  infoRange.merge();
  infoRange.setText('ANA NERY - ESCOLA TÉCNICA DE ENFERMAGEM\n'
      'CREDENCIADA PELA PORTARIA Nº 919, DE 11 DE SETEMBRO DE 2023\n'
      'Parecer nº 299/2023-CEDF, de 29 de agosto de 2023\n'
      'CNPJ: 32.032.304/0001-27\n'
      'Conjunto A, SN, Lote 22, Residencial Sandray, Planaltina, Brasília - Distrito Federal\n'
      '(61) 99501-3912 — ananerybsb@gmail.com');
  infoRange.cellStyle.wrapText = true;
  infoRange.cellStyle.fontSize = 10;
  infoRange.cellStyle.hAlign = xlsio.HAlignType.left;
  infoRange.cellStyle.vAlign = xlsio.VAlignType.center;

  // 🔷 TÍTULO
  sheet.getRangeByName('A8:J8').merge();
  sheet.getRangeByName('A8').setText('-- BOLETIM DE AVALIAÇÃO --');
  sheet.getRangeByName('A8').cellStyle.bold = true;
  sheet.getRangeByName('A8').cellStyle.hAlign = xlsio.HAlignType.center;
  sheet.getRangeByName('A8').cellStyle.fontSize = 12;
  sheet.getRangeByName('A8').cellStyle.fontColor = '#7030A0'; // Roxo

  // 🔷 DADOS DO ALUNO
  sheet.getRangeByName('A10').setText('Aluno(a):');
  sheet.getRangeByName('A10').cellStyle.bold = true; // Bold
  sheet.getRangeByName('B10:D10').merge();
  sheet.getRangeByName('B10').setText(user.name);
  sheet.getRangeByName('B10').cellStyle.hAlign = xlsio.HAlignType.left;

  sheet.getRangeByName('A11').setText('Curso:');
  sheet.getRangeByName('A11').cellStyle.bold = true; // Bold
  sheet.getRangeByName('B11:H11').merge();
  sheet.getRangeByName('B11').setText(
      'Técnico em Enfermagem – Eixo Tecnológico: Ambiente, Saúde e Segurança – CBO 3222-05');
  sheet.getRangeByName('B11').cellStyle.hAlign = xlsio.HAlignType.left;

  sheet.getRangeByName('A12').setText('Regime:');
  sheet.getRangeByName('A12').cellStyle.bold = true; // Bold
  sheet.getRangeByName('B12').setText('Modular (2ª a 6ª feira)');
  sheet.getRangeByName('B12').cellStyle.hAlign = xlsio.HAlignType.left;

  sheet.getRangeByName('D12').setText('Turno:');
  sheet.getRangeByName('D12').cellStyle.bold = true; // Bold
  sheet.getRangeByName('E12').setText('Noturno');
  sheet.getRangeByName('E12').cellStyle.hAlign = xlsio.HAlignType.left;

  sheet.getRangeByName('G12').setText('Ano:');
  sheet.getRangeByName('G12').cellStyle.bold = true; // Bold
  sheet.getRangeByName('H12').setText('2024');
  sheet.getRangeByName('H12').cellStyle.hAlign = xlsio.HAlignType.left;

// 🔷 CABEÇALHO DA TABELA
  const headerRow = 14;
  final headers = [
    'MÓDULO',
    'DISCIPLINA',
    'CARGA HORÁRIA',
    'AV1',
    'AV2',
    'TRAB',
    'REC',
    'FT',
    'MÉDIA',
    'RESULT. FINAL'
  ];

  for (int i = 0; i < headers.length; i++) {
    final cell = sheet.getRangeByIndex(headerRow, i + 1);
    cell.setText(headers[i]);
    cell.cellStyle.bold = true;
    cell.cellStyle.backColor = '#D9D9D9';
    cell.cellStyle.hAlign = xlsio.HAlignType.center;
    cell.cellStyle.vAlign =
        xlsio.VAlignType.center; // Vertical alignment for header
    cell.cellStyle.borders.all.lineStyle = xlsio.LineStyle.thin; // Add borders
  }

// 🔷 PREENCHIMENTO DAS DISCIPLINAS
  int currentRow = headerRow + 1;
  String? currentModule;
  int moduleStartRow = currentRow;

  for (int i = 0; i < listSubject.length; i++) {
    final subject = listSubject[i];

    // Handle module merging
    if (currentModule == null || currentModule != subject.module) {
      if (currentModule != null) {
        // Merge previous module's cells
        sheet.getRangeByIndex(moduleStartRow, 1, currentRow - 1, 1).merge();
        sheet.getRangeByIndex(moduleStartRow, 1).cellStyle.hAlign =
            xlsio.HAlignType.center;
        sheet.getRangeByIndex(moduleStartRow, 1).cellStyle.vAlign =
            xlsio.VAlignType.center;
        sheet
            .getRangeByIndex(moduleStartRow, 1)
            .setText(currentModule); // Set module text
      }
      currentModule = subject.module;
      moduleStartRow = currentRow;
    }

    final userNotes = listUserNote
        .where((n) => n.userId == user.uid && n.subjectId == subject.uid)
        .toList();

    final notesMap = {
      for (final note in listNotes) note.uid: note.title,
    };

    final notas = {
      for (final note in userNotes)
        notesMap[note.noteId] ?? '': note.value.replaceAll('.', ','),
    };

    final soma = userNotes.fold<double>(
      0,
      (sum, note) => sum + double.tryParse(note.value.replaceAll(',', '.'))!,
    );

    final resultFinal = soma >= 6.0 ? 'AP' : 'RP';

    final values = [
      '', // Module column will be merged later
      subject.title,
      subject.hour.toString(),
      notas['AV1'] ?? '',
      notas['AV2'] ?? '',
      notas['TRAB'] ?? '',
      notas['REC'] ?? '',
      notas['FT'] ?? '',
      soma.toStringAsFixed(2).replaceAll('.', ','),
      resultFinal,
    ];

    for (int j = 0; j < values.length; j++) {
      final cell = sheet.getRangeByIndex(currentRow, j + 1);
      cell.setText(values[j]);
      cell.cellStyle.borders.all.lineStyle =
          xlsio.LineStyle.thin; // Add borders to data cells

      // Center numerical/result columns
      if (j >= 2 && j <= 9) {
        // Columns C to J (Carga Horária to Result. Final)
        cell.cellStyle.hAlign = xlsio.HAlignType.center;
      } else {
        // Left align for others (Discipline)
        cell.cellStyle.hAlign = xlsio.HAlignType.left;
      }
    }

    currentRow++;
    // After the loop, merge the last module's cells
    // ignore: unnecessary_null_comparison
    if (i == listSubject.length - 1 && currentModule != null) {
      sheet.getRangeByIndex(moduleStartRow, 1, currentRow - 1, 1).merge();
      sheet.getRangeByIndex(moduleStartRow, 1).cellStyle.hAlign =
          xlsio.HAlignType.center;
      sheet.getRangeByIndex(moduleStartRow, 1).cellStyle.vAlign =
          xlsio.VAlignType.center;
      sheet
          .getRangeByIndex(moduleStartRow, 1)
          .setText(currentModule); // Set module text
    }
  }

// Ensure all cells in the data section also have borders.
// This is a catch-all; the loop above should already apply it.
  sheet
      .getRangeByName('A15:J${currentRow - 1}')
      .cellStyle
      .borders
      .all
      .lineStyle = xlsio.LineStyle.thin;

  // 🔷 RODAPÉ COM RESULTADOS E HORAS
  final footerRow = currentRow + 2;

  sheet
      .getRangeByName('A$footerRow:J$footerRow')
      .merge(); // Merge across all columns for result
  sheet.getRangeByIndex(footerRow, 1).setText('RESULTADO: APROVADO');
  sheet.getRangeByIndex(footerRow, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(footerRow, 1).cellStyle.hAlign =
      xlsio.HAlignType.right; // Right align

  sheet
      .getRangeByIndex(footerRow + 1, 1)
      .setText('CARGA HORÁRIA TOTAL DOS MÓDULOS (I + II + III)');
  sheet.getRangeByIndex(footerRow + 1, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(footerRow + 1, 1).cellStyle.hAlign =
      xlsio.HAlignType.left;

  sheet.getRangeByIndex(footerRow + 1, 2).setText('1200h');
  sheet.getRangeByIndex(footerRow + 1, 2).cellStyle.hAlign =
      xlsio.HAlignType.center;
  sheet.getRangeByIndex(footerRow + 1, 2).cellStyle.borders.all.lineStyle =
      xlsio.LineStyle.thin; // Borders

  sheet
      .getRangeByIndex(footerRow + 2, 1)
      .setText('CARGA HORÁRIA TOTAL DO ESTÁGIO SUPERVISIONADO (I + II)');
  sheet.getRangeByIndex(footerRow + 2, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(footerRow + 2, 1).cellStyle.hAlign =
      xlsio.HAlignType.left;

  sheet.getRangeByIndex(footerRow + 2, 2).setText('400h');
  sheet.getRangeByIndex(footerRow + 2, 2).cellStyle.hAlign =
      xlsio.HAlignType.center;
  sheet.getRangeByIndex(footerRow + 2, 2).cellStyle.borders.all.lineStyle =
      xlsio.LineStyle.thin; // Borders

  sheet.getRangeByIndex(footerRow + 3, 1).setText('TOTAL DE HORAS DO CURSO');
  sheet.getRangeByIndex(footerRow + 3, 1).cellStyle.bold = true;
  sheet.getRangeByIndex(footerRow + 3, 1).cellStyle.hAlign =
      xlsio.HAlignType.left;

  sheet.getRangeByIndex(footerRow + 3, 2).setText('1600h');
  sheet.getRangeByIndex(footerRow + 3, 2).cellStyle.hAlign =
      xlsio.HAlignType.center;
  sheet.getRangeByIndex(footerRow + 3, 2).cellStyle.borders.all.lineStyle =
      xlsio.LineStyle.thin; // Borders

// Merge cells for the total hours description to extend across more columns if needed
  sheet.getRangeByName('A${footerRow + 1}:A${footerRow + 3}').columnWidth =
      35; // Adjust width if needed

  // 🔷 CRITÉRIO DE AVALIAÇÃO / LEGENDA
  final legendRow = footerRow + 5;
  sheet
      .getRangeByName('A$legendRow:J${legendRow + 10}')
      .merge(); // Adjust the row span as needed
  sheet.getRangeByName('A$legendRow').setText(
      'CRITÉRIO DE AVALIAÇÃO / LEGENDA\n'
      '  • A duração do módulo-aula é de 50 (cinquenta) minutos, sendo no mínimo 4 (quatro) aulas diárias de 2ª a 6ª feira, e a carga horária semanal mínima de 18h30min excluídos os 10 (dez) minutos reservado para o intervalo diário;\n'
      '  • A avaliação do aproveitamento do aluno será expressa através de notas que variam de 0 (zero) a 10 (dez);\n'
      '  • O estágio supervisionado é reprovado se o último dia desse módulo for menos de 0 (zero) ou 10 (dez);\n'
      '  • O aluno para ser considerado APROVADO deve obter no mínimo 6.0 pontos (AV1 ou AV2) e no mínimo 6.0 pontos (AV1 + AV2 + TRABALHO) em cada componente curricular.\n'
      '  • A conclusão com êxito de todos os módulos e do estágio supervisionado, confere o diploma de Técnico em Enfermagem – EixoTecnológico: Ambiente, Saúde e Segurança, desde que comprovada a conclusão do Ensino Médio ou equivalente.\n'
      '  • (AP) - Aprovado / (RP) - Reprovado / (APR) - Aproveitamento');
  sheet.getRangeByName('A$legendRow').cellStyle.bold =
      true; // "CRITÉRIO DE AVALIAÇÃO / LEGENDA" should be bold
  sheet.getRangeByName('A$legendRow').cellStyle.wrapText = true;
  sheet.getRangeByName('A$legendRow').cellStyle.hAlign = xlsio.HAlignType.left;
  sheet.getRangeByName('A$legendRow').cellStyle.vAlign =
      xlsio.VAlignType.top; // Top align
  sheet.getRangeByName('A$legendRow').cellStyle.fontSize =
      9; // Smaller font for legend

// To bold only "CRITÉRIO DE AVALIAÇÃO / LEGENDA" and not the whole text,
// you might need to split this into two separate cell entries, or use rich text if xlsio supports it for partial bolding.
// As a workaround, you can set the whole text bold, and then try to unbold programmatically if the library offers fine-grained control,
// or just accept the whole text bold. For this example, I'm setting the entire text bold as per the previous line.

  // 🔽 Gera e faz download do arquivo
  final bytes = workbook.saveAsStream();
  workbook.dispose();

  final blob = html.Blob([bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  // ignore: unused_local_variable
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'boletim_${user.name}.xlsx')
    ..click();
  html.Url.revokeObjectUrl(url);
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
