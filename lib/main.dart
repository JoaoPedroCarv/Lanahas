import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firestore Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  List _recipes = [];
  bool _isLoading = false;
  String _selectedCountry = 'American'; // Valor padrão para o país

  // Lista de opções de países para o dropdown
  final List<String> _countryOptions = [
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
    _fetchRecipes(); // Buscar receitas ao iniciar a página
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?a=$_selectedCountry'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recipes = data['meals'] ?? [];
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
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Dropdown para selecionar o país
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
                        child: DropdownButton<String>(
                          value: _selectedCountry,
                          items: _countryOptions.map((String country) {
                            return DropdownMenuItem<String>(
                              value: country,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Text(
                                  country,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newCountry) {
                            setState(() {
                              _selectedCountry = newCountry!;
                              _fetchRecipes(); // Buscar receitas do país selecionado
                            });
                          },
                          hint: const Text('Select...'),
                          isExpanded: true,
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.grey, // Cor do ícone
                            size: 24,
                          ),
                          // Cor de fundo do DropdownButton quando fechado
                          focusColor: Colors.white,
                          dropdownColor:
                              Colors.white, // Cor de fundo do menu suspenso
                          elevation: 2,
                          underline:
                              SizedBox(), // Remove a linha abaixo do Dropdown
                          borderRadius:
                              BorderRadius.circular(8), // Borda arredondada
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: _recipes.length,
                          itemBuilder: (context, index) {
                            final recipe = _recipes[index];
                            return Container(
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
                                    // Exibição da imagem da receita
                                    Expanded(
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            child: Image.network(
                                              recipe[
                                                  'strMealThumb'], // Foto da receita
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
                                                  // Nome da receita
                                                  Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 4),
                                                    child: Text(
                                                      recipe[
                                                          'strMeal'], // Nome da receita
                                                      style: const TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 0.0,
                                                      ),
                                                      maxLines:
                                                          1, // Limita o nome a uma linha
                                                      overflow: TextOverflow
                                                          .ellipsis, // Adiciona '...' se o nome for longo
                                                    ),
                                                  ),
                                                  // Descrição da receita
                                                  const Padding(
                                                    padding:
                                                        EdgeInsetsDirectional
                                                            .fromSTEB(
                                                                0, 0, 0, 4),
                                                    child: Text(
                                                      'Delicious Recipe', // Texto de exemplo
                                                      style: TextStyle(
                                                        fontFamily: 'Inter',
                                                        fontSize: 14,
                                                        color: Colors.grey,
                                                        letterSpacing: 0.0,
                                                      ),
                                                      maxLines:
                                                          1, // Limita a descrição a uma linha
                                                      overflow: TextOverflow
                                                          .ellipsis, // Adiciona '...' se a descrição for longa
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Ícone para navegar para os detalhes da receita
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.black,
                                      size: 24,
                                    ),
                                  ],
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
