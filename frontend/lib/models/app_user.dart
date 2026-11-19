/// Modelo de usuario de la app sincronizado con la entidad de backend.
/// Por seguridad, la contraseña NUNCA se serializa a JSON ni se guarda localmente.
class AppUser {
  final String? id;
  final String name;
  final String email;
  final String? password;
  final String role;
  final bool isAdmin;

  const AppUser({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.role = 'customer',
    this.isAdmin = false,
  });

  String get firstName {
    final parts = name.trim().split(' ');
    return parts.isEmpty ? name : parts.first;
  }

  /// Serialización segura: omite explícitamente contraseñas y datos sensibles.
  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'name': name,
        'email': email,
        'role': role,
        'isAdmin': isAdmin,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String? ?? 'customer';
    final isAdmin = json['isAdmin'] as bool? ?? (role == 'admin');
    return AppUser(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Usuario',
      email: json['email'] as String? ?? '',
      password: json['password'] as String?,
      role: role,
      isAdmin: isAdmin,
    );
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    String? role,
    bool? isAdmin,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
