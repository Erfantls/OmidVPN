import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LicenseScreen extends ConsumerStatefulWidget {
  final VoidCallback onLicenseValidated;
  final bool isEditing;

  const LicenseScreen({
    super.key,
    required this.onLicenseValidated,
    this.isEditing = false,
  });

  @override
  ConsumerState<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends ConsumerState<LicenseScreen> {
  final TextEditingController _licenseController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkExistingLicense();
  }

  Future<void> _checkExistingLicense() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLicense = prefs.getString('premium_license_key');

    if (storedLicense != null && storedLicense.isNotEmpty) {
      // Only auto-validate if we're not in editing mode
      if (!widget.isEditing) {
        final isValid = await _validateLicense(storedLicense);
        if (isValid) {
          widget.onLicenseValidated();
        }
      } else {
        setState(() {
          _licenseController.text = storedLicense;
        });
      }
    }
  }

  Future<bool> _validateLicense(String licenseKey) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Make HTTP request to validate the license
      final response = await http.get(
        Uri.parse(
          'https://raw.githubusercontent.com/code3-dev/omidvpn-api/refs/heads/master/api/$licenseKey/index.json',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Parse the response to ensure it's valid JSON
        final data = json.decode(response.body);
        if (data != null) {
          // Save the valid license
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('premium_license_key', licenseKey);
          return true;
        }
      }

      setState(() {
        _errorMessage = 'Invalid license key or server error';
      });
      return false;
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: ${e.toString()}';
      });
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onSubmitLicense() async {
    final licenseKey = _licenseController.text.trim();

    if (licenseKey.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a license key';
      });
      return;
    }

    final isValid = await _validateLicense(licenseKey);
    if (isValid) {
      widget.onLicenseValidated();
    }
  }

  Future<void> _onContinueWithoutLicense() async {
    // Show confirmation dialog
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Continue Without License'),
          content: Text(
            'You will only see free servers. You can add a license later from the settings page.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Continue'),
            ),
          ],
        );
      },
    );

    if (shouldContinue == true) {
      // Save preference to storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('continue_without_license', true);

      // Notify the parent that we're proceeding without license
      widget.onLicenseValidated();
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open link: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(langProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('OmidVPN License'),
        automaticallyImplyLeading:
            !widget.isEditing,
        leading: widget.isEditing
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/icon.png',
              width: 100,
              height: 100,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.blue,
                );
              },
            ),
            SizedBox(height: 20),

            // App name
            Text(
              'OmidVPN Premium',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Description
            Text(
              'Enter your license key to unlock premium servers',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 5),

            // License note - updated to reflect 90-day renewal
            Text(
              'License must be renewed every 90 days',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 15),

            // License input field
            TextField(
              controller: _licenseController,
              decoration: InputDecoration(
                labelText: 'License Key',
                hintText: 'Enter your license key',
                border: OutlineInputBorder(),
                errorText: _errorMessage.isEmpty ? null : _errorMessage,
              ),
              enabled: !_isLoading,
            ),
            SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _onSubmitLicense,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Validate License', style: TextStyle(fontSize: 16)),
              ),
            ),
            if (!widget.isEditing) ...[
              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _onContinueWithoutLicense,
                  child: Text(
                    'Continue Without License',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
            SizedBox(height: 20),

            // Get license info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get Your License:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ListTile(
                      leading: Icon(Icons.telegram),
                      title: Text('Telegram'),
                      subtitle: Text('h3dev'),
                      onTap: () {
                        _launchUrl('https://t.me/h3dev');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text('Instagram'),
                      subtitle: Text('h3dev.pira'),
                      onTap: () {
                        _launchUrl('https://instagram.com/h3dev.pira');
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.rocket),
                      title: Text('X (Twitter)'),
                      subtitle: Text('albert_com32388'),
                      onTap: () {
                        _launchUrl('https://x.com/albert_com32388');
                      },
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),

            // Copyright
            Text(
              '© ${DateTime.now().year} Hossein Pira. All rights reserved.',
              style: TextStyle(
                fontSize: 12,
                color:
                    Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6) ??
                    Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }
}
