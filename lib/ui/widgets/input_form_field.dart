import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputFormField extends StatelessWidget {
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? labelText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final bool? obscure;
  final bool? enabled;
  final bool hasConstraints;
  final String? Function(String?)? onSaved;
  final String? Function(String?)? onChanged;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final String? initialValue;
  final Color? borderColor;
  final Color? fillColor;
  final bool filled;
  final bool readOnly;
  final bool above;
  final BorderRadius? borderRadius;
  final double? height;
  final TextEditingController? controller;

  const InputFormField({
    Key? key,
    this.prefixIcon,
    this.suffixIcon,
    this.labelText,
    this.height,
    this.readOnly = false,
    this.above = false,
    this.hasConstraints = true,
    this.hintText,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.fillColor,
    this.maxLength,
    this.obscure,
    this.enabled,
    this.onSaved,
    this.onChanged,
    this.filled = false,
    this.minLines,
    this.maxLines,
    this.autofillHints,
    this.textInputAction,
    this.initialValue,
    this.borderColor,
    this.borderRadius,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && above) ...{
          Text(
            labelText!,
            style: Theme.of(context)
                .textTheme
                .headlineLarge!
                .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 4,
          ),
        },
        SizedBox(
          height: height,
          child: TextFormField(
            controller: controller,
            enabled: enabled ?? true,
            obscureText: obscure ?? false,
            keyboardType: keyboardType,
            maxLength: maxLength,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            textInputAction: textInputAction,
            validator: validator,
            onSaved: onSaved,
            onChanged: onChanged,
            minLines: minLines,
            maxLines: maxLines ?? 1,
            style: Theme.of(context)
                .textTheme
                .headlineLarge
                ?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
            cursorColor: Theme.of(context).primaryColor,
            initialValue: initialValue,
            readOnly: readOnly,
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              labelText: above ? null : labelText,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: hasConstraints ? 8.0 : 0.0),
                child: prefixIcon,
              ),
              prefixIconConstraints: hasConstraints
                  ? const BoxConstraints(maxWidth: 60, maxHeight: 60)
                  : null,
              suffixIcon: Padding(
                padding: const EdgeInsets.all(10),
                child: suffixIcon,
              ),
              filled: true,
              fillColor: fillColor ?? Theme.of(context).backgroundColor,
              counterText: "",
            ),
          ),
        ),
      ],
    );
  }
}
