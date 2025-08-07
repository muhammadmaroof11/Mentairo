import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mentairo/widgets/custom_input_field.dart';
import 'package:mentairo/helper/firestore_validator.dart';
import 'package:mentairo/pages/Admin_dashboard/quiz_screen.dart';

class SignUpMentorScreen extends StatefulWidget {
  const SignUpMentorScreen({super.key});

  @override
  State<SignUpMentorScreen> createState() => _SignUpMentorScreenState();
}

class _SignUpMentorScreenState extends State<SignUpMentorScreen> {
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _linkedin = TextEditingController();
  final _contact = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final _emailFocusNode = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _selectedField;
  bool _loading = false;
  String? _error;
  bool _passwordValid = false;
  bool _passwordStarted = false;

  String? _emailError;
  String? _fullNameError;
  String? _contactError;

  final List<String> _fields = ['Computer Science', 'Engineering', 'Business', 'Design', 'Medical'];

  final Map<String, List<String>> _fieldSkillsMap = {
    'Computer Science': ['Flutter', 'Java', 'Machine Learning', 'Backend', 'React JS', 'JavaScript', 'C++', 'Game dev', 'Python', 'Databases'],
    'Engineering': ['AutoCAD', 'MATLAB', 'Embedded Systems', 'Robotics'],
    'Business': ['Marketing', 'Financial Management', 'Entrepreneurship', 'Negotiation', 'Customer Service'],
    'Design': ['UI and UX', 'Figma', 'Illustrator', 'Photoshop'],
    'Medical': ['Anatomy', 'Physiology', 'Pharmacology', 'Medical Ethics'],
  };

  List<String> _availableSkills = [];
  List<String> _selectedSkills = [];
  Timer? _debounce;

  void _validatePassword(String value) {
    setState(() {
      _passwordStarted = value.isNotEmpty;
      _passwordValid = value.length >= 6;
    });
  }

  void _checkExistsDebounced(String field, String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final exists = await FirestoreValidator.fieldExists(field, value);
      setState(() {
        if (field == 'email') _emailError = exists ? "Email already in use" : null;
        if (field == 'fullName') _fullNameError = exists ? "Name already taken" : null;
        if (field == 'contact') _contactError = exists ? "Contact number already exists" : null;
      });
    });
  }

  Future<void> _startQuizAndSignUp() async {
    if (_selectedField == null) {
      setState(() => _error = "Please select your field");
      return;
    }
    if (_selectedSkills.isEmpty) {
      setState(() => _error = "Please select at least one skill");
      return;
    }
    if (_password.text != _confirmPassword.text) {
      setState(() => _error = "Passwords do not match");
      return;
    }
    if (!_passwordValid) {
      setState(() => _error = "Password must be at least 6 characters");
      return;
    }
    if (_emailError != null || _fullNameError != null || _contactError != null) return;

    final mentorData = {
      'fullName': _fullName.text.trim(),
      'email': _email.text.trim(),
      'password': _password.text,
      'linkedin': _linkedin.text.trim(),
      'contact': _contact.text.trim(),
      'skills': _selectedSkills,
      'field': _selectedField,
    };

    final score = await Navigator.push<int>(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          field: _selectedField!,
          selectedSkills: _selectedSkills,
          mentorData: mentorData,
        ),
      ),
    );

    if (score == null) {
      setState(() => _error = "Quiz not completed.");
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.deepPurple),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Opacity(
                opacity: 0.07,
                child: Image.asset('assets/images/logo.png', width: 450),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Sign up as MENTOR",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                const SizedBox(height: 22),
                CustomInputField(
                  controller: _fullName,
                  label: 'Full Name',
                  onChanged: (val) => _checkExistsDebounced('fullName', val),
                  errorText: _fullNameError,
                ),
                CustomInputField(
                  controller: _email,
                  label: 'Email',
                  focusNode: _emailFocusNode,
                  onChanged: (val) {
                    final isValid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val);
                    setState(() {
                      if (!_emailFocusNode.hasFocus) {
                        _emailError = null;
                      } else if (!isValid) {
                        _emailError = 'Enter a valid email address';
                      } else {
                        _emailError = null;
                        _checkExistsDebounced('email', val);
                      }
                    });
                  },
                  errorText: _emailError,
                ),
                CustomInputField(controller: _linkedin, label: 'LinkedIn Profile'),
                CustomInputField(
                  controller: _contact,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  onChanged: (val) => _checkExistsDebounced('contact', val),
                  errorText: _contactError,
                ),
                const SizedBox(height: 12),
                const Text("Select your Field"),
                DropdownButton<String>(
                  value: _selectedField,
                  hint: const Text("Choose Field"),
                  isExpanded: true,
                  items: _fields.map((field) {
                    return DropdownMenuItem(value: field, child: Text(field));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedField = value;
                      _availableSkills = _fieldSkillsMap[value] ?? [];
                      _selectedSkills.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedField != null) ...[
                  const Text("Select your Skills"),
                  Wrap(
                    spacing: 8,
                    children: _availableSkills.map((skill) {
                      final isSelected = _selectedSkills.contains(skill);
                      return FilterChip(
                        label: Text(skill),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() {
                            if (val) {
                              _selectedSkills.add(skill);
                            } else {
                              _selectedSkills.remove(skill);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 20),
                TextField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  onChanged: _validatePassword,
                  decoration: InputDecoration(
                    labelText: "Password",
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_passwordStarted && !_passwordValid)
                  const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text("Password must be at least 6 characters",
                        style: TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _loading ? null : _startQuizAndSignUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Take Quiz & Sign Up"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
