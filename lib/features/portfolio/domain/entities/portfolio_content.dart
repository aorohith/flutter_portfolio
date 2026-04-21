class PortfolioContent {
  const PortfolioContent({
    required this.profile,
    required this.socials,
    required this.stats,
    required this.skillRings,
    required this.skillCategories,
    required this.projects,
    required this.timeline,
    required this.services,
    required this.testimonials,
    required this.contacts,
  });

  final Profile profile;
  final List<SocialLink> socials;
  final List<StatItem> stats;
  final List<SkillRingItem> skillRings;
  final List<SkillCategory> skillCategories;
  final List<ProjectItem> projects;
  final List<TimelineItem> timeline;
  final List<ServiceItem> services;
  final List<TestimonialItem> testimonials;
  final List<ContactItem> contacts;
}

class Profile {
  const Profile({
    required this.name,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.location,
    required this.email,
    this.careerStartDate,
  });

  final String name;
  final String title;
  final String subtitle;
  final String description;
  final String location;
  final String email;
  /// ISO 8601 date (e.g. `2022-08-01`) for tenure shown in stats.
  final String? careerStartDate;
}

class SocialLink {
  const SocialLink({required this.label, required this.url});

  final String label;
  final String url;
}

class StatItem {
  const StatItem({
    required this.value,
    required this.suffix,
    required this.label,
    required this.color,
  });

  final int value;
  final String suffix;
  final String label;
  final String color;
}

class SkillRingItem {
  const SkillRingItem({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final String color;
}

class SkillCategory {
  const SkillCategory({
    required this.title,
    required this.color,
    required this.items,
  });

  final String title;
  final String color;
  final List<String> items;
}

class ProjectItem {
  const ProjectItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.stack,
    required this.color,
    required this.emoji,
    required this.stars,
    required this.features,
  });

  final String title;
  final String subtitle;
  final String description;
  final List<String> stack;
  final String color;
  final String emoji;
  final int stars;
  final List<String> features;
}

class TimelineItem {
  const TimelineItem({
    required this.role,
    required this.company,
    required this.period,
    required this.description,
    required this.color,
  });

  final String role;
  final String company;
  final String period;
  final String description;
  final String color;
}

class ServiceItem {
  const ServiceItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final String icon;
  final String title;
  final String description;
  final String color;
}

class TestimonialItem {
  const TestimonialItem({
    required this.name,
    required this.role,
    required this.avatar,
    required this.text,
    required this.rating,
    required this.color,
  });

  final String name;
  final String role;
  final String avatar;
  final String text;
  final int rating;
  final String color;
}

class ContactItem {
  const ContactItem({
    required this.label,
    required this.value,
    required this.url,
    required this.icon,
  });

  final String label;
  final String value;
  final String url;
  final String icon;
}

// --- AI workflow section (hardcoded app content) ---

class AiWorkflowContent {
  const AiWorkflowContent({
    required this.sectionLabel,
    required this.sectionTitle,
    required this.hero,
    required this.tools,
    required this.pipeline,
    required this.productivitySignals,
    required this.recruiterBullets,
    required this.useCases,
    required this.ethicsHeadline,
    required this.ethicsPoints,
    required this.portfolioAttribution,
    required this.badges,
    required this.cta,
  });

  final String sectionLabel;
  final String sectionTitle;
  final AiWorkflowHeroContent hero;
  final List<AiToolItem> tools;
  final List<AiPipelineStageItem> pipeline;
  final List<AiProductivitySignalItem> productivitySignals;
  final List<String> recruiterBullets;
  final List<AiUseCaseItem> useCases;
  final String ethicsHeadline;
  final List<String> ethicsPoints;
  final String portfolioAttribution;
  final List<String> badges;
  final AiWorkflowCtaContent cta;

  bool get isVisible => tools.isNotEmpty;
}

class AiWorkflowHeroContent {
  const AiWorkflowHeroContent({
    required this.title,
    required this.subtitle,
    required this.ctas,
  });

  final String title;
  final String subtitle;
  final List<AiHeroCta> ctas;
}

class AiHeroCta {
  const AiHeroCta({required this.label, required this.target});

  final String label;
  /// Section id for [PortfolioPage] scroll: `workflow-pipeline`, `projects`, `contact`.
  final String target;
}

class AiToolItem {
  const AiToolItem({
    required this.category,
    required this.name,
    required this.monogram,
    required this.primaryPurpose,
    required this.usage,
    required this.impactTag,
    required this.color,
  });

  final String category;
  final String name;
  final String monogram;
  final String primaryPurpose;
  final String usage;
  final String impactTag;
  final String color;
}

class AiPipelineStageItem {
  const AiPipelineStageItem({
    required this.title,
    required this.description,
    required this.tools,
  });

  final String title;
  final String description;
  final List<String> tools;
}

class AiProductivitySignalItem {
  const AiProductivitySignalItem({
    required this.label,
    required this.subtitle,
    required this.color,
    this.numericValue,
    this.suffix = '',
    this.displayText,
  });

  final String label;
  final String subtitle;
  final String color;
  final int? numericValue;
  final String suffix;
  /// When set, UI shows this instead of a numeric animation.
  final String? displayText;
}

class AiUseCaseItem {
  const AiUseCaseItem({
    required this.title,
    required this.problem,
    required this.action,
    required this.outcome,
  });

  final String title;
  final String problem;
  final String action;
  final String outcome;
}

class AiWorkflowCtaContent {
  const AiWorkflowCtaContent({
    required this.headline,
    required this.lines,
    required this.primaryButtonLabel,
  });

  final String headline;
  final List<String> lines;
  final String primaryButtonLabel;
}
