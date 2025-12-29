import 'app_imports.dart';

class ChangeColorsPage extends StatefulWidget {
  final String pageName;

  const ChangeColorsPage({super.key, required this.pageName});

  @override
  State<ChangeColorsPage> createState() => _ChangeColorsPageState();
}

class _ChangeColorsPageState extends State<ChangeColorsPage> {
  late PageColors pageColors;

  @override
  void initState() {
    super.initState();
    // Load current page colors
    pageColors = AppColors.getPageColors(widget.pageName);
  }

  List<Map<String, dynamic>> _getColorOptions() {
    List<Map<String, dynamic>> options = [
      {
        'title': 'AppBar Color',
        'currentColor': pageColors.accent ?? Color(0xFF008080),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.accent = color;
            AppColors.notifyListeners();
          });
        },
      },
      {
        'title': 'Background Color',
        'currentColor':
            pageColors.background ??
            (AppColors.isDarkMode
                ? Color.fromARGB(255, 28, 28, 28)
                : Colors.white),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.background = color;
            AppColors.notifyListeners();
          });
        },
      },
      {
        'title': 'Text Color (Primary)',
        'currentColor':
            pageColors.textPrimary ??
            (AppColors.isDarkMode ? Colors.white : Colors.black),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.textPrimary = color;
            AppColors.notifyListeners();
          });
        },
      },
      {
        'title': 'Text Color (Secondary)',
        'currentColor':
            pageColors.textSecondary ??
            (AppColors.isDarkMode
                ? Color.fromARGB(255, 180, 180, 180)
                : Color.fromARGB(255, 100, 100, 100)),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.textSecondary = color;
            AppColors.notifyListeners();
          });
        },
      },
      {
        'title': 'Card Color',
        'currentColor':
            pageColors.card ??
            (AppColors.isDarkMode
                ? Color.fromARGB(255, 40, 40, 40)
                : Color(0xFFFFFFFF)),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.card = color;
            AppColors.notifyListeners();
          });
        },
      },
      {
        'title': 'Border Color',
        'currentColor':
            pageColors.border ??
            (AppColors.isDarkMode
                ? Color.fromARGB(255, 60, 60, 60)
                : Color(0xFFE0E0E0)),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.border = color;
            AppColors.notifyListeners();
          });
        },
      },
    ];

    // Page-specific additional options
    if (widget.pageName == 'HOME') {
      options.add({
        'title': 'Bottom Nav Bar Color',
        'currentColor':
            pageColors.accentBG ??
            (AppColors.isDarkMode
                ? Color(0xFF008080)
                : Color.fromARGB(255, 255, 255, 255)),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.accentBG = color;
            AppColors.notifyListeners();
          });
        },
      });
    }

    if (widget.pageName == 'PROFILE') {
      options.add({
        'title': 'Gradient Start Color',
        'currentColor': pageColors.gradientStart ?? Color(0xFF008080),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.gradientStart = color;
            AppColors.notifyListeners();
          });
        },
      });
      options.add({
        'title': 'Gradient End Color',
        'currentColor':
            pageColors.gradientEnd ??
            (AppColors.isDarkMode
                ? Color.fromARGB(255, 28, 28, 28)
                : Colors.white),
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.gradientEnd = color;
            AppColors.notifyListeners();
          });
        },
      });
    }

    if (widget.pageName == 'ADMIN') {
      options.add({
        'title': 'Tab Indicator/Text Color',
        'currentColor': pageColors.accentBG ?? Colors.white,
        'onColorChanged': (Color color) {
          setState(() {
            pageColors.accentBG = color;
            AppColors.notifyListeners();
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
          backgroundColor: AppColors.getCardForPage(widget.pageName),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Pick $title',
            style: TextStyle(
              color: AppColors.getTextPrimaryForPage(widget.pageName),
              fontFamily: 'IrishGrover',
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: pickerColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.getBorderForPage(widget.pageName),
                      width: 2,
                    ),
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
                  color: AppColors.getTextPrimaryForPage(widget.pageName),
                  fontFamily: 'ADLaMDisplay',
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getAccentForPage(widget.pageName),
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
        backgroundColor: AppColors.getCardForPage(widget.pageName),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              Icons.restore,
              color: AppColors.getAccentForPage(widget.pageName),
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Reset to Default',
                style: TextStyle(
                  color: AppColors.getTextPrimaryForPage(widget.pageName),
                  fontFamily: 'IrishGrover',
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Reset all colors for ${widget.pageName} to their default values?',
          style: TextStyle(
            color: AppColors.getTextSecondaryForPage(widget.pageName),
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
                color: AppColors.getTextPrimaryForPage(widget.pageName),
                fontFamily: 'ADLaMDisplay',
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.getAccentForPage(widget.pageName),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() {
                AppColors.resetPageColors(widget.pageName);
                AppColors.notifyListeners();
                pageColors = AppColors.getPageColors(widget.pageName);
              });
              Navigator.pop(context);
              _showSuccessSnackBar(
                'Colors reset to default for ${widget.pageName}!',
              );
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorOptions = _getColorOptions();

    return Scaffold(
      backgroundColor: AppColors.getBackgroundForPage(widget.pageName),
      appBar: AppBar(
        backgroundColor: AppColors.getAccentForPage(widget.pageName),
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
            color: AppColors.getBackgroundForPage(widget.pageName),
            child: Center(
              child: Column(
                children: [
                  Text(
                    widget.pageName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.getTextPrimaryForPage(widget.pageName),
                      fontFamily: 'IrishGrover',
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.getAccentForPage(
                        widget.pageName,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.getAccentForPage(widget.pageName),
                      ),
                    ),
                    child: Text(
                      'Colors for this page only',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getAccentForPage(widget.pageName),
                        fontFamily: 'ADLaMDisplay',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
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
                Divider(
                  color: AppColors.getBorderForPage(widget.pageName),
                  thickness: 1,
                ),
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
                  'Reset colors for ${widget.pageName} only',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryForPage(widget.pageName),
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
        color: AppColors.getCardForPage(widget.pageName),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.getBorderForPage(widget.pageName)),
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
            border: Border.all(
              color: AppColors.getBorderForPage(widget.pageName),
              width: 2,
            ),
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
            color: AppColors.getTextPrimaryForPage(widget.pageName),
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        subtitle: Text(
          '#${currentColor.value.toRadixString(16).substring(2).toUpperCase()}',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.getTextSecondaryForPage(widget.pageName),
            fontFamily: 'ADLaMDisplay',
          ),
        ),
        trailing: Icon(
          Icons.color_lens,
          color: AppColors.getAccentForPage(widget.pageName),
        ),
      ),
    );
  }
}
