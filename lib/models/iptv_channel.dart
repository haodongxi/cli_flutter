class IPTVChannel {
  final String name;
  final String streamUrl;
  final String? logoUrl;
  final String? groupTitle;
  final List<IPTVChannelVariant> variants;

  IPTVChannel({
    required this.name,
    required this.streamUrl,
    this.logoUrl,
    this.groupTitle,
    this.variants = const [],
  });

  factory IPTVChannel.fromJson(Map<String, dynamic> json) {
    List<IPTVChannelVariant> variants = [];
    if (json['childlist'] != null) {
      variants = (json['childlist'] as List)
          .map((e) => IPTVChannelVariant.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return IPTVChannel(
      name: json['channel_name'] as String? ?? json['name'] as String? ?? '',
      streamUrl: json['stream_url'] as String,
      logoUrl: json['attributes'] != null
          ? json['attributes']['tvg-logo'] as String?
          : null,
      groupTitle: json['attributes'] != null
          ? json['attributes']['group-title'] as String?
          : null,
      variants: variants,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['channel_name'] = name;
    data['stream_url'] = streamUrl;

    if (logoUrl != null || groupTitle != null) {
      data['attributes'] = <String, String?>{};
      if (logoUrl != null) {
        data['attributes']['tvg-logo'] = logoUrl;
      }
      if (groupTitle != null) {
        data['attributes']['group-title'] = groupTitle;
      }
    }

    if (variants.isNotEmpty) {
      data['childlist'] = variants.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class IPTVChannelVariant {
  final String streamUrl;
  final String? logoUrl;
  final String? groupTitle;
  final String? name;

  IPTVChannelVariant({
    required this.streamUrl,
    this.logoUrl,
    this.groupTitle,
    this.name,
  });

  factory IPTVChannelVariant.fromJson(Map<String, dynamic> json) {
    return IPTVChannelVariant(
      streamUrl: json['stream_url'] as String,
      logoUrl: json['attributes'] != null
          ? json['attributes']['tvg-logo'] as String?
          : null,
      groupTitle: json['attributes'] != null
          ? json['attributes']['group-title'] as String?
          : null,
      name: json['attributes'] != null
          ? json['attributes']['tvg-name'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stream_url'] = streamUrl;
    return data;
  }
}
