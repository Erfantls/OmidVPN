import 'package:omidvpn/api/lang/lang.dart';

class LangEN implements Lang {
  @override
  String get homeTitle => 'OmidVPN';
  @override
  String get vpnServer => 'VPN server';
  @override
  String get notSelected => 'not selected';
  @override
  String get connect => 'Connect';
  @override
  String get disconnect => 'Disonnect';
  @override
  String get selectServer => 'Select Server';

  @override
  String get serverListTitle => 'Server list';
  @override
  String get sessions => 'sessions';
  @override
  String get days => 'days';
  @override
  String get mbps => 'Mbps';
  @override
  String get areYouSureYouWantToContinue =>
      'Are you sure you want to continue?';
  @override
  String get yourCurrentSessionWillBeTerminated =>
      'Your current session will be terminated';
  @override
  String get yes => 'Yes';
  @override
  String get no => 'No';
}
