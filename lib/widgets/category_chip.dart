import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  IconData _getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'engineering':
        return Icons.engineering;
      case 'business':
        return Icons.business_center;
      case 'medical':
        return Icons.health_and_safety;
      case 'design':
        return Icons.design_services;
      case 'computer science':
        return Icons.computer;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent])
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade300,
              width: 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: Colors.deepPurple.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              if (!isSelected)
                const BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                _getIcon(label),
                size: 18,
                color: isSelected ? Colors.white : Colors.deepPurple,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
