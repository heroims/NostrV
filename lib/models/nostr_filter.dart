import 'package:nostr/nostr.dart';

class NostrFilter extends Filter {
  List<String>? t;

  NostrFilter(
      {super.ids,
        super.authors,
        super.kinds,
        super.e,
        super.a,
        super.p,
        this.t,
        super.since,
        super.until,
        super.limit,
        });

  NostrFilter.fromJson(super.json)
      : t = json['t'] == null ? null : List<String>.from(json['t']),
        super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (t != null) data['t'] = t;
    if (search != null) data['search'] = search;
    return data;
  }
}