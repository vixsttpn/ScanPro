
enum QrType { wifi, url, vcard, email, tel, geo, text }

class QrWifi {
  final String ssid;
  final String password;
  final String security;
  final bool hidden;
  const QrWifi({required this.ssid, required this.password, required this.security, this.hidden=false});
}

class ParsedQr {
  final QrType type;
  final String raw;
  final String? title;
  final QrWifi? wifi;
  final String? url;
  final Map<String,String>? vcard;
  const ParsedQr({required this.type, required this.raw, this.title, this.wifi, this.url, this.vcard});
}

class QrParser {
  static ParsedQr parse(String raw) {
    raw = raw.trim();
    if (raw.startsWith('WIFI:')) return _parseWifi(raw);
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return ParsedQr(type: QrType.url, raw: raw, url: raw, title: raw);
    }
    if (raw.startsWith('BEGIN:VCARD')) {
      final map = <String,String>{};
      for (var line in raw.split('\n')) {
        if (line.contains(':')) {
          final idx = line.indexOf(':');
          map[line.substring(0, idx)] = line.substring(idx+1);
        }
      }
      return ParsedQr(type: QrType.vcard, raw: raw, vcard: map, title: map['FN'] ?? 'Contact');
    }
    if (raw.toLowerCase().startsWith('mailto:')) {
      return ParsedQr(type: QrType.email, raw: raw, title: raw);
    }
    if (raw.toLowerCase().startsWith('tel:')) {
      return ParsedQr(type: QrType.tel, raw: raw, title: raw);
    }
    if (raw.toLowerCase().startsWith('geo:')) {
      return ParsedQr(type: QrType.geo, raw: raw, title: raw);
    }
    return ParsedQr(type: QrType.text, raw: raw, title: raw.length>40? raw.substring(0,40): raw);
  }

  static ParsedQr _parseWifi(String raw) {
    // WIFI:T:WPA;S:MySSID;P:pass;H:false;;
    final t = RegExp(r'T:([^;]*)').firstMatch(raw)?.group(1) ?? 'WPA';
    final s = RegExp(r'S:([^;]*)').firstMatch(raw)?.group(1) ?? '';
    final p = RegExp(r'P:([^;]*)').firstMatch(raw)?.group(1) ?? '';
    final h = RegExp(r'H:([^;]*)').firstMatch(raw)?.group(1) ?? 'false';
    return ParsedQr(
      type: QrType.wifi,
      raw: raw,
      title: s,
      wifi: QrWifi(ssid: s, password: p, security: t, hidden: h.toLowerCase()=='true'),
    );
  }
}
