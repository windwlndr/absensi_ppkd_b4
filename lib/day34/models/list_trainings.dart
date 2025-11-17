// To parse this JSON data, do
//
//     final listTrainingsModel = listTrainingsModelFromJson(jsonString);

import 'dart:convert';

ListTrainingsModel listTrainingsModelFromJson(String str) =>
    ListTrainingsModel.fromJson(json.decode(str));

String listTrainingsModelToJson(ListTrainingsModel data) =>
    json.encode(data.toJson());

class ListTrainingsModel {
  String? message;
  List<TrainingModelData>? data;

  ListTrainingsModel({this.message, this.data});

  factory ListTrainingsModel.fromJson(Map<String, dynamic> json) =>
      ListTrainingsModel(
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<TrainingModelData>.from(
                json["data"]!.map((x) => TrainingModelData.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class TrainingModelData {
  int? id;
  String? title;

  TrainingModelData({this.id, this.title});

  factory TrainingModelData.fromJson(Map<String, dynamic> json) =>
      TrainingModelData(id: json["id"], title: json["title"]);

  Map<String, dynamic> toJson() => {"id": id, "title": title};
}
