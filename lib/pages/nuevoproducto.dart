import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:trabajofinal/pages/listamarket.dart';
import 'package:trabajofinal/src/productos.dart';

class NuevoProducto extends StatefulWidget {
  NuevoProducto({
    Key? key,
    required this.producto,
    required this.appbartitulo,
    required this.listaproductostate,
    required this.databaseReference,
    this.index = '',
  }) : super(key: key);

  final Producto producto;
  final String appbartitulo;
  final ListamarketState listaproductostate;
  final DatabaseReference databaseReference;
  final String index;

  @override
  NuevoProductoState createState() => NuevoProductoState();
}

class NuevoProductoState extends State<NuevoProducto> {
  final DatabaseReference _sitiosPermitidosRef = FirebaseDatabase.instance.ref("SitiosPermitidos");
  late TextEditingController nombreController;
  late TextEditingController precioController;
  bool _estaEditando = false;
  bool marcado = false;
  String? _selectedItem;
  List<String> sitiosPermitidos = [];

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.producto.nombre);
    precioController = TextEditingController(text: widget.producto.precio.toString());
    _selectedItem = widget.producto.sitio;
    _estaEditando = widget.index.isNotEmpty;

    if (!_estaEditando) {
      precioController = TextEditingController();
      _selectedItem = null;
    }

    _fetchSitiosPermitidos();
  }

  void _fetchSitiosPermitidos() {
    _sitiosPermitidosRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value;

      if (data != null && data is Map<dynamic, dynamic>) {
        final List<String> fetchedSitios = [];
        data.forEach((key, value) {
          fetchedSitios.add(value['sitio'] as String);
        });

        setState(() {
          sitiosPermitidos = fetchedSitios;
        });
      } else {
        setState(() {
          sitiosPermitidos = []; // Inicializa la lista como vacía si no hay datos o son nulos
        });
        
      }
    });
  }

  @override
  void dispose() {
    nombreController.dispose();
    precioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appbartitulo),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              if (_estaEditando)
                CheckboxListTile(
                  title: const Text(
                    'Completado',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: marcado,
                  onChanged: (newValue) {
                    setState(() {
                      marcado = newValue!;
                    });
                  },
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    hintText: 'Ej: huevos, leche, pan, etc',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    widget.producto.nombre = nombreController.text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: precioController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    hintText: 'Ej: 10500',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    widget.producto.precio = double.tryParse(value) ?? 0;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: _selectedItem,
                      hint: const Text("Seleccione una opción"),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedItem = newValue;
                          widget.producto.sitio = newValue!;
                        });
                      },
                      items: sitiosPermitidos.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _mostrarDialogo,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: _guardar,
                  child: const Text("Guardar"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _mostrarDialogo() {
    TextEditingController sitioController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Nuevo sitio"),
          content: TextField(
            controller: sitioController,
            decoration: const InputDecoration(
              hintText: "Aquí el nombre del sitio",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Guardar"),
              onPressed: () {
                final String nuevoSitio = sitioController.text;
                if (nuevoSitio.isNotEmpty) {
                  // Verificar si el nuevo sitio ya está en la lista sitiosPermitidos
                  if (sitiosPermitidos.contains(nuevoSitio)) {
                    mostrarsnackbar("El sitio ya está registrado.");
                    Navigator.of(context).pop();
                    return;
                  }

                  _sitiosPermitidosRef.push().set({'sitio': nuevoSitio}).then((_) {
                    setState(() {
                      sitiosPermitidos.add(nuevoSitio);
                    });
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    mostrarsnackbar("Error al guardar el sitio: $error");
                  });
                }
              },
            ),
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _guardar() {
    if (_comprobarNoNull()) {
      widget.producto.nombre = nombreController.text;
      widget.producto.estado = (_estaEditando && marcado) ? "Completado" : "";

      if (!_estaEditando) {
        final id = DateTime.now().microsecondsSinceEpoch.toString();
        widget.databaseReference.child(id).set(widget.producto.toJson()).catchError((error) {
          mostrarsnackbar("Error al guardar: $error");
        });
      } else {
        widget.databaseReference.child(widget.index).update({
          'nombre': widget.producto.nombre,
          'sitio':  widget.producto.sitio, // Asegúrate de usar el valor de sitio correcto aquí
          'estado': widget.producto.estado,
          'precio': widget.producto.precio,
        }).catchError((error) {
          mostrarsnackbar("Error al actualizar: $error");
        });
      }

      widget.listaproductostate.actualizarListView();
      Navigator.pop(context);
      mostrarsnackbar("Producto guardado correctamente");
      nombreController.clear();
      precioController.clear();
      _selectedItem = null;
    }
  }


  bool _comprobarNoNull() {
    if (nombreController.text.isEmpty) {
      mostrarsnackbar("Ingrese el nombre del producto");
      return false;
    }
    if (_selectedItem == null) {
      mostrarsnackbar("Seleccione el sitio del producto");
      return false;
    }
    if (precioController.text.isEmpty) {
      mostrarsnackbar("Ingrese el precio del producto");
      return false;
    }
    return true;
  }

  void mostrarsnackbar(String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      duration: const Duration(seconds: 1, milliseconds: 500),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
