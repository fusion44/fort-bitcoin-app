/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/mutations/setup_wallet.dart';
import 'package:mobile_app/gql/types/lnseed.dart';
import 'package:mobile_app/widgets/setup_wallet/create.dart';
import 'package:mobile_app/widgets/setup_wallet/gen_seed.dart';
import 'package:mobile_app/widgets/setup_wallet/init_wallet.dart';
import 'package:mobile_app/widgets/setup_wallet/verify_seed.dart';
import 'package:mobile_app/widgets/setup_wallet/wallet_setup_success.dart';

/*
TODO: Refactor this class, as it has unnecessary complexity.
      Flutters Stepper class doesn't yet allow any customization 
      of it's action buttons. Ideally we'd use a custom next button. 
*/

class SetupWalletPage extends StatefulWidget {
  @override
  _SetupWalletPageState createState() => _SetupWalletPageState();
}

class _SetupWalletPageState extends State<SetupWalletPage> {
  final String _appBarText = "Wallet Setup";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _recoveryController = TextEditingController();

  bool _loading = false;
  GraphQLClient _client;
  LnSeed _seed;
  int _seedVerifyPos1;
  int _seedVerifyPos2;
  bool _wordsMatch = false;
  int _currentStep = 0;
  Map<int, bool> _stepsFinished = {0: false, 1: false, 2: false, 3: false};

  // if true, we have completed all steps and the
  // wallet is synchronizing
  bool _finished = false;

  void _seedVerifyWordsMatch(bool match) {
    _wordsMatch = match;
  }

  @override
  Widget build(BuildContext context) {
    _client = GraphQLProvider.of(context).value;

    if (_finished) {
      return Scaffold(
        appBar: AppBar(leading: Container(), title: Text("Sync with chain")),
        body: WalletSetupSuccessWidget(),
      );
    }

    var steps = [
      Step(
          title: Text("create"),
          content:
              CreateWalletWidget(_nameController, _aliasController, _loading),
          isActive: true),
      Step(
          title: Text("seed"),
          content: GenSeedWidget(_seed, _loading, genSeed),
          isActive: true),
      Step(
          title: Text("verify"),
          content: _seed != null
              ? VerifySeedWidget(
                  _seedVerifyPos1,
                  _seed.cipherSeedMnemonic[_seedVerifyPos1],
                  _seedVerifyPos2,
                  _seed.cipherSeedMnemonic[_seedVerifyPos2],
                  this._seedVerifyWordsMatch)
              : Container(),
          isActive: true),
      Step(
          title: Text("init"),
          content: InitWalletWidget(
              _recoveryController, _passwordController, _loading),
          isActive: true),
    ];

    return WillPopScope(
        onWillPop: () {
          return;
        },
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            leading: Container(),
            title: Text(_appBarText),
          ),
          body: Stepper(
            currentStep: _currentStep,
            steps: steps,
            type: StepperType.horizontal,
            onStepContinue: () {
              switch (_currentStep) {
                case 0:
                  if (!_stepsFinished[0]) {
                    createWallet();
                  }
                  break;
                case 1:
                  if (!_stepsFinished[1]) {
                    genSeed();
                  } else {
                    setState(() {
                      _currentStep = _currentStep + 1;
                      _loading = false;
                    });
                  }
                  break;
                case 2:
                  if (_wordsMatch) {
                    setState(() {
                      _stepsFinished[2] = true;
                      _currentStep = _currentStep + 1;
                      _loading = false;
                    });
                  }
                  break;
                case 3:
                  if (!_stepsFinished[3]) {
                    initWallet();
                  }
                  break;
                default:
              }
              setState(() {});
            },
            onStepCancel: () {
              setState(() {
                _currentStep -= 1;
              });
            },
          ),
        ));
  }

  void createWallet() {
    if (_stepsFinished[0]) {
      // TODO: update the name and alias on the server if the user
      //       changes one of the values. Server mutation currently not implemented.
      setState(() {
        _currentStep = _currentStep + 1;
      });
      return;
    }

    setState(() {
      _loading = true;
    });
    var v = {
      "publicAlias": _aliasController.value.text,
      "name": _nameController.value.text
    };

    _client
        .query(QueryOptions(document: lnCreateWalletQuery, variables: v))
        .then((data) {
      String typename = data.data["createLightningWallet"]["__typename"];
      switch (typename) {
        case "CreateWalletSuccess":
          break;
        case "CreateWalletExistsError":
          // TODO: retrieve existing wallet for user on the server
          //       and if it is not initialized, continiue with next steps
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Wallet exists.")));
          return;
        default:
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("An unknown error occured.")));
          return;
      }

      _stepsFinished[0] = true;
      setState(() {
        _currentStep = _currentStep + 1;
        _loading = false;
        genSeed();
      });
    }).catchError((error) {
      setState(() {
        _loading = false;
      });

      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("An error occured, check the logs")));
      print(error);
    });
  }

  void genSeed() {
    setState(() {
      _loading = true;
    });

    _client
        .query(QueryOptions(
            fetchPolicy: FetchPolicy.networkOnly, document: lnGenSeedQuery))
        .then((data) {
      String typename = data.data["lnGenSeed"]["__typename"];
      switch (typename) {
        case "GenSeedSuccess":
          _seed = LnSeed(data.data["lnGenSeed"]["lnSeed"]);
          break;
        case "GenSeedWalletInstanceNotFound":
          setState(() {
            _loading = false;
          });
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Wallet not found.")));
          return;
        case "ServerError":
        case "GenSeedError":
          var msg = data.data["lnGenSeed"]["errorMessage"];
          _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(msg)));
          setState(() {
            _loading = false;
          });
          return;
        default:
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("An unknown error occured.")));
          return;
      }

      var rng = Random();
      setState(() {
        _seedVerifyPos1 = rng.nextInt(12); // check one of the first seed half
        _seedVerifyPos2 = rng.nextInt(12) + 12; // check second seed half
        _stepsFinished[1] = true;
        _loading = false;
      });
    }).catchError((error) {
      setState(() {
        _loading = false;
      });

      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("An error occured, check the logs")));
      print(error);
    });
  }

  void initWallet() {
    setState(() {
      _loading = true;
    });
    var v = {
      "walletPassword": _passwordController.value.text,
      "cipherSeedMnemonic": _seed.cipherSeedMnemonic
    };
    _client
        .query(QueryOptions(
            fetchPolicy: FetchPolicy.networkOnly,
            document: lnInitWallet,
            variables: v))
        .then((data) {
      String typename = data.data["lnInitWallet"]["__typename"];
      switch (typename) {
        case "InitWalletSuccess":
          setState(() {
            _stepsFinished[3] = true;
            _loading = false;
            _finished = true;
          });
          return;
        case "InitWalletInstanceNotFound":
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Wallet not found.")));
          return;
        case "InitWalletError":
          String msg = data.data["lnInitWallet"]["errorMessage"];
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Error: $msg")));
          return;
        case "InitWalletIsInitialized":
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("Wallet is already initialized")));
          break;
        case "InitWalletPasswordToShortError":
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Password is to short")));
          break;
        case "ServerError":
          String msg = data.data["lnInitWallet"]["errorMessage"];
          _scaffoldKey.currentState
              .showSnackBar(SnackBar(content: Text("Error: $msg")));
          break;
        default:
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text("An unknown error occured.")));
          break;
      }
      setState(() {
        _loading = false;
      });
    }).catchError((error) {
      setState(() {
        _loading = false;
      });

      _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text("An error occured, check the logs")));
      print(error);
    });
  }
}
