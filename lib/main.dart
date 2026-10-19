import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDUsm-Z2PJvE0xhIJs_YBtyoOFzhFJmjw0",
      authDomain: "cinefilospi.firebaseapp.com",
      projectId: "cinefilospi",
      storageBucket: "cinefilospi.firebasestorage.app",
      messagingSenderId: "396299568698",
      appId: "1:396299568698:web:acd36c3062ab69f2025703",
    ),
  );
  
  runApp(const CinefilosPIApp());
}



class CinefilosPIApp extends StatelessWidget {
  const CinefilosPIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinéfilos - Catálogo de Películas PI',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// Controla si el usuario está logueado o debe iniciar sesión / registrarse
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const MainNavigatorScreen();
        }
        return const LoginRegisterScreen();
      },
    );
  }
}

// ==================== PANTALLA DE INICIO / LOGIN / REGISTRO ====================
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  bool _isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _submit() async {
    try {
      setState(() => _errorMessage = '');
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_movies, size: 80, color: Colors.amber),
              const SizedBox(height: 10),
              const Text('Cinéfilos PI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              const Text('Bienvenidos al catálogo de películas', style: TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 30),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white12,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(_errorMessage, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black, minimumSize: const Size.fromHeight(50)),
                onPressed: _submit,
                child: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(_isLogin ? '¿No tienes cuenta? Regístrate aquí' : '¿Ya tienes cuenta? Inicia sesión', style: const TextStyle(color: Colors.amberAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== NAVEGADOR PRINCIPAL (MENÚ SUPERIOR / PANTALLAS) ====================
class MainNavigatorScreen extends StatefulWidget {
  const MainNavigatorScreen({super.key});

  @override
  State<MainNavigatorScreen> createState() => _MainNavigatorScreenState();
}

class _MainNavigatorScreenState extends State<MainNavigatorScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const CatalogoScreen(),
    const AdminScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _verificarYPrecargarPeliculas();
  }

  // Precarga automática de 10 películas aleatorias si la BD está vacía
  Future<void> _verificarYPrecargarPeliculas() async {
    final query = await FirebaseFirestore.instance.collection('peliculas').get();
    if (query.docs.isEmpty) {
      final List<Map<String, dynamic>> initialMovies = [
        {'titulo': 'El Padrino', 'anio': 1972, 'director': 'Francis Ford Coppola', 'genero': 'Crimen', 'sinopsis': 'Legado familiar de la mafia ítalo-estadounidense.', 'valoracion': 5, 'imagen': 'https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SX300.jpg'},
        {'titulo': 'Interestelar', 'anio': 2014, 'director': 'Christopher Nolan', 'genero': 'Ciencia Ficción', 'sinopsis': 'Un grupo de astronautas viaja a través de un agujero de gusano.', 'valoracion': 5, 'imagen': 'https://m.media-amazon.com/images/M/MV5BZjdkOTU3MDktN2IxOS00OGEyLWFmMjktY2FiMmZkNWIyODZiXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg'},
        {'titulo': 'Pulp Fiction', 'anio': 1994, 'director': 'Quentin Tarantino', 'genero': 'Acción', 'sinopsis': 'Historias entrelazadas de delincuentes en Los Ángeles.', 'valoracion': 4, 'imagen': 'https://m.media-amazon.com/images/M/MV5BNGNhMDIzZTUtNTBlZi00MTRlLWFjM2ItYzViMjE3YzI5MjljXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_SX300.jpg'},
        {'titulo': 'Forrest Gump', 'anio': 1994, 'director': 'Robert Zemeckis', 'genero': 'Drama', 'sinopsis': 'Las vivencias de un hombre bondadoso con bajo coeficiente intelectual.', 'valoracion': 5, 'imagen': 'https://m.media-amazon.com/images/M/MV5BNWIwODRlZTUtY2U3ZS00Yzg1LWJhNzYtMmZiYmEyNmU1NjMzXkEyXkFqcGdeQXVyMTQxNzMzNDI@._V1_SX300.jpg'},
        {'titulo': 'Matrix', 'anio': 1999, 'director': 'Lana Wachowski', 'genero': 'Ciencia Ficción', 'sinopsis': 'Un hacker descubre que el mundo es una simulación virtual.', 'valoracion': 4, 'imagen': 'https://m.media-amazon.com/images/M/MV5BNzQzOTk3OTAtNDQ0Zi00ZTVkLWI0MTEtMDllZjNkYzNjNTc4XkEyXkFqcGdeQXVyNjU0OTQ0OTY@._V1_SX300.jpg'},
        {'titulo': 'Gladiador', 'anio': 2000, 'director': 'Ridley Scott', 'genero': 'Acción', 'sinopsis': 'Un general romano traicionado busca venganza en el Coliseo.', 'valoracion': 4, 'imagen': 'https://revistakinemabooks.com/wp-content/uploads/2025/11/thumb-1920-349101.jpg'},
        {'titulo': 'Titanic', 'anio': 1997, 'director': 'James Cameron', 'genero': 'Romance', 'sinopsis': 'Un romance trágico a bordo del transatlántico británico.', 'valoracion': 4, 'imagen': 'https://m.media-amazon.com/images/M/MV5BMDdmZGU3NDQtY2E5My00ZTliLWIzOTUtMTY4ZGI1YjdiNjk3XkEyXkFqcGdeQXVyNTA4NzY1MzY@._V1_SX300.jpg'},
        {'titulo': 'Jurassic Park', 'anio': 1993, 'director': 'Steven Spielberg', 'genero': 'Aventura', 'sinopsis': 'Científicos clonan dinosaurios para un parque temático.', 'valoracion': 4, 'imagen': 'https://m.media-amazon.com/images/M/MV5BMjM2MDgxMDg0Nl5BMl5BanBnXkFtZTgwNTM2OTM5NDE@._V1_SX300.jpg'},
        {'titulo': 'Whiplash', 'anio': 2014, 'director': 'Damien Chazelle', 'genero': 'Drama', 'sinopsis': 'Un joven baterista busca la perfección bajo un mentor implacable.', 'valoracion': 5, 'imagen': 'https://m.media-amazon.com/images/M/MV5BOTA5NDZlZGUtMjAxOS00YTRkLTkwYWYtYWQ0NWExZDZiNzUzXkEyXkFqcGdeQXVyMTMxODk2OTU@._V1_SX300.jpg'},
        {'titulo': 'El Rey León', 'anio': 1994, 'director': 'Roger Allers', 'genero': 'Animación', 'sinopsis': 'Un joven león debe asumir su papel como legítimo rey.', 'valoracion': 5, 'imagen': 'https://m.media-amazon.com/images/M/MV5BYTYxNGMyZTYtMjE3MS00MzNjLWFjNmYtMDk3N2JmM2JiMDU0XkEyXkFqcGdeQXVyNjY0OTI4MzY@._V1_SX300.jpg'},
      ];
      for (var mov in initialMovies) {
        await FirebaseFirestore.instance.collection('peliculas').add(mov);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final isAdmin = userEmail == 'administrador@udg.mx';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cinéfilos - Catálogo de Películas'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 1 && !isAdmin) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Acceso restringido solo al administrador (administrador@udg.mx)')),
            );
            return;
          }
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Catálogo'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Administración'),
        ],
      ),
    );
  }
}

