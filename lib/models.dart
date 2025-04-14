class TargetData {
  final int serviceBase;
  final int serviceTarget;
  final int servedAchievement;
  final int servedCommission;
  final int inactiveBase;
  final int inactiveTarget;
  final int inactiveAchievement;
  final int inactiveCommission;
  final int recruitmentTarget;
  final int recruitmentAchievement;
  final int recruitmentCommission;
  final int bonus;

  TargetData({
    required this.serviceBase,
    required this.serviceTarget,
    required this.servedAchievement,
    required this.servedCommission,
    required this.inactiveBase,
    required this.inactiveTarget,
    required this.inactiveAchievement,
    required this.inactiveCommission,
    required this.recruitmentTarget,
    required this.recruitmentAchievement,
    required this.recruitmentCommission,
    required this.bonus,
  });

  factory TargetData.fromJson(Map<String, dynamic> json) {
    return TargetData(
      serviceBase: _roundUpToWhole(json['service base']),
      serviceTarget: _roundUpToWhole(json['service target']),
      servedAchievement: _roundUpToWhole(json['served achievement']),
      servedCommission: _roundUpToWhole(json['served commission']),
      inactiveBase: _roundUpToWhole(json['inactive base']),
      inactiveTarget: _roundUpToWhole(json['inactive target']),
      inactiveAchievement: _roundUpToWhole(json['inactive achievement']),
      inactiveCommission: _roundUpToWhole(json['inactive commission']),
      recruitmentTarget: _roundUpToWhole(json['recruitment target']),
      recruitmentAchievement: _roundUpToWhole(json['recruitment achievement']),
      recruitmentCommission: _roundUpToWhole(json['recruitment commission']),
      bonus: _roundUpToWhole(json['bonus']),
    );
  }

  static int _roundUpToWhole(dynamic number) {
    if (number is int) return number;
    if (number is double) return number.ceil();
    return 0;
  }
}

class AgentData {
  final String agentAccount;
  final String agentName;
  final String phone;
  final String location;
  final String zone;
  final bool isToActive;
  final String crdbServed;
  final String traceServed;
  final String crdbActive;
  final String traceActive;
  final String traceStatus;
  final String traceComment;
  final bool group;
  final String traceGroupNo;

  AgentData({
    required this.agentAccount,
    required this.agentName,
    required this.phone,
    required this.location,
    required this.zone,
    required this.isToActive,
    required this.crdbServed,
    required this.traceServed,
    required this.crdbActive,
    required this.traceActive,
    required this.traceStatus,
    required this.traceComment,
    required this.group,
    required this.traceGroupNo,
  });

  factory AgentData.fromJson(Map<String, dynamic> json) {
    return AgentData(
      agentAccount: json['AgentAccount'] ?? "",
      agentName: json['AgentName'] ?? "",
      phone: json['Phone'].toString(),
      location: json['Location'] ?? "",
      zone: json['Zone'] ?? "",
      isToActive: json['IsToActive'] as bool,
      crdbServed: json['CrdbServed'] ?? "",
      traceServed: json['TraceServed'] ?? "",
      crdbActive: json['CrdbActive'] ?? "",
      traceActive: json['TraceActive'] ?? "",
      traceStatus: json['TraceStatus'] ?? "",
      traceComment: json['TraceComment'] ?? "",
      group: json['Group'] as bool,
      traceGroupNo: json['TraceGroupNo'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AgentAccount': agentAccount,
      'AgentName': agentName,
      'Phone': phone,
      'Location': location,
      'Zone': zone,
      'IsToActive': isToActive,
      'CrdbServed': crdbServed,
      'TraceServed': traceServed,
      'CrdbActive': crdbActive,
      'TraceActive': traceActive,
      'TraceStatus': traceStatus,
      'TraceComment': traceComment,
      'Group': group,
      'TraceGroupNo': traceGroupNo,
    };
  }
}

class Account {
  final int idNo;
  final String accountName;
  final String zone;
  final String dateSubmit;
  final bool fingerPrint;
  final bool contract;
  final bool accountCreated;
  final bool accountActivation;
  final String accountNumber;
  final int phone;

  Account({
    required this.idNo,
    required this.accountName,
    required this.zone,
    required this.dateSubmit,
    required this.fingerPrint,
    required this.contract,
    required this.accountCreated,
    required this.accountActivation,
    required this.accountNumber,
    required this.phone,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      idNo: json['IdNo'] as int,
      accountName: json['AccountName'] as String,
      zone: json['Zone'] as String,
      dateSubmit: json['DateSubmit'] as String,
      fingerPrint: json['FingerPrint'] as bool,
      contract: json['Contract'] as bool,
      accountCreated: json['AccountCreated'] as bool,
      accountActivation: json['AccountActivation'] as bool,
      accountNumber: json['AccountNumber'] as String,
      phone: json['Phone'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'IdNo': idNo,
      'AccountName': accountName,
      'Zone': zone,
      'DateSubmit': dateSubmit,
      'FingerPrint': fingerPrint,
      'Contract': contract,
      'AccountCreated': accountCreated,
      'AccountActivation': accountActivation,
      'AccountNumber': accountNumber,
      'Phone': phone,
    };
  }
}
