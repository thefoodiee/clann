// import 'dart:io';
//
// abstract class ITextRecognizer {
//   Future<String> processImage(String imgPath);
// }
//
// class MLKitTextRecognizer extends ITextRecognizer {
//   late TextRecognizer recognizer;
//
//   MLKitTextRecognizer() {
//     recognizer = TextRecognizer();
//   }
//
//   void dispose() {
//     recognizer.close();
//   }
//
//   @override
//   Future<String> processImage(String imgPath) async {
//     final image = InputImage.fromFile(File(imgPath));
//     final recognized = await recognizer.processImage(image);
//     return recognized.text;
//   }
// }
//
// class RecognitionResponse {
//   final String imgPath;
//   final String recognizedText;
//
//   RecognitionResponse({
//     required this.imgPath,
//     required this.recognizedText,
//   });
//
//   @override
//   bool operator ==(covariant RecognitionResponse other) {
//     if (identical(this, other)) return true;
//
//     return other.imgPath == imgPath && other.recognizedText == recognizedText;
//   }
//
//   @override
//   int get hashCode => imgPath.hashCode ^ recognizedText.hashCode;
// }