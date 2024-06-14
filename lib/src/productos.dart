class Producto {
  String _nombre;
  String _sitio;
  String _estado;
  double _precio;

  Producto(this._nombre, this._sitio, this._estado, this._precio) {
    _validarLongitud(_nombre, 'nombre');
    _validarLongitud(_sitio, 'sitio');
    _validarLongitud(_estado, 'estado'); // Validación para estado
    _validarPrecio(_precio);
  }

  Producto.fromJson(Map<dynamic, dynamic> json)
      : _nombre = json['nombre'] as String,
        _sitio = json['sitio'] as String,
        _estado = json['estado'] as String,
        _precio = double.tryParse(json['precio'].toString()) ?? 0.0 {
    _validarLongitud(_nombre, 'nombre');
    _validarLongitud(_sitio, 'sitio');
    _validarLongitud(_estado, 'estado'); // Validación para estado
    _validarPrecio(_precio);
  }

  String get nombre => _nombre;
  String get sitio => _sitio;
  String get estado => _estado;
  double get precio => _precio;

  set nombre(String nuevoNombre) {
    _validarLongitud(nuevoNombre, 'nombre');
    _nombre = nuevoNombre;
  }

  set sitio(String nuevoSitio) {
    _validarLongitud(nuevoSitio, 'sitio');
    _sitio = nuevoSitio;
  }

  set estado(String nuevoEstado) { // Setter para estado
    _validarLongitud(nuevoEstado, 'estado');
    _estado = nuevoEstado;
  }

  set precio(double nuevoPrecio) {
    _validarPrecio(nuevoPrecio);
    _precio = nuevoPrecio;
  }

  Map<String, Object?> toJson() => {
        'nombre': _nombre,
        'sitio': _sitio,
        'estado': _estado,
        'precio': _precio,
      };

  void _validarLongitud(String valor, String campo) {
    if (valor.length >= 255) {
      throw ArgumentError('El campo $campo debe tener menos de 255 caracteres.');
    }
  }

  void _validarPrecio(double valor) {
    if (valor < 0) {
      throw ArgumentError('El precio no puede ser negativo.');
    }
  }
}
