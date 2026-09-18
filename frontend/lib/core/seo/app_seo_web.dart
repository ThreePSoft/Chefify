// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

import 'package:frontend/core/seo/recipe_seo_data.dart';

const _defaultTitle = 'Chefify — Discover, create, and save recipes';
const _defaultDescription =
    'Discover practical recipes, save favorites, and create your own cooking guides with Chefify.';
const _defaultImagePath = 'icons/chefify-social.svg';
const _structuredDataId = 'chefify-recipe-structured-data';

void setDefaultSeo() {
  final pageUrl = html.window.location.href;
  html.document.title = _defaultTitle;
  _setDescription(_defaultDescription);
  _setProperty('og:title', _defaultTitle);
  _setProperty('og:description', _defaultDescription);
  _setProperty('og:type', 'website');
  _setProperty('og:site_name', 'Chefify');
  _setProperty('og:url', pageUrl);
  _setProperty('og:image', _absoluteUrl(_defaultImagePath));
  _setName('twitter:card', 'summary_large_image');
  _setName('twitter:title', _defaultTitle);
  _setName('twitter:description', _defaultDescription);
  _setName('twitter:image', _absoluteUrl(_defaultImagePath));
  _setCanonical(pageUrl);
  html.document.getElementById(_structuredDataId)?.remove();
}

void setRecipeSeo(RecipeSeoData recipe) {
  final pageUrl = html.window.location.href;
  final title = '${recipe.title} | Chefify';
  final imageUrl = recipe.imageUrl == null
      ? _absoluteUrl(_defaultImagePath)
      : _absoluteUrl(recipe.imageUrl!);

  html.document.title = title;
  _setDescription(recipe.description);
  _setProperty('og:title', title);
  _setProperty('og:description', recipe.description);
  _setProperty('og:type', 'article');
  _setProperty('og:site_name', 'Chefify');
  _setProperty('og:url', pageUrl);
  _setProperty('og:image', imageUrl);
  _setName('twitter:card', 'summary_large_image');
  _setName('twitter:title', title);
  _setName('twitter:description', recipe.description);
  _setName('twitter:image', imageUrl);
  _setCanonical(pageUrl);
  _setRecipeStructuredData(recipe, pageUrl: pageUrl, imageUrl: imageUrl);
}

void _setDescription(String content) {
  _setName('description', content);
}

void _setName(String name, String content) {
  final element =
      html.document.head!.querySelector('meta[name="$name"]')
          as html.MetaElement? ??
      (html.MetaElement()..name = name);
  element.content = content;
  if (element.parent == null) {
    html.document.head!.append(element);
  }
}

void _setProperty(String property, String content) {
  final element =
      html.document.head!.querySelector('meta[property="$property"]')
          as html.MetaElement? ??
      html.MetaElement();
  element.setAttribute('property', property);
  element.content = content;
  if (element.parent == null) {
    html.document.head!.append(element);
  }
}

void _setCanonical(String pageUrl) {
  final element =
      html.document.head!.querySelector('link[rel="canonical"]')
          as html.LinkElement? ??
      (html.LinkElement()..rel = 'canonical');
  element.href = pageUrl;
  if (element.parent == null) {
    html.document.head!.append(element);
  }
}

void _setRecipeStructuredData(
  RecipeSeoData recipe, {
  required String pageUrl,
  required String imageUrl,
}) {
  final element =
      html.document.getElementById(_structuredDataId) as html.ScriptElement? ??
      (html.ScriptElement()
        ..id = _structuredDataId
        ..type = 'application/ld+json');
  element.text = jsonEncode(
    recipe
        .structuredData(pageUrl: pageUrl)
        .map((key, value) => MapEntry(key, value))
      ..['image'] = <String>[imageUrl],
  );
  if (element.parent == null) {
    html.document.head!.append(element);
  }
}

String _absoluteUrl(String value) {
  return Uri.base.resolve(value.trim()).toString();
}
