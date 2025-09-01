import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_license_manager/flutter_license_manager.dart';
import 'package:open_password_manager/shared/presentation/buttons/glyph_button.dart';
import 'package:open_password_manager/style/ui.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LicenseList extends StatefulWidget {
  final List<OssLicenseInfo> licenses;

  const LicenseList({super.key, required this.licenses});

  @override
  State<LicenseList> createState() => _LicenseListState();

  static void show(BuildContext context, {required List<OssLicenseInfo> licenses}) {
    showDialog(
      context: context,
      builder: (context) => LicenseList(licenses: licenses),
    );
  }
}

class _LicenseListState extends State<LicenseList> {
  OssLicenseInfo? selectedLicense;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            Expanded(
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child: selectedLicense != null
                    ? LicenseDetailView(
                        key: ValueKey('detail_${selectedLicense!.packageName}'),
                        license: selectedLicense!,
                        onBack: () {
                          setState(() {
                            selectedLicense = null;
                          });
                        },
                      )
                    : _buildLicenseList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseList() {
    return Column(
      key: ValueKey('list'),
      children: [
        Expanded(
          child: widget.licenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.info, size: sizeXXL),
                      SizedBox(height: sizeS),
                      Text('No licenses found', style: ShadTheme.of(context).textTheme.large),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: widget.licenses.length,
                  itemBuilder: (context, index) {
                    final license = widget.licenses[index];
                    return ListTile(
                      title: Text(
                        license.packageName,
                        style: ShadTheme.of(context).textTheme.large,
                      ),
                      subtitle: Text(
                        license.licenseCount == 1
                            ? '1 license'
                            : '${license.licenseCount} licenses',
                        style: ShadTheme.of(context).textTheme.small,
                      ),
                      trailing: Icon(LucideIcons.arrowRight, size: sizeS),
                      onTap: () {
                        setState(() {
                          selectedLicense = license;
                        });
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class LicenseDetailView extends StatelessWidget {
  final OssLicenseInfo license;
  final VoidCallback onBack;

  const LicenseDetailView({super.key, required this.license, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: sizeXS,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: sizeXS,
          children: [
            GlyphButton.ghost(onTap: onBack, icon: LucideIcons.arrowLeft),
            Text(license.packageName, style: ShadTheme.of(context).textTheme.large),
            Spacer(),
            GlyphButton.ghost(
              onTap: _copyLicenseText,
              icon: LucideIcons.copy,
              tooltip: 'Copy license text',
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildLicenseTexts(context),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildLicenseTexts(BuildContext context) {
    final widgets = <Widget>[];

    for (int i = 0; i < license.licenseTexts.length; i++) {
      widgets.add(
        ShadCard(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(license.packageName, style: ShadTheme.of(context).textTheme.large),
              Text(_getLicenseCountText(), style: ShadTheme.of(context).textTheme.small),
            ],
          ),
          width: double.infinity,
          padding: EdgeInsets.all(sizeS),
          child: Padding(
            padding: const EdgeInsets.only(top: sizeS),
            child: Text(license.licenseTexts[i], style: ShadTheme.of(context).textTheme.muted),
          ),
        ),
      );

      if (i < license.licenseTexts.length - 1) {
        widgets.add(SizedBox(height: 16));
        widgets.add(ShadSeparator.horizontal());
        widgets.add(SizedBox(height: 16));
      }
    }

    return widgets;
  }

  String _getLicenseCountText() {
    if (license.licenseCount == 1) {
      return '1 license';
    } else {
      return '${license.licenseCount} licenses';
    }
  }

  void _copyLicenseText() {
    final textToCopy = 'Package: ${license.packageName}\n\n${license.licenseTexts.join('\n\n')}';
    Clipboard.setData(ClipboardData(text: textToCopy));
  }
}
