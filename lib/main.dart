import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Faja IoT',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        primaryColor: const Color(0xFF8B5CF6),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // TU URL DE RENDER
  final String apiUrl = "https://faja-backend-api.onrender.com";

  bool isConnected = false;
  bool isLoading = false;
  bool motorOn = false;
  int cPeq = 0, cMed = 0, cGra = 0;
  bool s1 = false, s2 = false, s3 = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    manualConnect();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if(isConnected) fetchStatus(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> manualConnect() async {
    setState(() => isLoading = true);
    await fetchStatus(silent: false);
    setState(() => isLoading = false);
  }

  Future<void> fetchStatus({bool silent = false}) async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/api/status'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            isConnected = true;
            motorOn = data['motorOn'];
            cPeq = data['pequenas'];
            cMed = data['medianas'];
            cGra = data['grandes'];
            s1 = data['sensors']['s1'];
            s2 = data['sensors']['s2'];
            s3 = data['sensors']['s3'];
          });
          if(!silent) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(content: Text("¡Conectado!"), backgroundColor: Colors.green)
             );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => isConnected = false);
        if(!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Error de conexión"), backgroundColor: Colors.red)
          );
        }
      }
    }
  }

  Future<void> controlMotor(String action) async {
    try {
      await http.post(Uri.parse('$apiUrl/api/motor/$action'));
      setState(() => motorOn = (action == "start"));
    } catch (e) {
       // Error de red
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faja IoT"),
        backgroundColor: const Color(0xFF1E293B),
        actions: [
          IconButton(
            icon: isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
              : const Icon(Icons.refresh),
            onPressed: manualConnect,
          ),
          const SizedBox(width: 15),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.circle, color: isConnected ? Colors.green : Colors.red, size: 15),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if(!isConnected && !isLoading)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2), 
                  borderRadius: BorderRadius.circular(10)
                ),
                child: const Row(
                  children: [
                    Icon(Icons.wifi_off, color: Colors.red),
                    SizedBox(width: 10),
                    Expanded(child: Text("Sin conexión. Toca 🔄", style: TextStyle(color: Colors.white))),
                  ],
                ),
              ),

            // MOTOR
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("CONTROL MOTOR", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.all(15)),
                            onPressed: isConnected ? () => controlMotor("start") : null,
                            icon: const Icon(Icons.play_arrow), label: const Text("INICIAR"),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.all(15)),
                            onPressed: isConnected ? () => controlMotor("stop") : null,
                            icon: const Icon(Icons.stop), label: const Text("PARAR"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(motorOn ? "MOTOR: ANDANDO" : "MOTOR: DETENIDO", 
                      style: TextStyle(color: motorOn ? Colors.greenAccent : Colors.white24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),

            // SENSORES
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text("SENSORES", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _sensorView("S1", s1),
                        _sensorView("S2", s2),
                        _sensorView("S3", s3),
                      ],
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            
            // CONTADORES
            const Text("CONTEO", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _infoCard("Pequeñas", cPeq, Colors.redAccent)),
              const SizedBox(width: 10),
              Expanded(child: _infoCard("Medianas", cMed, Colors.blueAccent)),
            ]),
            const SizedBox(height: 10),
            _infoCard("Grandes", cGra, Colors.greenAccent),
          ],
        ),
      ),
    );
  }

  Widget _sensorView(String name, bool active) {
    return Column(
      children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(
            color: active ? Colors.green : Colors.grey[800],
            shape: BoxShape.circle,
            boxShadow: active ? [BoxShadow(color: Colors.green, blurRadius: 10)] : []
          ),
        ),
        const SizedBox(height: 5),
        Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _infoCard(String title, int count, Color color) {
    return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2), 
          borderRadius: BorderRadius.circular(10), 
          border: Border.all(color: color)
        ),
        child: Column(children: [
          Text(count.toString(), style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: TextStyle(color: color)),
        ]),
    );
  }
}