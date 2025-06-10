class Transaccion {
  int? id;
  double valor;
  String descripcion;
  String tipo;
  String fecha;
  int categoriaId;

  Transaccion({
    this.id,
    required this.valor,
    required this.descripcion,
    required this.tipo,
    required this.fecha,
    required this.categoriaId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'valor': valor,
      'descripcion': descripcion,
      'tipo': tipo,
      'fecha': fecha,
      'categoria_id': categoriaId,
    };
  }

  factory Transaccion.fromMap(Map<String, dynamic> map) {
    return Transaccion(
      id: map['id'],
      valor: map['valor'],
      descripcion: map['descripcion'],
      tipo: map['tipo'],
      fecha: map['fecha'],
      categoriaId: map['categoria_id'],
    );
  }
}
