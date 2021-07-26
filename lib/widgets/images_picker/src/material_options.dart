class MaterialOptions {
  final actionBarColor;
  final statusBarColor;
  final bool lightStatusBar;
  final actionBarTitleColor;
  final allViewTitle;
  final actionBarTitle;
  final bool startInAllView;
  final bool useDetailsView;
  final selectCircleStrokeColor;
  final selectionLimitReachedText;
  final textOnNothingSelected;
  final backButtonDrawable;
  final okButtonDrawable;
  final bool autoCloseOnSelectionLimit;

  const MaterialOptions({
    this.actionBarColor,
    this.actionBarTitle,
    this.lightStatusBar,
    this.statusBarColor,
    this.actionBarTitleColor,
    this.allViewTitle,
    this.startInAllView,
    this.useDetailsView,
    this.selectCircleStrokeColor,
    this.selectionLimitReachedText,
    this.textOnNothingSelected,
    this.backButtonDrawable,
    this.okButtonDrawable,
    this.autoCloseOnSelectionLimit,
  });

  Map<String, String> toJson() {
    return {
      "actionBarColor": actionBarColor ?? "",
      "actionBarTitle": actionBarTitle ?? "",
      "actionBarTitleColor": actionBarTitleColor ?? "",
      "allViewTitle": allViewTitle ?? "",
      "lightStatusBar": lightStatusBar == true ? "true" : "false",
      "statusBarColor": statusBarColor ?? "",
      "startInAllView": startInAllView == true ? "true" : "false",
      "useDetailsView": useDetailsView == true ? "true" : "false",
      "selectCircleStrokeColor": selectCircleStrokeColor ?? "",
      "selectionLimitReachedText": selectionLimitReachedText ?? "",
      "textOnNothingSelected": textOnNothingSelected ?? "",
      "backButtonDrawable": backButtonDrawable ?? "",
      "okButtonDrawable": okButtonDrawable ?? "",
      "autoCloseOnSelectionLimit":
          autoCloseOnSelectionLimit == true ? "true" : "false"
    };
  }
}
