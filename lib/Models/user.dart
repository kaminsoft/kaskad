
class User {
  int id;
  String username;
  String firstname;
  String lastname;
  String password;
  String avatar;

  User({this.id, this.username, this.firstname, this.lastname, this.avatar, this.password});

  factory User.fromJSON(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      username: json['username'],
      firstname: json['firstname'],
      lastname: json['lastname'],
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
    };

}