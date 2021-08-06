class Guide {
  int guideId;
  String guideName;
  String guideDesc;
  String guideTag;
  String guideImage;

  Guide();

  factory Guide.fromJson(Map<String, dynamic> json) {
    Guide e = new Guide();
    e.guideId = json["guideId"];
    e.guideName = json["guideName"];
    e.guideDesc = json["guideDesc"];
    e.guideTag = json["guideTag"];
    e.guideImage = json["guideImage"];

    return e;
  }

  Map<String, dynamic> toBD() {
    var map = <String, dynamic>{
      'guideId': this.guideId,
      'guideName': this.guideName,
      'guideDesc': this.guideDesc,
      'guideTag': this.guideTag,
      'guideImage': this.guideImage,
    };
    return map;
  }
}
