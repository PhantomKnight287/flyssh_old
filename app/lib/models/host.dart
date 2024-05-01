class Host {
  String? label;
  String hostname;
  String username;
  String? password;
  String? key;

  Host({
    this.label,
    required this.hostname,
    required this.username,
    this.password,
    this.key,
  });
}
