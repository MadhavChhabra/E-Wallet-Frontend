class SignUpModel {
  final String? firstname;
  final String? lastname;
  final String? username;
  final String? email;
  final String? password;
  final String? pin;
  final String? profilePicture;
  final String? ktp;

  SignUpModel({
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.password,
    this.pin,
    this.profilePicture,
    this.ktp,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstname': firstname,
      'lastname': firstname,
      'username': username,
      'email': email,
      'password': password,
      'roles': ['ROLE_USER'],
      // 'pin': pin,
      // 'profile_picture': profilePicture,
      // 'ktp': ktp,
    };
  }

  SignUpModel copyWith({
    String? pin,
    String? profilePicture,
    String? ktp,
  }) =>
      SignUpModel(
        firstname: firstname,
        lastname: firstname,
        email: email,
        password: password,
        pin: pin ?? this.pin,
        profilePicture: profilePicture ?? this.profilePicture,
        ktp: ktp ?? this.ktp,
      );
}
