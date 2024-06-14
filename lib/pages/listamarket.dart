import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:trabajofinal/pages/nuevoproducto.dart';
import 'package:trabajofinal/src/fichaproducto.dart';
import 'package:trabajofinal/src/productos.dart';

class Listamarket extends StatefulWidget {
  const Listamarket({super.key});

  @override
  State<Listamarket> createState() {
    return ListamarketState();
  }
}

class ListamarketState extends State<Listamarket> {
  final DatabaseReference _productRef = FirebaseDatabase.instance.ref("StoreData");
  List<String> sitiosPermitidos = [];

  @override
  void initState() {
    super.initState();
    // Mover la llamada al diálogo después de que se haya completado la construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoadOrDeleteDialog();
    });
  }

  void _showLoadOrDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opciones de Lista'),
          content: const Text('¿Desea cargar la lista o eliminarla?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteAllData();
              },
              child: const Text('Eliminar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Proceder a cargar la lista
              },
              child: const Text('Cargar'),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllData() {
    _productRef.remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lista eliminada')),
      );
      setState(() {});
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la lista: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Lista de supermercado"),
      ),
      body: FirebaseAnimatedList(
        query: _productRef,
        itemBuilder: (context, snapshot, animation, index) {
          final json = snapshot.value as Map<dynamic, dynamic>;
          final producto = Producto.fromJson(json);

          return GestureDetector(
            onTap: () {
              _editarProducto(producto, this, _productRef, snapshot.key!);
            },
            child: Dismissible(
              key: Key(snapshot.key!),
              onDismissed: (direction) {
                eliminar(snapshot.key);
              },
              child: Card(
                margin: const EdgeInsets.all(1.0),
                elevation: 2.0,
                child: Fichaproducto(
                  titulo: producto.nombre,
                  sitio: producto.sitio,
                  estado: producto.estado,
                  precio: producto.precio,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _crearProducto(this, _productRef);
        },
        tooltip: 'Añadir producto',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editarProducto(Producto producto, ListamarketState obj, DatabaseReference databaseReference, String key) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NuevoProducto(
        producto: producto,
        appbartitulo: 'Editar producto',
        listaproductostate: obj,
        databaseReference: databaseReference,
        index: key,
      ))
    );
  }

  void _crearProducto(ListamarketState obj, DatabaseReference databaseReference) {
    Producto productoVacio = Producto('', '', '', 0);
    Navigator.push(context,
      MaterialPageRoute(builder: (context) => NuevoProducto(
        producto: productoVacio,
        appbartitulo: "Añadir Producto",
        listaproductostate: obj,
        databaseReference: databaseReference,
        index: '',
      ))
    );
  }

  void eliminar(String? key) {
    if (key != null) {
      _productRef.child(key).remove();
    }
  }

  void actualizarListView() {
    setState(() {});
  }
}
