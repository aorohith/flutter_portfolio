import 'package:flutter/material.dart';

/// A run of text, optionally a link.
class Seg {
  const Seg(this.text, {this.url});

  final String text;
  final String? url;
}

class RailItem {
  const RailItem(this.label, this.value);

  final String label;
  final List<Seg> value;
}

class Fact {
  const Fact(this.label, this.text);

  final String label;
  final String text;
}

class PipelineStep {
  const PipelineStep(this.title, this.caption);

  final String title;
  final String caption;
}

class CaseStudy {
  const CaseStudy({
    required this.title,
    required this.tagline,
    required this.rail,
    required this.facts,
    required this.decisions,
    this.pipelineLabel,
    this.pipeline = const <PipelineStep>[],
  });

  final String title;
  final String tagline;
  final List<RailItem> rail;
  final List<Fact> facts;
  final List<String> decisions;
  final String? pipelineLabel;
  final List<PipelineStep> pipeline;
}

class SmallProject {
  const SmallProject(this.title, this.kind, this.description);

  final String title;
  final String kind;
  final List<Seg> description;
}

class Capability {
  const Capability(this.title, this.tags);

  final String title;
  final List<String> tags;
}

class ServiceItem {
  const ServiceItem(this.kind, this.title, this.description);

  final String kind;
  final String title;
  final String description;
}

class EduRow {
  const EduRow(this.period, this.text);

  final String period;
  final String text;
}

/// One fictional white-label college shown inside the hero phone.
class DemoFlavour {
  const DemoFlavour({
    required this.id,
    required this.crest,
    required this.name,
    required this.liveTag,
    required this.liveSoon,
    required this.liveTitle,
    required this.liveMeta,
    required this.liveCta,
    required this.tiles,
    required this.list,
    required this.nav,
    required this.modules,
    required this.bg,
    required this.fg,
    required this.primary,
    required this.soft,
  });

  final String id;
  final String crest;
  final String name;
  final String liveTag;
  final bool liveSoon;
  final String liveTitle;
  final String liveMeta;
  final String liveCta;
  final List<String> tiles;
  final List<(String, String)> list;
  final List<String> nav;
  final String modules;
  final Color bg;
  final Color fg;
  final Color primary;
  final Color soft;

  String get label => 'Demo ${id.toUpperCase()}';
  String get flavourName => 'demo_$id';
  String get packageId => 'com.example.demo_$id';
}

abstract final class SheetContent {
  static const String name = 'Rohith A O';
  static const String email = 'rohithao.dev@gmail.com';
  static const String github = 'https://github.com/aorohith';
  static const String linkedin = 'https://www.linkedin.com/in/aorohith';
  static const String resume =
      'https://drive.google.com/file/d/1kletRdUd-Y-XhEvRm8Pa5gbSJ0NxGz4Z/view?usp=sharing';

  static const String kicker = 'Senior Flutter developer · Kerala, India';
  static const String lede =
      'I take Flutter apps from architecture to store release, and I keep one codebase shipping many apps.';
  static const String availability =
      'Open to full-time roles (remote, hybrid, on-site) and freelance work';

  static const List<(int, String, String)> stats = <(int, String, String)>[
    (49, '', 'production apps shipped'),
    (45, '', 'college apps from one codebase'),
    (4, '+', 'years of Flutter'),
  ];

