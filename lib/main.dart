import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _red = Color(0xFFCC203A);
const _orange = Color(0xFFFF8A00);
const _cream = Color(0xFFFFF7F2);
const _purple = Color(0xFF390351);
const _profileKey = 'mangis.ios.profile';
const _addressesKey = 'mangis.ios.addresses';
const _ordersKey = 'mangis.ios.orders';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MangisApp());
}

@immutable
class CustomerProfile {
  const CustomerProfile({
    required this.name,
    required this.phone,
  });

  final String name;
  final String phone;

  Map<String, Object?> toJson() => {'name': name, 'phone': phone};

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      CustomerProfile(name: json['name'] as String, phone: json['phone'] as String);
}

@immutable
class DeliveryAddress {
  const DeliveryAddress({
    required this.label,
    required this.line,
    this.zone = '',
    this.reference = '',
    this.latitude,
    this.longitude,
  });

  final String label;
  final String line;
  final String zone;
  final String reference;
  final double? latitude;
  final double? longitude;

  Map<String, Object?> toJson() => {
        'label': label,
        'line': line,
        'zone': zone,
        'reference': reference,
        'latitude': latitude,
        'longitude': longitude,
      };

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        label: json['label'] as String? ?? 'Casa',
        line: json['line'] as String? ?? '',
        zone: json['zone'] as String? ?? '',
        reference: json['reference'] as String? ?? '',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );
}

@immutable
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.store,
    required this.category,
    required this.service,
    required this.price,
    required this.image,
    required this.description,
    required this.time,
    this.badge = '',
    this.rating = '',
  });

  final String id;
  final String name;
  final String store;
  final String category;
  final String service;
  final int price;
  final String image;
  final String description;
  final String time;
  final String badge;
  final String rating;
}

