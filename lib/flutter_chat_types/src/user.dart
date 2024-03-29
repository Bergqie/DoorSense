import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'user.g.dart';

/// All possible roles user can have.
enum Role { admin, agent, moderator, user }

/// A class that represents user.
@JsonSerializable()
@immutable
abstract class User extends Equatable {
  /// Creates a user.
  const User._(
      {this.createdAt,
      this.firstName,
      required this.id,
      this.imageUrl,
      this.lastName,
      this.lastSeen,
      this.metadata,
      this.role,
      this.updatedAt,
      this.dob,
      this.fingerPrintHashList,
      this.email});

  const factory User(
      {int? createdAt,
      String? firstName,
      required String id,
      String? imageUrl,
      String? lastName,
      int? lastSeen,
      Map<String, dynamic>? metadata,
      Role? role,
      int? updatedAt,
      String? dob,
      List<String>? fingerPrintHashList,
      String? email}) = _User;

  /// Creates user from a map (decoded JSON).
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  /// Created user timestamp, in ms.
  final int? createdAt;

  /// First name of the user.
  final String? firstName;

  /// Unique ID of the user.
  final String id;

  /// Remote image URL representing user's avatar.
  final String? imageUrl;

  /// Last name of the user.
  final String? lastName;

  /// Timestamp when user was last visible, in ms.
  final int? lastSeen;

  /// Additional custom metadata or attributes related to the user.
  final Map<String, dynamic>? metadata;

  /// User [Role].
  final Role? role;

  /// Updated user timestamp, in ms.
  final int? updatedAt;

  final String? dob;

  final List<String>? fingerPrintHashList;

  final String? email;

  /// Equatable props.
  @override
  List<Object?> get props => [
        createdAt,
        firstName,
        id,
        imageUrl,
        lastName,
        lastSeen,
        metadata,
        role,
        updatedAt,
        dob,
    fingerPrintHashList,
        email
      ];

  User copyWith(
      {int? createdAt,
      String? firstName,
      String? id,
      String? imageUrl,
      String? lastName,
      int? lastSeen,
      Map<String, dynamic>? metadata,
      Role? role,
      int? updatedAt,
      String? dob,
      List<String>? fingerPrintHashList,
      String? email});

  /// Converts user to the map representation, encodable to JSON.
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

/// A utility class to enable better copyWith.
class _User extends User {
  const _User(
      {super.createdAt,
      super.firstName,
      required super.id,
      super.imageUrl,
      super.lastName,
      super.lastSeen,
      super.metadata,
      super.role,
      super.updatedAt,
      super.dob,
      super.fingerPrintHashList,
      super.email})
      : super._();

  @override
  User copyWith(
          {dynamic createdAt = _Unset,
          dynamic firstName = _Unset,
          String? id,
          dynamic imageUrl = _Unset,
          dynamic lastName = _Unset,
          dynamic lastSeen = _Unset,
          dynamic metadata = _Unset,
          dynamic role = _Unset,
          dynamic updatedAt = _Unset,
          dynamic dob = _Unset,
          dynamic fingerPrintHashList = _Unset,
          dynamic email = _Unset}) =>
      _User(
          createdAt: createdAt == _Unset ? this.createdAt : createdAt as int?,
          firstName:
              firstName == _Unset ? this.firstName : firstName as String?,
          id: id ?? this.id,
          imageUrl: imageUrl == _Unset ? this.imageUrl : imageUrl as String?,
          lastName: lastName == _Unset ? this.lastName : lastName as String?,
          lastSeen: lastSeen == _Unset ? this.lastSeen : lastSeen as int?,
          metadata: metadata == _Unset
              ? this.metadata
              : metadata as Map<String, dynamic>?,
          role: role == _Unset ? this.role : role as Role?,
          updatedAt: updatedAt == _Unset ? this.updatedAt : updatedAt as int?,
          dob: dob == _Unset ? this.dob : dob as String,
          fingerPrintHashList: fingerPrintHashList == _Unset
              ? this.fingerPrintHashList
              : fingerPrintHashList as List<String>?,
          email: email == _Unset ? this.email : email as String?);
}

class _Unset {}
