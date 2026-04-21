import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_portfolio/features/portfolio/data/models/portfolio_content_model.dart';

void main() {
  test('parses portfolio content model', () {
    final map =
        jsonDecode('''
      {
        "profile":{"name":"Alex","title":"Flutter","subtitle":"Dev","description":"desc","location":"Remote","email":"x@y.com"},
        "socials":[{"label":"GitHub","url":"#"}],
        "stats":[{"value":1,"suffix":"+","label":"Years","color":"#4F6EF7"}],
        "skillRings":[{"label":"Flutter","percent":90,"color":"#06B6D4"}],
        "skillCategories":[{"title":"Mobile","color":"#4F6EF7","items":["Flutter"]}],
        "projects":[{"title":"P","subtitle":"S","description":"D","stack":["Flutter"],"color":"#4F6EF7","emoji":"X","stars":10,"features":["A"]}],
        "timeline":[{"role":"R","company":"C","period":"P","description":"D","color":"#4F6EF7"}],
        "services":[{"icon":"I","title":"T","description":"D","color":"#4F6EF7"}],
        "testimonials":[{"name":"N","role":"R","avatar":"A","text":"T","rating":5,"color":"#4F6EF7"}],
        "contacts":[{"label":"Email","value":"x@y.com","url":"mailto:x@y.com","icon":"M"}]
      }
      ''')
            as Map<String, dynamic>;

    final model = PortfolioContentModel.fromJson(map);

    expect(model.profile.name, 'Alex');
    expect(model.projects.first.stars, 10);
    expect(model.testimonials.first.rating, 5);
  });
}