  static const List<DemoFlavour> flavours = <DemoFlavour>[
    DemoFlavour(
      id: 'a',
      crest: 'DIT',
      name: 'Demo Institute of Technology',
      liveTag: 'Live webinar',
      liveSoon: false,
      liveTitle: 'Placement orientation',
      liveMeta: 'Today at 10:00 AM · in app',
      liveCta: 'Join',
      tiles: <String>['Timetable', 'Assignments'],
      list: <(String, String)>[
        ('Notice board', 'Today'),
        ('Lab schedule', 'New'),
        ('Fee details', 'View'),
      ],
      nav: <String>['Home', 'Classes', 'Chat', 'Profile'],
      modules: 'webinars, timetable, fees',
      bg: Color(0xFFF4F7FB),
      fg: Color(0xFF0F2230),
      primary: Color(0xFF1E5E8C),
      soft: Color(0xFFDCE8F2),
    ),
    DemoFlavour(
      id: 'b',
      crest: 'DAS',
      name: 'Demo Arts and Science College',
      liveTag: 'Live lecture',
      liveSoon: false,
      liveTitle: 'Guest lecture: Modern poetry',
      liveMeta: 'Today at 2:30 PM · in app',
      liveCta: 'Join',
      tiles: <String>['Attendance', 'Library'],
      list: <(String, String)>[
        ('Exam results', 'Out'),
        ('Campus events', '2 new'),
        ('Hostel notices', 'View'),
      ],
      nav: <String>['Home', 'Library', 'Events', 'Profile'],
      modules: 'lectures, library, events',
      bg: Color(0xFFF2F7F3),
      fg: Color(0xFF12261A),
      primary: Color(0xFF2B7A4B),
      soft: Color(0xFFD8EBDF),
    ),
    DemoFlavour(
      id: 'c',
      crest: 'DSN',
      name: 'Demo School of Nursing',
      liveTag: 'Upcoming',
      liveSoon: true,
      liveTitle: 'Clinical skills workshop',
      liveMeta: 'Tomorrow at 11:00 AM',
      liveCta: 'Remind me',
      tiles: <String>['Clinical log', 'Study notes'],
      list: <(String, String)>[
        ('Duty roster', 'This week'),
        ('Announcements', '3 new'),
        ('Fee details', 'View'),
      ],
      nav: <String>['Home', 'Roster', 'Notes', 'Profile'],
      modules: 'workshops, roster, notes',
      bg: Color(0xFFF8F3FA),
      fg: Color(0xFF261230),
      primary: Color(0xFF84399C),
      soft: Color(0xFFEADCF0),
    ),
  ];

  static const String stamp = '45 flavours · 1 codebase';
  static const String demoNote =
      'Three fictional colleges, one codebase: each flavour sets its own theme, modules and content. Not real college apps.';

  static const String workLead =
      'Three case studies, then two smaller apps, all shipped at BOSC Tech Labs. App screens are not shown to respect client privacy; store links open the live apps.';

