import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class DetalheReceitaPage extends StatefulWidget {
  final dynamic receita;

  const DetalheReceitaPage({super.key, required this.receita});

  @override
  State<DetalheReceitaPage> createState() => _DetalheReceitaPageState();
}

class _DetalheReceitaPageState extends State<DetalheReceitaPage> {
  bool _isLoading = false;
  bool _showLottie = false;
  Map _detalhesReceita = {};

  @override
  void initState() {
    super.initState();
    _buscarDetalhesReceita();
  }

  Future<void> _buscarDetalhesReceita() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${widget.receita['idMeal']}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _detalhesReceita = data['meals']?[0] ?? {};
        });
      } else {
        print('Erro ao buscar detalhes da receita: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar detalhes da receita: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _salvarReceita() async {
    try {
      await FirebaseFirestore.instance.collection('receitas').add({
        'nome': _detalhesReceita['strMeal'] ?? 'Nome não disponível',
        'categoria':
            _detalhesReceita['strCategory'] ?? 'Categoria não disponível',
        'instrucoes':
            _detalhesReceita['strInstructions'] ?? 'Instruções não disponíveis',
        'ingredientes': List.generate(20, (index) {
          String? ingrediente = _detalhesReceita['strIngredient${index + 1}'];
          String? medida = _detalhesReceita['strMeasure${index + 1}'];
          if (ingrediente != null && ingrediente.isNotEmpty) {
            return '$ingrediente: $medida';
          }
          return null;
        }).where((e) => e != null).toList(),
      });

      setState(() {
        _showLottie = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _showLottie = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receita salva com sucesso!')),
      );
    } catch (e) {
      print('Erro ao salvar a receita: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar a receita.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6E648),
        title: const Text(
          'Detalhes da Receita',
          style: TextStyle(
            fontFamily: 'Inter Tight',
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _detalhesReceita['strMealThumb'] ?? '',
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _detalhesReceita['strMeal'] ??
                                'Nome não disponível',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Categoria: ${_detalhesReceita['strCategory'] ?? 'Categoria não disponível'}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Instruções:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(color: Colors.grey),
                              const SizedBox(height: 8),
                              Text(
                                _detalhesReceita['strInstructions'] ??
                                    'Instruções não disponíveis.',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ingredientes:',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(color: Colors.grey),
                              const SizedBox(height: 8),
                              _detalhesReceita['strIngredient1'] != null
                                  ? Column(
                                      children: List.generate(20, (index) {
                                        String? ingrediente = _detalhesReceita[
                                            'strIngredient${index + 1}'];
                                        String? medida = _detalhesReceita[
                                            'strMeasure${index + 1}'];

                                        if (ingrediente == null ||
                                            ingrediente.isEmpty) {
                                          return SizedBox.shrink();
                                        }

                                        return Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '$ingrediente: $medida',
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    )
                                  : const Text(
                                      'Sem ingredientes disponíveis.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: ElevatedButton(
                              onPressed: _salvarReceita,
                              child: const Text(
                                'Salvar Receita',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 32, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          if (_showLottie)
            Positioned.fill(
              child: Center(
                child: Lottie.asset(
                  'success_animation.json',
                  width: 200,
                  height: 200,
                  repeat: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
