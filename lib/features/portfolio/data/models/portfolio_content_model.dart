import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';

class PortfolioContentModel extends PortfolioContent {
  PortfolioContentModel({
    required super.profile,
    required super.socials,
    required super.stats,
    required super.skillRings,
    required super.skillCategories,
    required super.projects,
    required super.timeline,
    required super.services,
    required super.testimonials,
    required super.contacts,
  });

  factory PortfolioContentModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'] as Map<String, dynamic>;
    return PortfolioContentModel(
      profile: Profile(
        name: profileJson['name'] as String,
        title: profileJson['title'] as String,
        subtitle: profileJson['subtitle'] as String,
        description: profileJson['description'] as String,
        location: profileJson['location'] as String,
        email: profileJson['email'] as String,
        careerStartDate: profileJson['careerStartDate'] as String?,
        resumeUrl: profileJson['resumeUrl'] as String?,
      ),
      socials: (json['socials'] as List<dynamic>)
          .map(
            (e) => SocialLink(
              label: e['label'] as String,
              url: e['url'] as String,
            ),
          )
          .toList(growable: false),
      stats: (json['stats'] as List<dynamic>)
          .map(
            (e) => StatItem(
              value: e['value'] as int,
              suffix: e['suffix'] as String,
              label: e['label'] as String,
              color: e['color'] as String,
            ),
          )
          .toList(growable: false),
      skillRings: (json['skillRings'] as List<dynamic>)
          .map(
            (e) => SkillRingItem(
              label: e['label'] as String,
              percent: e['percent'] as int,
              color: e['color'] as String,
            ),
          )
          .toList(growable: false),
      skillCategories: (json['skillCategories'] as List<dynamic>)
          .map(
            (e) => SkillCategory(
              title: e['title'] as String,
              color: e['color'] as String,
              items: (e['items'] as List<dynamic>)
                  .map((item) => item as String)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      projects: (json['projects'] as List<dynamic>)
          .map(
            (e) => ProjectItem(
              title: e['title'] as String,
              subtitle: e['subtitle'] as String,
              description: e['description'] as String,
              stack: (e['stack'] as List<dynamic>)
                  .map((item) => item as String)
                  .toList(growable: false),
              color: e['color'] as String,
              emoji: e['emoji'] as String,
              stars: e['stars'] as int,
              features: (e['features'] as List<dynamic>)
                  .map((item) => item as String)
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
      timeline: (json['timeline'] as List<dynamic>)
          .map(
            (e) => TimelineItem(
              role: e['role'] as String,
              company: e['company'] as String,
              period: e['period'] as String,
              description: e['description'] as String,
              color: e['color'] as String,
            ),
          )
          .toList(growable: false),
      services: (json['services'] as List<dynamic>)
          .map(
            (e) => ServiceItem(
              icon: e['icon'] as String,
              title: e['title'] as String,
              description: e['description'] as String,
              color: e['color'] as String,
            ),
          )
          .toList(growable: false),
      testimonials: (json['testimonials'] as List<dynamic>)
          .map(
            (e) => TestimonialItem(
              name: e['name'] as String,
              role: e['role'] as String,
              avatar: e['avatar'] as String,
              text: e['text'] as String,
              rating: e['rating'] as int,
              color: e['color'] as String,
            ),
          )
          .toList(growable: false),
      contacts: (json['contacts'] as List<dynamic>)
          .map(
            (e) => ContactItem(
              label: e['label'] as String,
              value: e['value'] as String,
              url: e['url'] as String,
              icon: e['icon'] as String,
            ),
          )
          .toList(growable: false),
    );
  }
}
