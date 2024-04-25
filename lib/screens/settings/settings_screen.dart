import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ukuvota/widgets/language_switcher.dart';
import 'package:ukuvota/widgets/layout/main_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return CustomScaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.settingsTitle,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(localizations.settingsLanguage),
                  trailing: const LanguageSwitcher(),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: Text(localizations.settingsNotifications),
                  value: true,
                  onChanged: (value) {
                    // Handle notifications toggle
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(localizations.settingsPrivacy),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to privacy settings
                  },
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(localizations.settingsAbout),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to about screen
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
