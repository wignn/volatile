import 'package:flutter/material.dart';

class AuthTextfield extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction inputAction;
  final bool isObscure;
  final Key? textKey;
  final bool hasSuffix;
  final VoidCallback? onSuffixPressed;
  final IconData? prefixIcon;
  final String? Function(String?)? validator;

  const AuthTextfield({
    super.key,
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.isObscure = false,
    this.hasSuffix = false,
    this.onSuffixPressed,
    this.textKey,
    this.prefixIcon,
    this.validator,
  });

  @override
  State<AuthTextfield> createState() => _AuthTextfieldState();
}

class _AuthTextfieldState extends State<AuthTextfield> {
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isFocused
            ? [
          BoxShadow(
            color: Color(0xFF3B82F6).withOpacity(0.2),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ]
            : [],
      ),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isObscure,
        key: widget.textKey,
        focusNode: _focusNode,
        enableInteractiveSelection: true,
        validator: widget.validator,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: widget.labelText,
          labelStyle: TextStyle(
            color: _isFocused ? Color(0xFF3B82F6) : Colors.grey[500],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelStyle: TextStyle(
            color: Color(0xFF3B82F6),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          filled: true,
          fillColor: Color(0xFF1E293B),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
            widget.prefixIcon,
            color: _isFocused ? Color(0xFF3B82F6) : Colors.grey[500],
            size: 22,
          )
              : null,
          suffixIcon: widget.hasSuffix
              ? IconButton(
            onPressed: widget.onSuffixPressed,
            icon: Icon(
              widget.isObscure ? Icons.visibility_off : Icons.visibility,
              color: _isFocused ? Color(0xFF3B82F6) : Colors.grey[500],
            ),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[800]!,
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey[800]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Color(0xFF3B82F6),
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red[400]!,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.red[400]!,
              width: 2.5,
            ),
          ),
        ),
        keyboardType: widget.keyboardType,
        textInputAction: widget.inputAction,
      ),
    );
  }
}