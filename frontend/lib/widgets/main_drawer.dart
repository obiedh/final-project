import 'package:SportGrounds/api/google_signin_api.dart';
import 'package:SportGrounds/model/stadium.dart';
import 'package:SportGrounds/providers/favoritesProvider.dart';
import 'package:SportGrounds/providers/fieldsProvider.dart';
import 'package:SportGrounds/screens/addFieldScreen.dart';
import 'package:SportGrounds/screens/editFieldScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/providers/usersProvider.dart';
import 'package:SportGrounds/screens/creditCard.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key, required this.onSelectScreen});

  final void Function(String identifer) onSelectScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Stadium stadium = Stadium(
      id: "2",
      title: "2",
      location: "2",
      imagePath: "2",
      latitude: 45.5,
      longitude: 5445.5,
      type: "2",
      rating: '5',
    );
    String authenticationVar =
        ref.watch(userSingletonProvider).authenticationVar;
    String Username = ref.watch(userSingletonProvider).name;
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primaryContainer,
                  Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.sports_soccer,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(
                  width: 18,
                ),
                Expanded(
                  child: Text(
                    'Welcome!  ${authenticationVar == "" ? "" : Username}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                )
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.login,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              authenticationVar == "" ? 'Sign In' : "Sign out",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 24,
                  ),
            ),
            onTap: () async {
              print(authenticationVar);
              print (ref.read(userSingletonProvider).sso);
              if (authenticationVar != "" &&
                  ref.read(userSingletonProvider).sso!) {
                await GoogleSigninApi.logout();
                ref.read(favoriteStadiumsProvider.notifier).clearFavorites();
                ref.read(stadiumListProvider.notifier).clearStadiums();
              } else {
                if (authenticationVar != "" &&
                    ref.read(userSingletonProvider).sso == false) {
                  ref.read(favoriteStadiumsProvider.notifier).clearFavorites();
                  ref.read(stadiumListProvider.notifier).clearStadiums();
                }
              }

              onSelectScreen(authenticationVar == "" ? 'Sign In' : "Sign out");
            },
          ),
          ListTile(
            leading: Icon(
              Icons.support_agent,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Contact Us',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              onSelectScreen('Contact Us');
            },
          ),
          ref.read(userSingletonProvider).authenticationVar == ""
              ? const SizedBox()
              : ListTile(
                  leading: ref.read(userSingletonProvider).authenticationVar !=
                          "manager"
                      ? Icon(
                          Icons.payment,
                          size: 26,
                          color: Theme.of(context).colorScheme.onSurface,
                        )
                      : Icon(
                          Icons.stadium,
                          size: 26,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  title: ref.read(userSingletonProvider).authenticationVar !=
                          "manager"
                      ? Text(
                          'Credit Card',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurface,
                                fontSize: 24,
                              ),
                        )
                      : Text(
                          'Add Field',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 24,
                              ),
                        ),
                  onTap: () async {
                    if (ref.read(userSingletonProvider).authenticationVar !=
                        "manager") {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const CreditCardScreen(),
                        ),
                      );
                    } else {
                      final newStadium = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => const AddFieldScreen(
                            stadium: Stadium(
                              id: "22",
                              title: "22",
                              location: "22",
                              imagePath: "22",
                              latitude: 45,
                              longitude: 4,
                              type: "22",
                              rating: '5',
                            ),
                          ),
                        ),
                      );

                      if (newStadium != null) {
                        ref
                            .read(stadiumListProvider.notifier)
                            .addStadium(newStadium);
                      }
                    }
                  }),
          ref.read(userSingletonProvider).authenticationVar != "" &&
                  ref.read(userSingletonProvider).authenticationVar != "manager"
              ? ListTile(
                  leading: Icon(
                    Icons.supervised_user_circle_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  title: Text(
                    'User Prefrence',
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                        ),
                  ),
                  onTap: () {
                    onSelectScreen('User Prefrence');
                  },
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
