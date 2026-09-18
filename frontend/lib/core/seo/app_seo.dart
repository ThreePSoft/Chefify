import 'package:frontend/core/seo/app_seo_stub.dart'
    if (dart.library.html) 'package:frontend/core/seo/app_seo_web.dart'
    as implementation;
import 'package:frontend/core/seo/recipe_seo_data.dart';

export 'package:frontend/core/seo/recipe_seo_data.dart';

void setDefaultSeo() {
  implementation.setDefaultSeo();
}

void setRecipeSeo(RecipeSeoData recipe) {
  implementation.setRecipeSeo(recipe);
}
