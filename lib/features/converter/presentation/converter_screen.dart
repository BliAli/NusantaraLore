import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import 'currency_converter.dart';
import 'timezone_converter.dart';

class ConverterScreen extends StatelessWidget {
  const ConverterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kColorBackground,
        appBar: AppBar(
          title: const Text('Konverter'),
          bottom: const TabBar(
            indicatorColor: kColorSecondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(
                icon: Icon(Icons.currency_exchange),
                text: AppStrings.currencyConverter,
              ),
              Tab(
                icon: Icon(Icons.access_time),
                text: AppStrings.timezoneConverter,
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            CurrencyConverter(),
            TimezoneConverter(),
          ],
        ),
      ),
    );
  }
}
