/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String openChannelSubscription = """
subscription OpenChannelSub(\$nodePubkey: String, \$localFundingAmount: Int, \$pushSat: Int, 
\$targetConf: Int, \$satPerByte: Int, \$private: Boolean, \$minHtlcMsat: Int, 
\$remoteCsvDelay: Int, \$minConfs: Int, \$spendUnconfirmed: Boolean) {
  openChannelSubscription(nodePubkey: \$nodePubkey, localFundingAmount: \$localFundingAmount, 
  pushSat: \$pushSat, targetConf: \$targetConf, satPerByte: \$satPerByte, private: \$private, 
  minHtlcMsat: \$minHtlcMsat, remoteCsvDelay: \$remoteCsvDelay, minConfs: \$minConfs, spendUnconfirmed: \$spendUnconfirmed) {
    __typename
    ... on ChannelPendingUpdate {
      channelPoint {
        fundingTxid
        outputIndex
      }
    }
    ... on ChannelConfirmationUpdate {
      blockSha
      blockHeight
      numConfsLeft
    }
    ... on ChannelOpenUpdate {
      channelPoint {
        fundingTxid
        outputIndex
      }
    }
    ... on OpenChannelError {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";
