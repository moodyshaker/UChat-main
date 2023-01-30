import 'package:chat_task/utils/vars.dart';

class UserModel {
  String? id;
  String? email;
  String? name;
  String? phone;
  String? countryCode;
  String? imageUrl;
  String? imagePath;
  bool? online;
  String? token;

  UserModel(
      {this.id,
      this.email,
      this.name,
      this.phone,
      this.countryCode,
      this.imageUrl,
      this.imagePath,
      this.token});

  UserModel.fromMap(Map<String, dynamic> m) {
    id = m[UserVars.id];
    email = m[UserVars.email];
    name = m[UserVars.name] ?? m['firstName'];
    phone = m[UserVars.phone];
    countryCode = m[UserVars.countryCode];
    imageUrl = m[UserVars.imageURL];
    imagePath = m[UserVars.imagePath];
    online = m[UserVars.online];
    token = m[UserVars.token];
  }

  Map<String, dynamic> toMap() {
    return {
      UserVars.email: email,
      UserVars.name: name,
      UserVars.phone: phone,
      UserVars.countryCode: countryCode,
      UserVars.imageURL: imageUrl ?? '',
      UserVars.imagePath: imagePath ?? '',
      UserVars.online: online ?? false,
      UserVars.token: token ?? '',
    };
  }
}
