import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  CustomTextFormField(
      {Key? key,
      this.label,
      this.controller,
      this.hintText,
      this.labelStyle,
      this.enableObscure = false,
      this.hintStyle,
      this.textInputType,
      this.isEnabled,
      this.prefixIcon,
      this.onChange,
      this.suffixIcon,
      this.initialValue,
      this.validate,
      this.maxLength,
      this.inputFormatter,
      this.suffixCallback})
      : super(key: key);

  final String? label;
  final TextEditingController? controller;
  final String? hintText;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool enableObscure;
  List<FilteringTextInputFormatter>? inputFormatter;
  final TextInputType? textInputType;
  final bool? isEnabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Function(String val)? onChange;
  final String? initialValue;
  final String? Function(String? val)? validate;
  final int? maxLength;
  final VoidCallback? suffixCallback;
  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool isValid = true;

  int _maxLength() {
    if (widget.maxLength == null) {
      return 100;
    } else {
      return widget.maxLength!;
    }
  }
  // List<dynamic> _inputFormatter(){
  //   if (widget.inputFormatter == null){
  //     return [];
  //   }else{
  //     return widget.inputFormatter;
  //   }

  // }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: TextFormField(
            keyboardType: widget.textInputType,
            controller: widget.controller,
            enabled: widget.isEnabled,
            obscureText: widget.enableObscure,
            validator: widget.validate,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: _maxLength(),
            inputFormatters: widget.inputFormatter,
            onChanged: (val) {
              // if (widget.emailField == true) {
              //   isValid = validateEmail(val);
              // }
              // if (widget.lengthField == true) {
              //   isValid = validateMinLength(val, 3);
              // }
              // if (widget.requiredField == true) {
              //   isValid = validateEmpty(val);
              // }

              // setState(() {});
              // widget.validate!(isValid);
              // if (widget.onChange)
              if (widget.onChange != null) widget.onChange!(val);
            },
            initialValue: widget.initialValue,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              hintText: widget.hintText,
              labelStyle: widget.labelStyle,
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : Icon(widget.prefixIcon,
                      size: 16, color: !isValid ? Colors.red : null),
              suffixIcon: widget.suffixIcon == null
                  ? null
                  : (widget.suffixCallback == null
                      ? Icon(widget.suffixIcon,
                          size: 16, color: !isValid ? Colors.red : null)
                      : IconButton(
                          onPressed: widget.suffixCallback!,
                          icon: Icon(widget.suffixIcon,
                              size: 16, color: !isValid ? Colors.red : null))),
            ),
          ),
        )
      ],
    );
  }
}
