import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
class RewardService {

  static Future<int> getRewardIndexFromSheet(
      List<String> segmentTexts,
      int Function() fallback,
      String mobile,
      ) async {

    try {

      const apiUrl =
          'https://script.google.com/macros/s/AKfycbz-evYzqkf2FGHp-0orT5O4s3wO6XcrsZpUXHJ_RXXipvMWlJZeTbPJxn7ae_bZAq0WPA/exec';

      debugPrint("Sending Mobile: $mobile");
      debugPrint("URL: $apiUrl?mobile=$mobile");

      final response =
      await http.get(Uri.parse('$apiUrl?mobile=$mobile'));

      final data =
      jsonDecode(response.body);

      debugPrint("API Response: $data");


      final reward =
      data['reward'];

      debugPrint("Reward from API: $reward");

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

      debugPrint("Mapped Reward Text: $rewardText");

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