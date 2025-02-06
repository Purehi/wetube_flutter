import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  bool _isDarkMode = false;
  String? _appVersion;
  @override
  void initState() {
    PackageInfo.fromPlatform().then((packageInfo){
      setState(() {
        _appVersion = packageInfo.version;
      });
    });
    AdaptiveTheme.getThemeMode().then((theme){
      _isDarkMode = theme?.isDark ?? false;
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: defaultColorScheme.surface,
      appBar: AppBar(
        scrolledUnderElevation:0.0,
        elevation: 0,
        backgroundColor: defaultColorScheme.surface,
        shadowColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: BackButton(
          style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -3.0, vertical: -3.0),),
          color: defaultColorScheme.primary,
        ),
        title: Text('Settings', style: textTheme.titleLarge?.copyWith(
            color: defaultColorScheme.primary
        ),),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            tiles: [
              SettingsTile(
                backgroundColor: defaultColorScheme.surface,
                title: Text('Dark Mode', style: textTheme.titleMedium?.copyWith(
                    color: defaultColorScheme.primary
                ),),
                leading: _isDarkMode ? const Icon(Icons.dark_mode) : const Icon(Icons.dark_mode_outlined),
                trailing: Padding(padding: const EdgeInsets.all(10),child: Switch(
                    value: _isDarkMode,
                    activeColor:  Color(0xff42C83C),
                    inactiveTrackColor: Colors.grey,
                    onChanged: (value){
                  if(_isDarkMode == false){
                        AdaptiveTheme.of(context).setDark();
                        setState(() {
                          _isDarkMode = true;
                        });
                      }else if(_isDarkMode == true){
                        AdaptiveTheme.of(context).setLight();
                        setState(() {
                          _isDarkMode = false;
                        });
                      }
                }),),
              ),
              SettingsTile(
                backgroundColor: defaultColorScheme.surface,
                title: Text(_appVersion != null ? 'Version($_appVersion)' : 'Version', style: textTheme.titleMedium?.copyWith(
                    color: defaultColorScheme.primary
                ),),
                leading: Icon(Icons.info),
                onPressed: (BuildContext context) {},
              ),
            ],
          ),

        ],
      ),
    );
  }
}
