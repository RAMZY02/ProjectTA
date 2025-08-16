class WaModel {
  final int timestamp;
  final String messageId;

  WaModel({
    required this.timestamp,
    required this.messageId,
  });

  factory WaModel.fromJson(Map<String, dynamic> json) {
    return WaModel(
      timestamp: json["data"]['timestamp'],
      messageId: json["data"]['messageId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'messageId': messageId,
    };
  }
}