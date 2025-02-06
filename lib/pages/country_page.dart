import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:translator/translator.dart';
import 'package:you_tube/model/api_request.dart';
import 'package:you_tube/model/country.dart';

import 'package:you_tube/pages/loading_page.dart';

import '../model/youtube_client.dart';

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});
  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {

  String _countryCode = '';
  //local text
  final _translator = GoogleTranslator();
  String _titleText = 'Location';
  Map<String, String>? _countries;

  @override
  void initState() {
    _countryCode = countryCode ?? 'US';
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchData();
      _translatorText();
    });
  }
  @override
  Widget build(BuildContext context) {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: defaultColorScheme.surface,
      appBar: AppBar(
        backgroundColor: defaultColorScheme.surface,
        scrolledUnderElevation:0.0,
        shadowColor: Colors.transparent,
        elevation: 0.0,
        leading: BackButton(
          style: const ButtonStyle(visualDensity: VisualDensity(horizontal: -3.0, vertical: -3.0),),
          color: defaultColorScheme.primary,
        ),
        title: Text(_titleText, style: textTheme.headlineSmall?.copyWith(
            color: defaultColorScheme.primary
        ),),
      ),
      body: _buildNarrowLayout());
  }

  Widget _buildNarrowLayout() {
    final defaultColorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if(_countries != null){
      final countryNames = _countries!.values.toList();
      final countryCodes = _countries!.keys.toList();

      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView.builder(
            itemCount: countryNames.length,
            itemBuilder: (context, index){
              final country = countryNames[index];
              final code = countryCodes[index];
              final remove = removeSomeCountry(code);
              if(remove)return const SizedBox(height: 0,);//移除不丹
              final isCheck = code == _countryCode;
              return InkWell(
                onTap: () async {
                  if(isCheck){
                    if(context.mounted){
                      Navigator.of(context).pop();
                    }
                    return ;
                  }
                  _countryCode = code;
                  final filter = filterSomeCountry(_countryCode);
                  _countryCode = filter ?? _countryCode;

                  countryCode = _countryCode;
                  final language = getLanguageCode(_countryCode);
                  languageCode = language ?? 'en';
                  //cache data
                  localStorage.setItem('countryCode', _countryCode);
                  localStorage.setItem('languageCode', languageCode ?? 'en');

                  countryCodeChanged.value = false;
                  countryCodeChanged.value = true;

                  if(context.mounted){
                    Navigator.of(context).pop();
                  }
                },
                child: ListTile(
                  title: Text(country, style: textTheme.titleMedium?.copyWith(
                      color: isCheck ? const Color(0xff009a3d) : defaultColorScheme.primary
                  ),),
                  trailing: isCheck ? const Icon(Icons.check, color: Color(0xff009a3d),) : null,
                ),
              );
            }),
      );
    }
    return const LoadingPage();
  }
  ///翻译
  void _translatorText() async{
    if(mounted){
      int count = 0;
      int total = 3;
      Locale myLocale = Localizations.localeOf(context);
      final languageCode = myLocale.languageCode;
      if(languageCode == 'en')return;
      final countryPageTitle = localStorage.getItem('countryPageTitle');
      if(countryPageTitle == null){
        _translator.translate('Location', from: 'en', to: languageCode).then((s) {
          localStorage.setItem('countryPageTitle', s.text);//设置底部提示语
          _titleText = s.text;
          count += 1;
          if(count >= total){
            setState(() {});
          }
        });
      }else{
        _titleText = countryPageTitle;
      }
    }
  }
  static Future<Map<String, String>?> _getCounties(Locale locale) async{
    ///获取国家
    final countries = getAllCounties(locale);
    return countries;
  }
  Future<void> _fetchData() async {

    Locale myLocale = Localizations.localeOf(context);
    final filter = filterSomeCountry(myLocale.countryCode ?? 'US');
    Locale locale = Locale(myLocale.languageCode, filter ?? 'US');
    final countries = await compute(_getCounties, locale);
    if(countries != null){
      setState(() {
        _countries = countries;
      });
    }
  }
}

