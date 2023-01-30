import 'package:chat_task/utils/vars.dart';

class MessageModel {
  String? id;
  String? message;
  String? filePath;
  String? fileUrl;
  int? type;
  String? senderID;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? seen;

  MessageModel({
    this.message,
    this.type,
    this.senderID,
    this.createdAt,
    this.filePath,
    this.fileUrl,
    this.updatedAt,
    this.seen,
  });

  MessageModel.fromMap(Map<String, dynamic> m) {
    message = m[MessageVars.message];
    id = m[MessageVars.id];
    type = m[MessageVars.type];
    senderID = m[MessageVars.senderID];
    filePath = m[MessageVars.filePath];
    fileUrl = m[MessageVars.fileUrl];
    seen = m[MessageVars.seen];
    createdAt = DateTime.parse(m[ChatVars.createdAt].toDate().toString());
    updatedAt = DateTime.parse(m[ChatVars.updatedAt].toDate().toString());
  }

  Map<String, dynamic> toMap() {
    return {
      MessageVars.message: message,
      MessageVars.type: type,
      MessageVars.senderID: senderID,
      MessageVars.createdAt: createdAt,
      MessageVars.updatedAt: updatedAt,
      MessageVars.seen: false,
      MessageVars.filePath: filePath,
      MessageVars.fileUrl: fileUrl,
    };
  }
}