// ==================== PANTALLA DE CATÁLOGO Y FILTROS ====================
class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String _searchQuery = '';
  String _selectedGenre = 'Todos';
  int? _selectedRating;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de filtros
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar por título, director o año...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedGenre,
                      items: ['Todos', 'Crimen', 'Ciencia Ficción', 'Acción', 'Drama', 'Romance', 'Aventura', 'Animación']
                          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedGenre = val ?? 'Todos'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<int?>(
                      isExpanded: true,
                      hint: const Text('Calificación ⭐'),
                      value: _selectedRating,
                      items: [null, 1, 2, 3, 4, 5]
                          .map((r) => DropdownMenuItem(value: r, child: Text(r == null ? 'Todas' : '$r Estrellas')))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedRating = val),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Listado en tiempo real desde Firestore
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('peliculas').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final title = data['titulo'].toString().toLowerCase();
                final director = data['director'].toString().toLowerCase();
                final genero = data['genero'].toString();
                final rating = data['valoracion'];

                bool matchesSearch = title.contains(_searchQuery) || director.contains(_searchQuery);
                bool matchesGenre = _selectedGenre == 'Todos' || genero == _selectedGenre;
                bool matchesRating = _selectedRating == null || rating == _selectedRating;

                return matchesSearch && matchesGenre && matchesRating;
              }).toList();

              if (docs.isEmpty) {
                return const Center(child: Text('No se encontraron películas con esos filtros.'));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DetallePeliculaScreen(pelicula: data)),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                data['imagen'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data['titulo'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text('${data['anio']} • ${data['genero']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                Text('⭐ ${data['valoracion']} / 5', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                              ],
                            ),
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
    );
  }
}

