class Categoria {
  int? id;
  String nombre;
  String tipo;
  int tipoImagen;

  Categoria({
    this.id,
    required this.nombre,
    required this.tipo,
    required this.tipoImagen,
  });

  //Crear sobrecarga de operadores para saber cuando dos objetos categorias son iguales por su Id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Categoria && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  //Se crea metodo toMap(Convierte objetos a base de datos)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
      'tipo_imagen': tipoImagen,
    };
  }

  // Se crea metodo fromMap (Convierte de la base de datos a objetos)
  factory Categoria.fromMap(Map<String, dynamic> map) {
    return Categoria(
      id: map['id'],
      nombre: map['nombre'],
      tipo: map['tipo'],
      tipoImagen: int.tryParse(map['tipo_imagen'].toString()) ?? 0xe8cc,
    );
  }
}
