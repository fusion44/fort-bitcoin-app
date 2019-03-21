/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

// A list of hop hints that when chained together can assist in reaching a specific destination.
import 'package:mobile_app/common/types/lnhophint.dart';

class LnRouteHint {
  List<LnHopHint> hopHints;

  LnRouteHint(data) {
    if (data) {
      for (var hop_hint in data) {
        hopHints.add(LnHopHint(hop_hint));
      }
    }
  }
}
