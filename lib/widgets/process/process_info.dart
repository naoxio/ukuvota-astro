/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:ukuvota/models/process.dart';
import 'package:ukuvota/utils/markdown_loader.dart';
import 'package:ukuvota/utils/proposal_utils.dart';
import 'package:ukuvota/utils/weighting_options.dart';
import 'package:ukuvota/widgets/datetime/process_time_label.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ProcessInfo extends StatelessWidget {
  final Process process;
  final bool showSharePart;
  final bool skipCompleted;

  const ProcessInfo({
    Key? key,
    required this.process,
    this.showSharePart = true,
    this.skipCompleted = false,
  }) : super(key: key);
  void _showModal(BuildContext context, String title, Widget content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final localizations = AppLocalizations.of(context)!;

        return AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.buttonClose),
            ),
          ],
        );
      },
    );
  }

  void _showQRCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text(
            AppLocalizations.of(context)!.processQrCode,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          children: [
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(
                  data: 'https://web.ukuvota.world/#/process/${process.id}',
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.circle, color: Colors.white),
                  dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.circle,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final weightLabel =
        process.weighting != null ? weightingOptions[process.weighting] : null;
    final timezone = process.timezone ?? 'UTC';
    final description = process.description ?? '';

    final proposalsLength = process.proposals?.length ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            process.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: 16),
        HtmlWidget(convertToHtml(description)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(localizations.processWeighting),
            const SizedBox(width: 8),
            Text(weightLabel ?? ''),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () {
                _showModal(
                  context,
                  localizations.processWeighting,
                  MarkdownLoader(
                    localeName: localizations.localeName,
                    fileName: 'NegativeScoreWeighting',
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!skipCompleted &&
            process.proposalDates != null &&
            process.proposalDates![0] > 0)
          ProcessTimeLabel(
            timezone: timezone,
            phase: 'proposal',
            dates: process.proposalDates!,
          ),
        if (!skipCompleted) const SizedBox(height: 8),
        if (!skipCompleted)
          ProcessTimeLabel(
            timezone: timezone,
            phase: 'voting',
            dates: process.votingDates,
            proposalsLength: proposalsLength,
          ),
        if (skipCompleted && process.votingDates.length == 2)
          ProcessTimeLabel(
            timezone: timezone,
            phase: 'completed',
            dates: process.votingDates,
          ),
        const SizedBox(height: 16),
        if (showSharePart)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(localizations.processShareableUrl),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text:
                            'https://web.ukuvota.world/#/process/${process.id}',
                      ),
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            final value =
                                'https://web.ukuvota.world/#/process/${process.id}';
                            Clipboard.setData(ClipboardData(text: value));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(localizations.linkCopied),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.qr_code),
                    onPressed: () {
                      _showQRCodeDialog(context);
                    },
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
