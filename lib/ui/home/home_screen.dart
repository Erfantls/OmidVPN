import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/api/domain/entity/vpn_stage.dart';
import 'package:omidvpn/ui/about/about_screen.dart';
import 'package:omidvpn/ui/home/controller/home_controller.dart';

class HomePage extends ConsumerWidget with HomeState, HomeHandler {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(langProvider);
    final server = serverInfo(ref);
    final vpnstage = vpnStage(ref);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.homeTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 2, child: Container()),
          Expanded(
            flex: 4,
            child: Center(
              child: (server != null)
                  ? (vpnstage == VpnStage.disconnected)
                        ? SizedBox(
                            width: 150,
                            height: 150,
                            child: FilledButton(
                              onPressed: () =>
                                  connectUsecase(ref, server: server),
                              style: FilledButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(
                                Icons.power_settings_new,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : SizedBox(
                            width: 150, // Circular button
                            height: 150, // Circular button
                            child: FilledButton(
                              onPressed: () => disconnectUsecase(ref),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(30),
                              ),
                              child: Icon(
                                Icons.power_off,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          )
                  : Icon(
                      Icons.power_settings_new,
                      size: 150,
                      color: Colors.grey,
                    ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: server != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Country flag
                        (() {
                          final countryCode = server.countryShort.toLowerCase();
                          final flagAssetPath =
                              'assets/CountryFlags/$countryCode.png';
                          return Image.asset(
                            flagAssetPath,
                            width: 60,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return SizedBox.shrink();
                            },
                            fit: BoxFit.contain,
                          );
                        })(),
                        SizedBox(height: 8),
                        // Server name
                        Text(
                          server.hostName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        // Country
                        Text(
                          '${server.countryLong} (${server.countryShort})',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        // Status
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: vpnstage == VpnStage.connected
                                ? Colors.green
                                : vpnstage == VpnStage.disconnected
                                ? Colors.red
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            vpnstage.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          lang.notSelected,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Please select a server to connect',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: SizedBox(
                width: 250,
                height: 60,
                child: FilledButton.icon(
                  onPressed: () => selectServerUsecase(ref),
                  icon: Icon(Icons.list, size: 30),
                  label: Text(
                    lang.selectServer,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
