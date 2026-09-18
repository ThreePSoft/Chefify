import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/recipes/presentation/image_upload/recipe_image_url_registry.dart';

void main() {
  test('releases each registered object URL exactly once', () {
    final revoked = <String>[];
    final registry = RecipeImageUrlRegistry(revoked.add)
      ..register('blob:first')
      ..register('blob:second');

    registry.release('blob:first');
    registry.release('blob:first');
    registry.release(null);

    expect(revoked, ['blob:first']);
    expect(registry.activeUrlCount, 1);

    registry.releaseAll();

    expect(revoked, ['blob:first', 'blob:second']);
    expect(registry.activeUrlCount, 0);
  });
}
