// To parse this JSON data, do
//
//     final multiversxNft = multiversxNftFromJson(jsonString);

import 'dart:convert';

List<MultiversxNft> multiversxNftFromJson(String str) =>
    List<MultiversxNft>.from(
        json.decode(str).map((x) => MultiversxNft.fromJson(x)));

String multiversxNftToJson(List<MultiversxNft> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MultiversxNft {
  final String identifier;
  final String ticker;
  final String collection;
  final Metadata? metadata;
  final String type;
  final int nonce;
  final String? balance;
  final String url;

  final int timestamp;
  final String attributes;

  final String? name;
  final String creator;
  final int royalties;

  final Media media;
  final bool isWhitelistedStorage;
  final String thumbnailUrl;

  final String owner;

  final String supply;
  final int decimals;
  final Assets? assets;

  final ScamInfo? scamInfo;
  final num score;
  final int rank;
  final Rarities? rarities;
  final bool isNsfw;
  final int unlockEpoch;
  final int price;
  final int valueUsd;

  MultiversxNft({
    required this.identifier,
    required this.collection,
    required this.timestamp,
    required this.attributes,
    required this.nonce,
    required this.type,
    required this.name,
    required this.creator,
    required this.royalties,
    required this.url,
    required this.media,
    required this.isWhitelistedStorage,
    required this.thumbnailUrl,
    this.metadata,
    required this.owner,
    required this.balance,
    required this.supply,
    required this.decimals,
    this.assets,
    required this.ticker,
    this.scamInfo,
    required this.score,
    required this.rank,
    this.rarities,
    required this.isNsfw,
    required this.unlockEpoch,
    required this.price,
    required this.valueUsd,
  });

  factory MultiversxNft.fromJson(Map<String, dynamic> json) => MultiversxNft(
        identifier: json["identifier"],
        collection: json["collection"],
        timestamp: json["timestamp"],
        attributes: json["attributes"],
        nonce: json["nonce"],
        type: json["type"],
        name: json["name"],
        creator: json["creator"],
        royalties: json["royalties"],
        url: json["url"],
        media: Media.fromJson(json["media"][0]),
        isWhitelistedStorage: json["isWhitelistedStorage"],
        thumbnailUrl: json["thumbnailUrl"],
        metadata: json["metadata"] == null
            ? null
            : Metadata.fromJson(json["metadata"]),
        owner: json["owner"],
        balance: json["balance"],
        supply: json["supply"],
        decimals: json["decimals"],
        assets: json["assets"] != null ? Assets.fromJson(json["assets"]) : null,
        ticker: json["ticker"],
        scamInfo: json["scamInfo"] != null
            ? ScamInfo.fromJson(json["scamInfo"])
            : null,
        score: json["score"],
        rank: json["rank"],
        rarities: json["rarities"] != null
            ? Rarities.fromJson(json["rarities"])
            : null,
        isNsfw: json["isNsfw"],
        unlockEpoch: json["unlockEpoch"],
        price: json["price"],
        valueUsd: json["valueUsd"],
      );

  Map<String, dynamic> toJson() => {
        "identifier": identifier,
        "collection": collection,
        "timestamp": timestamp,
        "attributes": attributes,
        "nonce": nonce,
        "type": type,
        "name": name,
        "creator": creator,
        "royalties": royalties,
        "url": url,
        "media": media.toJson(),
        "isWhitelistedStorage": isWhitelistedStorage,
        "thumbnailUrl": thumbnailUrl,
        "metadata": metadata!.toJson(),
        "owner": owner,
        "balance": balance,
        "supply": supply,
        "decimals": decimals,
        "assets": assets!.toJson(),
        "ticker": ticker,
        "scamInfo": scamInfo!.toJson(),
        "score": score,
        "rank": rank,
        "rarities": rarities!.toJson(),
        "isNsfw": isNsfw,
        "unlockEpoch": unlockEpoch,
        "price": price,
        "valueUsd": valueUsd,
      };
}

class Assets {
  final String website;
  final String description;
  final String status;
  final String pngUrl;
  final String svgUrl;
  final String ledgerSignature;
  final List<String>? extraTokens;
  final String preferredRankAlgorithm;

  Assets({
    required this.website,
    required this.description,
    required this.status,
    required this.pngUrl,
    required this.svgUrl,
    required this.ledgerSignature,
    this.extraTokens,
    required this.preferredRankAlgorithm,
  });

  factory Assets.fromJson(Map<String, dynamic> json) => Assets(
        website: json["website"],
        description: json["description"],
        status: json["status"],
        pngUrl: json["pngUrl"],
        svgUrl: json["svgUrl"],
        ledgerSignature: json["ledgerSignature"],
        extraTokens:
            List<String>.from((json["extraTokens"] ?? []).map((x) => x)),
        preferredRankAlgorithm: json["preferredRankAlgorithm"],
      );

  Map<String, dynamic> toJson() => {
        "website": website,
        "description": description,
        "status": status,
        "pngUrl": pngUrl,
        "svgUrl": svgUrl,
        "ledgerSignature": ledgerSignature,
        "extraTokens": List<dynamic>.from(extraTokens!.map((x) => x)),
        "preferredRankAlgorithm": preferredRankAlgorithm,
      };
}

class Media {
  final String url;
  final String originalUrl;
  final String thumbnailUrl;
  final String fileType;
  final int fileSize;

  Media({
    required this.url,
    required this.originalUrl,
    required this.thumbnailUrl,
    required this.fileType,
    required this.fileSize,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      url: json["url"],
      originalUrl: json["originalUrl"],
      thumbnailUrl: json["thumbnailUrl"],
      fileType: json["fileType"],
      fileSize: json["fileSize"],
    );
  }

  Map<String, dynamic> toJson() => {
        "url": url,
        "originalUrl": originalUrl,
        "thumbnailUrl": thumbnailUrl,
        "fileType": fileType,
        "fileSize": fileSize,
      };
}

class Metadata {
  final String description;
  final String fileType;
  final String fileUri;
  final String fileName;

  Metadata({
    required this.description,
    required this.fileType,
    required this.fileUri,
    required this.fileName,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        description: json["description"],
        fileType: json["fileType"],
        fileUri: json["fileUri"],
        fileName: json["fileName"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "fileType": fileType,
        "fileUri": fileUri,
        "fileName": fileName,
      };
}

class Error {
  final String code;
  final String message;
  final int timestamp;

  Error({
    required this.code,
    required this.message,
    required this.timestamp,
  });

  factory Error.fromJson(Map<String, dynamic> json) => Error(
        code: json["code"],
        message: json["message"],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "timestamp": timestamp,
      };
}

class Rarities {
  final Custom statistical;
  final Custom trait;
  final Custom jaccardDistances;
  final Custom openRarity;
  final Custom custom;

  Rarities({
    required this.statistical,
    required this.trait,
    required this.jaccardDistances,
    required this.openRarity,
    required this.custom,
  });

  factory Rarities.fromJson(Map<String, dynamic> json) => Rarities(
        statistical: Custom.fromJson(json["statistical"]),
        trait: Custom.fromJson(json["trait"]),
        jaccardDistances: Custom.fromJson(json["jaccardDistances"]),
        openRarity: Custom.fromJson(json["openRarity"]),
        custom: Custom.fromJson(json["custom"]),
      );

  Map<String, dynamic> toJson() => {
        "statistical": statistical.toJson(),
        "trait": trait.toJson(),
        "jaccardDistances": jaccardDistances.toJson(),
        "openRarity": openRarity.toJson(),
        "custom": custom.toJson(),
      };
}

class Custom {
  final int rank;
  final int score;

  Custom({
    required this.rank,
    required this.score,
  });

  factory Custom.fromJson(Map<String, dynamic> json) => Custom(
        rank: json["rank"],
        score: json["score"],
      );

  Map<String, dynamic> toJson() => {
        "rank": rank,
        "score": score,
      };
}

class ScamInfo {
  final String type;
  final String info;

  ScamInfo({
    required this.type,
    required this.info,
  });

  factory ScamInfo.fromJson(Map<String, dynamic> json) => ScamInfo(
        type: json["type"],
        info: json["info"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "info": info,
      };
}

class UnlockSchedule {
  final int remainingEpochs;
  final int percent;

  UnlockSchedule({
    required this.remainingEpochs,
    required this.percent,
  });

  factory UnlockSchedule.fromJson(Map<String, dynamic> json) => UnlockSchedule(
        remainingEpochs: json["remainingEpochs"],
        percent: json["percent"],
      );

  Map<String, dynamic> toJson() => {
        "remainingEpochs": remainingEpochs,
        "percent": percent,
      };
}
