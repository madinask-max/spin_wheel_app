import 'dart:convert';
import 'package:http/http.dart' as http;
class RewardService {

  static Future<int> getRewardIndexFromSheet(
      List<String> segmentTexts,
      int Function() fallback,
      ) async {

    try {

      const apiUrl =
          'https://script.google.com/macros/s/AKfycbxK2bAGDPwGLFU4JJ2QApLdxp042Sqbq6yM1GI65B_5hgN-ZH-MWA6dmoyuF8P7uvtFrg/exec';

      final response =
      await http.get(Uri.parse(apiUrl));

      final data =
      jsonDecode(response.body);

      final reward =
      data['reward'];

      String rewardText;

      switch (reward.toString().trim()) {

        case "0.1":
        case "10":
        case "10%":
          rewardText = "10%";
          break;

        case "0.15":
        case "15":
        case "15%":
          rewardText = "15%";
          break;

        case "0.2":
        case "20":
        case "20%":
          rewardText = "20%";
          break;

        case "0.25":
        case "25":
        case "25%":
          rewardText = "25%";
          break;

        case "0.3":
        case "30":
        case "30%":
          rewardText = "30%";
          break;

        case "0.5":
        case "50":
        case "50%":
          rewardText = "50%";
          break;

        default:
          rewardText = reward.toString();
      }

      final index =
      segmentTexts.indexOf(
          rewardText);

      if (index == -1) {
        return fallback();
      }

      return index;

    } catch (_) {
      return fallback();
    }
  }
}