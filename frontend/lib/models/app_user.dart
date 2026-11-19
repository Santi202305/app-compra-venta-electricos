/// Usuario de la app. En la versión real vivirá en PostgreSQL y la
/// contraseña se guardará cifrada (hash) por el backend; aquí se usa
/// texto plano solo porque es un prototipo sin backend.
class AppUser {
  final String name;
  final String email;
  final String password;
  final bool isAdmin;

  const AppUser({
    required this.name,
    required this.email,
    required this.password,
    this.isAdmin = false,
  });

  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isEmpty ? name : parts.first;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'isAdmin': isAdmin,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        name: json['name'] as String? ?? 'Usuario',
        email: json['email'] as String? ?? '',
        password: json['password'] as String? ?? '',
        isAdmin: json['isAdmin'] as bool? ?? false,
      );
}
