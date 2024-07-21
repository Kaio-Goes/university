import 'package:flutter/material.dart';
import 'package:university/components/app_bar_component.dart';
import 'package:university/components/drawer_component.dart';
import 'package:university/components/footer.dart';
import 'package:university/components/forms/register_studant_form.dart';
import 'package:university/components/my_courses.dart';
import 'package:university/components/text_studant.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToRegisterForm() {
    _scrollController.animateTo(
      450.0,
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToCourses() {
    _scrollController.animateTo(
      800.0,
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
            bool isLargeScreen = constraints.maxWidth > 1100;
            bool isSmallScreen = constraints.maxWidth < 600;
            return Column(
              children: [
                Stack(
                  children: [
                    SizedBox(
                      height: 520,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/studants.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                    Positioned(
                      top: 80,
                      left: isSmallScreen
                          ? 0
                          : MediaQuery.of(context).size.height * 0.25,
                      child: SizedBox(
                        width: isSmallScreen ? 380 : 500,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextStudant(
                            function: _scrollToRegisterForm,
                            functionTwo: _scrollToCourses,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -50),
                        child: SizedBox(
                          width: isLargeScreen
                              ? MediaQuery.of(context).size.width * 0.52
                              : MediaQuery.of(context).size.width * 0.9,
                          child:
                              RegisterStudantForm(isSmallScreen: isSmallScreen),
                        ),
                      ),
                      MyCourses(isSmallScreen: isSmallScreen)
                    ],
                  ),
                ),
                const Footer()
              ],
            );
          },
        ),
      ),
    );
  }
}
