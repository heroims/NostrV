// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "createByCancel": MessageLookupByLibrary.simpleMessage("取消"),
        "createByHDNode": MessageLookupByLibrary.simpleMessage("HD Node"),
        "createByNormal": MessageLookupByLibrary.simpleMessage("普通"),
        "dialogByCreate": MessageLookupByLibrary.simpleMessage("请选择创建账户的方式。"),
        "dialogByTitle": MessageLookupByLibrary.simpleMessage("温馨提示"),
        "pageMnemonicDescribe": MessageLookupByLibrary.simpleMessage("请备份助记词"),
        "pageMnemonicNext": MessageLookupByLibrary.simpleMessage("下一步"),
        "pageMnemonicShowTip": MessageLookupByLibrary.simpleMessage(
            "助记词是恢复钱包所必须的。请把这些助记词写在纸上,并妥善保管在安全地方。"),
        "pageMnemonicTitle": MessageLookupByLibrary.simpleMessage("助记词"),
        "pageMnemonicVerifyTip":
            MessageLookupByLibrary.simpleMessage("请以顺序选择助记词,并确保您输入的助记词正确无误。"),
        "pageWelcomeGo": MessageLookupByLibrary.simpleMessage("进入"),
        "pageWelcomeImport": MessageLookupByLibrary.simpleMessage("导入"),
        "pageWelcomeTitle": MessageLookupByLibrary.simpleMessage("欢迎")
      };
}
