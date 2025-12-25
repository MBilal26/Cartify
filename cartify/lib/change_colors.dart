import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'colors.dart';

class ChangeColorsPage extends StatefulWidget {
  final String pageName;

  const ChangeColorsPage({super.key, required this.pageName});

  @override
  State<ChangeColorsPage> createState() => _ChangeColorsPageState();
}

class _ChangeColorsPageState extends State<ChangeColorsPage> {
  // Get page-specific color options
  List<Map<String, dynamic>> _getColorOptions() {
    List<Map<String, dynamic>> options = [
      {
        'title': 'AppBar Color',
        'currentColor': AppColors.accent,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customAccent = color;
          });
        },
      },
      {
        'title': 'Background Color',
        'currentColor': AppColors.background,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customBackground = color;
          });
        },
      },
      {
        'title': 'Text Color (Primary)',
        'currentColor': AppColors.textPrimary,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customTextPrimary = color;
          });
        },
      },
      {
        'title': 'Text Color (Secondary)',
        'currentColor': AppColors.textSecondary,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customTextSecondary = color;
          });
        },
      },
      {
        'title': 'Card Color',
        'currentColor': AppColors.card,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customCard = color;
          });
        },
      },
      {
        'title': 'Border Color',
        'currentColor': AppColors.border,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customBorder = color;
          });
        },
      },
      {
        'title': 'Icon Color',
        'currentColor': AppColors.accent,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customAccent = color;
          });
        },
      },
    ];

    // Add page-specific options
    if (widget.pageName == 'HOME') {
      options.add({
        'title': 'Drawer Background Color',
        'currentColor': AppColors.background,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customBackground = color;
          });
        },
      });
      options.add({
        'title': 'Bottom Nav Bar Color',
        'currentColor': AppColors.accentBG,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customAccentBG = color;
          });
        },
      });
    }

    if (widget.pageName == 'CART' || widget.pageName == 'CHECKOUT') {
      options.add({
        'title': 'Button Color',
        'currentColor': AppColors.accent,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customAccent = color;
          });
        },
      });
    }

    if (widget.pageName == 'PROFILE') {
      options.add({
        'title': 'Gradient Start Color',
        'currentColor': Color(0xFF008080),
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customGradientStart = color;
          });
        },
      });
      options.add({
        'title': 'Gradient End Color',
        'currentColor': AppColors.background,
        'onColorChanged': (Color color) {
          setState(() {
            AppColors.customGradientEnd = color;
          });
        },
      });
    }

    return options;
  }

  void _showColorPicker(
      BuildContext context,
      String title,
      Color currentColor,
      Function(Color) onColorChanged,
      ) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pick $title',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'IrishGrover',
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Color Wheel Picker
                ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: (Color color) {
                    pickerColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  displayThumbColor: true,
                  paletteType: PaletteType.hueWheel,
                  labelTypes: [],
                ),
                SizedBox(height: 16),
                // Color preview
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: pickerColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      'Preview',
                      style: TextStyle(
                        color: pickerColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ADLaMDisplay',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () {
                onColorChanged(pickerColor);
                Navigator.pop(context);
                _showSuccessSnackBar('Color updated successfully!');
              },
              child: Text(
                'Confirm',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'ADLaMDisplay',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(Icons.restore, color: AppColors.accent, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reset to Default',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'IrishGrover',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to reset all colors to their default values?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: 'ADLaMDisplay',
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                AppColors.resetToDefaults();
              });
              Navigator.pop(context);
              _showSuccessSnackBar('All colors reset to default!');
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'ADLaMDisplay',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontFamily: 'ADLaMDisplay'),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorOptions = _getColorOptions();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'CHANGE COLORS',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'IrishGrover',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Page Name Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 24),
            color: AppColors.background,
            child: Center(
              child: Text(
                widget.pageName,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  fontFamily: 'IrishGrover',
                ),
              ),
            ),
          ),

          // Color Options List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: colorOptions.length,
              itemBuilder: (context, index) {
                final option = colorOptions[index];
                return _buildColorOption(
                  title: option['title'],
                  currentColor: option['currentColor'],
                  onTap: () => _showColorPicker(
                    context,
                    option['title'],
                    option['currentColor'],
                    option['onColorChanged'],
                  ),
                );
              },
            ),
          ),

          // Reset to Default Button
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Divider(color: AppColors.border, thickness: 1),
                SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _resetToDefault,
                    icon: Icon(Icons.restore, color: Colors.white),
                    label: Text(
                      'RESET TO DEFAULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'ADLaMDisplay',
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'This will reset all colors to their original values',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontFamily: 'ADLaMDisplay',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption({
    required String title,
    required Color currentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        subtitle: Text(
          '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        trailing: Icon(
          Icons.color_lens,
          color: AppColors.accent,
        ),
      ),
    );
  }
}