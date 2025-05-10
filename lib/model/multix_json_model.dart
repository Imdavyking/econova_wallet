class MultiversXConnectModel {
  String target;
  String type;
  String data;
  MultiversXConnectModel({
    required this.target,
    required this.type,
    required this.data,
  });

  Map toJson() {
    return {
      'target': target,
      'type': type,
      'data': data,
    };
  }

  factory MultiversXConnectModel.fromJson(Map<String, dynamic> json) {
    return MultiversXConnectModel(
      target: json['target'],
      type: json['type'],
      data: json['data'],
    );
  }
}
