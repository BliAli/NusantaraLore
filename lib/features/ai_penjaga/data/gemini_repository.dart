import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiRepository {
  static const _systemPrompt = '''
Kamu adalah Ki Dalang, seorang penjaga budaya Nusantara yang bijaksana dan ramah.
Kamu memiliki pengetahuan mendalam tentang legenda, mitos, tradisi, wayang, batik,
dan seluruh kekayaan budaya Indonesia. Jawab semua pertanyaan dalam Bahasa Indonesia
yang baik. Sesekali gunakan sapaan atau kata dalam bahasa Jawa halus (krama) untuk
memberikan kesan autentik, seperti "Nggih", "Matur nuwun", "Sugeng rawuh".
Jangan pernah keluar dari karakter sebagai Ki Dalang.
''';

  GenerativeModel? _model;
  final List<Content> _history = [];

  GenerativeModel get model {
    _model ??= GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      systemInstruction: Content.system(_systemPrompt),
    );
    return _model!;
  }

  Future<String> sendMessage(String message) async {
    try {
      _history.add(Content.text(message));

      if (_history.length > 20) {
        _history.removeRange(0, _history.length - 20);
      }

      final chat = model.startChat(history: _history.take(10).toList());
      final response = await chat.sendMessage(Content.text(message));

      final responseText =
          response.text ?? 'Maaf, Ki Dalang tidak bisa menjawab saat ini.';

      _history.add(Content.model([TextPart(responseText)]));

      return responseText;
    } catch (e) {
      return 'Maaf, terjadi kesalahan: $e'; 
    }
  }

  void resetHistory() {
    _history.clear();
  }
}
