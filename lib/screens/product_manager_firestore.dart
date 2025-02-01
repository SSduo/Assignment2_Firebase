import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductManagerFirestore extends StatefulWidget {
  @override
  _ProductManagerFirestoreState createState() => _ProductManagerFirestoreState();
}

class _ProductManagerFirestoreState extends State<ProductManagerFirestore> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Manager (Firestore)'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(product['name']),
                        subtitle: Text(
                            '${product['description']}\nPrice: \$${product['price']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _showForm(product.id, product['name'], product['description'], product['price']),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteProduct(product.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showForm(null, '', '', 0.0),
      ),
    );
  }

  void _showForm(String? id, String name, String description, double price) async {
    _nameController.text = name;
    _descriptionController.text = description;
    _priceController.text = price.toString();
    _selectedProductId = id;

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 15,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_nameController.text.isEmpty || _descriptionController.text.isEmpty || _priceController.text.isEmpty) {
                  return;
                }

                final product = {
                  'name': _nameController.text,
                  'description': _descriptionController.text,
                  'price': double.parse(_priceController.text),
                };

                if (_selectedProductId == null) {
                  await _firestore.collection('products').add(product);
                } else {
                  await _firestore.collection('products').doc(_selectedProductId).update(product);
                }

                _nameController.clear();
                _descriptionController.clear();
                _priceController.clear();
                Navigator.of(context).pop();
              },
              child: Text(_selectedProductId == null ? 'Add Product' : 'Update Product'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}