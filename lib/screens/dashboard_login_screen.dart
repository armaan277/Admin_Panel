import 'package:flutter/material.dart';
import 'package:new_admin_panel/side_bar.dart';

class DashboardLoginScreen extends StatefulWidget {
  const DashboardLoginScreen({super.key});

  @override
  State<DashboardLoginScreen> createState() => _DashboardLoginScreenState();
}

class _DashboardLoginScreenState extends State<DashboardLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  String email = 'admin@gmail.com';
  String password = 'admin123';
  String error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      backgroundColor: Colors.white, // Dark blue background
      body: Center(
        child: Container(
          width: isSmallScreen ? size.width * 0.9 : 800,
          height: isSmallScreen ? null : 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: isSmallScreen ? _buildMobileLayout() : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left side with illustration
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xffdb3022)
                  .withOpacity(0.3), // Light blue background
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Image.asset(
                'images/ic_launcher.png',
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Image error: $error');
                  return const Text('Image not found');
                },
              ),
            ),
          ),
        ),
        // Right side with login form
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(40),
            child: _buildLoginForm(),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            child: _buildLoginForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Center(
          child: Text(
            'Login to Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xffdb3022), // Dark blue text
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Email field
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@email.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xffdb3022), width: 2),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        // Password field
        TextField(
          controller: _passwordController,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xffdb3022), width: 2),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Error message
        if (error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        // Login button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                if (_emailController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  error = 'Please fill all fields!';
                } else if (_emailController.text != email ||
                    _passwordController.text != password) {
                  error = 'Invalid email or password!';
                } else {
                  error = ''; // Clear error if login is successful
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const SideBar(),
                  ));
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffdb3022), // Dark blue button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'LOGIN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
