import 'package:flutter_doing/Helpers/parse_helper.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class User {
  @JsonKey(name: "user_nickname")
  String userNickname;
  @JsonKey(name: "user_firstname")
  String userFirstname;
  @JsonKey(name: "user_lastname")
  String userLastname;
  @JsonKey(name: "user_email")
  String userEmail;

  User({
    this.userNickname = "",
    this.userFirstname = "",
    this.userLastname = "",
    this.userEmail = "",
  });

  // factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userNickname: decodeHtml(json['user_nickname'] as String?),
      userFirstname: decodeHtml(json['user_firstname'] as String?),
      userLastname: decodeHtml(json['user_lastname'] as String?),
      userEmail: decodeHtml(json['user_email'] as String?),
    );
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
    'user_nickname': instance.userNickname,
    'user_firstname': instance.userFirstname,
    'user_lastname': instance.userLastname,
    'user_email': instance.userEmail,
  };
}
