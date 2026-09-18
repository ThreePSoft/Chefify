// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

import 'package:frontend/features/recipes/presentation/image_upload/recipe_image_url_registry.dart';

final RecipeImageUrlRegistry _objectUrls = RecipeImageUrlRegistry(
  html.Url.revokeObjectUrl,
);

Future<String?> pickRecipeHeroImageUrl() {
  final completer = Completer<String?>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..multiple = false;

  input.onChange.first.then((_) {
    final file = input.files?.isNotEmpty == true ? input.files!.first : null;
    if (file == null) {
      completer.complete(null);
      return;
    }

    final imageUrl = html.Url.createObjectUrl(file);
    _objectUrls.register(imageUrl);
    completer.complete(imageUrl);
  });

  input.click();
  return completer.future;
}

void releaseRecipeImageUrl(String? imageUrl) {
  _objectUrls.release(imageUrl);
}
