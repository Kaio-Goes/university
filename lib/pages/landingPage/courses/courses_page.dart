import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/text_fields.dart';
import 'package:university/components/validation/validation.dart';
import 'package:university/core/utilities/styles.constants.dart';
import 'package:university/core/services/send_email.dart';

class CoursesPage extends StatefulWidget {
  final String titleCourse;
  final String msgCourse;
  final String urlImage;
  final String semesters;
  final String typeFormatCourse;
  final String? aboutTheCourse;
  const CoursesPage(
      {super.key,
      required this.titleCourse,
      required this.msgCourse,
      required this.urlImage,
      required this.semesters,
      required this.typeFormatCourse,
      this.aboutTheCourse});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _selectedModality;
  String? _selectedUnit;

  _clickButton() async {
    bool formOk = _formKey.currentState!.validate();

    if (!formOk) {
      return;
    }

    var responseSendEmail = await SendEmail().sendEmail(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        modality: _selectedUnit!,
        course: widget.titleCourse,
        unit: _selectedUnit!);

    if (responseSendEmail.statusCode == 200) {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sucesso'),
            content: const Text(
                'Um de nossos consultores entrará em contato com você.'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  // Limpar o formulário
                  _formKey.currentState?.reset();
                  _nameController.clear();
                  _emailController.clear();
                  _phoneController.clear();
                  setState(() {
                    _selectedModality = null;
                    _selectedUnit = null;
                  });

                  Navigator.of(context).pop();
                },
                child: const Text('Combinado!'),
              ),
            ],
          );
        },
      );
    }
  }

  void _scrollCourse() {
    _scrollController.animateTo(
      450.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarComponent(),
      drawer: const DrawerComponent(),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
          return Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 520,
                    width: double.infinity,
                    child: Image.asset(
                      widget.urlImage,
                      fit: BoxFit.cover,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                  Container(
                    height: 520,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          const Color.fromARGB(255, 8, 21, 61)
                              .withValues(alpha: 0.5),
                          const Color.fromARGB(255, 20, 42, 138)
                              .withValues(alpha: 0.5)
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 80,
                    left: isSmallScreen
                        ? 0
                        : MediaQuery.of(context).size.height * 0.25,
                    child: SizedBox(
                      width: isSmallScreen ? 400 : 600,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Início > Cursos > ${widget.titleCourse}',
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.titleCourse,
                              style: texTitleCard,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              widget.msgCourse,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 226, 223, 223),
                                fontSize: 13.0,
                              ),
                            ),
                            const SizedBox(height: 30),
                            Row(
                              children: [
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(widget.semesters,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white)),
                                const SizedBox(width: 25),
                                Container(
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                  child: const Icon(Icons.school_outlined,
                                      size: 20),
                                ),
                                const SizedBox(width: 10),
                                Text(widget.typeFormatCourse,
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 80),
                            Row(
                              children: [
                                buttonTransparent(
                                    label: 'Sobre o Curso',
                                    function: _scrollCourse),
                                const SizedBox(width: 5),
                                // buttonTransparent(label: 'Grade Curricular')
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 60,
                  left: isSmallScreen
                      ? 10
                      : MediaQuery.of(context).size.height * 0.25,
                  right: isSmallScreen
                      ? 10
                      : MediaQuery.of(context).size.height * 0.25,
                ),
                child: isSmallScreen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sobre o Curso',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 35),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: Text(
                                  widget.aboutTheCourse ?? '',
                                  style: const TextStyle(
                                    height: 2,
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 30),
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 40),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Receba uma consultoria gratuita sobre o curso, valores e mais detalhes',
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 30),
                                            textFormField(
                                                controller: _nameController,
                                                validator: (value) =>
                                                    validInputNome(value),
                                                hint:
                                                    'Digite seu nome completo',
                                                label: 'Nome Completo:',
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1),
                                            const SizedBox(height: 25),
                                            textFormField(
                                                controller: _emailController,
                                                validator: (value) =>
                                                    validInputNome(value),
                                                hint: 'Digite seu e-mail',
                                                label: 'E-mail:',
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1),
                                            const SizedBox(height: 25),
                                            textFormField(
                                              controller: _phoneController,
                                              validator: validInputPhone,
                                              textInputType:
                                                  TextInputType.phone,
                                              inputFormatters: [phoneMask],
                                              label: "Celular",
                                              hint: "(61) 99999-9999",
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                            ),
                                            const SizedBox(height: 25),
                                            dropDownField(
                                              label: 'Modalidade',
                                              select: _selectedModality,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedModality = value;
                                                });
                                              },
                                              hintText:
                                                  'Selecione a Modalidade',
                                              items: <String>['Noturno']
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              validator: (value) =>
                                                  validatorDropdown(value),
                                            ),
                                            const SizedBox(height: 25),
                                            dropDownField(
                                              label: 'Unidade de Interesse',
                                              select: _selectedUnit,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedUnit = value;
                                                });
                                              },
                                              items: <String>[
                                                'Planaltina',
                                                'Paranoá'
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              hintText: 'Selecione a unidade',
                                              validator: (value) =>
                                                  validatorDropdown(value),
                                            ),
                                            const SizedBox(height: 25),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _clickButton();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue),
                                                child: const Text(
                                                  'Quero Saber Mais',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sobre Curso',
                                  style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 35),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.40,
                                  child: Text(widget.aboutTheCourse ?? '',
                                      style: const TextStyle(
                                        height: 2,
                                      )))
                            ],
                          ),
                          Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.30,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black12,
                                    width: 1,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(12)),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 40),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Receba uma consultoria gratuita sobre o curso, valores e mais detalhes',
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          children: [
                                            const SizedBox(height: 30),
                                            textFormField(
                                                controller: _nameController,
                                                validator: (value) =>
                                                    validInputNome(value),
                                                hint:
                                                    'Digite seu nome completo',
                                                label: 'Nome Completo:',
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1),
                                            const SizedBox(height: 25),
                                            textFormField(
                                                controller: _emailController,
                                                validator: (value) =>
                                                    validInputNome(value),
                                                hint: 'Digite seu e-mail',
                                                label: 'E-mail:',
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    1),
                                            const SizedBox(height: 25),
                                            textFormField(
                                              controller: _phoneController,
                                              validator: validInputPhone,
                                              textInputType:
                                                  TextInputType.phone,
                                              inputFormatters: [phoneMask],
                                              label: "Celular",
                                              hint: "(61) 99999-9999",
                                              size: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  1,
                                            ),
                                            const SizedBox(height: 25),
                                            dropDownField(
                                              label: 'Modalidade',
                                              select: _selectedModality,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedModality = value;
                                                });
                                              },
                                              hintText:
                                                  'Selecione a Modalidade',
                                              items: <String>['Noturno']
                                                  .map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              validator: (value) =>
                                                  validatorDropdown(value),
                                            ),
                                            const SizedBox(height: 25),
                                            dropDownField(
                                              label: 'Unidade de Interesse',
                                              select: _selectedUnit,
                                              onChanged: (value) {
                                                setState(() {
                                                  _selectedUnit = value;
                                                });
                                              },
                                              items: <String>[
                                                'Planaltina',
                                                'Paranoá'
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                              hintText: 'Selecione a unidade',
                                              validator: (value) =>
                                                  validatorDropdown(value),
                                            ),
                                            const SizedBox(height: 25),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _clickButton();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.blue),
                                                child: const Text(
                                                  'Quero Saber Mais',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
              ),
              const SizedBox(height: 30),
              const Footer()
            ],
          );
        }),
      ),
    );
  }
}
