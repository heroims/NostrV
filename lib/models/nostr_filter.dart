import 'package:nostr/nostr.dart';

class NostrFilter extends Filter {
  List<String>? t;
  List<String>? P;

  NostrFilter(
      {super.ids,
        super.authors,
        super.kinds,
        super.e,
        super.a,
        super.p,
        this.t,
        this.P,
        super.since,
        super.until,
        super.limit,
        });

  NostrFilter.fromJson(super.json)
      : t = json['#t'] == null ? null : List<String>.from(json['#t']),
        P = json['#P'] == null ? null : List<String>.from(json['#P']),
        super.fromJson();

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    if (t != null) data['#t'] = t;
    if (P != null) data['#P'] = P;
    return data;
  }
}