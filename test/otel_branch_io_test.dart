// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_branch_io/otel_branch_io.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_branch_io-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('init session records first-session + clicked', () async {
    await tracedBranchIo<String>(
      operation: 'init',
      invoke: () async => const BranchIoCallResult(
        value: 'ok',
        result: BranchIoResult(
          sessionClickedBranchLink: true,
          isFirstSession: true,
          linkChannel: 'paid_search',
          linkCampaign: 'spring_2026',
          feature: 'onboarding',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('branch_io init')!);
    expect(a['branch_io.session.clicked_branch_link'], true);
    expect(a['branch_io.session.is_first'], true);
    expect(a['branch_io.link.channel'], 'paid_search');
  });

  test('logEvent records standard event + revenue', () async {
    await tracedBranchIo<String>(
      operation: 'logEvent',
      invoke: () async => const BranchIoCallResult(
        value: 'ok',
        result: BranchIoResult(
          eventName: 'PURCHASE',
          standardEvent: true,
          revenueMinor: 4999,
          currencyCode: 'USD',
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('branch_io logEvent')!);
    expect(a['branch_io.event.standard'], true);
    expect(a['branch_io.revenue.minor'], 4999);
  });

  test('error sets span error', () async {
    await tracedBranchIo<String>(
      operation: 'getShortUrl',
      invoke: () async => const BranchIoCallResult(
        value: 'ok',
        result: BranchIoResult(
          errorCode: -1,
          errorMessage: 'No internet connection',
        ),
      ),
    );
    expect(
      spans.findSpanByName('branch_io getShortUrl')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutBranchIoInstrumentationAsync(() async {
      await tracedBranchIo<String>(
        operation: 'setIdentity',
        invoke: () async => const BranchIoCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('branch_io '), isEmpty);
  });
}
