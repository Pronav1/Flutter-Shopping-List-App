import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/screen/new_item.dart';
import 'package:http/http.dart' as http;

class GrocoeryList extends StatefulWidget {
  const GrocoeryList({super.key});

  @override
  State<GrocoeryList> createState() => _GrocoeryListState();
}

class _GrocoeryListState extends State<GrocoeryList> {
  List<GroceryItem> _grocoryItems = [];
  String? _error;
  var isLoading = true;
  var content;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https(
        'console.firebase.google.com/u/0/project/shoppinglist-7a0ca/database/shoppinglist-7a0ca-default-rtdb/data/~2F',
        'shopping-list.json');

    try {
      // throw exception('');

      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
        });
      }
      // ignore: unnecessary_null_comparison
      if (response.body == 'null') {
        // check statuscode, null, string, empty string for body response for different backend
        setState(() {
          isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItem = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (catItem) => catItem.value.title == item.value['category'])
            .value;
        loadedItem.add(GroceryItem(
            id: item.key,
            category: category,
            name: item.value['name'],
            quantity: item.value['quantity']));
      }
      setState(() {
        _grocoryItems = loadedItem;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'OOPS.. something went wrong. Please try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );
    if (newItem == null) return;

    setState(() {
      _grocoryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _grocoryItems.indexOf(item);
    setState(() {
      _grocoryItems.remove(item);
    });

    final url = Uri.https(
        'console.firebase.google.com/u/0/project/shoppinglist-7a0ca/database/shoppinglist-7a0ca-default-rtdb/data/~2F',
        'shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error, plz try again in a moment.')));
      setState(() {
        _grocoryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_grocoryItems.isEmpty) {
      // ignore: sized_box_for_whitespace
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Text(
          'Go shop some items!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 25),
        ),
      );
    }
    if (_error != null) {
      return content = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Gorceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: ListView.builder(
        itemCount: _grocoryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_grocoryItems[index].id),
          background: Container(
            color: Theme.of(context).colorScheme.primary,
          ),
          onDismissed: (direction) {
            _removeItem(_grocoryItems[index]);
          },
          child: ListTile(
            title: Text(_grocoryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _grocoryItems[index].category.color,
            ),
            trailing: Text(
              _grocoryItems[index].quantity.toString(),
            ),
          ),
        ),
      ),
    );
  }
}
