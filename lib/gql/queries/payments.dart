/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String listPayments = """
query listPayments(\$testnet: Boolean) {
  lnListPayments(testnet: \$testnet) {
    payments {
      value
      creationDate
      fee
    }
  }
}
""";

String decodePayRequest =
    """query decodePayRequest(\$testnet: Boolean, \$payReq: String!) {
  lnDecodePayReq(testnet: \$testnet, payReq: \$payReq) {
    destination
    paymentHash
    numSatoshis
    timestamp
    expiry
    description
    descriptionHash
    fallbackAddr
    cltvExpiry
    routeHints{
      hopHints{
        nodeId
        chanId
        feeBaseMsat
        feeProportionalMillionths
        cltvExpiryDelta
      }
    }
  }
}
""";

String sendPaymentForRequest = """
mutation sendPayment(\$testnet: Boolean, \$paymentRequest: String!) {
  lnSendPayment(testnet: \$testnet, paymentRequest: \$paymentRequest) {
    paymentError
    paymentPreimage
    paymentRoute{
      totalTimeLock
      totalFees
      totalAmt
      hops {
        chanId
        chanCapacity
        amtToForward
        fee
        expiry
        amtToForwardMsat
        feeMsat
      }
      totalFeesMsat
      totalAmtMsat
    }
  }
}
""";
