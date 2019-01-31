/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc_events.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc_input.dart';
import 'package:mobile_app/blocs/close_channel/close_channel_bloc_state.dart';
import 'package:mobile_app/gql/types/lnchannel.dart';
import 'package:mobile_app/widgets/help_form_text_field.dart';
import 'package:mobile_app/widgets/scale_in_animated_icon.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CloseChannelPage extends StatefulWidget {
  final LnChannel channel;
  final String token;
  const CloseChannelPage({Key key, this.channel, this.token}) : super(key: key);

  _CloseChannelPageState createState() => _CloseChannelPageState();
}

class _CloseChannelPageState extends State<CloseChannelPage> {
  final String _appBarText = "Close Channel";

  final _formKey = GlobalKey<FormState>();
  final _localCommentController = TextEditingController();
  final _targetConfController = TextEditingController(text: "6");
  final _satsPerKBController = TextEditingController(text: "3");

  // if fee manual == true => user enters a sats per kb value
  // if fee manual == false => user enters a confirmed in x blocks value
  bool _feeManual = false;

  bool _force = false;

  CloseChannelBloc _bloc;

  _CloseChannelPageState() {
    CloseChannelBloc(widget.token);
  }

  @override
  void dispose() {
    if (_bloc != null) {
      _bloc.reset();
      _bloc = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return BlocBuilder<CloseChannelEvent, ChannelCloseState>(
      bloc: _bloc,
      builder: (BuildContext context, ChannelCloseState state) {
        Widget body;

        switch (state.type) {
          case CloseChannelEventType.initial:
            body = _buildForm();
            break;
          case CloseChannelEventType.start:
          case CloseChannelEventType.channelCloseIsPending:
            body = _buildLoadingWidget(theme, 0);
            break;
          case CloseChannelEventType.channelIsClosed:
            body = Column(
              children: <Widget>[
                ScaleInAnimatedIcon(
                  Icons.check_circle_outline,
                ),
                Text(
                  "Wohoo! Channel is closed.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headline,
                ),
              ],
            );
            break;
          case CloseChannelEventType.failClosing:
            _showCloseChannelErrorDialog(state.error);
            _bloc.reset();
            print("failed: ${state.error}");
            break;
          default:
            body = Text("Implement me ${state.type}");
        }
        return WillPopScope(
          onWillPop: () {
            _bloc.reset();
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
              "Confirmations: $confirmations / 666",
              style: theme.textTheme.headline,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                "Unfortunately, LND currently doesn't deliver the actual status messages. The indicator will jump from 0 to finished then the channel is closed.",
                style: theme.textTheme.caption,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    Widget body = SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            HelpFormTextField(
              helpText:
                  "An optional comment on why the channel is closed. Will be saved in local database.",
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Comment"),
              controller: _localCommentController,
              validator: (value) {
                // must be more than local funding amount
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
                  value: _force,
                  onChanged: (bool value) {
                    setState(() {
                      _force = value;
                    });
                  },
                ),
                Text("Force")
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
            RaisedButton(
              child: Text("Close"),
              onPressed: () => _showCloseChannelQuestionDialog(),
            )
          ],
        ),
      ),
    );
    return body;
  }

  _onCloseChannel() {
    StartCloseChannelInput input = StartCloseChannelInput(
      channelPoint: this.widget.channel.channelPoint,
      force: _force,
      targetConf:
          !_feeManual ? int.parse(_targetConfController.value.text) : null,
      satPerByte:
          _feeManual ? int.parse(_satsPerKBController.value.text) : null,
    );
    _bloc.startCloseChannel(input);
  }

  Future<Null> _showCloseChannelErrorDialog(String errorMessage) async {
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

  Future<Null> _showCloseChannelQuestionDialog() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await showDialog<Null>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Close Channel?'),
              content: SingleChildScrollView(
                child: Text("This action cannot be undone"),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _onCloseChannel();
                  },
                ),
                FlatButton(
                  child: Text('Cancel'),
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
