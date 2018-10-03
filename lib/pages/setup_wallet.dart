/*
This Source Code Form is subject to the terms of the Mozilla Public
License, v. 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
*/

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/gql/mutations/setup_wallet.dart';
import 'package:mobile_app/gql/types/lnd_wallet.dart';
import 'package:mobile_app/widgets/setup_wallet/create.dart';

class SetupWalletPage extends StatefulWidget {
  @override
  _SetupWalletPageState createState() => _SetupWalletPageState();
}

class _SetupWalletPageState extends State<SetupWalletPage> {
  final String _appBarText = "Wallet Setup";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aliasController = TextEditingController();

  bool _loading = false;
  GraphQLClient _client;
  LNDWallet _wallet;
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    _client = GraphQLProvider.of(context).value;

    var steps = [
      Step(
          title: Text("create"),
          content:
              CreateWalletWidget(_nameController, _aliasController, _loading),
          isActive: true),
      Step(title: Text("seed"), content: Text("2"), isActive: true),
      Step(title: Text("verify"), content: Text("3"), isActive: true),
      Step(title: Text("init"), content: Text("4"), isActive: true),
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
            onStepTapped: (step) {
              setState(() {
                _currentStep = step;
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep = _currentStep - 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            onStepContinue: () {
              setState(() {
                switch (_currentStep) {
                  case 0:
                    createWallet(context);
                    break;
                  case 1:
                    _currentStep = _currentStep + 1;
                    break;
                  case 2:
                    print("fin");
                    break;
                  default:
                    print("Unknown step");
                }
              });
            },
          ),
        ));
  }

  void createWallet(BuildContext context) {
    if (_wallet != null) {
      // TODO: update the name and alias on the server if the user
      //       changes one of the values. Server mutation currently not implemented.
      _currentStep = _currentStep + 1;
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
          _wallet = LNDWallet(data.data["createLightningWallet"]["wallet"]);
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
      setState(() {
        _loading = false;
      });
      _currentStep = _currentStep + 1;
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
