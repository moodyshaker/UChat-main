abstract class UserVars {
  static const String usersTable = 'users';
  static const String id = 'id';
  static const String token = 'token';
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String countryCode = 'country_code';
  static const String imageURL = 'image_url';
  static const String imagePath = 'image_path';
  static const String online = 'online';
}

abstract class ChatVars {
  static const String chatsTable = 'chats';
  static const String id = 'id';
  static const String userIDS = 'user_ids';
  static const String users = 'users';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String messages = 'messages';
}

abstract class MessageVars {
  static const String id = 'id';
  static const String message = 'message';
  static const String type = 'type';
  static const String senderID = 'sender_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  static const String seen = 'seen';
  static const String filePath = 'file_path';
  static const String fileUrl = 'file_url';
}
