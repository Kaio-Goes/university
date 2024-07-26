import 'package:flutter/material.dart';
import 'package:university/pages/landingPage/units/pole_unit_page.dart';

class UnitsCard extends StatelessWidget {
  final String local;
  final String pole;
  final String address;
  final String phone;
  const UnitsCard(
      {super.key,
      required this.local,
      required this.pole,
      required this.address,
      required this.phone});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: SizedBox(
        width: 270,
        child: Padding(
          padding: const EdgeInsets.all(35.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local,
                style: TextStyle(fontSize: 16, color: Colors.red[600]),
              ),
              const SizedBox(height: 5),
              Text(
                pole,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      address,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => PoleUnitPage(
                                pole: pole,
                                address: address,
                                phone: phone,
                              )),
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const SizedBox(
                    width: 160,
                    child: Text(
                      'Saiba Mais',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
