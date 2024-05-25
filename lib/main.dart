import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:primera_app/api_response.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        textTheme: TextTheme(
          bodyMedium: GoogleFonts.roboto()
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _urlimagen = "";
  String _query = "";
  bool loading = false;

  void _obteneriImagen(String topic) {
    if (loading) {
      return;
    }
    loading = true;
    setState(() {});
    GetImageBgUseCase().call(topic).then((value) {
      _urlimagen = value;
      loading = false;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("imagenes de $_query"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  _query = value;
                  setState(() {});
                },
                decoration: const InputDecoration(
                    hintText: "Ingresa la imagen que buscas",
                    border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: Text("Cargando imagen"))
                  : SizedBox(
                      width: 400,
                      height: 400,
                      child: Center(
                        child: Image.network(
                          _urlimagen,
                          fit: BoxFit.cover,
                       
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                                "");
                          },
                        ),
                      ),
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _obteneriImagen(_query),
        tooltip: 'Increment',
        child: const Icon(Icons.replay),
      ),
    );
  }
}

class GetImageBgUseCase {
  final kUnsplashClientId = 'Wq_0gMg6fxGQjTlSPQZjL1XrMZSp_cZ3KVVMXzv4K78';
  Future<String> call(String place) async {
    try {
      final query = place.split(',').first;
      final url = 'https://api.unsplash.com/search/photos?'
          'page=1&'
          'query=$query&'
          'client_id=$kUnsplashClientId';
      final response = await http.get(Uri.parse(url));
      final data = response.toApiResponse<String>().data!;
      final doc = json.decode(data) as Map<String, dynamic>;
      final results = doc['results'] as List<dynamic>;
      results.shuffle();
      final first = results.first as Map<String, dynamic>;

      return (first['urls'] as Map<String, dynamic>)['full'];
    } catch (e) {
      rethrow;
    }
  }
}
