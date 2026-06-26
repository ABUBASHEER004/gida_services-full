import 'package:flutter/material.dart';
import 'provider_login.dart'; // provider login screen
import 'provider_register.dart'; // (you will create next)

class ProvidersScreen extends StatelessWidget {
  const ProvidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Providers"),
      ),

      body: ListView(
        children: [

          _buildInfoCard(
            context,
            title: "Become a Provider",
            subtitle: "Register with email and start receiving jobs",
            icon: Icons.person_add,
            buttonText: "Register",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProviderRegister(),
                ),
              );
            },
          ),

          _buildInfoCard(
            context,
            title: "Provider Login",
            subtitle: "Login to access your dashboard & requests",
            icon: Icons.lock,
            buttonText: "Login",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProviderLogin(),
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Available Service Categories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _buildCategory("Waste Pickup", Icons.delete),
          _buildCategory("Tailor", Icons.man),
          _buildCategory("Shoe Seller", Icons.man),
          _buildCategory("Plumber", Icons.plumbing),
          _buildCategory("Electrician", Icons.electrical_services),
          _buildCategory("Carpenter", Icons.carpenter),
          _buildCategory("Phone Repair", Icons.man_2),
          _buildCategory("Car Repair", Icons.car_repair),
          _buildCategory("Weilding", Icons.electrical_services_outlined),
          _buildCategory("Car Wash", Icons.local_car_wash),
          _buildCategory("Gardener", Icons.man_2),
          _buildCategory("P.o.s Agent", Icons.man_2),
          _buildCategory("Gas Refill", Icons.gas_meter),
          _buildCategory("Meat Seller", Icons.restaurant),
          _buildCategory("Food Delivery", Icons.fastfood),
          _buildCategory("Laundry", Icons.local_laundry_service),
          _buildCategory("Book Barbing Queue", Icons.man),
          _buildCategory("Mai Kitso", Icons.woman),
          _buildCategory("Lesson Teacher", Icons.book),
          _buildCategory("Book Saloon Queue", Icons.woman),
          _buildCategory("Fish Seller", Icons.woman),
          _buildCategory("Delivery Services", Icons.man),
          _buildCategory("Painter", Icons.man),
          _buildCategory("Mai Lalle", Icons.woman),
          _buildCategory("Vegetables and Kayan Miya", Icons.grass),
          _buildCategory("Cleaning", Icons.cleaning_services),
          _buildCategory("Order Snacks", Icons.woman),
           _buildCategory("Napep Booking",Icons.woman),
    _buildCategory("Electronic Appliances Repair",Icons.woman),
    _buildCategory("Animal clinic",Icons.woman),
   _buildCategory("chicken Booking, feeds and Drugs",Icons.woman),
    _buildCategory("Diagnostic centre",Icons.woman),
    _buildCategory("Hospital",Icons.woman),
    _buildCategory("Building Materials",Icons.woman),
    _buildCategory("Plumbing Materials Seller",Icons.woman),
    _buildCategory("Carpentry Materials Seller",Icons.woman),
    _buildCategory("Cement seller",Icons.woman),
    _buildCategory("Pharmacy",Icons.woman),
    _buildCategory("Fabrics(shadda/yadi) Dealer ",Icons.woman),
    _buildCategory("Abaya Seller ",Icons.woman),
    _buildCategory("Football Kits Seller",Icons.woman),
    _buildCategory("Kitchen Utensils Seller",Icons.woman),
    _buildCategory("Restaurant",Icons.woman),
    _buildCategory("Graphic Designer",Icons.woman),
    _buildCategory("Building Labourer",Icons.woman),
    _buildCategory("Construction Firms",Icons.woman),
    _buildCategory("Real Estate Agent",Icons.woman),
    _buildCategory("Pure Water Distributor",Icons.woman),
    _buildCategory("Cloths/Baby Cloths Seller",Icons.woman),
    _buildCategory("Make-up Saloon",Icons.woman),
    _buildCategory("Printing, Writing and Reading Materials Seller",Icons.woman),
    _buildCategory("Electronic Appliances Seller",Icons.woman),
    _buildCategory("Provision Store",Icons.woman),
    _buildCategory("Islamic Lesson Teacher",Icons.woman),
    _buildCategory("Beds Seller",Icons.woman),
    _buildCategory("Furniture Seller",Icons.woman),
    _buildCategory("Suya Spot",Icons.woman),
    _buildCategory("Animals Seller",Icons.woman),
    _buildCategory("Rice Seller",Icons.woman),
    _buildCategory("Grain Seller",Icons.woman),
    _buildCategory("Yam Seller",Icons.woman),
    _buildCategory("Fruits Seller",Icons.woman),
    _buildCategory("Rubber Home Equipment Seller ",Icons.woman),
    _buildCategory("Palm oil/Groundnut oil seller",Icons.woman),
    _buildCategory("Petrol Black Marketer",Icons.woman),
    _buildCategory("Women Beauty Products Seller",Icons.woman),
    _buildCategory("School ",Icons.woman),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: Text(buttonText),
        ),
      ),
    );
  }

  Widget _buildCategory(String title, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }
}






