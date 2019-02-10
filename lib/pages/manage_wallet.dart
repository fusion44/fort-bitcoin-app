import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/blocs/auth/auth/authentication.dart';
import 'package:mobile_app/gql/queries/system_status.dart';
import 'package:mobile_app/gql/types/lninfo.dart';
import 'package:mobile_app/models.dart';

enum _Views { walletNotRunning, showInfo, showError }

class ManageWalletPage extends StatefulWidget {
  static final IconData icon = Icons.settings;
  static final String appBarText = "Manage Wallet";

  _ManageWalletPageState createState() => _ManageWalletPageState();
}

class _ManageWalletPageState extends State<ManageWalletPage> {
  GraphQLClient _client;
  _Views _currentView = _Views.showInfo;
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  LnInfoType _info;
  String _error;
  bool _autopilot = false;

  AuthenticationBloc _authBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authBloc == null) {
      _authBloc = BlocProvider.of<AuthenticationBloc>(context);
    }
    if (_client == null) {
      _client = GraphQLProvider.of(context).value;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    if (_authBloc.userRepository.user.walletState == WalletState.notRunning) {
      _currentView = _Views.walletNotRunning;
    } else {
      _currentView = _Views.showInfo;
    }

    Widget currentView;
    switch (_currentView) {
      case _Views.showInfo:
        currentView = Column(children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              child: Text("Stop Daemon"),
              color: theme.buttonTheme.colorScheme.error,
              onPressed: _onStopDaemon,
            ),
          )
        ]);
        break;
      case _Views.walletNotRunning:
        currentView = Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: <Widget>[
              Text(
                "Start Wallet",
                style: theme.textTheme.display1,
              ),
              Text("Your wallet daemon is currently offline"),
              Row(
                children: <Widget>[
                  Checkbox(
                      value: _autopilot,
                      onChanged: (bool checked) {
                        setState(() {
                          _autopilot = checked;
                        });
                      }),
                  Text("Autopilot")
                ],
              ),
              TextField(
                enabled: !_loading,
                autocorrect: false,
                obscureText: true,
                decoration: InputDecoration(labelText: "Wallet Password"),
                controller: _passwordController,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: RaisedButton(
                  child: !_loading
                      ? Text("Start daemon and unlock wallet")
                      : Text("Working ..."),
                  onPressed: !_loading ? _onStartDaemon : null,
                ),
              ),
            ],
          ),
        );
        break;
      case _Views.showError:
        currentView = Text("Error: $_error");
        break;
      default:
        currentView = Text("Implement me $_currentView");
    }

    return Column(
      children: <Widget>[
        _loading ? LinearProgressIndicator() : Container(),
        currentView
      ],
    );
  }

  _onStartDaemon() async {
    setState(() {
      _loading = true;
    });

    var v = {
      "walletPassword": _passwordController.value.text,
      "autopilot": _autopilot
    };
    QueryResult result = await _client.query(QueryOptions(
      document: startDaemon,
      variables: v,
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    var typename = result.data["startDaemon"]["__typename"];
    switch (typename) {
      case "StartDaemonSuccess":
        var info = LnInfoType(result.data["startDaemon"]["info"]);
        _passwordController.clear();
        _authBloc.userRepository.user.walletState = WalletState.ready;
        setState(() {
          _info = info;
          _currentView = _Views.showInfo;
          _loading = false;
        });
        break;
      default:
    }
  }

  _onStopDaemon() async {
    setState(() {
      _loading = true;
    });

    QueryResult result = await _client.query(QueryOptions(
      document: stopDaemon,
      fetchPolicy: FetchPolicy.networkOnly,
    ));
    var typename = result.data["lnStopDaemon"]["__typename"];
    switch (typename) {
      case "StopDaemonSuccess":
        _authBloc.userRepository.user.walletState = WalletState.notRunning;
        setState(() {
          _info = null;
          _currentView = _Views.walletNotRunning;
          _loading = false;
        });
        break;
      case "ServerError":
      case "StopDaemonError":
        setState(() {
          _currentView = _Views.showError;
          _error = result.data["lnStopDaemon"]["errorMessage"];
          _info = null;
          _loading = false;
        });
        break;
      default:
        setState(() {
          _currentView = _Views.showError;
          _error = "Implement me: $typename";
          _info = null;
          _loading = false;
        });
    }
  }
}
