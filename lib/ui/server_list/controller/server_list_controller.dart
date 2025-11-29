import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/api/api.dart';
import 'package:omidvpn/api/domain/entity/server_info.dart';
import 'package:omidvpn/api/domain/entity/vpn_stage.dart';
import 'package:omidvpn/api/domain/repository/vpn_repository.dart';
import 'package:omidvpn/api/domain/repository/vpn_service.dart';
import 'package:omidvpn/ui/server_list/providers/selected_country_provider.dart';
import 'package:omidvpn/ui/server_list/widgets/disconnect_alert_dialog.dart';

part 'server_list_state.dart';
part 'server_list_handler.dart';
part 'server_list_async_notifier.dart';