  static const List<CaseStudy> cases = <CaseStudy>[
    CaseStudy(
      title: 'BSmart',
      tagline:
          'A white-label EdTech platform for colleges, on Android, iOS and the web.',
      rail: <RailItem>[
        RailItem('Role', <Seg>[Seg('Sole Flutter developer')]),
        RailItem('Stack', <Seg>[
          Seg('Flutter, Dart, flavours, MVVM, Firebase, Hasura'),
        ]),
        RailItem('Platforms', <Seg>[Seg('Android, iOS, Web / PWA')]),
        RailItem('Status', <Seg>[
          Seg('In production: 45 college apps and 4 standalone apps'),
        ]),
        RailItem('Samples', <Seg>[
          Seg(
            'NSBTA',
            url:
                'https://play.google.com/store/apps/details?id=in.bslearning.nsbta',
          ),
          Seg(', '),
          Seg(
            'SCMSA',
            url:
                'https://play.google.com/store/apps/details?id=in.bslearning.scmsa',
          ),
          Seg(' on Google Play'),
        ]),
      ],
      facts: <Fact>[
        Fact(
          'Problem',
          'Every new college needed its own app, and onboarding each one by hand did not scale.',
        ),
        Fact(
          'Constraint',
          'One Flutter developer, 45 customised college apps, one codebase, all released to the stores.',
        ),
      ],
      pipelineLabel: 'How a new college app gets built',
      pipeline: <PipelineStep>[
        PipelineStep('Package IDs', 'list of new colleges'),
        PipelineStep('Script', 'generates the apps'),
        PipelineStep('1 codebase', 'Flutter flavours'),
        PipelineStep('Codemagic', 'Android and iOS'),
        PipelineStep('Stores', '45 college apps'),
      ],
      decisions: <String>[
        'Wrote a script that generates new college apps from a list of package IDs, so onboarding became a repeatable, scripted step.',
        'Set up Codemagic CI/CD for Android and iOS releases so the release process scaled as more colleges were added.',
        'Integrated the Zoom Meeting SDK with custom deep links, built without Firebase, to run webinars and virtual events inside the app.',
        'Added Flutter Web and PWA support, extending access to desktop and mobile browsers.',
        'Manage the central admin system for settings, themes and user permissions across all college apps.',
        'Structured the app on MVVM and verified stability with UI tests.',
      ],
    ),
    CaseStudy(
      title: 'Business Standard',
      tagline: 'A national news app moved from native code to Flutter.',
      rail: <RailItem>[
        RailItem('Role', <Seg>[Seg('Flutter developer')]),
        RailItem('Stack', <Seg>[
          Seg(
            'Flutter, BLoC, Google News Toolkit, Very Good Ventures architecture',
          ),
        ]),
        RailItem('Platforms', <Seg>[Seg('Android, iOS')]),
        RailItem('Status', <Seg>[
          Seg('Live. '),
          Seg(
            'Google Play',
            url:
                'https://play.google.com/store/apps/details?id=com.businessstandard.bs',
          ),
        ]),
      ],
      facts: <Fact>[
        Fact(
          'Problem',
          'The app lived in separate native Android and iOS codebases.',
        ),
        Fact('Result', 'One Flutter codebase, now live.'),
      ],
      decisions: <String>[
        'Migrated the app from separate native codebases to a single Flutter codebase.',
        'Built a modular architecture using Google News Toolkit and Very Good Ventures principles.',
        'Used BLoC for state management, with clean separation of concerns across features.',
        'Delivered features with a focus on performance, modularity and maintainability.',
      ],
    ),
    CaseStudy(
      title: 'Claw Crazy',
      tagline: 'A real-time remote gaming app with live video.',
      rail: <RailItem>[
        RailItem('Role', <Seg>[Seg('Flutter developer')]),
        RailItem('Stack', <Seg>[
          Seg('Flutter, Firebase, live video, Hasura GraphQL'),
        ]),
        RailItem('Client', <Seg>[Seg('Australia')]),
        RailItem('Status', <Seg>[Seg('Live, available in Australia only')]),
      ],
      facts: <Fact>[
        Fact(
          'Problem',
          'Players drop coins remotely and watch the result live, so the game has to stay stable on real devices and networks.',
        ),
        Fact(
          'Constraint',
          "The client's backend requirements changed mid-project.",
        ),
      ],
      decisions: <String>[
        'Built real-time gameplay on Firebase: players drop coins onto a coin mountain and win the matching amount.',
        'Integrated live video streaming so players watch the game as it happens.',
        'Added Hasura with GraphQL mid-project to meet the new client backend requirements.',
        'Tested across devices and network conditions for stable gameplay.',
      ],
    ),
  ];

  static const List<SmallProject> smallProjects = <SmallProject>[
    SmallProject('Hire That', 'Rental marketplace', <Seg>[
      Seg(
        'A rental marketplace with item discovery and a booking flow, built on Firebase Authentication, Realtime Database and Cloud Storage, with GetX for state management. Released on the Play Store.',
      ),
    ]),
    SmallProject('Coin Toss', 'Customisable coin-flip app', <Seg>[
      Seg(
        'Ships new themes and country-specific coin packs through Firebase Remote Config and Storage with no store release, and earns through Facebook Ads. ',
      ),
      Seg(
        'Google Play',
        url: 'https://play.google.com/store/apps/details?id=com.bosc.cointoss',
      ),
    ]),
  ];

