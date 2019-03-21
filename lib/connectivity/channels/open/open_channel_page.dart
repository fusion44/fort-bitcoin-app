/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/common/types/lnpeer.dart';
import 'package:mobile_app/common/widgets/help_form_text_field.dart';
import 'package:mobile_app/common/widgets/scale_in_animated_icon.dart';
import 'package:mobile_app/connectivity/channels/open/open_channel.dart';
import 'package:mobile_app/connectivity/peer/select_peer_pubkey_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class OpenChannelPage extends StatefulWidget {
  final LnPeer peer;

  const OpenChannelPage({Key key, this.peer}) : super(key: key);

  _OpenChannelPageState createState() => _OpenChannelPageState();
}

class _OpenChannelPageState extends State<OpenChannelPage> {
  final String _appBarText = "Open Channel";

  String _selectedPubKey;

  final _formKey = GlobalKey<FormState>();
  final _localAmtController = TextEditingController(text: "1000000");
  final _pushAmtController = TextEditingController(text: "0");
  final _targetConfController = TextEditingController(text: "6");
  final _satsPerKBController = TextEditingController(text: "3");
  final _htlcMinSatController = TextEditingController(text: "1000");
  final _remoteCSVDelayController = TextEditingController();
  final _minConfsController = TextEditingController(text: "6");

  // if fee manual == true => user enters a sats per kb value
  // if fee manual == false => user enters a confirmed in x blocks value
  bool _feeManual = false;

  bool _private = false;

  bool _spendUnconfirmed = false;

  int _minConfs;

  @override
  Widget build(BuildContext context) {
    OpenChannelBloc bloc = BlocProvider.of<OpenChannelBloc>(context);
    ThemeData theme = Theme.of(context);
    return BlocBuilder<OpenChannelEvent, ChannelOpenState>(
      bloc: bloc,
      builder: (BuildContext context, ChannelOpenState state) {
        Widget body;
        switch (state.type) {
          case OpenChannelEventType.initial:
            body = _buildForm(bloc);
            break;
          case OpenChannelEventType.start:
          case OpenChannelEventType.channelIsPending:
            body = _buildLoadingWidget(theme, 0);
            break;
          case OpenChannelEventType.channelConfUpdate:
            int currentConfs = _minConfs - state.confData.numConfsLeft;
            body = _buildLoadingWidget(theme, currentConfs);
            break;
          case OpenChannelEventType.channelIsOpen:
            body = Column(
              children: <Widget>[
                ScaleInAnimatedIcon(
                  Icons.check_circle_outline,
                ),
                Text(
                  "Wohoo! Channel is open.\nHappy bolting!",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline,
                ),
              ],
            );
            break;
          case OpenChannelEventType.failOpening:
            _showOpenChannelErrorDialog(state.error);
            bloc.reset();
            print("failed: ${state.error}");
            break;
          default:
            body = Text("Implement me ${state.type}");
        }
        return WillPopScope(
          onWillPop: () {
            bloc.reset();
            Navigator.of(context).pop();
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(_appBarText),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: body,
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget(ThemeData theme, int confirmations) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Center(
        child: Column(
          children: <Widget>[
            SpinKitWanderingCubes(color: theme.accentColor),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "Working ...",
                style: theme.textTheme.headline,
              ),
            ),
            Text(
              "Confirmations: $confirmations / $_minConfs",
              style: theme.textTheme.headline,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "Unfortunately, LND currently doesn't deliver the actual status messages. The indicator will jump from 0 to finished then the channel is open.",
                style: theme.textTheme.caption,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForm(OpenChannelBloc bloc) {
    Widget body = SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            SelectPeerPubkeyWidget(
                initialSelection: widget.peer.pubKey,
                peerSelectedCallback: (String pubKey) =>
                    _selectedPubKey = pubKey),
            HelpFormTextField(
              helpText:
                  "The number of satoshis the wallet should commit to the channel",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Local funding (sats)"),
              controller: _localAmtController,
              validator: (value) {
                // must be more than local funding amount
              },
            ),
            HelpFormTextField(
              helpText:
                  "The number of satoshis to push to the remote side as part of the initial commitment state",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Push amount (sats)"),
              controller: _pushAmtController,
              validator: (value) {
                // must be less than local funding amount
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Switch(
                  value: _feeManual,
                  onChanged: (bool value) {
                    setState(() {
                      _feeManual = value;
                    });
                  },
                ),
                Text("Manual Fee"),
                Container(
                  width: 15.0,
                ),
                Switch(
                  value: _spendUnconfirmed,
                  onChanged: (bool value) {
                    setState(() {
                      _spendUnconfirmed = value;
                    });
                  },
                ),
                Text("Spend unconfirmed utxo")
              ],
            ),
            _feeManual
                ? HelpFormTextField(
                    helpText:
                        "A manual fee rate set in sat/byte that should be used when crafting the funding transaction.",
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: "Sats per byte"),
                    controller: _satsPerKBController,
                  )
                : HelpFormTextField(
                    helpText:
                        "The target number of blocks that the funding transaction should be confirmed by.",
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: "Target conf in blocks"),
                    controller: _targetConfController,
                  ),
            Row(
              children: <Widget>[
                Switch(
                  value: _private,
                  onChanged: (bool value) {
                    setState(() {
                      _private = value;
                    });
                  },
                ),
                Text("Private channel"),
                Container(
                  height: 1.0,
                  width: 18.0,
                ),
                Expanded(
                  child: HelpFormTextField(
                    helpText:
                        "The minimum value in millisatoshi we will require for incoming HTLCs on the channel.",
                    keyboardType: TextInputType.number,
                    decoration:
                        InputDecoration(labelText: "Min incoming HTLC mSat "),
                    controller: _htlcMinSatController,
                  ),
                ),
              ],
            ),
            HelpFormTextField(
              helpText:
                  "The delay we require on the remote’s commitment transaction. If this is not set, it will be scaled automatically with the channel size.",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Remote CSV delay"),
              controller: _remoteCSVDelayController,
            ),
            HelpFormTextField(
              helpText:
                  "The minimum number of confirmations each one of your outputs used for the funding transaction must satisfy.",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Min block confirmations"),
              controller: _minConfsController,
            ),
            RaisedButton(
              child: Text("Open"),
              onPressed: () => _onOpenChannel(bloc),
            )
          ],
        ),
      ),
    );
    return body;
  }

  _onOpenChannel(OpenChannelBloc bloc) {
    _minConfs = int.parse(_minConfsController.value.text);
    StartOpenChannelInput input = StartOpenChannelInput(
      nodePubkey:
          _selectedPubKey == null ? widget.peer.pubKey : _selectedPubKey,
      localFundingAmount: int.parse(_localAmtController.value.text),
      pushSat: int.tryParse(_pushAmtController.value.text),
      targetConf:
          !_feeManual ? int.parse(_targetConfController.value.text) : null,
      satPerByte:
          _feeManual ? int.parse(_satsPerKBController.value.text) : null,
      private: _private,
      minHtlcMsat: int.parse(_htlcMinSatController.value.text),
      remoteCsvDelay: int.tryParse(_remoteCSVDelayController.value.text),
      minConfs: int.parse(_minConfsController.value.text),
      spendUnconfirmed: _spendUnconfirmed,
    );
    bloc.startOpenChannel(input);
  }

  Future<Null> _showOpenChannelErrorDialog(String errorMessage) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error!'),
              content: SingleChildScrollView(
                child: Text(errorMessage),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
