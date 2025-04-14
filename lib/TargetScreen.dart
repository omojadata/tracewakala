import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import 'models.dart';

// // Model class to handle the target data
// class TargetData {
//   final double serviceBase;
//   final double serviceTarget;
//   final double servedAchievement;
//   final double servedCommission;
//   final double inactiveBase;
//   final double inactiveTarget;
//   final double inactiveAchievement;
//   final double inactiveCommission;
//   final double recruitmentTarget;
//   final double recruitmentAchievement;
//   final double recruitmentCommission;
//   final double bonus;

//   TargetData({
//     required this.serviceBase,
//     required this.serviceTarget,
//     required this.servedAchievement,
//     required this.servedCommission,
//     required this.inactiveBase,
//     required this.inactiveTarget,
//     required this.inactiveAchievement,
//     required this.inactiveCommission,
//     required this.recruitmentTarget,
//     required this.recruitmentAchievement,
//     required this.recruitmentCommission,
//     required this.bonus,
//   });

//   factory TargetData.fromJson(Map<String, dynamic> json) {
//     return TargetData(
//       serviceBase: json['service base'] as double,
//       serviceTarget: json['service target'] as double,
//       servedAchievement: json['served achievement'] as double,
//       servedCommission: json['served commission'] as double,
//       inactiveBase: json['inactive base'] as double,
//       inactiveTarget: json['inactive target'] as double,
//       inactiveAchievement: json['inactive achievement'] as double,
//       inactiveCommission: json['inactive commission'] as double,
//       recruitmentTarget: json['recruitment target'] as double,
//       recruitmentAchievement: json['recruitment achievement'] as double,
//       recruitmentCommission: json['recruitment commission'] as double,
//       bonus: json['bonus'] as double,
//     );
//   }
// }

class TargetScreen extends StatefulWidget {
//   const TargetScreen({Key? key}) : super(key: key);

  final User user;

  TargetScreen({
    required this.user,
  });

  @override
  _TargetScreenState createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  late Future<TargetData> _targetData;
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _targetData = _fetchTargetData();
  }

  Future<TargetData> _fetchTargetData() async {
    try {
      final response = await _dio.get(
          'https://omojadata.pockethost.io/targetbase/${widget.user.email}');
      // print("https://omojadata.pockethost.io/crdbbase/${widget.user.email}");
      if (response.statusCode == 200) {
        print(response.data);
        return TargetData.fromJson(response.data);
      } else {
        throw Exception('Failed to load agents');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  // Future<TargetData> _fetchTargetData() async {
  //   // Simulating API call with the provided JSON
  //   const String jsonData = '''
  //     {
  //       "service base": 151,
  //       "service target": 137,
  //       "served achievement": 0,
  //       "served commission": 100000,
  //       "inactive base": 19,
  //       "inactive target": 10,
  //       "inactive achievement": 0,
  //       "inactive commission": 100000,
  //       "recruitment target": 10,
  //       "recruitment achievement": 4,
  //       "recruitment commission": 100000,
  //       "bonus": 100000
  //     }
  //   ''';
  //
  //   // Simulate network delay
  //   await Future.delayed(const Duration(seconds: 1));
  //   return TargetData.fromJson(json.decode(jsonData));
  // }

  Widget _buildInfoRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Information'),
      ),
      body: FutureBuilder<TargetData>(
        future: _targetData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Service Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Base', data.serviceBase),
                    _buildInfoRow('Target', data.serviceTarget),
                    _buildInfoRow('Achievement', data.servedAchievement),
                    _buildInfoRow('Commission', data.servedCommission),
                    const SizedBox(height: 20),
                    const Text(
                      'Inactive Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Base', data.inactiveBase),
                    _buildInfoRow('Target', data.inactiveTarget),
                    _buildInfoRow('Achievement', data.inactiveAchievement),
                    _buildInfoRow('Commission', data.inactiveCommission),
                    const SizedBox(height: 20),
                    const Text(
                      'Recruitment Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Target', data.recruitmentTarget),
                    _buildInfoRow('Achievement', data.recruitmentAchievement),
                    _buildInfoRow('Commission', data.recruitmentCommission),
                    const SizedBox(height: 20),
                    const Text(
                      'Bonus Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfoRow('Bonus', data.bonus),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
