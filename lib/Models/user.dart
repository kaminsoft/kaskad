class User {
  int id;
  String guid;
  String individualGuid;
  String username;
  String firstname;
  String lastname;
  String secondname;
  String position;
  String subdivision;
  String password;
  String avatar;

  User(
      {this.id,
      this.username,
      this.guid,
      this.individualGuid,
      this.firstname,
      this.lastname,
      this.avatar,
      this.password,
      this.position,
      this.secondname,
      this.subdivision});

  factory User.fromJSON(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      secondname: json['secondname'],
      position: json['position'],
      subdivision: json['subdivision'],
      password: json['password'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "username": username,
        "firstname": firstname,
        "lastname": lastname,
        "password": password,
        "avatar": avatar,
        "secondname": secondname,
        "position": position,
        "subdivision": subdivision,
      };
}
