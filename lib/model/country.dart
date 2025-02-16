import 'dart:ui';

import 'package:you_tube/strings/ar.dart';
import 'package:you_tube/strings/bg.dart';
import 'package:you_tube/strings/ca.dart';
import 'package:you_tube/strings/cn.dart';
import 'package:you_tube/strings/cs.dart';
import 'package:you_tube/strings/de.dart';
import 'package:you_tube/strings/en.dart';
import 'package:you_tube/strings/es.dart';
import 'package:you_tube/strings/et.dart';
import 'package:you_tube/strings/fr.dart';
import 'package:you_tube/strings/gr.dart';
import 'package:you_tube/strings/hr.dart';
import 'package:you_tube/strings/ht.dart';
import 'package:you_tube/strings/id.dart';
import 'package:you_tube/strings/it.dart';
import 'package:you_tube/strings/ja.dart';
import 'package:you_tube/strings/ko.dart';
import 'package:you_tube/strings/ku.dart';
import 'package:you_tube/strings/lt.dart';
import 'package:you_tube/strings/lv.dart';
import 'package:you_tube/strings/nb.dart';
import 'package:you_tube/strings/nl.dart';
import 'package:you_tube/strings/nn.dart';
import 'package:you_tube/strings/np.dart';
import 'package:you_tube/strings/pl.dart';
import 'package:you_tube/strings/pt.dart';
import 'package:you_tube/strings/ro.dart';
import 'package:you_tube/strings/ru.dart';
import 'package:you_tube/strings/sk.dart';
import 'package:you_tube/strings/tr.dart';
import 'package:you_tube/strings/tw.dart';
import 'package:you_tube/strings/uk.dart';
import 'package:you_tube/strings/he.dart';

