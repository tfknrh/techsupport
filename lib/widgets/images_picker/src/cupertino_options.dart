class CupertinoOptions {
  final backgroundColor;
  final doneButtonTitle;
  final selectionShadowColor;
  final selectionStrokeColor;
  final selectionFillColor;
  final selectionTextColor;
  final selectionCharacter;
  final takePhotoIcon;
  final bool autoCloseOnSelectionLimit;

  const CupertinoOptions({
    this.backgroundColor,
    this.doneButtonTitle,
    this.selectionFillColor,
    this.selectionShadowColor,
    this.selectionStrokeColor,
    this.selectionTextColor,
    this.selectionCharacter,
    this.takePhotoIcon,
    this.autoCloseOnSelectionLimit,
  });

  Map<String, String> toJson() {
    return {
      "backgroundColor": backgroundColor ?? "",
      "doneButtonTitle": doneButtonTitle ?? "",
      "selectionFillColor": selectionFillColor ?? "",
      "selectionShadowColor": selectionShadowColor ?? "",
      "selectionStrokeColor": selectionStrokeColor ?? "",
      "selectionTextColor": selectionTextColor ?? "",
      "selectionCharacter": selectionCharacter ?? "",
      "takePhotoIcon": takePhotoIcon ?? "",
      "autoCloseOnSelectionLimit":
          autoCloseOnSelectionLimit == true ? "true" : "false"
    };
  }
}
