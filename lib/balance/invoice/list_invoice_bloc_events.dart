/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

enum ListInvoiceEventType {
  initial,
  startLoading,
  startLoadMore,
  finishLoading,
  failLoading,
}

abstract class ListInvoiceEvent {}

class LoadInvoices extends ListInvoiceEvent {
  final bool pendingOnly;
  final int indexOffset;
  final int numMaxInvoices;
  final bool reverse;
  LoadInvoices([
    this.pendingOnly,
    this.indexOffset,
    this.numMaxInvoices,
    this.reverse,
  ]);
}