// ToDo: solution to prevent manual update on adding new localizations?
/// Returns a translation for the given [locale]. Defaults to english.
Map<String, String> getAllCounties(Locale locale) {
  switch (locale.languageCode) {
    case 'zh':
      switch (locale.scriptCode) {
        case 'Hant':
          return tw;
        case 'Hans':
        default:
          return cn;
      }
    case 'el':
      return gr;
    case 'ar':
      return ar;
    case 'bg':
      return bg;
    case 'ku':
      return ku;
    case 'es':
      return es;
    case 'et':
      return et;
    case 'pt':
      return pt;
    case 'nb':
      return nb;
    case 'nn':
      return nn;
    case 'uk':
      return uk;
    case 'pl':
      return pl;
    case 'tr':
      return tr;
    case 'hr':
      return hr;
    case 'ht':
      return ht;
    case 'ro':
      return ro;
    case 'ru':
      return ru;
    case 'sk':
      return sk;
    case 'hi':
    case 'ne':
      return np;
    case 'fr':
      return fr;
    case 'de':
      return de;
    case 'lv':
      return lv;
    case 'lt':
      return lt;
    case 'nl':
      return nl;
    case 'it':
      return it;
    case 'ja':
      return ja;
    case 'id':
      return id;
    case 'ko':
      return ko;
    case 'cs':
      return cs;
    case 'ca':
      return ca;
    case 'he':
      return he;
    case 'en':
    default:
      return en;
  }
}
String? filterSomeCountry(String? countryCode){
  switch (countryCode) {
  //过滤美国萨维亚
    case 'AL'://阿尔巴尼亚
      return 'GR';
    case 'DZ'://阿尔及利亚
      return 'AE';
    case 'AD'://安道尔
    case 'CU'://古巴
    case 'DO'://多米尼加共和国
    case 'EC'://厄瓜多尔
    case 'SV'://萨尔瓦多
    case 'GT'://危地马拉
    case 'HN'://洪都拉斯
    case 'UY'://乌拉圭
      return 'ES';
    case 'AO'://安哥拉
    case 'AI'://安圭拉
    case 'AG'://安提瓜和巴布达
    case 'AM'://亚美尼亚
    case 'AW'://阿路巴
    case 'AC'://阿森森岛
    case 'AZ'://阿塞拜疆
    case 'BS'://巴哈马
    case 'JM'://牙买加
    case 'ZW'://津巴布韦
    case 'AS':
    case 'AF'://阿富汗
    case 'AX'://奥兰群岛
      return 'US';
    case 'BY'://白俄罗斯
    case 'RU'://俄罗斯
      return 'UA';
    case 'BO'://玻利维亚
    case 'NI'://尼加拉瓜
    case 'PA'://巴拿马
    case 'PY'://巴拉圭
    case 'VE'://委内瑞拉
      return 'ES';
    case 'BW'://博茨瓦纳
      return 'GB';
    case 'LB'://黎巴嫩
    case 'LY'://利比亚
    case 'MA'://摩洛哥
    case 'SY'://叙利亚
    case 'TN'://突尼斯
    case 'YE'://也门
      return 'AE';
    case 'JO'://约旦
    case 'KW'://科威特
    case 'OM'://阿曼
    case 'QA'://卡塔尔
    case 'BH'://巴林
      return 'SA';
    case 'BA'://贝宁
      return 'HR';
    case 'BZ'://伯利兹
      return 'HN';
    case 'VG'://英属维尔京群岛
    case 'KY'://英属开曼群岛
    case 'IO'://英属印度洋领地
    case 'PG'://巴布亚新几内亚
      return 'GB';
    case 'BN'://文莱
      return 'MY';
    case 'BF'://布基纳法索
    case 'CF'://中非共和国
    case 'TD'://乍得
    case 'CD'://刚果
    case 'GF'://法属圭亚那
    case 'PF'://法属波西尼亚
    case 'LU'://卢森堡
    case 'MC'://摩纳哥
    case 'SN'://塞内加尔
      return 'FR';
    case 'BQ'://荷兰加勒比
      return 'NL';
    case 'CN':
    case 'HK':
    case 'MO':
      return 'TW';
    default:
      return null;
  }
}
String? getLanguageCode(String? countryCode) {
  switch (countryCode) {
    case 'DZ'://阿尔及利亚
    case 'AE'://阿联酋
    case 'BH'://巴林

    case 'EG'://埃及
    case 'IQ'://伊拉克
    case 'JO'://约旦
    case 'KW'://科威特
    case 'LB'://黎巴嫩
    case 'LY'://利比亚
    case 'MA'://摩洛哥
    case 'OM'://阿曼
    case 'QA'://卡塔尔
    case 'SA'://沙特阿拉伯
    case 'SY'://叙利亚
    case 'TN'://突尼斯
    case 'YE'://也门
      return 'ar';
    case 'AF'://阿富汗
    case 'IR'://伊朗
      return 'pl';
    case 'VN'://越南
      return 'vi';
    case 'CN':
      return 'zh-CN';
    case 'TW':
      return 'zh-TW';
    case 'MO':
    case 'HK':
      return 'zh-HK';
    case 'GR':
      return 'el';
    case 'SI'://斯洛文尼亚
      return 'sl';
    case 'LA'://老挝
      return 'lo';
    case 'MK'://马其顿
      return 'mk';
    case 'TH'://泰国
      return 'th';
    case 'UZ'://乌兹别克斯坦
      return 'uz';
    case 'ES'://西班牙
    case 'AR'://阿根廷
    case 'BO'://玻利维亚
    case 'CL'://智利
    case 'CO'://哥伦比亚
    case 'CR'://哥斯达黎加
    case 'DO'://多米尼加共和国
    case 'EC'://厄瓜多尔
    case 'GT'://危地马拉
    case 'HN'://洪都拉斯
    case 'MX'://墨西哥
    case 'NI'://尼加拉瓜
    case 'PA'://巴拿马
    case 'PE'://秘鲁
    case 'PR'://波多黎各(美)
    case 'PY'://巴拉圭
    case 'SV'://萨尔瓦多
    case 'UY'://乌拉圭
    case 'VE'://委内瑞拉
    case 'CU'://古巴
      return 'es';
    case 'AL'://阿尔巴利亚
      return 'bg';
    case 'AM'://亚美尼亚
    case 'AZ'://阿塞拜疆
      return 'az';
    case 'EE'://爱沙尼亚语
      return 'et';
    case 'PT'://葡萄牙
    case 'BR'://巴西
      return 'pt';
    case 'NO'://挪威
      return 'nb';
    case 'UA'://乌克兰
      return 'uk';
    case 'PL'://波兰
      return 'pl';
    case 'GE'://格鲁吉亚
      return 'ka';
    case 'TR'://土耳其
      return 'tr';
    case 'PK'://巴基斯坦
      return 'ur';
    case 'HR'://克罗地亚语
    case 'BA'://波斯尼亚和黑塞哥维那
      return 'hr';
    case 'HA'://海地
      return 'ht';
    case 'RO'://罗马尼亚语
      return 'ro';
    case 'BY'://白俄罗斯
    case 'RU'://俄罗斯
      return 'ru';
    case 'SK'://斯洛伐克
      return 'sk';
    case 'NP'://尼泊尔
      return 'hi';
    case 'KZ'://哈萨克
      return 'kk';
    case 'KG'://吉尔吉斯
      return 'ky';
    case 'FR'://法国
    case 'BE'://比利时
    case 'CH'://瑞士
    case 'LU'://卢森堡
    case 'MC'://摩纳哥
    case 'BJ'://贝宁
    case 'BF'://布基纳法索
    case 'CF'://中非共和国
    case 'TD'://乍得
    case 'CD'://刚果
    case 'GF'://法属圭亚那
    case 'PF'://法属波西尼亚
    case 'SN'://塞内加尔
      return 'fr';
    case 'DE'://德国
    case 'AT'://奥地利
    case 'LI'://列支敦士登
      return 'de';
    case 'CA'://加拿大
    case 'AC'://阿森森岛
    case 'AU'://澳大利亚
    case 'BZ'://伯利兹
    case 'CB'://加勒比海
    case 'GB'://英国
    case 'IE'://爱尔兰
    case 'JM'://牙买加
    case 'NZ'://新西兰
    case 'PH'://菲律宾
    case 'TT'://特立尼达
    case 'US'://美国
    case 'ZA'://南非
    case 'ZW'://津巴布韦
    case 'PG'://巴布亚新几内亚
      return 'en';
    case 'LV'://	拉脱维亚
      return 'lv';
    case 'LT'://立陶宛
      return 'lt';
    case 'FI'://芬兰
      return 'fi';
    case 'BQ'://荷兰加勒比
    case 'NL'://荷兰
      return 'nl';
    case 'IT'://意大利
      return 'it';
    case 'JP':
      return 'ja';
    case 'ID'://印度尼西亚
      return 'id';
    case 'KR'://韩国
      return 'ko';
    case 'CZ'://捷克
      return 'cs';
    case 'KE'://肯尼亚
      return 'sw';
    case 'HU'://匈牙利
      return 'hu';
    case 'IS'://冰岛
      return 'is';
    case 'IN'://印度
      return 'hi';
    case 'BD'://孟加拉
      return 'bn';
    case 'BG'://保加利亚
      return 'bg';
    case 'IL'://以色列
      return 'he';
    case 'DK'://丹麦
      return 'da';
    case 'BN'://文莱
    case 'MY'://马来西亚
      return 'ms';
    default:
      return 'en';
  }
}
bool removeSomeCountry(String? countryCode){
  switch (countryCode) {
  //过滤美国萨维亚
    case 'AF'://阿富汗
    case 'AX'://奥兰群岛
    case 'BT'://不丹
    case 'AO'://安哥拉
    case 'AI'://安圭拉
    case 'AG'://安提瓜和巴布达
    case 'AM'://亚美尼亚
    case 'AW'://阿路巴
    case 'AC'://阿森森岛
    case 'AZ'://阿塞拜疆
    case 'BS'://巴哈马
    case 'BH'://巴林
    case 'BW'://博茨瓦纳
    case 'BA'://波希尼亚及赫塞哥维那
    case 'BB'://巴巴多斯
    case 'BZ'://伯利兹
    case 'BJ'://贝宁
    case 'BM'://百慕大
    case 'BI'://布隆迪
    case 'CM'://喀麦隆
    case 'CV'://维德角岛
    case 'CC'://科克斯群岛
    case 'CI'://科迪瓦
    case 'CX'://圣诞岛
    case 'KM'://科摩罗
    case 'BF'://布基纳法索
    case 'CG'://刚果
    case 'CK'://库克群岛
    case 'CW'://库拉索
    case 'CY'://塞浦路斯
    case 'CZ'://捷克
    case 'DJ'://吉布提
    case 'DM'://多米尼克
    case 'TL'://东帝汶
    case 'GQ'://赤道几内亚
    case 'ER'://厄立特里亚
    case 'ET'://埃塞尔比亚
    case 'FK'://法罗群岛
    case 'FO'://法罗群岛
    case 'FJ'://斐济
    case 'GA'://加蓬
    case 'GM'://冈比亚
    case 'GH'://加纳
    case 'GI'://直布罗陀
    case 'GL'://格陵兰岛
    case 'GD'://格林那达
    case 'GP'://哥的罗布
    case 'GU'://关岛
    case 'GG'://根西
    case 'GN'://几内亚
    case 'GW'://几内亚比绍
    case 'GY'://圭亚那
    case 'HT'://海地
    case 'HM'://赫德岛
    case 'IM'://马恩岛
    case 'JE'://泽西
    case 'KI'://基里巴斯
    case 'XK'://科索沃
    case 'LS'://莱索托
    case 'LR'://利比里亚
    case 'LI'://列支敦士登
    case 'MG'://马达加斯加
    case 'MW'://马拉维
    case 'MV'://马尔代夫
    case 'ML'://马里
    case 'MT'://马耳他
    case 'MH'://马绍尔群岛
    case 'MQ'://马提尼克岛
    case 'MU'://毛里求斯
    case 'MR'://毛里塔尼亚
    case 'YT'://马约特
    case 'FM'://密克罗尼亚
    case 'MD'://摩尔多瓦
    case 'MN'://蒙古
    case 'MS'://蒙拉塞拉特
    case 'MZ'://莫桑比克
    case 'MM'://缅甸
    case 'NA'://纳米比亚
    case 'NR'://努鲁
    case 'NC'://信科里多尼亚
    case 'NE'://尼日尔
    case 'NU'://纽埃
    case 'NF'://幅克群岛
    case 'KP'://朝鲜
    case 'MP'://北马里亚纳群岛
    case 'PW'://帕劳
    case 'PS'://巴勒斯坦
    case 'PA'://留尼汪
    case 'SH'://圣赫勒拿岛
    case 'RE'://留尼汪
    case 'RW'://卢旺达
    case 'BL'://圣巴泰勒米
    case 'KN'://圣济慈和维尼斯
    case 'LC'://圣卢西亚
    case 'MF'://法属圣马丁
    case 'PM'://圣皮埃尔和密克隆
    case 'VC'://圣文森特
    case 'WS'://萨摩亚
    case 'SM'://圣马力诺
    case 'ST'://圣多美和普林西比
    case 'SX'://荷属圣马丁
    case 'SC'://塞舌尔
    case 'SL'://塞拉利昂
    case 'SB'://所罗门群岛
    case 'SO'://索马里
    case 'GS'://南乔治亚
    case 'SS'://南苏丹
    case 'LK'://斯里兰卡
    case 'SR'://苏里南
    case 'SD'://苏丹
    case 'SJ'://苏瓦尔巴
    case 'SZ'://斯威士兰
    case 'TK'://托克劳
    case 'TJ'://塔吉克斯坦
    case 'TZ'://坦桑尼亚
    case 'TT'://特立尼达和多巴哥
    case 'TO'://汤加
    case 'TG'://多哥
    case 'TM'://土库曼斯坦
    case 'TC'://特克斯
    case 'TV'://图瓦卢
    case 'VI'://维京群岛
    case 'UZ'://乌兹别克斯坦
    case 'VU'://瓦努阿图
    case 'VA'://梵蒂冈
    case 'WF'://瓦里斯
    case 'WW'://全世界
    case 'EH'://撒哈拉共和国
    case 'ZM'://赞比亚
    case 'search'://查询
      return true;
    default:
      return false;
  }
}

