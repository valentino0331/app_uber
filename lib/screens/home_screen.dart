import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'create_trip_screen.dart';
import 'my_trips_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _user;
  List<dynamic> _viajes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await ApiService.getUser();
    final viajes = await ApiService.getViajes();
    
    setState(() {
      _user = user;
      _viajes = viajes;
      _isLoading = false;
    });
  }

  Future<void> _reservarViaje(int idViaje) async {
    try {
      await ApiService.createReserva(
        idViaje: idViaje,
        idPasajero: _user!['id'],
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reserva realizada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Recargar viajes
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('UniHitch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateTripScreen()),
              ).then((_) => _loadData());
            },
            tooltip: 'Crear Viaje',
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyTripsScreen()),
              );
            },
            tooltip: 'Mis Viajes',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: Column(
          children: [
            // Header Usuario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, ${_user!['nombre'].split(' ')[0]}! 👋',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user!['correo'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Lista de Viajes
            Expanded(
              child: _viajes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.directions_car, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay viajes disponibles',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _viajes.length,
                      itemBuilder: (context, index) {
                        final viaje = _viajes[index];
                        final fecha = DateTime.parse(viaje['fecha_hora']);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Conductor
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      child: Icon(Icons.person),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          viaje['conductor_nombre'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          viaje['conductor_telefono'] ?? '',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                // Ruta
                                Row(
                                  children: [
                                    const Icon(Icons.trip_origin, color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(viaje['origen'])),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(viaje['destino'])),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Fecha y hora
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat('dd/MM/yyyy HH:mm').format(fecha),
                                      style: const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Precio y asientos
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'S/ ${viaje['precio'].toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_seat, size: 16),
                                        const SizedBox(width: 4),
                                        Text('${viaje['asientos_disponibles']} disponibles'),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Botón Reservar
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: viaje['asientos_disponibles'] > 0
                                        ? () => _reservarViaje(viaje['id'])
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('RESERVAR'),
                                  ),
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
    );
  }
}