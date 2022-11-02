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
      this.maxLine,
      this.inputFormatter,
      this.suffixCallback})
      : super(key: key);
  final int? maxLine;
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

  @override
  Widget build(BuildContext context) {
    return


        Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              widget.label!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
            ),
          ),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
          child: TextFormField(
            keyboardType: widget.textInputType,
            controller: widget.controller,
            enabled: widget.isEnabled,
            obscureText: widget.enableObscure,
            maxLines: widget.maxLine ?? 1,
            validator: widget.validate,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: widget.maxLength ?? 100,
            inputFormatters: widget.inputFormatter,
            onChanged: (val) {
              if (widget.onChange != null) widget.onChange!(val);
            },
            initialValue: widget.initialValue,
            decoration: InputDecoration(
              // contentPadding:
              //     const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              counterText: "",
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
