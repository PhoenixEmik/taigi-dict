import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hokkien_dictionary/core/preferences/app_preferences.dart';
import 'package:hokkien_dictionary/features/settings/presentation/screens/reference_article_screen.dart';
import 'package:hokkien_dictionary/features/settings/presentation/widgets/audio_resource_tile.dart';
import 'package:hokkien_dictionary/features/settings/presentation/widgets/settings_section_header.dart';
import 'package:hokkien_dictionary/features/settings/presentation/widgets/settings_theme_mode_tile.dart';
import 'package:hokkien_dictionary/features/settings/presentation/widgets/settings_text_scale_tile.dart';
import 'package:hokkien_dictionary/offline_audio.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.audioLibrary,
    required this.onDownloadArchive,
  });

  final OfflineAudioLibrary audioLibrary;
  final Future<void> Function(AudioArchiveType type) onDownloadArchive;

  void _showReferenceArticle(
    BuildContext context, {
    required String title,
    required String introduction,
    required List<ReferenceArticleSection> sections,
    required String sourceUrl,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ReferenceArticleScreen(
          title: title,
          introduction: introduction,
          sections: sections,
          sourceUrl: sourceUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appPreferences = AppPreferencesScope.of(context);

    return AnimatedBuilder(
      animation: Listenable.merge([audioLibrary, appPreferences]),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('設定')),
          body: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth >= 900 ? 920 : 720,
                  ),
                  child: ListTileTheme(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 28),
                      children: [
                        const SettingsSectionHeader(title: '離線資源'),
                        AudioResourceTile(
                          type: AudioArchiveType.word,
                          audioLibrary: audioLibrary,
                          onDownload: onDownloadArchive,
                        ),
                        AudioResourceTile(
                          type: AudioArchiveType.sentence,
                          audioLibrary: audioLibrary,
                          onDownload: onDownloadArchive,
                        ),
                        const Divider(height: 32),
                        const SettingsSectionHeader(title: '外觀'),
                        SettingsThemeModeTile(
                          value: appPreferences.themePreference,
                          onSelected: (value) {
                            unawaited(appPreferences.setThemePreference(value));
                          },
                        ),
                        SettingsTextScaleTile(
                          value: appPreferences.readingTextScale,
                          onChanged: (value) {
                            unawaited(
                              appPreferences.setReadingTextScale(value),
                            );
                          },
                        ),
                        const Divider(height: 32),
                        const SettingsSectionHeader(title: '關於'),
                        ListTile(
                          leading: const Icon(
                            Icons.translate_outlined,
                            color: Color(0xFF17454C),
                          ),
                          title: const Text('臺羅標注說明'),
                          subtitle: const Text('查看教育部頁面的重點整理與台羅拼寫原則。'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            _showReferenceArticle(
                              context,
                              title: '臺羅標注說明',
                              introduction:
                                  '這份頁面整理了教育部臺灣台語常用詞辭典採用的臺灣台語羅馬字拼音方案。辭典以教育部公告的臺羅作為主要羅馬字系統，詞目與例句都盡量依同一套標記方式呈現；外來詞則視為台語詞目，標示其回推的本調。',
                              sections: const [
                                ReferenceArticleSection(
                                  title: '拼寫基礎',
                                  paragraphs: [
                                    '頁面先交代辭典以臺羅作為統一拼寫基礎，目的是讓讀者在查詞、比對例句、學習發音時有一致的書寫依據。系統不只是把台語音節拼出來，還會一起保留詞內結構與本調資訊。',
                                  ],
                                  bullets: [
                                    '聲母與韻母會依標準臺羅拆分，讓使用者可以對照讀音結構。',
                                    '鼻化、喉塞與入聲字尾會保留在拼寫中，不另外改寫成口語化的簡略形式。',
                                    '音節之間會用連字符號標示多音節詞，讓詞形邊界更清楚。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '一般聲調',
                                  paragraphs: [
                                    '頁面將一般聲調整理為第1聲、第2聲、第3聲、第4聲、第5聲、第7聲、第8聲。從漢語傳統調類來看，對應到陰平、陰上、陰去、陰入、陽平、陽去、陽入；現代通行腔裡，陽上通常已和陽去合流，所以一般會看到七個主要聲調。',
                                  ],
                                  bullets: [
                                    '辭典同時可對照正式版調符和數字版寫法，例如 tong1、tong2、tong3、tok4、tong5、tong7、tok8。',
                                    '入聲字會和塞音尾一起判讀，例如 -p、-t、-k、-h 的音節要連同尾音一起看。',
                                    '查詞時看到不同調號，不只是語氣差異，往往也會直接影響詞義和詞條排序。',
                                  ],
                                  tables: [
                                    ReferenceArticleTableData(
                                      caption: '聲調舉例',
                                      headers: [
                                        '聲調',
                                        '第1聲',
                                        '第2聲',
                                        '第3聲',
                                        '第4聲',
                                        '第5聲',
                                        '（第6聲）',
                                        '第7聲',
                                        '第8聲',
                                      ],
                                      rows: [
                                        [
                                          '漢語調類',
                                          '陰平',
                                          '陰上',
                                          '陰去',
                                          '陰入',
                                          '陽平',
                                          '（陽上）',
                                          '陽去',
                                          '陽入',
                                        ],
                                        [
                                          '正式版',
                                          'tong',
                                          'tóng',
                                          'tòng',
                                          'tok',
                                          'tông',
                                          '',
                                          'tōng',
                                          'to̍k',
                                        ],
                                        [
                                          '數字版',
                                          'tong1',
                                          'tong2',
                                          'tong3',
                                          'tok4',
                                          'tong5',
                                          '',
                                          'tong7',
                                          'tok8',
                                        ],
                                        [
                                          '例字',
                                          '東',
                                          '黨',
                                          '棟',
                                          '督',
                                          '同',
                                          '（動）',
                                          '洞',
                                          '毒',
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '特殊聲調與輕聲',
                                  paragraphs: [
                                    '除了常見的七個主要聲調，頁面也補充辭典會遇到的特殊標記。這些標記不算日常入門最先學的部分，但對讀懂詞條、例句與口語節奏很重要。',
                                  ],
                                  bullets: [
                                    '部分地方音會出現第6聲，頁面以像 o6 這類形式舉例說明。',
                                    '合音與三連音的第一音節可能標成第9聲，用來表示特殊音值。',
                                    '輕聲用「--」標記在重讀與輕讀之間；輕聲符前面的音節唸本調，後面的音節則依輕聲處理。',
                                    '像 āu--ji̍t、tsáu--tshut-khì 這類寫法，重點就是提醒你不要把整串都當成同一種調值。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '變調',
                                  paragraphs: [
                                    '頁面特別說明台語在詞句中常有連讀變調，也就是字接上後字時，實際唸出的聲調會和單字本調不同。不過變調會受斷句、語氣、弱讀與焦點影響，因此同一句話可能依不同切法出現不同實際調值。',
                                  ],
                                  bullets: [
                                    '頁面整理了主流變調規則，例如 1 變 7、2 變 1、3 變 2、7 變 3。',
                                    '第4聲與第8聲會依塞音尾或 -h 尾出現不同變化方向，所以要連同尾音一起判讀。',
                                    '第5聲在漳、泉系統下可能出現不同變調結果，辭典頁面也有特別提醒。',
                                    '本辭典為了保持查詢一致性，詞目原則上標本調，不直接標出連讀後的變調。',
                                  ],
                                  tables: [
                                    ReferenceArticleTableData(
                                      caption: '變調規則',
                                      headers: [
                                        '聲調',
                                        '變調規則',
                                        '例詞',
                                        '本調',
                                        '變調後實際語音',
                                      ],
                                      rows: [
                                        [
                                          '第1聲',
                                          '1→7',
                                          '心肝',
                                          'sim-kuann',
                                          'sīm-kuann',
                                        ],
                                        [
                                          '第2聲',
                                          '2→1',
                                          '小弟',
                                          'sió-tī',
                                          'sio-tī',
                                        ],
                                        [
                                          '第3聲',
                                          '3→2',
                                          '世間',
                                          'sè-kan',
                                          'sé-kan',
                                        ],
                                        [
                                          '第4聲',
                                          '4→8(-p-t-k)',
                                          '出名',
                                          'tshut-miâ',
                                          'tshu̍t-miâ',
                                        ],
                                        [
                                          '',
                                          '4→2(-h)',
                                          '鐵馬',
                                          'thih-bé',
                                          'thí-bé',
                                        ],
                                        [
                                          '第5聲',
                                          '5→7(漳)',
                                          '來往',
                                          'lâi-óng',
                                          'lāi-óng',
                                        ],
                                        [
                                          '',
                                          '5→3(泉)',
                                          '來往',
                                          'lâi-óng',
                                          'lài-óng',
                                        ],
                                        [
                                          '第7聲',
                                          '7→3',
                                          '外口',
                                          'guā-kháu',
                                          'guà-kháu',
                                        ],
                                        [
                                          '第8聲',
                                          '8→4(-p-t-k)',
                                          '木瓜',
                                          'bo̍k-kue',
                                          'bok-kue',
                                        ],
                                        [
                                          '',
                                          '8→3(-h)',
                                          '月娘',
                                          'gue̍h-niû',
                                          'guè-niû',
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '無固定聲調的寫法',
                                  paragraphs: [
                                    '語助詞、感嘆詞和部分語法詞沒有穩定本調時，頁面說明辭典通常依書寫慣例用第4聲喉塞尾 -h 來標記，並再加上「--」表示輕聲。',
                                  ],
                                  bullets: [
                                    '像 --lah、--aih、--ooh、--ah 這些寫法，重點不是背數字調，而是辨認它們在句中的語氣功能。',
                                    '因為這些成分通常輕讀，所以前字的變調判斷也要把它們的弱讀性質一起考慮。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '查詢時怎麼用',
                                  paragraphs: [
                                    '實際使用時，可以先把臺羅當成穩定的索引工具。即使不熟悉全部符號，也能先用基本拼法輸入，再回頭比對詞條內的正式標注。',
                                  ],
                                  bullets: [
                                    '先抓聲母與韻母的大致形狀，再確認本調，不要先用句中實際變調回推拼法。',
                                    '遇到鼻化、入聲尾、連字符與輕聲符時，不要把它們當成裝飾；它們本身就是辨識詞義的重要線索。',
                                    '如果查詢結果接近但不完全相同，優先比對詞條裡的正式臺羅標注，再看例句中的語境與讀音。',
                                  ],
                                ),
                              ],
                              sourceUrl:
                                  'https://sutian.moe.edu.tw/zh-hant/piantsip/tailo-phiautsu-suatbing/',
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.edit_note_outlined,
                            color: Color(0xFF17454C),
                          ),
                          title: const Text('漢字用字原則'),
                          subtitle: const Text('查看教育部頁面的重點整理與辭典漢字選用方式。'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            _showReferenceArticle(
                              context,
                              title: '漢字用字原則',
                              introduction:
                                  '這份頁面說明辭典編輯時怎麼選擇漢字。核心不是把所有台語口語都硬套成單一寫法，而是在語音、語義、歷史文獻、使用現況與資訊流通之間取得平衡，給出適合辭典檢索與教學的字形。',
                              sections: const [
                                ReferenceArticleSection(
                                  title: '漢字狀況',
                                  paragraphs: [
                                    '頁面先說明臺灣台語和華語在語音、詞彙、句法上本來就有不少差異，而且台語長期沒有像共通語那樣完成統一文字規範，所以現行用字一直相當分歧。',
                                    '雖然歷來詞書和學界對不少「本字」已有越來越穩定的考證，但仍然有不少詞來源不明，甚至根本不是漢語來源，於是就出現「有音無穩定漢字」的狀況。',
                                  ],
                                  bullets: [
                                    '同一個詞在不同書寫傳統裡可能會對應不同字形。',
                                    '辭典編輯必須在學理考證和讀者實際可用性之間做取捨。',
                                    '因此字形不只是語源問題，也牽涉教學、檢索和流通成本。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '本辭典的用字類型',
                                  paragraphs: [
                                    '頁面將辭典主要用字分成幾種型態。大方向上，辭典仍以漢字書寫為基礎，而且傾向一個音節對應一個字形，再依既定編輯概念選定主用字。',
                                  ],
                                  bullets: [
                                    '本字：在傳統文獻中已有字形，而且字義和台語詞彙有同源關係；這通常是最優先考慮的類型。',
                                    '訓用字：借字義不借字音，用華語讀音和台語讀音不同的既有漢字來表達相同詞義。',
                                    '俗字：包含借音字與新造字。借音字是借近音字形來記錄別的詞義；新造字則是在找不到可用字時另外造字。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '替代字說明',
                                  paragraphs: [
                                    '頁面把非本字的寫法統稱為「替代字」。辭典原則上傾向本字，但不是一旦找到本字就一定使用，因為實際閱讀與流通情況也必須納入考量。',
                                  ],
                                  bullets: [
                                    '若本字太冷僻、太難辨識，一般讀者幾乎不會用，辭典可能改採較常見的替代字。',
                                    '若本字和標準語日常基本字差異過大，反而會增加閱讀阻礙，辭典也可能改用較直觀的字形。',
                                    '若俗字已經廣泛約定俗成，不易改變使用習慣，辭典也可能沿用俗字而不強推考證本字。',
                                    '選字時還會考慮「望字生音義」的效果，也就是讓讀者看到字形時比較容易同時聯想到讀音和意義。',
                                    '另外也盡量避免無限制造字，因為造字太多會增加電腦輸入、字型支援、學習與流通上的阻礙。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '推薦用字',
                                  paragraphs: [
                                    '頁面最後指出，教育部曾公告一批「臺灣台語推薦用字」，本辭典原則上會參照該成果來擬定實際用字。也就是說，辭典不是完全自由選字，而是盡量建立在既有官方整理基礎上。',
                                  ],
                                  bullets: [
                                    '查詢時若看到和自己習慣不同的字形，先比對讀音與義項，不要只看字面。',
                                    '遇到同音異字、同義異寫很多的情況，可以把辭典主詞條當作優先參考入口。',
                                    '需要教學、整理筆記或做標準化書寫時，辭典主用字通常是最穩定的起點。',
                                  ],
                                ),
                              ],
                              sourceUrl:
                                  'https://sutian.moe.edu.tw/zh-hant/piantsip/hanji-iongji-guantsik/',
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.library_books_outlined,
                            color: Color(0xFF17454C),
                          ),
                          title: const Text('辭典附錄'),
                          subtitle: const Text('查看教育部附錄內容整理與附錄收錄範圍。'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            _showReferenceArticle(
                              context,
                              title: '辭典附錄',
                              introduction:
                                  '教育部在辭典本文之外另外設置「附錄」資料，用來補足正文詞目有限時不易完整容納的內容。附錄的角色不是取代主詞條，而是擴充實用資訊，讓姓名、地名、交通站名、方言差、親屬稱謂、人體部位等主題能集中整理。',
                              sections: const [
                                ReferenceArticleSection(
                                  title: '姓名查詢',
                                  paragraphs: [
                                    '頁面先說明姓名查詢功能和《國家語言發展法》及護照外文別名規範有關，目的之一是提供民眾以國家語言讀音進行逐字音譯的參考。',
                                    '姓名的傳統讀法並不是完全固定規則，常見情況是姓偏白讀、名偏文讀，但仍須兼顧家族習慣、個人習慣、古今音與地方腔差。',
                                  ],
                                  bullets: [
                                    '字姓部分整理了內政部收錄姓氏，再補入辭典資料，總數超過一千八百筆。',
                                    '人名部分整理超過一萬筆漢字音讀，並特別說明許多名字常會出現白讀、訓讀、文白夾雜或方音差異。',
                                    '臺羅標注原則是「姓」和「名」分寫，且姓與名起頭字母大寫；複姓與雙姓也有對應的大寫方式。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '固定主題附錄',
                                  paragraphs: [
                                    '除了姓名附錄，頁面還列出多種固定主題資料，讓使用者在查詢常見文化與生活類名稱時有一致入口。',
                                  ],
                                  bullets: [
                                    '百家姓：以既有台語辭典與常用字詞典為基礎，參考戶政資料補充，並以高雄腔為主、酌收第二優勢腔。',
                                    '節氣：收錄二十四節氣名稱，附音讀與釋義。',
                                    '外來詞：收錄沒有漢語字形、也不是漢語發音的日語來源詞，聲調以逆推本調標示。',
                                    '俗諺：參考多本俗語與諺語書籍，收錄常用、熟知的俗諺，並提供釋義和例句。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '地名與公共場所',
                                  paragraphs: [
                                    '頁面將地名相關附錄分成多個子類別，核心原則是若當地實際唸法和字面讀法不同，就以當地讀法為主。',
                                  ],
                                  bullets: [
                                    '舊地名：收錄各縣市與鄉鎮市區的部分舊地名，並標出其現屬行政區。',
                                    '山脈名、河川、海港：收錄台灣主要山脈、支脈、河川支流與海港名稱。',
                                    '文教處所：收錄大型公共建築場所，音讀以高雄腔為主，酌收第二優勢腔。',
                                    '廟宇名：收錄大型廟宇通稱，有異稱者會列出別名。',
                                    '臺灣縣市行政區名：收錄本島及外島行政區名。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '交通站名',
                                  paragraphs: [
                                    '交通附錄以官方站名與線名為基礎，並盡量依實際廣播音讀或當地慣讀來整理。',
                                  ],
                                  bullets: [
                                    '火車線站名：以國營臺灣鐵路股份有限公司的列車線與站名資料為依據，廣播資料優先。',
                                    '捷運站名：以各捷運公司的公定站名為依據，音讀同樣優先採官方廣播，並酌收第二優勢腔。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '方言差',
                                  paragraphs: [
                                    '方言差附錄分成〔語音差異表〕和〔詞彙比較表〕兩部分，用來對照不同地區在單字音讀和詞彙選擇上的差別。',
                                    '頁面列出鹿港、三峽、臺北、宜蘭、臺南、高雄、金門、馬公、新竹、臺中等十個調查點。為了更忠實呈現地方語音，台南與高雄部分甚至會直接用更貼近實際音值的標法。',
                                  ],
                                ),
                                ReferenceArticleSection(
                                  title: '親屬關係與人體器官',
                                  paragraphs: [
                                    '附錄也整理了教育、生活上很實用但不適合拆成大量零散正文詞條的圖表型資料。',
                                  ],
                                  bullets: [
                                    '親屬關係：以《教育部重編國語辭典修訂本》的親屬關係圖為參考，再擴充台語特殊稱謂，並同時呈現男女在各自家庭關係中的叫法。',
                                    '人體器官：分成人體外觀圖、內部器官圖、人體骨骼圖、手指名稱圖四部分。',
                                    '若某些名稱在臺灣台語裡沒有穩定對應唸法，頁面也會直接保留華語名稱。',
                                  ],
                                ),
                              ],
                              sourceUrl:
                                  'https://sutian.moe.edu.tw/zh-hant/piantsip/sutian-huliok/',
                            );
                          },
                        ),
                        AboutListTile(
                          icon: const Icon(
                            Icons.info_outline,
                            color: Color(0xFF17454C),
                          ),
                          applicationName: '台語辭典',
                          applicationLegalese:
                              'App code: MIT\nDictionary data and audio: 教育部《臺灣台語常用詞辭典》衍生內容，採 CC BY-ND 3.0 TW。',
                          aboutBoxChildren: const [
                            SizedBox(height: 12),
                            Text('台語辭典提供離線的台語與華語雙向查詢，並支援下載教育部詞目與例句音檔。'),
                            SizedBox(height: 12),
                            Text(
                              '參考頁面：https://sutian.moe.edu.tw/zh-hant/siongkuantsuguan/',
                            ),
                            SizedBox(height: 8),
                            Text(
                              '臺羅標注說明：https://sutian.moe.edu.tw/zh-hant/piantsip/tailo-phiautsu-suatbing/',
                            ),
                            SizedBox(height: 8),
                            Text(
                              '漢字用字原則：https://sutian.moe.edu.tw/zh-hant/piantsip/hanji-iongji-guantsik/',
                            ),
                            SizedBox(height: 8),
                            Text(
                              '辭典附錄：https://sutian.moe.edu.tw/zh-hant/piantsip/sutian-huliok/',
                            ),
                          ],
                          applicationIcon: const Icon(
                            Icons.menu_book_outlined,
                            color: Color(0xFF17454C),
                          ),
                          child: const Text('關於台語辭典'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
