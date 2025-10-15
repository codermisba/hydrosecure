import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

/// Animated Header Widget
Widget animatedHeader(String animationPath, {double height = 180}) {
  return Lottie.asset(animationPath, height: height);
}

/// Custom TextField (with optional validator)
Widget customTextField({
  required BuildContext context, // ✅ added context
  required TextEditingController controller,
  required String hint,
  bool isPassword = false,
  IconData? icon,
  String? Function(String?)? validator,
}) {
  final borderColor = Theme.of(context).primaryColor; // dynamic color

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: TextFormField(
      controller: controller,
      obscureText: isPassword,
      style: GoogleFonts.poppins(fontSize: 16),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey[500]),
        prefixIcon: icon != null ? Icon(icon, color: borderColor) : null,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 20.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.5), // ✅ bolder
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.5), // ✅ bolder
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: borderColor,
            width: 2.5,
          ), // slightly thicker
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    ),
  );
}

/// Custom Button Widget
Widget customButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        elevation: 3,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}

/// Grid-style expandable selector
Widget buildExpandableSelector({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<Map<String, String>> options,
  required String? selectedValue,
  required bool isExpanded,
  required VoidCallback onToggle,
  required ValueChanged<String?> onChanged,
  required String? Function(dynamic value) validator, // ✅ updated type
}) {
  final crossAxisCount = 2;

  // ✅ Wrap everything inside a FormField for validation
  return FormField<String>(
    validator: (value) => validator(selectedValue),
    builder: (formFieldState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onToggle, // toggle expansion
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                          .inputDecorationTheme
                          .fillColor ??
                      Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: formFieldState.hasError
                        ? Colors.red // ✅ red border on error
                        : Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(icon, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              selectedValue ?? title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),

                    // Expandable grid content
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: options.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 1.0,
                                ),
                                itemBuilder: (context, index) {
                                  final option = options[index];
                                  final isSelected =
                                      selectedValue == option['value'];

                                  return GestureDetector(
                                    onTap: () {
                                      onChanged(option['value']);
                                      formFieldState
                                          .didChange(option['value']); // ✅ update form field
                                      onToggle();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                                .inputDecorationTheme
                                                .fillColor ??
                                            Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                              : Theme.of(context).primaryColor,
                                          width: isSelected ? 2 : 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: option['image'] != null &&
                                                    option['image']!.isNotEmpty
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            14),
                                                    child: Image.asset(
                                                      option['image']!,
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : Center(
                                                    child: Text(
                                                      option['label'] ??
                                                          option['value']!,
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            option['label'] ??
                                                option['value']!,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ✅ Display error text below
          if (formFieldState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 12),
              child: Text(
                formFieldState.errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      );
    },
  );
}

/// Text-style expandable selector with validation support
Widget buildTextExpandableSelector({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<Map<String, String>> options,
  required String? selectedValue,
  required bool isExpanded,
  required VoidCallback onToggle,
  required ValueChanged<String?> onChanged,
  String? Function(String?)? validator, // <-- Make this a proper validator
}) {
  return FormField<String>(
    validator: (value) => validator?.call(selectedValue),
    builder: (FormFieldState<String> field) {
      final errorText = field.errorText;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onToggle,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).inputDecorationTheme.fillColor ??
                      Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: errorText != null
                        ? Colors.red
                        : Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(icon,
                                color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              selectedValue ?? title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),

                    // Expandable options
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: isExpanded
                          ? Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Column(
                                children: options.map((option) {
                                  final isSelected =
                                      selectedValue == option['value'];
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                              .inputDecorationTheme
                                              .fillColor ??
                                          Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .secondary
                                            : Theme.of(context).primaryColor,
                                        width: isSelected ? 2 : 1.5,
                                      ),
                                    ),
                                    child: ListTile(
                                      dense: true,
                                      visualDensity:
                                          const VisualDensity(vertical: -2),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 4),
                                      title: Text(
                                        option['label'] ??
                                            option['value'] ??
                                            '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      onTap: () {
                                        onChanged(option['value']);
                                        onToggle();
                                        field.didChange(option['value']);
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Error text
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 6.0),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      );
    },
  );
}