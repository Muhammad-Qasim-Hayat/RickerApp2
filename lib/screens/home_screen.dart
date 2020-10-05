import 'package:flutter/material.dart';
import 'package:ricker_app/config/app.example.dart';
import 'package:ricker_app/schemas/latest_checklist.dart';
import 'package:ricker_app/screens/login_screen.dart';
import 'package:ricker_app/screens/vehicle_screen.dart';
import 'package:ricker_app/services/auth_service.dart';
// import 'package:ricker_app/services/checklist_service.dart';
import 'package:ricker_app/widgets/custom_button.dart';
import 'package:ricker_app/widgets/infinite_scroll.dart';
import 'package:ricker_app/widgets/latest_checked_checklist_item.dart';
// import 'package:ricker_app/widgets/latest_checked_checklists_list.dart';
// import 'package:ricker_app/widgets/try_again_button.dart';
// import 'history_screen.dart';
import 'vehicle_screen.dart';

enum Menu {
  logout,
  // history,
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _infiniteScrollController = InfiniteScrollController();


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    print('home');
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Image.asset('assets/images/logo-white.png', height: 36.0,),
            const SizedBox(width: 8.0,),
            Text(Config.APP_NAME),
          ],
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (Menu menu) {
              switch (menu) {
                case Menu.logout:
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Tem certeza que deseja sair?'),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          textColor: Colors.grey,
                          child: Text('CANCELAR'),
                        ),
                        FlatButton(
                          onPressed: () {
                            AuthService.logout();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          textColor: Theme.of(context).primaryColor,
                          child: Text('SAIR'),
                        ),
                      ],
                    )
                  );
                  break;
                // case Menu.history:
                //   Navigator.of(context).push(
                //     MaterialPageRoute(
                //       builder: (context) => HistoryScreen()
                //     )
                //   );
                //   break;
              }
            },
            itemBuilder: (context) => [
              // const PopupMenuItem(
              //   value: Menu.history,
              //   child: Text('Histórico'),
              // ),
              const PopupMenuItem(
                value: Menu.logout,
                child: Text('Sair da conta'),
              ),
            ],
          ),
        ],
      ),

      body: LayoutBuilder(
        builder: (context, viewportConstraints) => SingleChildScrollView(
          controller: _infiniteScrollController,

          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight
            ),
            child: InfiniteScroll<LatestChecklist>(
              controller: _infiniteScrollController,
              endpoint: '/checklists/checked',
              fromJson: (data) => LatestChecklist.fromJson(data),
              renderItem: (item) => LatestCheckedChecklistItem(item),
              noItemsText: 'Nenhuma checklist feita.',
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomButton(
        type: CustomButtonTypes.primary,
        label: 'FAZER CHECKLIST',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VehicleScreen(cameFromHome: true,),
            )
          );

          _infiniteScrollController.jumpTo(0.0);
          _infiniteScrollController.restart();
        },
      ),
    );
  }
}