const _products = <Product>[
  Product(id: 'food-1', name: 'Doble Mangis', store: 'La Burguesa', category: 'Hamburguesas', service: 'Comida', price: 42000, image: 'burger', description: 'Doble carne, queso cheddar, lechuga y salsa de la casa.', time: '25–35 min', badge: 'Más pedido', rating: '4.9'),
  Product(id: 'food-2', name: 'Pizza cuatro quesos', store: 'Pizzería Napoli', category: 'Pizza', service: 'Comida', price: 58000, image: 'pizza-cheese', description: 'Mozzarella, parmesano, provolone y queso azul.', time: '30–40 min', badge: '−20%', rating: '4.8'),
  Product(id: 'food-3', name: 'Sushi mix · 20 piezas', store: 'Sakura Sushi', category: 'Sushi', service: 'Comida', price: 69000, image: 'sushi', description: 'Una selección fresca para compartir.', time: '35–45 min', badge: 'Favorito', rating: '4.9'),
  Product(id: 'food-4', name: 'Combo lomito árabe', store: 'El Buen Sabor', category: 'Comida paraguaya', service: 'Comida', price: 35000, image: 'lomito', description: 'Lomito con acompañamiento y salsa casera.', time: '20–30 min', rating: '4.7'),
  Product(id: 'food-5', name: 'Açaí bowl tropical', store: 'Verde Vida', category: 'Postres', service: 'Comida', price: 28000, image: 'acai', description: 'Açaí, frutas frescas y granola crocante.', time: '20–30 min', badge: 'Nuevo', rating: '4.8'),
  Product(id: 'food-6', name: 'Pollo crispy familiar', store: 'Pollos Don Juan', category: 'Pollo', service: 'Comida', price: 62000, image: 'chicken', description: 'Pollo crocante, dorado y recién hecho.', time: '30–40 min', rating: '4.6'),
  Product(id: 'food-7', name: 'Pizza pepperoni', store: 'Pizzería Napoli', category: 'Pizza', service: 'Comida', price: 54000, image: 'pepperoni', description: 'Masa artesanal, mozzarella y pepperoni.', time: '30–40 min', rating: '4.8'),
  Product(id: 'food-8', name: 'Lasagna boloñesa', store: 'Pizzería Napoli', category: 'Pastas', service: 'Comida', price: 52000, image: 'lasagna', description: 'Capas de pasta, salsa boloñesa y queso.', time: '30–40 min', badge: 'Casera', rating: '4.8'),
  Product(id: 'food-9', name: 'Fettuccine Alfredo', store: 'Pasta & Punto', category: 'Pastas', service: 'Comida', price: 48000, image: 'pasta', description: 'Pasta cremosa con parmesano.', time: '25–35 min', rating: '4.9'),
  Product(id: 'food-10', name: 'Tacos al pastor', store: 'Taquería Norte', category: 'Tacos', service: 'Comida', price: 39000, image: 'tacos', description: 'Tortillas con cerdo al pastor, piña y cilantro.', time: '20–30 min', rating: '4.8'),
  Product(id: 'food-11', name: 'Tacos de carne asada', store: 'Taquería Norte', category: 'Tacos', service: 'Comida', price: 42000, image: 'tacos-asada', description: 'Carne asada a la parrilla con salsa fresca.', time: '20–30 min', rating: '4.7'),
  Product(id: 'food-12', name: 'Smash burger clásica', store: 'La Burguesa', category: 'Hamburguesas', service: 'Comida', price: 36000, image: 'burger', description: 'Carne smash, queso, pepinillos y salsa.', time: '25–35 min', badge: 'Nueva', rating: '4.9'),
  Product(id: 'market-1', name: 'Arroz blanco · 1 kg', store: 'Supermercado Mangis', category: 'Almacén', service: 'Supermercado', price: 9000, image: 'demo-rice', description: 'Arroz blanco, paquete de 1 kg.', time: 'Entrega a coordinar'),
  Product(id: 'market-2', name: 'Leche entera · 1 litro', store: 'Supermercado Mangis', category: 'Lácteos', service: 'Supermercado', price: 8500, image: 'demo-milk', description: 'Leche entera en envase de 1 litro.', time: 'Entrega a coordinar'),
  Product(id: 'market-3', name: 'Banana · 1 kg', store: 'Supermercado Mangis', category: 'Frutas', service: 'Supermercado', price: 12000, image: 'demo-banana', description: 'Bananas frescas por kilogramo.', time: 'Entrega a coordinar'),
  Product(id: 'market-4', name: 'Huevos · docena', store: 'Supermercado Mangis', category: 'Frescos', service: 'Supermercado', price: 18000, image: 'demo-eggs', description: 'Docena de huevos frescos.', time: 'Entrega a coordinar'),
  Product(id: 'pharmacy-1', name: 'Alcohol en gel · 250 ml', store: 'Farmacia Mangis', category: 'Higiene', service: 'Farmacia', price: 14000, image: 'demo-gel', description: 'Gel antibacterial para higiene de manos, presentación de 250 ml.', time: 'Entrega a coordinar'),
  Product(id: 'pharmacy-2', name: 'Protector solar · 50 ml', store: 'Farmacia Mangis', category: 'Cuidado personal', service: 'Farmacia', price: 52000, image: 'demo-sunscreen', description: 'Protector solar para el cuidado diario de la piel, 50 ml.', time: 'Entrega a coordinar'),
  Product(id: 'pharmacy-3', name: 'Apósitos adhesivos · caja', store: 'Farmacia Mangis', category: 'Primeros auxilios', service: 'Farmacia', price: 11000, image: 'demo-bandages', description: 'Caja de apósitos adhesivos para primeros auxilios.', time: 'Entrega a coordinar'),
  Product(id: 'pharmacy-4', name: 'Shampoo · 400 ml', store: 'Farmacia Mangis', category: 'Cuidado personal', service: 'Farmacia', price: 32000, image: 'demo-shampoo', description: 'Shampoo de uso diario en presentación de 400 ml.', time: 'Entrega a coordinar'),
  Product(id: 'shop-1', name: 'Auriculares inalámbricos', store: 'Tecnología Mangis', category: 'Tecnología', service: 'Tiendas', price: 145000, image: 'demo-headphones', description: 'Auriculares inalámbricos para escuchar música y atender llamadas.', time: 'Entrega a coordinar'),
  Product(id: 'shop-2', name: 'Termo de acero · 1 litro', store: 'Hogar y regalos', category: 'Hogar', service: 'Tiendas', price: 98000, image: 'demo-bottle', description: 'Termo de acero inoxidable con capacidad de 1 litro.', time: 'Entrega a coordinar'),
  Product(id: 'shop-3', name: 'Mochila urbana', store: 'Accesorios Mangis', category: 'Accesorios', service: 'Tiendas', price: 185000, image: 'demo-backpack', description: 'Mochila urbana con compartimento principal y bolsillos laterales.', time: 'Entrega a coordinar'),
  Product(id: 'shop-4', name: 'Lámpara de escritorio', store: 'Hogar y regalos', category: 'Hogar', service: 'Tiendas', price: 125000, image: 'demo-lamp', description: 'Lámpara de escritorio para espacios de estudio y trabajo.', time: 'Entrega a coordinar'),
];