  static const List<Capability> capabilities = <Capability>[
    Capability('Architecture and state', <String>[
      'BLoC',
      'GetX',
      'MVVM',
      'Very Good Ventures modular architecture',
    ]),
    Capability('Release', <String>[
      'Codemagic CI/CD',
      'Android and iOS store releases',
      'App-generation scripts',
    ]),
    Capability('Backend', <String>[
      'Firebase Auth',
      'Realtime Database',
      'Cloud Storage',
      'Remote Config',
      'Hasura',
      'GraphQL',
      'REST APIs',
    ]),
    Capability('Platforms', <String>[
      'Flutter',
      'Dart',
      'Android',
      'iOS',
      'Flutter flavours',
      'Flutter Web / PWA',
      'Google News Toolkit',
    ]),
    Capability('Integrations', <String>[
      'Zoom Meeting SDK',
      'Custom deep links',
      'Live video streaming',
      'Facebook Ads',
    ]),
    Capability('Tools', <String>[
      'Git',
      'GitHub',
      'Bitbucket',
      'Figma',
      'Postman',
      'Cursor',
      'Windsurf',
    ]),
    Capability('Also familiar with', <String>[
      'Native iOS',
      'React JS',
      'Python',
      'FlutterFlow',
    ]),
  ];

  static const String aboutBig =
      'I build high-performance Flutter apps for education, gaming and utility products.';
  static const List<String> aboutBody = <String>[
    'I ship scalable releases with flavours, Firebase and disciplined delivery practices. I am at my best on products that need strong backend integration, release automation and a delivery workflow that keeps working as the product grows.',
    'Since August 2022 I have worked at BOSC Tech Labs, where I am the sole Flutter developer on BSmart. Before that I trained in Flutter at Brototype, Ernakulam.',
  ];
  static const String portraitCaption = 'Rohith A O · Kerala, India';

  static const String servicesLead =
      'Available for full-time roles, freelance projects and collaborations.';
  static const List<ServiceItem> services = <ServiceItem>[
    ServiceItem(
      'Apps',
      'Flutter app development',
      'Production-ready Flutter apps for Android, iOS and Web / PWA with a scalable architecture.',
    ),
    ServiceItem(
      'White-label',
      'Multi-flavour app setup',
      'Flutter flavour setup for large white-label rollouts and their release pipelines.',
    ),
    ServiceItem(
      'Backend',
      'Firebase integration',
      'Authentication, realtime data, storage, remote config and custom backend workflows.',
    ),
    ServiceItem(
      'Release',
      'Release automation',
      'Codemagic and workflow automation for repeatable, faster Android and iOS releases.',
    ),
    ServiceItem(
      'Integrations',
      'SDK and API integration',
      'Third-party SDKs and APIs, including the Zoom Meeting SDK and GraphQL services.',
    ),
    ServiceItem(
      'Quality',
      'Performance and stability',
      'Optimisation, bug fixing and quality improvements backed by structured testing.',
    ),
  ];

  static const String contactAvailability =
      'Open to full-time roles, freelance projects and collaborations. I reply within 24 hours.';

  static const String jobPeriod = 'Aug 2022 to present';
  static const String jobTitle = 'Senior Software Developer';
  static const String jobBody =
      'BOSC Tech Labs Private Limited, Gujarat, India (remote). Sole Flutter developer on BSmart. Flutter developer on Business Standard, Claw Crazy, Hire That and Coin Toss.';

  static const List<EduRow> education = <EduRow>[
    EduRow(
      '2013 to 2017',
      'B.Tech, Computer Science, College of Engineering Kallooppara (CUSAT). Course completed 2017.',
    ),
    EduRow(
      'Jan to Jul 2022',
      'Mobile App Development using Flutter, Brototype, Ernakulam.',
    ),
  ];

  static const String contactTitle = 'Hiring for Flutter? Write to me.';
  static const String footerLeft = '© Rohith A O · Kerala, India';
}
