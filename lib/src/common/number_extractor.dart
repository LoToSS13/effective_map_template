String? extractNumberFromText(String? text) =>
    text?.replaceAll(RegExp('[^0-9]'), '') ?? '';
