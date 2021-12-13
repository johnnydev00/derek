class InformationModel {
  final String? newsTitle;
  final String? newsText;
  final String? newsDate;
  final String? newsImage;

  InformationModel({this.newsTitle, this.newsText, this.newsDate, this.newsImage});

  factory InformationModel.fromJson(Map<String, dynamic> json) {
    return InformationModel(
      newsTitle: json['news_title'],
      newsText: json['news_text'],
      newsDate: json['news_data'],
      newsImage: json['news_image_name'],
    );
  }
}