class MangisApp extends StatefulWidget {
  const MangisApp({super.key, this.initialProfile});

  final CustomerProfile? initialProfile;

  @override
  State<MangisApp> createState() => _MangisAppState();
}

class _MangisAppState extends State<MangisApp> {
  CustomerProfile? _profile;
  List<DeliveryAddress> _addresses = [];
  List<Map<String, dynamic>> _orders = [];
  Map<String, int> _cart = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final profileValue = widget.initialProfile == null
        ? prefs.getString(_profileKey)
        : jsonEncode(widget.initialProfile!.toJson());
    if (profileValue != null) {
      _profile = CustomerProfile.fromJson(
          jsonDecode(profileValue) as Map<String, dynamic>);
    }
    _addresses = (jsonDecode(prefs.getString(_addressesKey) ?? '[]') as List)
        .map((item) => DeliveryAddress.fromJson(item as Map<String, dynamic>))
        .toList();
    _orders = (jsonDecode(prefs.getString(_ordersKey) ?? '[]') as List)
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    if (widget.initialProfile != null) {
      await prefs.setString(_profileKey, profileValue!);
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _saveProfile(CustomerProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
    if (mounted) setState(() => _profile = profile);
  }

  Future<void> _saveAddresses(List<DeliveryAddress> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _addressesKey, jsonEncode(addresses.map((item) => item.toJson()).toList()));
    if (mounted) setState(() => _addresses = addresses);
  }

  Future<void> _saveOrder(Map<String, dynamic> order) async {
    final prefs = await SharedPreferences.getInstance();
    final next = [order, ..._orders];
    await prefs.setString(_ordersKey, jsonEncode(next));
    if (mounted) setState(() {
      _orders = next;
      _cart = {};
    });
  }

  void _changeQuantity(Product product, int amount) {
    final next = Map<String, int>.from(_cart);
    final value = (next[product.id] ?? 0) + amount;
    if (value <= 0) {
      next.remove(product.id);
    } else {
      next[product.id] = value;
    }
    setState(() => _cart = next);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Mangis',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: _red,
          colorScheme: ColorScheme.fromSeed(
            seedColor: _red,
            primary: _red,
            secondary: _orange,
            surface: _cream,
          ),
          fontFamily: 'Nunito',
          appBarTheme: const AppBarTheme(
            backgroundColor: _red,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: _loading
            ? const _Splash()
            : _profile == null
                ? _Onboarding(
                    onComplete: (profile, address) async {
                      await _saveProfile(profile);
                      await _saveAddresses([address]);
                    },
                  )
                : _Home(
                    profile: _profile!,
                    addresses: _addresses,
                    orders: _orders,
                    cart: _cart,
                    onQuantity: _changeQuantity,
                    onSaveAddresses: _saveAddresses,
                    onSaveOrder: _saveOrder,
                    onSaveProfile: _saveProfile,
                  ),
      );
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: _orange),
        ),
      );
}

class _Onboarding extends StatefulWidget {
  const _Onboarding({required this.onComplete});
  final Future<void> Function(CustomerProfile, DeliveryAddress) onComplete;

  @override
  State<_Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<_Onboarding> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.onComplete(
      CustomerProfile(name: _name.text.trim(), phone: _phone.text.trim()),
      DeliveryAddress(label: 'Casa', line: _address.text.trim()),
    );
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
            children: [
              Center(
                child: Image.asset('assets/images/mangis-logo-white.png',
                    height: 54, fit: BoxFit.contain),
              ),
              const SizedBox(height: 32),
              Center(
                child: Image.asset('assets/images/mangis-burger.png',
                    height: 172, fit: BoxFit.contain),
              ),
              const SizedBox(height: 20),
              const Text('Bienvenido a Mangis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'Completá tus datos para empezar a pedir.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 24),
              Form(
                key: _form,
                child: Column(
                  children: [
                    _input(_name, 'Nombre y apellido', Icons.person_outline),
                    const SizedBox(height: 12),
                    _input(_phone, 'Número de celular', Icons.phone_outlined,
                        keyboard: TextInputType.phone),
                    const SizedBox(height: 12),
                    _input(_address, 'Dirección de entrega', Icons.location_on_outlined),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _continue,
                        style: FilledButton.styleFrom(
                          backgroundColor: _orange,
                          foregroundColor: _purple,
                          minimumSize: const Size.fromHeight(52),
                        ),
                        child: Text(_saving ? 'Guardando…' : 'Continuar',
                            style: const TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

Widget _input(TextEditingController controller, String label, IconData icon,
    {TextInputType keyboard = TextInputType.text}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboard,
    textCapitalization: TextCapitalization.sentences,
    validator: (value) =>
        (value == null || value.trim().isEmpty) ? 'Este campo es obligatorio' : null,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: _red),
      filled: true,
      fillColor: _cream,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .5))),
    ),
  );
}

