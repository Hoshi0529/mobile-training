import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SmallNumberField extends StatelessWidget {
  const SmallNumberField({required this.controller, this.onChanged, super.key});

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 82,
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
        ],
        onChanged: onChanged,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        decoration: const InputDecoration(contentPadding: EdgeInsets.zero),
      ),
    );
  }
}
