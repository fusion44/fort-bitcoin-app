/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String addInvoice = """
mutation addInvoice(\$value: Int!, \$memo: String) {
  lnAddInvoice(value: \$value, memo: \$memo) {
    result {
      __typename
      ... on AddInvoiceSuccess {
        invoice {
          rHash
          paymentRequest
          addIndex
        }
      }
      ... on ServerError {
        errorMessage
      }
      ... on AddInvoiceError {
        paymentError
      }
    }
  }
}
""";

String invoiceSubscription = """
subscription InvoicesSubscription {
  invoiceSubscription {
    __typename
    ... on InvoiceSubSuccess {
      invoice {
        memo
        receipt
        rPreimage
        rHash
        value
        settled
        creationDate
        settleDate
        paymentRequest
        descriptionHash
        expiry
        fallbackAddr
        cltvExpiry
        private
        addIndex
        settleIndex
        amtPaid
      }
    }
    ... on InvoiceSubError {
      paymentError
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";

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

String decodePayRequest = """query decodePayReq(\$payReq: String!) {
  lnDecodePayReq(payReq: \$payReq) {
    __typename
    ... on DecodePayReqSuccess {
      lnTransactionDetails {
        destination
        paymentHash
        numSatoshis
        timestamp
        expiry
        description
        descriptionHash
        fallbackAddr
        cltvExpiry
      }
    }
    ... on ServerError{
      errorMessage
    }
  }
}
""";

String sendPaymentForRequest = """
mutation sendPayment(\$payReq: String!) {
  lnSendPayment(paymentRequest: \$payReq) {
    paymentResult {
      __typename
      ... on SendPaymentSuccess {
        paymentPreimage
        paymentRoute {
          totalTimeLock
          totalFees
          totalAmt
          totalFeesMsat
          totalAmtMsat
          hops {
            chanId
            chanCapacity
            amtToForward
            fee
            expiry
            amtToForwardMsat
            feeMsat
          }
        }
      }
      ... on SendPaymentError {
        paymentError
      }
      ... on ServerError {
        errorMessage
      }
    }
  }
}
""";
