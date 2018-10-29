/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

String getInfoQuery = """
{
  lnGetInfo {
    __typename
    ... on GetInfoSuccess {
      lnInfo {
        identityPubkey
        alias
        numPendingChannels
        numActiveChannels
        numPeers
        blockHeight
        blockHash
        syncedToChain
        testnet
        bestHeaderTimestamp
        version
      }
    }
    ... on ServerError{ 
      errorMessage
    }
  }
}
""";

String getSystemStatus = """
query getBlocks {
  systemstatus: getSystemStatus {
    uptime
    cpuLoad
    trafficIn
    trafficOut
    memoryUsed
    memoryTotal
  }
  testnetblocks: getBlockchainInfo(testnet: true) {
    blocks
  }
  mainnetblocks: getBlockchainInfo(testnet: false) {
    blocks
  }
  testnetnetwork: getNetworkInfo(testnet: true) {
    subversion
    connections
    warnings
  }
  mainnetnetwork: getNetworkInfo(testnet: false) {
    subversion
    connections
    warnings
  }
  testnetln: lnGetInfo(testnet: true) {
    alias
    blockHeight
    identityPubkey
    numActiveChannels
    numPeers
    syncedToChain
    testnet
    version
  }
  mainnetln: lnGetInfo(testnet: false) {
    alias
    blockHeight
    identityPubkey
    numActiveChannels
    numPeers
    syncedToChain
    testnet
    version
  }
}
""";

String listChannelsQuery = """
{
  lnListChannels {
    __typename
    ... on ListChannelsSuccess {
      channels {
        active
        remotePubkey
        channelPoint
        chanId
        capacity
        localBalance
        remoteBalance
        commitFee
        commitWeight
        feePerKw
        unsettledBalance
        totalSatoshisSent
        totalSatoshisReceived
        numUpdates
        csvDelay
        private
        pendingHtlcs {
          incoming
          amount
          hashLock
          expirationHeight
        }
      }
    }
    ... on ListChannelsError {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";

String listPeersQuery = """
{
  lnListPeers {
    __typename
    ... on ListPeersSuccess {
      peers {
        hasChannel
        pubKey
        address
        bytesSent
        bytesRecv
        satSent
        satRecv
        inbound
        pingTime
      }
    }
    ... on ListPeersError {
      errorMessage
    }
    ... on ServerError {
      errorMessage
    }
  }
}
""";

String startDaemon = """
mutation sd(\$walletPassword: String!) {
  startDaemon(walletPassword: \$walletPassword) {
    __typename
    ... on StartDaemonSuccess {
      info {
        identityPubkey
        alias
        numPendingChannels
        numActiveChannels
        numPeers
        blockHeight
        blockHash
        syncedToChain
        testnet
        chains
        uris
        bestHeaderTimestamp
        version
      }
    }
    ... on ServerError {
      errorMessage
    }
    ... on StartDaemonInstanceIsAlreadyRunning {
      errorMessage
      suggestions
    }
  }
}
""";

String stopDaemon = """
mutation StopDaemon {
  lnStopDaemon {
    __typename
    ... on ServerError {
      errorMessage
    }
    ... on StopDaemonError{
      errorMessage
    }
  }
}
""";
