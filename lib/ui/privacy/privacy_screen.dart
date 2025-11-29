import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:flutter/services.dart';

class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    
    final privacyText = '''
${lang.privacyPolicy}

Last Updated: ${DateTime.now().toString().split(' ').first}

1. No Data Collection
We do not collect, store, or process any personal data or usage information from users of this application.

2. No Ads
This application is completely free of advertisements. We do not display any banners, pop-ups, or promotional content.

3. No Payments
This application is completely free to use. We do not charge any fees or require any payments for accessing or using the application's features.

4. No Tracking
We do not track user activities, behaviors, or preferences. No analytics or tracking services are integrated into this application.

5. Local Processing
All application functions are processed locally on your device. No data is transmitted to external servers or third parties.

6. VPN Connection
When you connect to a VPN server, the connection is established directly between your device and the public VPN server. We do not intercept or monitor your internet traffic.

7. Open Source
This application is open source. You can review the source code to verify our privacy commitments.

8. Third-Party Services
This application uses publicly available VPN servers from vpngate.net. Please review their privacy policies for information about their data practices.

9. Changes to This Policy
We may update this privacy policy from time to time. Any changes will be posted within the application.

10. Contact Us
If you have any questions about this privacy policy, please contact us at h3dev.pira@gmail.com
''';

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.privacyPolicy),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: privacyText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Privacy policy copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          privacyText,
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
      ),
    );
  }
}