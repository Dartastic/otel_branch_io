// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_branch_io_suppression.dart';

const _tracerName = 'dartastic_otel_libs_branch_io';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class BranchIoResult {
  const BranchIoResult({
    this.branchKey,
    this.linkUrl,
    this.linkAlias,
    this.linkChannel,
    this.linkCampaign,
    this.feature,
    this.sessionClickedBranchLink,
    this.isFirstSession,
    this.identityId,
    this.developerIdentity,
    this.eventName,
    this.standardEvent,
    this.revenueMinor,
    this.currencyCode,
    this.errorCode,
    this.errorMessage,
    this.statusCode,
  });

  /// Branch app key.
  final String? branchKey;

  /// Generated short link URL.
  final String? linkUrl;

  /// Custom alias for the link.
  final String? linkAlias;

  /// `email` / `paid_search` / `sms` / `social` / `referral` / app
  /// name / etc — UTM-style channel attribution.
  final String? linkChannel;

  final String? linkCampaign;

  /// `share` / `onboarding` / `referral` / `marketing` — Branch
  /// taxonomy.
  final String? feature;

  /// `true` when the current session was opened via a Branch link
  /// (vs cold start).
  final bool? sessionClickedBranchLink;

  /// `true` for the first session of a Branch install.
  final bool? isFirstSession;

  /// Branch's identity id (anonymous + post-login).
  final String? identityId;

  /// `setIdentity()` value (your end-user id).
  final String? developerIdentity;

  /// Custom or standard event name.
  final String? eventName;

  /// `true` when the event is one of Branch's standard events
  /// (PURCHASE/ADD_TO_CART/COMPLETE_REGISTRATION/SEARCH/VIEW_CONTENT
  /// /LOGIN/SHARE/etc.).
  final bool? standardEvent;

  /// Revenue in minor units (Branch supports per-event revenue).
  final int? revenueMinor;

  final String? currencyCode;

  final int? errorCode;
  final String? errorMessage;

  final int? statusCode;
}

class BranchIoCallResult<T> {
  const BranchIoCallResult({required this.value, this.result});
  final T value;
  final BranchIoResult? result;
}

/// Wraps a Branch SDK call in a CLIENT span. [operation] is one of
/// `init`, `getShortUrl`, `getLatestReferringParams`,
/// `getFirstReferringParams`, `setIdentity`, `logout`,
/// `trackContent`, `trackContentItems`, `logEvent`,
/// `requestATTransparencyTracking`, `setDMAParamsForEEA`,
/// `setRequestMetadata`.
Future<T> tracedBranchIo<T>({
  required String operation,
  required Future<BranchIoCallResult<T>> Function() invoke,
}) async {
  if (branchIoInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'branch_io',
    'rpc.method': operation,
    'branch_io.operation': operation,
  };

  final span = _tracer().startSpan(
    'branch_io $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.branchKey != null) {
        extras.add(OTel.attributeString(
          'branch_io.app.key',
          r.result!.branchKey!,
        ));
      }
      if (r.result!.linkUrl != null) {
        extras.add(OTel.attributeString(
          'branch_io.link.url',
          r.result!.linkUrl!,
        ));
      }
      if (r.result!.linkAlias != null) {
        extras.add(OTel.attributeString(
          'branch_io.link.alias',
          r.result!.linkAlias!,
        ));
      }
      if (r.result!.linkChannel != null) {
        extras.add(OTel.attributeString(
          'branch_io.link.channel',
          r.result!.linkChannel!,
        ));
      }
      if (r.result!.linkCampaign != null) {
        extras.add(OTel.attributeString(
          'branch_io.link.campaign',
          r.result!.linkCampaign!,
        ));
      }
      if (r.result!.feature != null) {
        extras.add(OTel.attributeString(
          'branch_io.link.feature',
          r.result!.feature!,
        ));
      }
      if (r.result!.sessionClickedBranchLink != null) {
        extras.add(OTel.attributeBool(
          'branch_io.session.clicked_branch_link',
          r.result!.sessionClickedBranchLink!,
        ));
      }
      if (r.result!.isFirstSession != null) {
        extras.add(OTel.attributeBool(
          'branch_io.session.is_first',
          r.result!.isFirstSession!,
        ));
      }
      if (r.result!.identityId != null) {
        extras.add(OTel.attributeString(
          'branch_io.identity.id',
          r.result!.identityId!,
        ));
      }
      if (r.result!.developerIdentity != null) {
        extras.add(OTel.attributeString(
          'branch_io.developer_identity',
          r.result!.developerIdentity!,
        ));
      }
      if (r.result!.eventName != null) {
        extras.add(OTel.attributeString(
          'branch_io.event.name',
          r.result!.eventName!,
        ));
      }
      if (r.result!.standardEvent != null) {
        extras.add(OTel.attributeBool(
          'branch_io.event.standard',
          r.result!.standardEvent!,
        ));
      }
      if (r.result!.revenueMinor != null) {
        extras.add(OTel.attributeInt(
          'branch_io.revenue.minor',
          r.result!.revenueMinor!,
        ));
      }
      if (r.result!.currencyCode != null) {
        extras.add(OTel.attributeString(
          'branch_io.currency.code',
          r.result!.currencyCode!,
        ));
      }
      if (r.result!.errorCode != null) {
        extras.add(OTel.attributeInt(
          'branch_io.error.code',
          r.result!.errorCode!,
        ));
        span.setStatus(
          SpanStatusCode.Error,
          'Branch error ${r.result!.errorCode}',
        );
      }
      if (r.result!.errorMessage != null) {
        extras.add(OTel.attributeString(
          'branch_io.error.message',
          r.result!.errorMessage!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Branch HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
