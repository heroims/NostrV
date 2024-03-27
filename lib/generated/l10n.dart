// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Reply`
  String get notifyByReply {
    return Intl.message(
      'Reply',
      name: 'notifyByReply',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get notifyByFollow {
    return Intl.message(
      'Follow',
      name: 'notifyByFollow',
      desc: '',
      args: [],
    );
  }

  /// `Upvote`
  String get notifyByUpvote {
    return Intl.message(
      'Upvote',
      name: 'notifyByUpvote',
      desc: '',
      args: [],
    );
  }

  /// `Repost`
  String get notifyByRepost {
    return Intl.message(
      'Repost',
      name: 'notifyByRepost',
      desc: '',
      args: [],
    );
  }

  /// `Error Card`
  String get cardOfError {
    return Intl.message(
      'Error Card',
      name: 'cardOfError',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to exit the current editing page?`
  String get dialogByEditPop {
    return Intl.message(
      'Are you sure you want to exit the current editing page?',
      name: 'dialogByEditPop',
      desc: '',
      args: [],
    );
  }

  /// `Relay`
  String get navByRelay {
    return Intl.message(
      'Relay',
      name: 'navByRelay',
      desc: '',
      args: [],
    );
  }

  /// `Post`
  String get navByPost {
    return Intl.message(
      'Post',
      name: 'navByPost',
      desc: '',
      args: [],
    );
  }

  /// `Key Manager`
  String get settingByKey {
    return Intl.message(
      'Key Manager',
      name: 'settingByKey',
      desc: '',
      args: [],
    );
  }

  /// `Relay Manager`
  String get settingByRelay {
    return Intl.message(
      'Relay Manager',
      name: 'settingByRelay',
      desc: '',
      args: [],
    );
  }

  /// `Mute Manager`
  String get settingByMute {
    return Intl.message(
      'Mute Manager',
      name: 'settingByMute',
      desc: '',
      args: [],
    );
  }

  /// `Notify Manager`
  String get settingByNotify {
    return Intl.message(
      'Notify Manager',
      name: 'settingByNotify',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get settingByVersion {
    return Intl.message(
      'Version',
      name: 'settingByVersion',
      desc: '',
      args: [],
    );
  }

  /// `Recommended relays`
  String get tipRecommendRelay {
    return Intl.message(
      'Recommended relays',
      name: 'tipRecommendRelay',
      desc: '',
      args: [],
    );
  }

  /// `Please select the type of report.`
  String get actionSheetByReport {
    return Intl.message(
      'Please select the type of report.',
      name: 'actionSheetByReport',
      desc: '',
      args: [],
    );
  }

  /// `depictions of nudity, porn, etc.`
  String get reportByNudity {
    return Intl.message(
      'depictions of nudity, porn, etc.',
      name: 'reportByNudity',
      desc: '',
      args: [],
    );
  }

  /// `profanity, hateful speech, etc.`
  String get reportByProfanity {
    return Intl.message(
      'profanity, hateful speech, etc.',
      name: 'reportByProfanity',
      desc: '',
      args: [],
    );
  }

  /// `may be illegal in some jurisdiction`
  String get reportByIllegal {
    return Intl.message(
      'may be illegal in some jurisdiction',
      name: 'reportByIllegal',
      desc: '',
      args: [],
    );
  }

  /// `Spam`
  String get reportBySpam {
    return Intl.message(
      'Spam',
      name: 'reportBySpam',
      desc: '',
      args: [],
    );
  }

  /// `Impersonation`
  String get reportByImpersonation {
    return Intl.message(
      'Impersonation',
      name: 'reportByImpersonation',
      desc: '',
      args: [],
    );
  }

  /// `Public Chat`
  String get navByPublicChat {
    return Intl.message(
      'Public Chat',
      name: 'navByPublicChat',
      desc: '',
      args: [],
    );
  }

  /// `Private Chat`
  String get navByPrivateChat {
    return Intl.message(
      'Private Chat',
      name: 'navByPrivateChat',
      desc: '',
      args: [],
    );
  }

  /// `Post`
  String get searchTabByPost {
    return Intl.message(
      'Post',
      name: 'searchTabByPost',
      desc: '',
      args: [],
    );
  }

  /// `User`
  String get searchTabByUser {
    return Intl.message(
      'User',
      name: 'searchTabByUser',
      desc: '',
      args: [],
    );
  }

  /// `Update userinfo failed.`
  String get tipUpdateUserFailed {
    return Intl.message(
      'Update userinfo failed.',
      name: 'tipUpdateUserFailed',
      desc: '',
      args: [],
    );
  }

  /// `No content to publish.`
  String get tipNoFeedToPost {
    return Intl.message(
      'No content to publish.',
      name: 'tipNoFeedToPost',
      desc: '',
      args: [],
    );
  }

  /// `Not supported by NIP11.`
  String get tipByUnSupportNip11 {
    return Intl.message(
      'Not supported by NIP11.',
      name: 'tipByUnSupportNip11',
      desc: '',
      args: [],
    );
  }

  /// `Reposted`
  String get tipByReposted {
    return Intl.message(
      'Reposted',
      name: 'tipByReposted',
      desc: '',
      args: [],
    );
  }

  /// `Enter your search query`
  String get tipBySearchQuery {
    return Intl.message(
      'Enter your search query',
      name: 'tipBySearchQuery',
      desc: '',
      args: [],
    );
  }

  /// `Repost`
  String get repostByPostID {
    return Intl.message(
      'Repost',
      name: 'repostByPostID',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get shareByPostID {
    return Intl.message(
      'Share',
      name: 'shareByPostID',
      desc: '',
      args: [],
    );
  }

  /// `Copy Post ID`
  String get copyByPostID {
    return Intl.message(
      'Copy Post ID',
      name: 'copyByPostID',
      desc: '',
      args: [],
    );
  }

  /// `Copy User ID`
  String get copyByUserID {
    return Intl.message(
      'Copy User ID',
      name: 'copyByUserID',
      desc: '',
      args: [],
    );
  }

  /// `Copy Post`
  String get copyByPost {
    return Intl.message(
      'Copy Post',
      name: 'copyByPost',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copyToClipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copyToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Please do not report repeatedly.`
  String get tipReportRepeatedly {
    return Intl.message(
      'Please do not report repeatedly.',
      name: 'tipReportRepeatedly',
      desc: '',
      args: [],
    );
  }

  /// `Replies`
  String get userReplies {
    return Intl.message(
      'Replies',
      name: 'userReplies',
      desc: '',
      args: [],
    );
  }

  /// `Upvote`
  String get userUpvote {
    return Intl.message(
      'Upvote',
      name: 'userUpvote',
      desc: '',
      args: [],
    );
  }

  /// `Reposts`
  String get userReposts {
    return Intl.message(
      'Reposts',
      name: 'userReposts',
      desc: '',
      args: [],
    );
  }

  /// `Replies List`
  String get userRepliesList {
    return Intl.message(
      'Replies List',
      name: 'userRepliesList',
      desc: '',
      args: [],
    );
  }

  /// `Upvote List`
  String get userUpvoteList {
    return Intl.message(
      'Upvote List',
      name: 'userUpvoteList',
      desc: '',
      args: [],
    );
  }

  /// `Reposts List`
  String get userRepostsList {
    return Intl.message(
      'Reposts List',
      name: 'userRepostsList',
      desc: '',
      args: [],
    );
  }

  /// `Report User`
  String get reportUser {
    return Intl.message(
      'Report User',
      name: 'reportUser',
      desc: '',
      args: [],
    );
  }

  /// `Mute User`
  String get muteUser {
    return Intl.message(
      'Mute User',
      name: 'muteUser',
      desc: '',
      args: [],
    );
  }

  /// `Mute Post`
  String get mutePost {
    return Intl.message(
      'Mute Post',
      name: 'mutePost',
      desc: '',
      args: [],
    );
  }

  /// `unMute User`
  String get unMuteUser {
    return Intl.message(
      'unMute User',
      name: 'unMuteUser',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get avatarCardByEdit {
    return Intl.message(
      'Edit',
      name: 'avatarCardByEdit',
      desc: '',
      args: [],
    );
  }

  /// `Following`
  String get avatarCardByFollowing {
    return Intl.message(
      'Following',
      name: 'avatarCardByFollowing',
      desc: '',
      args: [],
    );
  }

  /// `Followers`
  String get avatarCardByFollowers {
    return Intl.message(
      'Followers',
      name: 'avatarCardByFollowers',
      desc: '',
      args: [],
    );
  }

  /// `Relays`
  String get avatarCardByRelays {
    return Intl.message(
      'Relays',
      name: 'avatarCardByRelays',
      desc: '',
      args: [],
    );
  }

  /// `Follow`
  String get avatarCardByFollow {
    return Intl.message(
      'Follow',
      name: 'avatarCardByFollow',
      desc: '',
      args: [],
    );
  }

  /// `Followed`
  String get avatarCardByFollowed {
    return Intl.message(
      'Followed',
      name: 'avatarCardByFollowed',
      desc: '',
      args: [],
    );
  }

  /// `Display Name`
  String get profileEditByName {
    return Intl.message(
      'Display Name',
      name: 'profileEditByName',
      desc: '',
      args: [],
    );
  }

  /// `About me`
  String get profileEditByAbout {
    return Intl.message(
      'About me',
      name: 'profileEditByAbout',
      desc: '',
      args: [],
    );
  }

  /// `Avatar Url`
  String get profileEditByAvatar {
    return Intl.message(
      'Avatar Url',
      name: 'profileEditByAvatar',
      desc: '',
      args: [],
    );
  }

  /// `Banner Url`
  String get profileEditByBanner {
    return Intl.message(
      'Banner Url',
      name: 'profileEditByBanner',
      desc: '',
      args: [],
    );
  }

  /// `Website Url`
  String get profileEditByWebsite {
    return Intl.message(
      'Website Url',
      name: 'profileEditByWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Nostr Address(xxx@xxx.xxx)`
  String get profileEditByNip05 {
    return Intl.message(
      'Nostr Address(xxx@xxx.xxx)',
      name: 'profileEditByNip05',
      desc: '',
      args: [],
    );
  }

  /// `LN Address(xxx@xxx.xxx)`
  String get profileEditByLud16 {
    return Intl.message(
      'LN Address(xxx@xxx.xxx)',
      name: 'profileEditByLud16',
      desc: '',
      args: [],
    );
  }

  /// `Camera`
  String get profileEditByCamera {
    return Intl.message(
      'Camera',
      name: 'profileEditByCamera',
      desc: '',
      args: [],
    );
  }

  /// `Album`
  String get profileEditByAlbum {
    return Intl.message(
      'Album',
      name: 'profileEditByAlbum',
      desc: '',
      args: [],
    );
  }

  /// `reply:`
  String get postByReply {
    return Intl.message(
      'reply:',
      name: 'postByReply',
      desc: '',
      args: [],
    );
  }

  /// `Comment`
  String get postDetailByComment {
    return Intl.message(
      'Comment',
      name: 'postDetailByComment',
      desc: '',
      args: [],
    );
  }

  /// `Main`
  String get postDetailByMain {
    return Intl.message(
      'Main',
      name: 'postDetailByMain',
      desc: '',
      args: [],
    );
  }

  /// `Root`
  String get postDetailByRoot {
    return Intl.message(
      'Root',
      name: 'postDetailByRoot',
      desc: '',
      args: [],
    );
  }

  /// `Previous`
  String get postDetailByPrevious {
    return Intl.message(
      'Previous',
      name: 'postDetailByPrevious',
      desc: '',
      args: [],
    );
  }

  /// `Currently positioned at the main comment.`
  String get tipByOnThisPost {
    return Intl.message(
      'Currently positioned at the main comment.',
      name: 'tipByOnThisPost',
      desc: '',
      args: [],
    );
  }

  /// `Currently positioned at the user page.`
  String get tipByOnThisUser {
    return Intl.message(
      'Currently positioned at the user page.',
      name: 'tipByOnThisUser',
      desc: '',
      args: [],
    );
  }

  /// `Keystore Password Error`
  String get tipByKeystorePwError {
    return Intl.message(
      'Keystore Password Error',
      name: 'tipByKeystorePwError',
      desc: '',
      args: [],
    );
  }

  /// `Tip`
  String get dialogByTitle {
    return Intl.message(
      'Tip',
      name: 'dialogByTitle',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get dialogByDone {
    return Intl.message(
      'Done',
      name: 'dialogByDone',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get dialogByCopy {
    return Intl.message(
      'Copy',
      name: 'dialogByCopy',
      desc: '',
      args: [],
    );
  }

  /// `Add Failed`
  String get dialogByAddFailed {
    return Intl.message(
      'Add Failed',
      name: 'dialogByAddFailed',
      desc: '',
      args: [],
    );
  }

  /// `Input can't be empty`
  String get dialogByInputFailed {
    return Intl.message(
      'Input can\'t be empty',
      name: 'dialogByInputFailed',
      desc: '',
      args: [],
    );
  }

  /// `Please add additional relays to fetch data.`
  String get dialogByNoDataInRelay {
    return Intl.message(
      'Please add additional relays to fetch data.',
      name: 'dialogByNoDataInRelay',
      desc: '',
      args: [],
    );
  }

  /// `Please select a method to create an account.`
  String get dialogByCreate {
    return Intl.message(
      'Please select a method to create an account.',
      name: 'dialogByCreate',
      desc: '',
      args: [],
    );
  }

  /// `Reason for blocking`
  String get dialogByMuteReason {
    return Intl.message(
      'Reason for blocking',
      name: 'dialogByMuteReason',
      desc: '',
      args: [],
    );
  }

  /// `Mute`
  String get dialogByMute {
    return Intl.message(
      'Mute',
      name: 'dialogByMute',
      desc: '',
      args: [],
    );
  }

  /// `UnMute`
  String get dialogByCancelMute {
    return Intl.message(
      'UnMute',
      name: 'dialogByCancelMute',
      desc: '',
      args: [],
    );
  }

  /// `You will not receive posts or private messages from this user after blocking them.`
  String get dialogByMuteDescribe {
    return Intl.message(
      'You will not receive posts or private messages from this user after blocking them.',
      name: 'dialogByMuteDescribe',
      desc: '',
      args: [],
    );
  }

  /// `You will not be able to see this post after blocking.`
  String get dialogByMuteEvent {
    return Intl.message(
      'You will not be able to see this post after blocking.',
      name: 'dialogByMuteEvent',
      desc: '',
      args: [],
    );
  }

  /// `HD Node`
  String get createByHDNode {
    return Intl.message(
      'HD Node',
      name: 'createByHDNode',
      desc: '',
      args: [],
    );
  }

  /// `Normal`
  String get createByNormal {
    return Intl.message(
      'Normal',
      name: 'createByNormal',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get createByCancel {
    return Intl.message(
      'Cancel',
      name: 'createByCancel',
      desc: '',
      args: [],
    );
  }

  /// `Export Nostr Private Key`
  String get exportByNostrKey {
    return Intl.message(
      'Export Nostr Private Key',
      name: 'exportByNostrKey',
      desc: '',
      args: [],
    );
  }

  /// `Export Nostr Private Key`
  String get exportByWalletKey {
    return Intl.message(
      'Export Nostr Private Key',
      name: 'exportByWalletKey',
      desc: '',
      args: [],
    );
  }

  /// `Export Keystore`
  String get exportByKeystore {
    return Intl.message(
      'Export Keystore',
      name: 'exportByKeystore',
      desc: '',
      args: [],
    );
  }

  /// `Welcome`
  String get pageWelcomeTitle {
    return Intl.message(
      'Welcome',
      name: 'pageWelcomeTitle',
      desc: '',
      args: [],
    );
  }

  /// `Go`
  String get pageWelcomeGo {
    return Intl.message(
      'Go',
      name: 'pageWelcomeGo',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get pageWelcomeImport {
    return Intl.message(
      'Import',
      name: 'pageWelcomeImport',
      desc: '',
      args: [],
    );
  }

  /// `Mnemonic`
  String get pageMnemonicTitle {
    return Intl.message(
      'Mnemonic',
      name: 'pageMnemonicTitle',
      desc: '',
      args: [],
    );
  }

  /// `Please backup the mnemonic words`
  String get pageMnemonicDescribe {
    return Intl.message(
      'Please backup the mnemonic words',
      name: 'pageMnemonicDescribe',
      desc: '',
      args: [],
    );
  }

  /// `The mnemonic words are required for recovering your wallet. Please write these mnemonic words on a piece of paper and store it in a secure location.`
  String get pageMnemonicShowTip {
    return Intl.message(
      'The mnemonic words are required for recovering your wallet. Please write these mnemonic words on a piece of paper and store it in a secure location.',
      name: 'pageMnemonicShowTip',
      desc: '',
      args: [],
    );
  }

  /// `Please choose mnemonic words in order and make sure your mnemonic was correct written.`
  String get pageMnemonicVerifyTip {
    return Intl.message(
      'Please choose mnemonic words in order and make sure your mnemonic was correct written.',
      name: 'pageMnemonicVerifyTip',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get pageMnemonicNext {
    return Intl.message(
      'Next',
      name: 'pageMnemonicNext',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
