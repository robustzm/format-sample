// Copyright (C) 2021 Yaroslav Pronin <proninyaroslav@mail.ru>
// Copyright (C) 2021 Insurgo Inc. <insurgo@riseup.net>
//
// This file is part of LibreTrack.
//
// LibreTrack is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// LibreTrack is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with LibreTrack.  If not, see <http://www.gnu.org/licenses/>.

import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';
import 'package:libretrack/core/entity/entity.dart';
import 'package:libretrack/ui/parcel_details/parcel_details.dart';
import 'package:libretrack/ui/widget/widget.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../locale.dart';
import 'generate_barcode_dialog.dart';
import 'parcel_info.dart';

class BaseParcelInfo extends StatelessWidget {
  final ParcelInfo info;

  const BaseParcelInfo({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final lastTrackingInfo = info.trackingHistory.isEmpty
        ? null
        : info.trackingHistory.first.trackingInfo;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: _ClickableTrackNumber(info: info),
                ),
                _BarcodeGenButton(trackNumber: info.trackInfo.trackNumber),
              ],
            ),
            if (info.trackInfo.dateAdded != null)
              _ParcelDateAdded(dateAdded: info.trackInfo.dateAdded!),
            if (lastTrackingInfo != null)
              _ParcelTrackingDate(
                trackingDate: lastTrackingInfo.dateTime,
              ),
            const Divider(),
            _Status(info: info),
          ],
        ),
      ),
    );
  }
}

class _ClickableTrackNumber extends StatelessWidget {
  final ParcelInfo info;

  const _ClickableTrackNumber({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: S.of(context).copyTrackNumber,
      child: InkWell(
        borderRadius: BorderRadius.circular(4.0),
        onTap: () {
          context.read<DetailsActionsCubit>().copyTrackNumber(info);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  info.trackInfo.trackNumber,
                  style: Theme.of(context)
                      .textTheme
                      .subtitle1!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8.0),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.copy,
                  size: 15.0,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodeGenButton extends StatelessWidget {
  final String trackNumber;

  const _BarcodeGenButton({
    Key? key,
    required this.trackNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(MdiIcons.barcode),
      tooltip: S.of(context).generateBarcode,
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return GenerateBarcodeDialog(
              trackNumber: trackNumber,
            );
          },
        );
      },
    );
  }
}

class _ParcelDateAdded extends StatelessWidget {
  final DateTime dateAdded;

  const _ParcelDateAdded({
    Key? key,
    required this.dateAdded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text.rich(
        TextSpan(
          children: [
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: 8.0),
                child: Icon(MdiIcons.calendar, size: 18.0),
              ),
            ),
            TextSpan(
              text: S.of(context).trackingStartedDate(
                    Jiffy(dateAdded).yMMMdjm,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParcelTrackingDate extends StatelessWidget {
  final DateTime trackingDate;

  const _ParcelTrackingDate({
    Key? key,
    required this.trackingDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text.rich(
        TextSpan(
          children: [
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: EdgeInsetsDirectional.only(end: 8.0),
                child: Icon(Icons.refresh, size: 18.0),
              ),
            ),
            TextSpan(
              text: S.of(context).lastTrackingDate(
                    Jiffy(trackingDate).yMMMdjm,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final ParcelInfo info;

  const _Status({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RRectIconData statusIcon;
    String statusText;
    bool showActivateButton = false;

    final lastTrackingInfo = info.trackingHistory.isEmpty
        ? null
        : info.trackingHistory.first.trackingInfo;
    final lastActivity = info.activities.isEmpty ? null : info.activities.first;
    final trackServices = info.trackServices;
    final deliveryShipmentInfo = info.shipmentInfoList
        .firstWhereOrNull(
          (entry) => entry.shipmentInfo.deliveryDate != null,
        )
        ?.shipmentInfo;
    final deliveryDate = deliveryShipmentInfo?.deliveryDate;
    final signedForByName = deliveryShipmentInfo?.signedForByName;

    if (lastTrackingInfo?.status == TrackingStatus.inProgress) {
      statusIcon = const RRectIconData.widget(
        icon: CircularProgressIndicator(),
        backgroundColor: Colors.transparent,
      );
      statusText = S.of(context).parcelTrackingStatus;
    } else if (deliveryDate != null) {
      statusIcon = StatusIconsData.delivered;
      statusText = S.of(context).parcelDeliveredStatus(
            Jiffy(deliveryDate).yMMMMd,
          );
    } else if (lastTrackingInfo != null &&
        lastTrackingInfo.invalidTrackNumber) {
      statusIcon = StatusIconsData.invalidTrackNumber;
      statusText = S.of(context).invalidTrackingNumberStatus;
    } else if (trackServices.every((trackService) => !trackService.isActive)) {
      statusIcon = StatusIconsData.trackingStopped;
      statusText = S.of(context).trackingStoppedStatus;
      showActivateButton = true;
    } else if (lastActivity == null) {
      statusIcon = StatusIconsData.notAvailable;
      statusText = S.of(context).parcelInfoNotAvailableStatus;
    } else if (lastActivity.statusType == ShipmentStatusType.delivered) {
      statusIcon = StatusIconsData.delivered;
      statusText = S.of(context).parcelDeliveredStatus(
            Jiffy(lastActivity.dateTime).yMMMMd,
          );
    } else {
      statusIcon = StatusIconsData.inTransit;
      final firstActivity = info.activities.last;
      final duration = DateTime.now().difference(firstActivity.dateTime);
      statusText = S.of(context).parcelInTransitStatus(duration.inDays);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RRectIcon(iconData: statusIcon, size: 40.0),
              const SizedBox(width: 16.0),
              Flexible(
                child: Text(
                  signedForByName != null
                      ? '$statusText\n${S.of(context).parcelSignedBy(signedForByName)}'
                      : statusText,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(fontSize: 15.0),
                ),
              ),
            ],
          ),
          if (showActivateButton) const SizedBox(height: 8.0),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: showActivateButton
                ? _ActivateAndRefreshButton(info: info)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _ActivateAndRefreshButton extends StatelessWidget {
  final ParcelInfo info;

  const _ActivateAndRefreshButton({
    Key? key,
    required this.info,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await context.read<DetailsActionsCubit>().activateTracking(info);
        context.read<DetailsActionsCubit>().refresh(info);
      },
      icon: const Icon(Icons.refresh),
      label: Text(S.of(context).activateAndRefresh),
    );
  }
}
