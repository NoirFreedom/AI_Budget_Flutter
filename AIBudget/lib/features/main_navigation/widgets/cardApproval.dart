import 'package:AIBudget/features/main_navigation/payment_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardApprovalData {
  final DateTime datetime;
  final String category;
  final String type;
  final int amount;

  CardApprovalData({
    required this.datetime,
    required this.category,
    required this.type,
    required this.amount,
  });

  factory CardApprovalData.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['datetime']);
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return CardApprovalData(
      datetime: parsedDate,
      category: json['category'],
      type: json['type'],
      amount: json['amount'],
    );
  }
}

Future<List<CardApprovalData>> fetchCardApprovals(
    DateTime startDate, DateTime endDate) async {
  // API 주소를 설정해주세요.
  var apiUrl =
      "https://5431508973.for-seoul.synctreengine.com/get_transactions";

  var response = await http.post(Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(
        {
          "is_week": false,
          "start_date": startDate.toIso8601String(),
          "end_date": endDate.toIso8601String()
        },
      ));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse =
        json.decode(utf8.decode(response.bodyBytes));
    final List<dynamic> transactionList = jsonResponse['result'];
    return transactionList
        .map((data) => CardApprovalData.fromJson(data))
        .toList();
  } else {
    throw Exception('Failed to load transaction data');
  }
}

class CardApproval extends StatefulWidget {
  final CardApprovalData approvalData;

  const CardApproval({
    Key? key,
    required this.approvalData,
  }) : super(key: key);

  @override
  State<CardApproval> createState() => _CardApprovalState();
}

class _CardApprovalState extends State<CardApproval> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        tileColor: Colors.amber,
        title: RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: <TextSpan>[
              TextSpan(
                text: "${widget.approvalData.type}   ",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: widget.approvalData.type == "지출"
                        ? Colors.red.shade400
                        : Colors.lightBlue.shade500),
              ),
              TextSpan(
                text: "${widget.approvalData.amount}원  ",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: "(${widget.approvalData.category})",
                style: const TextStyle(fontSize: 16),
              )
            ],
          ),
        ),
        subtitle: Text(
            widget.approvalData.datetime.toLocal().toString().split(".")[0]),
        trailing: const FaIcon(FontAwesomeIcons.chevronRight),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  PaymentDetailSheet(userData: widget.approvalData),
            ),
          );
        },
      ),
    );
  }
}
