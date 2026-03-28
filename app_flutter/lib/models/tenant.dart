class Tenant {
  final int id;
  final String fullName;
  final String phone;
  final String? identityNumber;
  final String? email;
  final List<IdentityDocument> documents;

  const Tenant({
    required this.id,
    required this.fullName,
    required this.phone,
    this.identityNumber,
    this.email,
    this.documents = const [],
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      identityNumber: json['identity_number'] as String?,
      email: json['email'] as String?,
      documents: (json['documents'] as List<dynamic>?)
              ?.map((d) => IdentityDocument.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class IdentityDocument {
  final int id;
  final String documentType;
  final String documentNumber;

  const IdentityDocument({
    required this.id,
    required this.documentType,
    required this.documentNumber,
  });

  factory IdentityDocument.fromJson(Map<String, dynamic> json) {
    return IdentityDocument(
      id: json['id'] as int,
      documentType: json['document_type'] as String,
      documentNumber: json['document_number'] as String,
    );
  }
}
