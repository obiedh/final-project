import 'package:SportGrounds/screens/SettingsScreen.dart';
import 'package:SportGrounds/screens/manager_screen.dart';
import 'package:SportGrounds/screens/reports_Screen.dart';
import 'package:SportGrounds/screens/reservationManager_screen.dart';
import 'package:SportGrounds/screens/userPrefrences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SportGrounds/providers/favoritesProvider.dart';
import 'package:SportGrounds/providers/reservationCancelFlag.dart';
import 'package:SportGrounds/screens/profile_screen.dart';
import 'package:SportGrounds/screens/reservationsScreen.dart';
import 'package:SportGrounds/screens/sports_categories.dart';
import 'package:SportGrounds/widgets/main_drawer.dart';
import 'package:SportGrounds/screens/auth.dart';
import 'package:SportGrounds/providers/usersProvider.dart';

import 'favorites_screen.dart';

class MainPageScreen extends ConsumerStatefulWidget {
  const MainPageScreen({super.key});

  @override
  ConsumerState<MainPageScreen> createState() {
    // TODO: implement createState
    return _MainPagaeScreenState();
  }
}

class _MainPagaeScreenState extends ConsumerState<MainPageScreen> {
  int _selectedPageIndex = 0;

  void _showInforMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _drawerSelect(String p) {
    if (p == "Sign In") {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => const AuthScreen(),
      ));
    }
    if (p == "Sign out") {
      ref.watch(userSingletonProvider.notifier).Logout();
    }
    if (p == "User Prefrence") {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (ctx) => const UserPreferenceScreen(),
      ));
    }
  }

  void _selectPage(int index) {
    if (index == 2 || index == 1) {
      // 2 corresponds to "My Games" screen
      if (ref.read(userSingletonProvider).authenticationVar != "") {
        // Replace with your actual condition to check authentication
        setState(() {
          _selectedPageIndex = index;
        });
      } else {
        _showInforMessage("Please sign in to access this tab.");
      }
    } else {
      setState(() {
        _selectedPageIndex = index;
      });
    }
    ref.read(flagProvider.notifier).turnFlagOFF(false);
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(userSingletonProvider);
    ref.watch(flagProvider);
    if (ref.read(flagProvider).reservationFlag == true) {
      _selectedPageIndex = 0;
    }
    var activePageTitle =
        ref.read(userSingletonProvider).authenticationVar == 'manager'
            ? 'Welcome Manager Avii'
            : 'Categories';
    Widget activePage =
        ref.read(userSingletonProvider).authenticationVar == 'manager'
            ? const ManagerScreen()
            : const SportsCategoriesScreen();

    if (_selectedPageIndex == 1) {
      final favoriteStadiums = ref.watch(favoriteStadiumsProvider);
      activePage =
          ref.read(userSingletonProvider).authenticationVar != 'manager'
              ? FavoritesScreen()
              : const ReservationScreenManager();
      activePageTitle =
          ref.read(userSingletonProvider).authenticationVar == 'manager'
              ? 'Reservations'
              : 'Favorites';
    }
    if (_selectedPageIndex == 2) {
      activePageTitle =
          ref.read(userSingletonProvider).authenticationVar == 'manager'
              ? 'Statistics'
              : 'My Games';
      activePage =
          ref.read(userSingletonProvider).authenticationVar == 'manager'
              ? ReportsScreen()
              : const ReservationScreenEbra();
    }
    if (_selectedPageIndex == 3) {
      activePage = const ProfileScreen();
      activePageTitle = 'My Profile';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      drawer: MainDrawer(onSelectScreen: _drawerSelect),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.background,
                Theme.of(context).colorScheme.onSecondary
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: activePage),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        //backgroundColor: Colors.black,
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.stadium), //set_meal //categoroes
              label:
                  ref.read(userSingletonProvider).authenticationVar == 'manager'
                      ? 'Manage Fields'
                      : 'Categories'),
          BottomNavigationBarItem(
            icon: ref.read(userSingletonProvider).authenticationVar == 'manager'
                ? const Icon(Icons.date_range)
                : const Icon(Icons.star),
            label:
                ref.read(userSingletonProvider).authenticationVar == 'manager'
                    ? 'Reservations'
                    : 'Favorites',
          ), //favorites //star icon
          BottomNavigationBarItem(
            icon: ref.read(userSingletonProvider).authenticationVar == 'manager'
                ? const Icon(Icons.query_stats)
                : const Icon(Icons.stadium),
            label:
                ref.read(userSingletonProvider).authenticationVar == 'manager'
                    ? 'Statistics'
                    : 'Reservations',
          ), //My games
          BottomNavigationBarItem(
              icon: const Icon(Icons.account_box),
              label:
                  ref.read(userSingletonProvider).authenticationVar == 'manager'
                      ? 'Profile'
                      : 'Profile'), //profile
        ],
      ),
    );
  }
}