String getLanguageCodeWithCountryCode(String? countryCode) {
  switch (countryCode) {
    case 'AE'://阿联酋
    case 'DZ'://阿尔及利亚
    case 'BH'://巴林

    case 'EG'://埃及
    case 'IQ'://伊拉克
    case 'JO'://约旦
    case 'KW'://科威特
    case 'LB'://黎巴嫩
    case 'LY'://利比亚
    case 'MA'://摩洛哥
    case 'OM'://阿曼
    case 'QA'://卡塔尔
    case 'SA'://沙特阿拉伯
    case 'SY'://叙利亚
    case 'TN'://突尼斯
    case 'YE'://也门
      return 'ar';
    case 'AF'://阿富汗
    case 'IR'://伊朗
      return 'pl';
    case 'VN'://越南
      return 'vi';
    case 'CN':
      return 'zh-CN';
    case 'TW':
      return 'zh-TW';
    case 'MO':
    case 'HK':
      return 'zh-HK';
    case 'GR':
      return 'el';
    case 'SI'://斯洛文尼亚
      return 'sl';
    case 'LA'://老挝
      return 'lo';
    case 'MK'://马其顿
      return 'mk';
    case 'TH'://泰国
      return 'th';
    case 'UZ'://乌兹别克斯坦
      return 'uz';
    case 'ES'://西班牙
    case 'AR'://阿根廷
    case 'BO'://玻利维亚
    case 'CL'://智利
    case 'CO'://哥伦比亚
    case 'CR'://哥斯达黎加
    case 'DO'://多米尼加共和国
    case 'EC'://厄瓜多尔
    case 'GT'://危地马拉
    case 'HN'://洪都拉斯
    case 'MX'://墨西哥
    case 'NI'://尼加拉瓜
    case 'PA'://巴拿马
    case 'PE'://秘鲁
    case 'PR'://波多黎各(美)
    case 'PY'://巴拉圭
    case 'SV'://萨尔瓦多
    case 'UY'://乌拉圭
    case 'VE'://委内瑞拉
    case 'CU'://古巴
      return 'es';
    case 'AL'://阿尔巴利亚
      return 'bg';
    case 'AM'://亚美尼亚
    case 'AZ'://阿塞拜疆
      return 'az';
    case 'EE'://爱沙尼亚语
      return 'et';
    case 'PT'://葡萄牙
    case 'BR'://巴西
      return 'pt';
    case 'NO'://挪威
      return 'nb';
    case 'UA'://乌克兰
      return 'uk';
    case 'PL'://波兰
      return 'pl';
    case 'GE'://格鲁吉亚
      return 'ka';
    case 'TR'://土耳其
      return 'tr';
    case 'PK'://巴基斯坦
      return 'ur';
    case 'HR'://克罗地亚语
    case 'BA'://波斯尼亚和黑塞哥维那
      return 'hr';
    case 'HA'://海地
      return 'ht';
    case 'RO'://罗马尼亚语
      return 'ro';
    case 'BY'://白俄罗斯
    case 'RU'://俄罗斯
      return 'ru';
    case 'SK'://斯洛伐克
      return 'sk';
    case 'NP'://尼泊尔
      return 'hi';
    case 'KZ'://哈萨克
      return 'kk';
    case 'KG'://吉尔吉斯
      return 'ky';
    case 'FR'://法国
    case 'BE'://比利时
    case 'CH'://瑞士
    case 'LU'://卢森堡
    case 'MC'://摩纳哥
    case 'BJ'://贝宁
    case 'BF'://布基纳法索
    case 'CF'://中非共和国
    case 'TD'://乍得
    case 'CD'://刚果
    case 'GF'://法属圭亚那
    case 'PF'://法属波西尼亚
    case 'SN'://塞内加尔
      return 'fr';
    case 'DE'://德国
    case 'AT'://奥地利
    case 'LI'://列支敦士登
      return 'de';
    case 'CA'://加拿大
    case 'AC'://阿森森岛
    case 'AU'://澳大利亚
    case 'BZ'://伯利兹
    case 'CB'://加勒比海
    case 'GB'://英国
    case 'IE'://爱尔兰
    case 'JM'://牙买加
    case 'NZ'://新西兰
    case 'PH'://菲律宾
    case 'TT'://特立尼达
    case 'US'://美国
    case 'ZA'://南非
    case 'ZW'://津巴布韦
    case 'PG'://巴布亚新几内亚
      return 'en';
    case 'LV'://	拉脱维亚
      return 'lv';
    case 'LT'://立陶宛
      return 'lt';
    case 'FI'://芬兰
      return 'fi';
    case 'BQ'://荷兰加勒比
    case 'NL'://荷兰
      return 'nl';
    case 'IT'://意大利
      return 'it';
    case 'JP':
      return 'ja';
    case 'ID'://印度尼西亚
      return 'id';
    case 'KR'://韩国
      return 'ko';
    case 'CZ'://捷克
      return 'cs';
    case 'KE'://肯尼亚
      return 'sw';
    case 'HU'://匈牙利
      return 'hu';
    case 'IS'://冰岛
      return 'is';
    case 'IN'://印度
      return 'hi';
    case 'BD'://孟加拉
      return 'bn';
    case 'BG'://保加利亚
      return 'bg';
    case 'IL'://以色列
      return 'he';
    case 'DK'://丹麦
      return 'da';
    case 'BN'://文莱
    case 'MY'://马来西亚
      return 'ms';
    default:
      return 'en';
  }
}