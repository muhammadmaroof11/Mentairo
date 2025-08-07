// widgets/skill_selector.dart
import 'package:flutter/material.dart';

class SkillSelector extends StatefulWidget {
  final List<String> allSkills;
  final Function(List<String>) onChanged;

  const SkillSelector({super.key, required this.allSkills, required this.onChanged});

  @override
  State<SkillSelector> createState() => _SkillSelectorState();
}

class _SkillSelectorState extends State<SkillSelector> {
  List<String> selectedSkills = [];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: widget.allSkills.map((skill) {
        final isSelected = selectedSkills.contains(skill);
        return FilterChip(
          label: Text(skill),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val) {
                selectedSkills.add(skill);
              } else {
                selectedSkills.remove(skill);
              }
              widget.onChanged(selectedSkills);
            });
          },
        );
      }).toList(),
    );
  }
}
