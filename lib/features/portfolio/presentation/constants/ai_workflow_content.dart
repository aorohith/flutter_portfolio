import 'package:flutter_portfolio/features/portfolio/domain/entities/portfolio_content.dart';

const AiWorkflowContent kAiWorkflowContent = AiWorkflowContent(
  sectionLabel: 'AI WORKFLOW',
  sectionTitle: 'AI-Powered Flutter Delivery',
  hero: AiWorkflowHeroContent(
    title: 'AI-Powered Flutter Developer',
    subtitle:
        'I combine Flutter expertise with disciplined AI-assisted workflows to ship faster, debug smarter, and keep architecture maintainable.',
    ctas: <AiHeroCta>[
      AiHeroCta(label: 'View workflow', target: 'workflow-pipeline'),
      AiHeroCta(label: 'Explore projects', target: 'projects'),
      AiHeroCta(label: 'Hire me', target: 'contact'),
    ],
  ),
  tools: <AiToolItem>[
    AiToolItem(
      category: 'AI',
      name: 'Claude',
      monogram: 'C',
      primaryPurpose: 'Deep reasoning, planning, and architecture notes',
      usage:
          'Co-works sessions for specs, trade-offs, and structured refactors before implementation.',
      impactTag: 'Planning',
      color: '#8B5CF6',
    ),
    AiToolItem(
      category: 'AI',
      name: 'ChatGPT',
      monogram: 'GPT',
      primaryPurpose: 'Debugging support and rapid idea exploration',
      usage:
          'Stack traces, edge-case brainstorming, and short implementation spikes with manual verification.',
      impactTag: 'Debug',
      color: '#10B981',
    ),
    AiToolItem(
      category: 'AI',
      name: 'Gemini',
      monogram: 'G',
      primaryPurpose: 'Research and multimodal workflows',
      usage:
          'Docs synthesis, API research, and comparing integration options for Flutter plugins and backends.',
      impactTag: 'Research',
      color: '#06B6D4',
    ),
    AiToolItem(
      category: 'AI',
      name: 'Google AI Studio',
      monogram: 'AI',
      primaryPurpose: 'Model experiments and prototyping',
      usage:
          'Quick prompts and structured outputs for UI copy drafts and data-shape exploration.',
      impactTag: 'Build',
      color: '#4F6EF7',
    ),
    AiToolItem(
      category: 'AI',
      name: 'OpenClaw',
      monogram: 'OC',
      primaryPurpose: 'Automation and agent-style tasks',
      usage:
          'Scripting and workflow glue where it saves time without bypassing code review.',
      impactTag: 'Build',
      color: '#F59E0B',
    ),
    AiToolItem(
      category: 'Development',
      name: 'Cursor',
      monogram: 'Cu',
      primaryPurpose: 'AI coding agent in the editor',
      usage:
          'Refactors, multi-file edits, and test scaffolding with strict review before merge.',
      impactTag: 'Build',
      color: '#4F6EF7',
    ),
    AiToolItem(
      category: 'Development',
      name: 'VS Code',
      monogram: 'VS',
      primaryPurpose: 'Primary editor for focused Dart work',
      usage:
          'Debugging, extensions, and team-friendly workflows alongside AI tooling.',
      impactTag: 'Build',
      color: '#06B6D4',
    ),
    AiToolItem(
      category: 'Development',
      name: 'Accio IDE',
      monogram: 'A',
      primaryPurpose: 'Alternate IDE for experimentation',
      usage:
          'Trying new AI-assisted flows while keeping Flutter analyzer feedback authoritative.',
      impactTag: 'Build',
      color: '#8B5CF6',
    ),
    AiToolItem(
      category: 'Development',
      name: 'Antigravity',
      monogram: 'An',
      primaryPurpose: 'Exploratory builds and spikes',
      usage:
          'Rapid UI drafts and throwaway prototypes that later land in production Flutter after cleanup.',
      impactTag: 'Build',
      color: '#10B981',
    ),
  ],
  pipeline: <AiPipelineStageItem>[
    AiPipelineStageItem(
      title: 'Idea',
      description:
          'Capture intent, constraints, and success criteria before touching code.',
      tools: <String>['Claude', 'ChatGPT'],
    ),
    AiPipelineStageItem(
      title: 'Requirement analysis',
      description:
          'Break down flows, edge cases, and integration risks with written acceptance notes.',
      tools: <String>['Claude', 'Gemini'],
    ),
    AiPipelineStageItem(
      title: 'UI planning',
      description:
          'Wire-level thinking, component boundaries, and theme tokens aligned to Flutter layout.',
      tools: <String>['Claude', 'Cursor', 'Figma'],
    ),
    AiPipelineStageItem(
      title: 'Flutter development',
      description:
          'Implement features with immutable state patterns, const where possible, and analyzer-clean builds.',
      tools: <String>['Cursor', 'VS Code', 'Accio IDE'],
    ),
    AiPipelineStageItem(
      title: 'Refactor',
      description:
          'Tighten architecture, remove duplication, and keep modules testable.',
      tools: <String>['Cursor', 'Claude', 'ChatGPT'],
    ),
    AiPipelineStageItem(
      title: 'Testing',
      description:
          'Widget and integration checks for regressions; manual QA on devices.',
      tools: <String>['VS Code', 'Cursor'],
    ),
    AiPipelineStageItem(
      title: 'Launch',
      description: 'Release hygiene, flavours, and CI-friendly handoff.',
      tools: <String>['CodeMagic', 'GitHub'],
    ),
  ],
  productivitySignals: <AiProductivitySignalItem>[
    AiProductivitySignalItem(
      label: 'Faster delivery cycles',
      subtitle:
          'Compared to my pre-AI baseline on similar spikes (internal estimate; varies by task).',
      color: '#4F6EF7',
      displayText: 'High',
    ),
    AiProductivitySignalItem(
      label: 'Debug turnaround',
      subtitle: 'Structured root-cause notes before code changes.',
      color: '#8B5CF6',
      displayText: 'Strong',
    ),
    AiProductivitySignalItem(
      label: 'Prototype speed',
      subtitle: 'UI and module spikes to de-risk unknowns early.',
      color: '#06B6D4',
      displayText: 'Strong',
    ),
    AiProductivitySignalItem(
      label: 'Rework reduction',
      subtitle: 'Architecture-first decisions and review before merge.',
      color: '#10B981',
      numericValue: 60,
      suffix: '%',
    ),
  ],
  recruiterBullets: <String>[
    'Faster onboarding: specs, diagrams, and written decisions arrive before the first PR.',
    'Ownership: I integrate AI output but remain accountable for correctness, security, and reviews.',
    'Throughput on repetitive work: boilerplate, refactors, and test scaffolding - always manually verified.',
    'Modern toolchain without hype-chasing: tools chosen for measurable workflow gains.',
    'Quality with speed: architecture and tests first, acceleration second.',
    'Learning velocity: research workflows compress unknown-unknowns into actionable next steps.',
    'Fewer bottlenecks: parallel exploration (docs, APIs, UI) while keeping shipping discipline.',
  ],
  useCases: <AiUseCaseItem>[
    AiUseCaseItem(
      title: 'Faster Flutter modules',
      problem: 'Tight timelines across multiple flavoured apps.',
      action:
          'Pair programming workflow with AI for scaffolding, then hardening with tests and review.',
      outcome: 'Repeatable module patterns without sacrificing analyzer cleanliness.',
    ),
    AiUseCaseItem(
      title: 'Refactors that stick',
      problem: 'Large legacy areas with unclear dependencies.',
      action:
          'Map dependencies with AI-assisted notes, then incremental refactors with CI-friendly steps.',
      outcome: 'Safer merges and easier reviews for teammates.',
    ),
    AiUseCaseItem(
      title: 'Complex bugs',
      problem: 'Intermittent issues across devices and backends.',
      action:
          'Reproduce, log hypotheses, use AI for trace analysis - validate against real telemetry.',
      outcome: 'Shorter mean-time-to-diagnosis on non-trivial defects.',
    ),
    AiUseCaseItem(
      title: 'Architecture decisions',
      problem: 'Choosing between state management and data-layer patterns.',
      action:
          'Decision matrix with pros/cons, then Flutter-specific validation against app constraints.',
      outcome: 'Documented rationale the team can reuse.',
    ),
    AiUseCaseItem(
      title: 'Reusable widgets',
      problem: 'Duplicated UI across flavours.',
      action:
          'Extract design tokens and widgets with AI drafting, then unify APIs manually.',
      outcome: 'Consistent UX with less drift between branded builds.',
    ),
    AiUseCaseItem(
      title: 'Iteration cycles',
      problem: 'Feedback loops with stakeholders.',
      action:
          'Rapid UI drafts and copy iterations, converging on shippable Flutter code after review.',
      outcome: 'Earlier alignment and fewer late surprises.',
    ),
  ],
  ethicsHeadline: 'How I use AI (responsibly)',
  ethicsPoints: <String>[
    'AI augments planning, exploration, and drafts - it never replaces Dart and Flutter fundamentals.',
    'Every generated snippet is reviewed, tested for edge cases, and aligned with team standards.',
    'No secrets in prompts; no unchecked paste into production paths.',
    'Maintainability first: readable structure, clean architecture, and reviews over shortcut velocity.',
  ],
  portfolioAttribution:
      'This portfolio\'s design direction was developed with Claude; implementation and iteration were done in Cursor - including this AI workflow section.',
  badges: <String>[
    'AI-enabled developer',
    'Flutter specialist',
    'Fast learner',
    'Modern workflow engineer',
    'Builder mindset',
    'Productivity driven',
  ],
  cta: AiWorkflowCtaContent(
    headline: 'Let\'s build together',
    lines: <String>[
      'Hire for Flutter projects',
      'Open to full-time roles',
      'Available for freelance engagements',
    ],
    primaryButtonLabel: 'Hire me',
  ),
);
