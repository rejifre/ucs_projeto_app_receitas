import 'package:flutter/material.dart';

//TODO: Implementar a lógica de pesquisa
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _searchResults = [];

  void _performSearch(String query) {
    // Simulate search logic
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = List.generate(10, (index) => '$query Result $index');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pesquisar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('TODO: Implementar a lógica de pesquisa'),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  _searchResults.isEmpty
                      ? const Center(
                        child: Text('Nenhum resultado encontrado.'),
                      )
                      : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(_searchResults[index]));
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
