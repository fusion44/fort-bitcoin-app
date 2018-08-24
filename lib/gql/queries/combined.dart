/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String getLightningFinanceInfo = """
query getLightningFinanceInfo(\$testnet: Boolean) {
  lnListPayments(testnet: \$testnet) {
    payments {
      value
      creationDate
      fee
    }
  }
  lnGetChannelBalance(testnet: \$testnet){
    balance
    pendingOpenBalance
  }
}
""";

String getOnchainFinanceInfo = """
query getOnchainFinanceInfo(\$testnet: Boolean) {
  lnGetTransactions(testnet: \$testnet) {
    transactions {
      amount
      timeStamp
      totalFees
      destAddresses
    }
  }
  lnGetWalletBalance(testnet: \$testnet) {
    totalBalance
    confirmedBalance
    unconfirmedBalance
  }
}
""";
