import 'package:flutter/material.dart';

class PiereAuthScreen extends StatefulWidget {
  const PiereAuthScreen({super.key});

  @override
  State<PiereAuthScreen> createState() => _PiereAuthScreenState();
}

class _PiereAuthScreenState extends State<PiereAuthScreen> {
  List<String> _groceryItems = [];

  final _isLoading = true;
  String? _error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    /*final url = Uri.https('flutter-project-52f3c-default-rtdb.firebaseio.com',
        'shopping-list.json');
    final response = await http.get(url);

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
      setState(() {
        _error = 'failed to fetch data. please try again later';
      });
    }

    if(response.body == 'null')
    {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (element) => element.value.title == item.value['category'],
          )
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
    }
    catch(error) {
      setState(() {
        _error = 'failed to fetch data. please try again later';
      });
    }
  */
    _groceryItems = ["hey", "piere"];
  }

  void _removeItem(String item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    /*final url = Uri.https('flutter-project-52f3c-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
    final response = await http.delete(url);

    if(response.statusCode >=400)
    {
      setState(() {
        _groceryItems.insert(index,item);
      });
    }*/
  }

  void _addItem() async {
    /*final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });*/
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text('no items added yet.'),
    );

    if (_isLoading == true) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index]),
          child: ListTile(
            title: Text(_groceryItems[index]),
            leading: Container(
              width: 24,
              height: 24,
              color: Colors.yellow,
            ),
            trailing: Text(
              _groceryItems[index],
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
