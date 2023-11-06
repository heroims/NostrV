import 'package:nostr/nostr.dart';

class NostrFilter extends Filter {
  List<String>? t;
  String? search;

  NostrFilter(
      {List<String>? ids,
        List<String>? authors,
        List<int>? kinds,
        List<String>? e,
        List<String>? a,
        List<String>? p,
        this.t,
        this.search,
        int? since,
        int? until,
        int? limit,
        })
      : super(
    ids: ids,
    authors: authors,
    kinds: kinds,
    e: e,
    a: a,
    p: p,
    since: since,
    until: until,
    limit: limit,
  );

  NostrFilter.fromJson(Map<String, dynamic> json)
      : t = json['t'] == null ? null : List<String>.from(json['t']),
        search = json['search'],
        super.fromJson(json);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (t != null) data['t'] = t;
    if (search != null) data['search'] = search;
    return data;
  }
}