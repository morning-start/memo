class WebDavModel {
  final String uri;
  final String name;
  final String pwd;

  WebDavModel({required this.uri, required this.name, required this.pwd});
  Map<String, dynamic> toMap() {
    return {
      'uri': uri,
      'name': name,
      'pwd': pwd,
    };
  }

  factory WebDavModel.fromMap(Map<String, dynamic> map) {
    return WebDavModel(
      uri: map['uri'],
      name: map['name'],
      pwd: map['pwd'],
    );
  }
}
