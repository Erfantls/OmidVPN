part of 'home_controller.dart';

mixin HomeState {
  ServerInfo? serverInfo(WidgetRef ref) {
    final serverInfoAsync = ref.watch(_serverInfoNotifier);
    return serverInfoAsync.maybeWhen(
      data: (serverInfo) => serverInfo,
      orElse: () => null,
    );
  }

  VpnStage vpnStage(WidgetRef ref) => ref
      .watch(vpnStageProvider)
      .maybeWhen(
        data: (VpnStage stage) => stage,
        orElse: () => VpnService.defaultVpnStage,
      );
}
