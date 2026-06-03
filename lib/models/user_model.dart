class UserModel {
  final int? id;
  final String? firstname;
  final String? lastname;
  final String? email;
  final String? username;
  final String? password;
  final int? verified;
  final String? profilePicture;
  final int? balance;
  final String? cardNumber;
  final String? pin;
  final String? token;

  UserModel({
    this.id,
    this.firstname,
    this.lastname,
    this.email,
    this.username,
    this.password,
    this.verified,
    this.profilePicture,
    this.balance,
    this.cardNumber,
    this.pin,
    this.token,
  });

//   Map<String, dynamic> toJson() {
//   return {
//     'id': id,
//     'firstname': firstname,
//     'lastname': lastname,
//     'email': email,
//     'username': username,
//     'password': password,
//     'verified': verified,
//     'profile_picture': profilePicture,
//     'balance': balance,
//     'card_number': cardNumber,
//     'pin': pin,
//     'token': token,
//   };
// }


  factory UserModel.formJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        firstname: json['firstname'],
        lastname: json['lastname'],
        email: json['email'],
        username: json['username'],
        verified: json['verified'],
        profilePicture: json['profile_picture'],
        balance: json['balance'],
        cardNumber: json['card_number'],
        pin: json['pin'],
        token: json['token'],
      );

  UserModel copyWith({
    String? firstname,
    String? lastname,
    String? username,
    String? email,
    String? pin,
    int? balance,
    String? password,
  }) =>
      UserModel(
        id: id,
        username: username ?? this.username,
        firstname: firstname ?? this.firstname,
        lastname: lastname ?? this.lastname,
        email: email ?? this.email,
        pin: pin ?? this.pin,
        balance: balance ?? this.balance,
        password: password ?? this.password,
        verified: verified,
        profilePicture: profilePicture,
        cardNumber: cardNumber,
        token: token,
      );

        int? get userId => id;
  String? get userFirstname => firstname;
  String? get userLastname => lastname;
}
