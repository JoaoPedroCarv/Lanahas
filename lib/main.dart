import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detalhe_receita.dart';
import 'lista_receitas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const FirebaseOptions firebaseOptions = FirebaseOptions(
    apiKey: "AIzaSyAa_pDIscMAb3LbVi_lSv_qVSUppje6aCE",
    appId: "1:1049572431533:web:619b3d91e0d40b07ef5824",
    messagingSenderId: "1049572431533",
    projectId: "flutter-aulka",
    storageBucket: "flutter-aulka.appspot.com",
    authDomain: "flutter-aulka.firebaseapp.com",
  );

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firestore Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MinhaPaginaInicial(),
    );
  }
}

class MinhaPaginaInicial extends StatefulWidget {
  const MinhaPaginaInicial({super.key});

  @override
  State<MinhaPaginaInicial> createState() => _MinhaPaginaInicialState();
}

class _MinhaPaginaInicialState extends State<MinhaPaginaInicial> {
  List _receitas = [];
  bool _isLoading = false;
  String _paisSelecionado = 'American';

  final List<String> _opcoesPais = [
    'American',
    'British',
    'Canadian',
    'Chinese',
    'French',
    'Indian',
    'Italian',
    'Japanese',
    'Mexican',
  ];

  @override
  void initState() {
    super.initState();
    _buscarReceitas();
  }

  Future<void> _buscarReceitas() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?a=$_paisSelecionado'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _receitas = data['meals'] ?? [];
        });
      } else {
        print('Erro ao buscar receitas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar receitas: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: const Color(0xFFE6E648),
          automaticallyImplyLeading: false,
          title: const Text(
            'Início',
            style: TextStyle(
              fontFamily: 'Inter Tight',
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ListaReceitasPage(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _paisSelecionado,
                        items: _opcoesPais.map((String pais) {
                          return DropdownMenuItem<String>(
                            value: pais,
                            child: Text(pais),
                          );
                        }).toList(),
                        onChanged: (String? novoPais) {
                          setState(() {
                            _paisSelecionado = novoPais!;
                            _buscarReceitas();
                          });
                        },
                        hint: const Text('Selecione o país'),
                        isExpanded: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _receitas.length,
                          itemBuilder: (context, index) {
                            final receita = _receitas[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetalheReceitaPage(
                                      receita: receita,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                receita['strMealThumb'],
                                                width: 106,
                                                height: 85,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsetsDirectional
                                                    .fromSTEB(8, 0, 0, 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 4),
                                                      child: Text(
                                                        receita['strMeal'],
                                                        style: const TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    const Padding(
                                                      padding:
                                                          EdgeInsetsDirectional
                                                              .fromSTEB(
                                                                  0, 0, 0, 4),
                                                      child: Text(
                                                        'Delicious Recipe',
                                                        style: TextStyle(
                                                          fontFamily: 'Inter',
                                                          fontSize: 14,
                                                          color: Colors.grey,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
