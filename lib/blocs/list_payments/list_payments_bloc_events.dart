/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

enum ListPaymentsEventType {
  initial,
  startLoading,
  startLoadMore,
  finishLoading,
  failLoading,
}

abstract class ListPaymentsEvent {}

class LoadPayments extends ListPaymentsEvent {
  final bool pendingOnly;
  final int indexOffset;
  final int numMaxPayments;
  final bool reverse;
  LoadPayments(
      [this.pendingOnly, this.indexOffset, this.numMaxPayments, this.reverse]);
}
