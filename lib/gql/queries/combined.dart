/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String getLightningFinanceInfo = """
query getLightningFinanceInfo {
  lnListPayments {
    __typename
    ... on ListPaymentsSuccess {
      lnTransactionDetails {
        payments {
          paymentHash
          value
          creationDate
          path
          fee
          paymentPreimage
        }
      }
    }
    ... on ServerError {
      errorMessage
    }
  }
  lnGetChannelBalance {
    __typename
    ... on GetChannelBalanceSuccess {
      lnChannelBalance {
        balance
        pendingOpenBalance
      }
    }
    ... on ServerError {
      errorMessage
    }
  }
}

""";

String getOnchainFinanceInfo = """
query getOnchainFinanceInfo {
  lnGetTransactions {
    __typename
    ... on GetTransactionsSuccess {
      lnTransactionDetails {
        transactions {
          amount
          timeStamp
          totalFees
          destAddresses
        }
      }
    }
    ... on ServerError {
      errorMessage
    }
  }
  lnGetWalletBalance {
    __typename
    ... on GetWalletBalanceSuccess {
      lnWalletBalance {
        totalBalance
        confirmedBalance
        unconfirmedBalance
      }
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";