// ==================== PANTALLA DE DESCRIPCIÓN DE LA PELÍCULA ====================
class DetallePeliculaScreen extends StatelessWidget {
  final Map<String, dynamic> pelicula;
  const DetallePeliculaScreen({super.key, required this.pelicula});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(pelicula['titulo']), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                pelicula['imagen'] ?? '',
                height: 320,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(pelicula['titulo'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Año de estreno: ${pelicula['anio']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('Director: ${pelicula['director']}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('Género: ${pelicula['genero']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.deepPurple)),
                  const SizedBox(height: 10),
                  Text('Valoración: ${'⭐' * (pelicula['valoracion'] ?? 1)} (${pelicula['valoracion']}/5)', style: const TextStyle(fontSize: 18)),
                  const Divider(height: 30),
                  const Text('Sinopsis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(pelicula['sinopsis'], style: const TextStyle(fontSize: 16, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PANTALLA DE ADMINISTRACIÓN (CRUD) ====================
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  void _mostrarFormulario(BuildContext context, [DocumentSnapshot? doc]) {
    final titleController = TextEditingController(text: doc?['titulo'] ?? '');
    final anioController = TextEditingController(text: doc?['anio']?.toString() ?? '');
    final directorController = TextEditingController(text: doc?['director'] ?? '');
    String genero = doc?['genero'] ?? 'Drama';
    final sinopsisController = TextEditingController(text: doc?['sinopsis'] ?? '');
    final ratingController = TextEditingController(text: doc?['valoracion']?.toString() ?? '3');
    final imagenController = TextEditingController(text: doc?['imagen'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(doc == null ? 'Dar de Alta Película' : 'Actualizar Película', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Título')),
              TextField(controller: anioController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Año')),
              TextField(controller: directorController, decoration: const InputDecoration(labelText: 'Director')),
              TextField(controller: sinopsisController, decoration: const InputDecoration(labelText: 'Sinopsis')),
              TextField(controller: ratingController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Valoración (1-5)')),
              TextField(controller: imagenController, decoration: const InputDecoration(labelText: 'URL de la Imagen')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final data = {
                    'titulo': titleController.text,
                    'anio': int.tryParse(anioController.text) ?? 2023,
                    'director': directorController.text,
                    'genero': genero,
                    'sinopsis': sinopsisController.text,
                    'valoracion': int.tryParse(ratingController.text) ?? 3,
                    'imagen': imagenController.text,
                  };
                  if (doc == null) {
                    await FirebaseFirestore.instance.collection('peliculas').add(data);
                  } else {
                    await FirebaseFirestore.instance.collection('peliculas').doc(doc.id).update(data);
                  }
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                },
                child: Text(doc == null ? 'Guardar' : 'Actualizar'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('peliculas').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                leading: Image.network(data['imagen'] ?? '', width: 40, height: 40, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.movie)),
                title: Text(data['titulo']),
                subtitle: Text('Dir: ${data['director']} • ⭐ ${data['valoracion']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarFormulario(context, doc)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => FirebaseFirestore.instance.collection('peliculas').doc(doc.id).delete()),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        onPressed: () => _mostrarFormulario(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}