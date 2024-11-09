import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Substitua os valores abaixo pelas suas credenciais do Firebase
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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('flutter-banco').add({
        'text': _controller.text,
        'createdAt': Timestamp.now(),
      });
      _controller.clear();
    } catch (e) {
      print('Erro ao enviar dados: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firestore Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Digite sua mensagem',
                ),
              ),
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendData,
                    child: const Text('Enviar'),
                  ),
          ],
        ),
      ),
    );
  }
}