class _Home extends StatefulWidget {
  const _Home({
    required this.profile,
    required this.addresses,
    required this.orders,
    required this.cart,
    required this.onQuantity,
    required this.onSaveAddresses,
    required this.onSaveOrder,
    required this.onSaveProfile,
  });
  final CustomerProfile profile;
  final List<DeliveryAddress> addresses;
  final List<Map<String, dynamic>> orders;
  final Map<String, int> cart;
  final void Function(Product, int) onQuantity;
  final Future<void> Function(List<DeliveryAddress>) onSaveAddresses;
  final Future<void> Function(Map<String, dynamic>) onSaveOrder;
  final Future<void> Function(CustomerProfile) onSaveProfile;

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  int _tab = 0;
  String _service = 'Comida';
  String _query = '';

  int get _cartCount => widget.cart.values.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final views = [
      _catalog(),
      _promos(),
      _cart(),
      _orders(),
      _account(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/mangis-logo-white.png',
            height: 34, fit: BoxFit.contain),
        actions: [
          TextButton.icon(
            onPressed: () => _editAddresses(),
            icon: const Icon(Icons.location_on_outlined, color: Colors.white),
            label: Text(
              widget.addresses.isEmpty
                  ? 'Agregar dirección'
                  : widget.addresses.first.label,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(child: views[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        backgroundColor: _cream,
        indicatorColor: const Color(0xFFFFE6CF),
        destinations: [
          const NavigationDestination(
              icon: Icon(Icons.home_outlined), label: 'Inicio'),
          const NavigationDestination(
              icon: Icon(Icons.local_offer_outlined), label: 'Promos'),
          NavigationDestination(
              icon: Badge(
                  isLabelVisible: _cartCount > 0,
                  label: Text('$_cartCount'),
                  child: const Icon(Icons.shopping_bag_outlined)),
              label: 'Carrito'),
          const NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined), label: 'Pedidos'),
          const NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Mi perfil'),
        ],
      ),
    );
  }

  Widget _catalog({bool promosOnly = false}) {
    final shown = _products.where((product) {
      final matchesService = promosOnly
          ? product.badge.isNotEmpty
          : _service == 'Todos' || product.service == _service;
      final matchesQuery = _query.isEmpty ||
          '${product.name} ${product.store} ${product.category}'
              .toLowerCase()
              .contains(_query.toLowerCase());
      return matchesService && matchesQuery;
    }).toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    hintText: '¿Qué estás buscando?',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: _cream,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none),
                  ),
                ),
                if (!promosOnly) ...[
                  const SizedBox(height: 18),
                  const Text('PEDÍ, COMPRÁ, RECIBÍ',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 8),
                  const Text('Descubrí lo que te gusta.',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['Todos', 'Comida', 'Supermercado', 'Farmacia', 'Tiendas']
                          .map((name) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(name),
                                  selected: name == _service,
                                  onSelected: (_) => setState(() => _service = name),
                                  selectedColor: _orange,
                                  backgroundColor: _cream,
                                  labelStyle: TextStyle(
                                      color: name == _service ? _purple : _red,
                                      fontWeight: FontWeight.w800),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Promociones',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900)),
                  ),
              ],
            ),
          ),
        ),
        if (shown.isEmpty)
          const SliverFillRemaining(
              child: Center(
                  child: Text('No encontramos productos.',
                      style: TextStyle(color: Colors.white))))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            sliver: SliverGrid.builder(
              itemCount: shown.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 315,
              ),
              itemBuilder: (context, index) => _productCard(shown[index]),
            ),
          ),
      ],
    );
  }

  Widget _productCard(Product product) => Container(
        decoration: BoxDecoration(
            color: _cream,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x1F390351), blurRadius: 12, offset: Offset(0, 5))
            ]),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 112,
              width: double.infinity,
              child: Image.asset(
                'assets/images/food-${product.image}.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFFFE6CF),
                  child: const Icon(Icons.restaurant, color: _red, size: 40),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.store,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _purple, fontSize: 10)),
                    const SizedBox(height: 4),
                    Text(product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _purple,
                            fontSize: 14,
                            height: 1.1,
                            fontWeight: FontWeight.w900)),
                    if (product.badge.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(product.badge,
                            style: const TextStyle(
                                color: _red,
                                fontSize: 10,
                                fontWeight: FontWeight.w800)),
                      ),
                    const Spacer(),
                    Text(_money(product.price),
                        style: const TextStyle(
                            color: _purple,
                            fontSize: 13,
                            fontWeight: FontWeight.w900)),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 34,
                      child: OutlinedButton(
                        onPressed: () {
                          widget.onQuantity(product, 1);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${product.name} agregado')));
                        },
                        style: OutlinedButton.styleFrom(
                            foregroundColor: _red,
                            side: const BorderSide(color: _red),
                            padding: EdgeInsets.zero),
                        child: const Text('＋ Agregar al pedido',
                            style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _promos() => _catalog(promosOnly: true);

  Widget _cart() {
    final lines = _products
        .where((product) => (widget.cart[product.id] ?? 0) > 0)
        .toList();
    final total = lines.fold<int>(
        0, (sum, product) => sum + product.price * widget.cart[product.id]!);
    if (lines.isEmpty) {
      return const Center(
          child: Text('Tu carrito está vacío.',
              style: TextStyle(color: Colors.white, fontSize: 16)));
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Tu pedido',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 12),
        ...lines.map((product) => Card(
              color: _cream,
              child: ListTile(
                title: Text(product.name,
                    style: const TextStyle(color: _purple, fontWeight: FontWeight.w800)),
                subtitle: Text(_money(product.price)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        onPressed: () => widget.onQuantity(product, -1),
                        icon: const Icon(Icons.remove_circle_outline, color: _red)),
                    Text('${widget.cart[product.id]}'),
                    IconButton(
                        onPressed: () => widget.onQuantity(product, 1),
                        icon: const Icon(Icons.add_circle_outline, color: _red)),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 10),
        _summaryRow('Subtotal', _money(total)),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _checkout(lines, total),
          style: FilledButton.styleFrom(
              backgroundColor: _orange, foregroundColor: _purple, minimumSize: const Size.fromHeight(50)),
          child: const Text('Confirmar pedido',
              style: TextStyle(fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Future<void> _checkout(List<Product> products, int total) async {
    if (widget.addresses.isEmpty) {
      await _editAddresses();
      return;
    }
    final address = widget.addresses.first;
    final order = <String, dynamic>{
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'createdAt': DateTime.now().toIso8601String(),
      'status': 'Recibido',
      'customer': widget.profile.name,
      'phone': widget.profile.phone,
      'address': address.line,
      'addressName': address.label,
      'total': total,
      'items': products
          .map((product) => {
                'name': product.name,
                'quantity': widget.cart[product.id],
                'unitPrice': product.price,
              })
          .toList(),
    };
    await widget.onSaveOrder(order);
    if (!mounted) return;
    setState(() => _tab = 3);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido confirmado.')));
  }

  Widget _orders() => widget.orders.isEmpty
      ? const Center(
          child: Text('Todavía no tenés pedidos.',
              style: TextStyle(color: Colors.white, fontSize: 16)))
      : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Mis pedidos',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            ...widget.orders.map((order) => Card(
                  color: _cream,
                  child: ExpansionTile(
                    title: Text('Pedido #${order['id']}',
                        style: const TextStyle(color: _purple, fontWeight: FontWeight.w800)),
                    subtitle: Text('${order['status']} · ${_money(order['total'] as int)}'),
                    children: [
                      ...(order['items'] as List<dynamic>).map((item) => ListTile(
                            dense: true,
                            title: Text(item['name'] as String),
                            trailing: Text('×${item['quantity']}'),
                          )),
                      ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: _red),
                        title: Text(order['address'] as String),
                      ),
                    ],
                  ),
                )),
          ],
        );

  Widget _account() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Mi perfil',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          Card(
            color: _cream,
            child: ListTile(
              leading: const CircleAvatar(
                  backgroundColor: _red,
                  child: Icon(Icons.person, color: Colors.white)),
              title: Text(widget.profile.name,
                  style: const TextStyle(color: _purple, fontWeight: FontWeight.w800)),
              subtitle: Text(widget.profile.phone),
              trailing: IconButton(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined, color: _red)),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            color: _cream,
            child: ListTile(
              leading: const Icon(Icons.location_on_outlined, color: _red),
              title: const Text('Direcciones'),
              subtitle: Text(widget.addresses.isEmpty
                  ? 'Agregá una dirección'
                  : widget.addresses.map((item) => item.line).join('\n')),
              trailing: const Icon(Icons.chevron_right, color: _red),
              onTap: _editAddresses,
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _editAddresses(addNew: true),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: const Text('Agregar otra dirección'),
            style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white)),
          ),
        ],
      );

  Future<void> _editProfile() async {
    final name = TextEditingController(text: widget.profile.name);
    final phone = TextEditingController(text: widget.profile.phone);
    final result = await showDialog<CustomerProfile>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Celular')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () {
                if (name.text.trim().isNotEmpty && phone.text.trim().isNotEmpty) {
                  Navigator.pop(context,
                      CustomerProfile(name: name.text.trim(), phone: phone.text.trim()));
                }
              },
              child: const Text('Guardar')),
        ],
      ),
    );
    name.dispose();
    phone.dispose();
    if (result != null) await widget.onSaveProfile(result);
  }

  Future<void> _editAddresses({bool addNew = false}) async {
    final current = addNew || widget.addresses.isEmpty ? null : widget.addresses.first;
    final label = TextEditingController(text: current?.label ?? 'Casa');
    final line = TextEditingController(text: current?.line ?? '');
    final zone = TextEditingController(text: current?.zone ?? '');
    final reference = TextEditingController(text: current?.reference ?? '');
    var point = current?.latitude != null && current?.longitude != null
        ? LatLng(current!.latitude!, current.longitude!)
        : const LatLng(-25.2867, -57.3333);
    final result = await showDialog<DeliveryAddress>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Dirección de entrega'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: label, decoration: const InputDecoration(labelText: 'Nombre (Casa, trabajo…)')),
                  TextField(controller: line, decoration: const InputDecoration(labelText: 'Calle y número')),
                  TextField(controller: zone, decoration: const InputDecoration(labelText: 'Zona o ciudad')),
                  TextField(controller: reference, decoration: const InputDecoration(labelText: 'Referencia')),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 170,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: point,
                        initialZoom: 13,
                        onTap: (_, selected) => setDialogState(() => point = selected),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.mangis.mangis',
                        ),
                        MarkerLayer(markers: [
                          Marker(
                            point: point,
                            width: 42,
                            height: 42,
                            child: const Icon(Icons.location_pin, color: _red, size: 40),
                          )
                        ]),
                        RichAttributionWidget(
                          attributions: [
                            TextSourceAttribution('OpenStreetMap contributors'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        final enabled = await Geolocator.isLocationServiceEnabled();
                        if (!enabled) throw Exception('Activá los servicios de ubicación.');
                        var permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }
                        if (permission == LocationPermission.denied ||
                            permission == LocationPermission.deniedForever) {
                          throw Exception('Permití el acceso a la ubicación en Ajustes.');
                        }
                        final pos = await Geolocator.getCurrentPosition();
                        setDialogState(() => point = LatLng(pos.latitude, pos.longitude));
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(error.toString())));
                        }
                      }
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Usar mi ubicación actual'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                if (label.text.trim().isNotEmpty && line.text.trim().isNotEmpty) {
                  Navigator.pop(
                    dialogContext,
                    DeliveryAddress(
                      label: label.text.trim(),
                      line: line.text.trim(),
                      zone: zone.text.trim(),
                      reference: reference.text.trim(),
                      latitude: point.latitude,
                      longitude: point.longitude,
                    ),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
    label.dispose();
    line.dispose();
    zone.dispose();
    reference.dispose();
    if (result != null) {
      final next = addNew || widget.addresses.isEmpty
          ? [result, ...widget.addresses]
          : [result, ...widget.addresses.skip(1)];
      await widget.onSaveAddresses(next);
    }
  }

  Widget _summaryRow(String left, String right) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(left, style: const TextStyle(color: Colors.white)),
            Text(right,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w900)),
          ],
        ),
      );
}

String _money(int amount) =>
    '₲ ${amount.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
