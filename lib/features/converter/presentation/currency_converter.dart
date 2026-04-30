import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/database/hive_service.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/connectivity_service.dart';

class CurrencyConverter extends StatefulWidget {
  const CurrencyConverter({super.key});

  @override
  State<CurrencyConverter> createState() => _CurrencyConverterState();
}

class _CurrencyConverterState extends State<CurrencyConverter> {
  final _amountController = TextEditingController(text: '100000');
  String _fromCurrency = 'IDR';
  String _toCurrency = 'USD';
  double? _result;
  bool _isLoading = false;
  String? _lastUpdated;
  String? _errorMessage;

  final _currencies = ['IDR', 'USD', 'EUR', 'MYR', 'SGD'];

  // Fallback rates relatif terhadap IDR (perkiraan, digunakan jika API gagal)
  static const _fallbackRatesFromIDR = {
    'IDR': 1.0,
    'USD': 0.0000614,
    'EUR': 0.0000554,
    'MYR': 0.000274,
    'SGD': 0.0000816,
  };

  @override
  void initState() {
    super.initState();
    _convert();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _convert() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null) {
      setState(() => _errorMessage = 'Masukkan jumlah yang valid');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic>? rates;

      final cached = HiveService.getCached('exchange_rates_$_fromCurrency');
      if (cached != null) {
        rates = Map<String, dynamic>.from(cached);
        _lastUpdated = 'Dari cache';
      }

      final isOnline = await ConnectivityService.isConnected();

      if (rates == null && !isOnline) {
        _convertWithFallback(amount);
        setState(() => _isLoading = false);
        return;
      }

      if (isOnline) {
        final apiKey = dotenv.env['EXCHANGERATE_API_KEY'] ?? '';

        final response = await ApiClient.get(
          'https://v6.exchangerate-api.com/v6/$apiKey/latest/$_fromCurrency',
        );

        final data = response.data;
        if (data is Map<String, dynamic> && data['result'] == 'success') {
          rates = Map<String, dynamic>.from(data['conversion_rates']);
          await HiveService.cacheWithTtl(
            'exchange_rates_$_fromCurrency',
            rates,
          );
          _lastUpdated = 'Baru saja';
        } else {
          final errorType = data is Map ? data['error-type'] : 'unknown';
          setState(() {
            _errorMessage = 'API error: $errorType';
            _isLoading = false;
          });
          return;
        }
      }

      if (rates != null && rates.containsKey(_toCurrency)) {
        final rate = (rates[_toCurrency] as num).toDouble();
        setState(() {
          _result = amount * rate;
          _errorMessage = null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Mata uang $_toCurrency tidak ditemukan dalam data.';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Currency convert error: $e');

      // Coba cache dulu
      final cached = HiveService.getCached('exchange_rates_$_fromCurrency');
      if (cached != null) {
        final rates = Map<String, dynamic>.from(cached);
        if (rates.containsKey(_toCurrency)) {
          final rate = (rates[_toCurrency] as num).toDouble();
          setState(() {
            _result = amount * rate;
            _lastUpdated = 'Dari cache';
            _errorMessage = null;
          });
        }
      } else {
        // Fallback ke rate statis
        _convertWithFallback(amount);
      }
      setState(() => _isLoading = false);
    }
  }

  void _convertWithFallback(double amount) {
    final fromRate = _fallbackRatesFromIDR[_fromCurrency];
    final toRate = _fallbackRatesFromIDR[_toCurrency];

    if (fromRate != null && toRate != null && fromRate > 0) {
      final amountInIDR = amount / fromRate;
      final result = amountInIDR * toRate;
      setState(() {
        _result = result;
        _lastUpdated = 'Estimasi (rate offline)';
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = 'Gagal mengambil data kurs. Coba lagi nanti.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimasi harga souvenir & tiket pertunjukan',
            style: TextStyle(color: kColorTextLight, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Jumlah',
              prefixIcon: Icon(Icons.monetization_on),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _fromCurrency,
                  decoration: const InputDecoration(labelText: 'Dari'),
                  items: _currencies
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _fromCurrency = v);
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      final temp = _fromCurrency;
                      _fromCurrency = _toCurrency;
                      _toCurrency = temp;
                    });
                  },
                  icon: const Icon(Icons.swap_horiz, color: kColorPrimary),
                ),
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _toCurrency,
                  decoration: const InputDecoration(labelText: 'Ke'),
                  items: _currencies
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _toCurrency = v);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _convert,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Konversi'),
            ),
          ),
          const SizedBox(height: 16),
          if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: kColorError.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kColorError.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: kColorError, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: kColorError, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          if (_result != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kColorSurface,
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: kColorSecondary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    '${_amountController.text} $_fromCurrency',
                    style: const TextStyle(fontSize: 16, color: kColorTextLight),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.arrow_downward, color: kColorPrimary),
                  const SizedBox(height: 4),
                  Text(
                    '${_result!.toStringAsFixed(2)} $_toCurrency',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: kColorPrimary,
                    ),
                  ),
                  if (_lastUpdated != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Terakhir diperbarui: $_lastUpdated',
                      style: const TextStyle(
                          fontSize: 11, color: kColorTextLight),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
