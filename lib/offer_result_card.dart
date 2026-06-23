import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String> getReward() async {

  final response =
  await http.get(
    Uri.parse(
      'https://script.google.com/macros/s/AKfycbze6Ig99t_fGV7LVttvBIATK6eRbwVz6qosHNyuYyvhCNM85dlvFTm1RzCMtaI53EXLbA/exec',
    ),
  );

  final data =
  jsonDecode(response.body);

  return data['reward'];
}