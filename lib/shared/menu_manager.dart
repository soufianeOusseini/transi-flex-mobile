import 'package:flutter/material.dart';

import '../authentification/model/user_role.dart';
import 'menu.dart';

class MenuManager {
  // Menus pour le rôle Client
  static List<Menu> getClientMenus() {
    return [
      Menu(
        title: 'Accueil',
        icon: Icons.home,
        route: '/client/accueil',
      ),
      Menu(
        title: 'Recherche',
        icon: Icons.search,
        route: '/client/recherche',
      ),
      Menu(
        title: 'Mes Réservations',
        icon: Icons.book_online,
        route: '/client/reservations',
      ),
      Menu(
        title: 'Mes Colis',
        icon: Icons.inventory_2,
        route: '/client/colis',
      ),
      Menu(
        title: 'Paiements',
        icon: Icons.payment,
        route: '/client/paiements',
      ),
      Menu(
        title: 'Notifications',
        icon: Icons.notifications,
        route: '/client/notifications',
        badge: 5, // Exemple de badge
      ),
      Menu(
        title: 'Profil',
        icon: Icons.person,
        route: '/client/profil',
      ),
      Menu(
        title: 'Aide et Support',
        icon: Icons.help,
        route: '/client/aide',
      ),
    ];
  }

  // Menus pour le rôle Chauffeur
  static List<Menu> getChauffeurMenus() {
    return [
      Menu(
        title: 'Accueil',
        icon: Icons.home,
        route: '/chauffeur/accueil',
      ),
      Menu(
        title: 'Mon Planning',
        icon: Icons.schedule,
        route: '/chauffeur/planning',
      ),
      Menu(
        title: 'Trajets en Cours',
        icon: Icons.directions_car,
        route: '/chauffeur/trajets',
      ),
      Menu(
        title: 'Passagers',
        icon: Icons.people,
        route: '/chauffeur/passagers',
      ),
      Menu(
        title: 'Colis & Bsj',
        icon: Icons.local_shipping,
        route: '/chauffeur/colis',
      ),
      Menu(
        title: 'Mon Véhicule',
        icon: Icons.car_repair,
        route: '/chauffeur/vehicule',
      ),
      Menu(
        title: 'Signaler Incident',
        icon: Icons.report_problem,
        route: '/chauffeur/incident',
      ),
      Menu(
        title: 'Mon Profil',
        icon: Icons.person,
        route: '/chauffeur/profil',
      ),
    ];
  }

  // Menus pour le rôle Admin
  static List<Menu> getAdminMenus() {
    return [
      Menu(
        title: 'Dashboard',
        icon: Icons.dashboard,
        route: '/admin/dashboard',
      ),
      Menu(
        title: 'Ma Compagnie',
        icon: Icons.business,
        route: '/admin/compagnie',
      ),
      Menu(
        title: 'Gestion Bus',
        icon: Icons.directions_bus,
        route: '/admin/bus',
      ),
      Menu(
        title: 'Chauffeurs',
        icon: Icons.people,
        route: '/admin/chauffeurs',
      ),
      Menu(
        title: 'Trajets',
        icon: Icons.route,
        route: '/admin/trajets',
      ),
      Menu(
        title: 'Réservations',
        icon: Icons.book_online,
        route: '/admin/reservations',
      ),
      Menu(
        title: 'Gestion Colis',
        icon: Icons.inventory,
        route: '/admin/colis',
      ),
      Menu(
        title: 'Rapport',
        icon: Icons.analytics,
        route: '/admin/rapport',
      ),
      Menu(
        title: 'Notifications',
        icon: Icons.notifications,
        route: '/admin/notifications',
        badge: 12, // Exemple de badge pour admin
      ),
    ];
  }

  // Méthode pour obtenir les menus selon le rôle
  static List<Menu> getMenusByRole(UserRole role) {
    switch (role) {
      case UserRole.CLIENT:
        return getClientMenus();
      case UserRole.DRIVER:
        return getChauffeurMenus();
      case UserRole.ADMIN:
        return getAdminMenus();
    }
  }

  // Méthode pour obtenir les menus principaux pour la bottom navigation (max 5 items)
  static List<Menu> getBottomNavigationMenus(UserRole role) {
    List<Menu> allMenus = getMenusByRole(role);

    switch (role) {
      case UserRole.CLIENT:
        return [
          allMenus[0], // Accueil
          allMenus[1], // Recherche
          allMenus[2], // Mes Réservations
          allMenus[3], // Mes Colis
          allMenus[6], // Profil
        ];
      case UserRole.DRIVER:
        return [
          allMenus[0], // Accueil
          allMenus[1], // Mon Planning
          allMenus[2], // Trajets en Cours
          allMenus[3], // Passagers
          allMenus[7], // Mon Profil
        ];
      case UserRole.ADMIN:
        return [
          allMenus[0], // Dashboard
          allMenus[1], // Ma Compagnie
          allMenus[2], // Gestion Bus
          allMenus[3], // Chauffeurs
          allMenus[7], // Rapport
        ];
    }
  }

  // Méthode pour obtenir les menus du drawer selon le rôle
  static List<Menu> getDrawerMenus(UserRole role) {
    switch (role) {
      case UserRole.CLIENT:
        return [
          Menu(
            title: 'Paiements',
            icon: Icons.credit_card,
            route: '/client/paiements',
          ),
          Menu(
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            route: '/client/notifications',
            badge: 5,
          ),
          Menu(
            title: 'Support',
            icon: Icons.support_agent,
            route: '/client/support',
          ),
          Menu(
            title: 'Paramètres',
            icon: Icons.settings_outlined,
            route: '/client/parametres',
          ),
        ];

      case UserRole.DRIVER:
        return [
          Menu(
            title: 'Mon Planning',
            icon: Icons.schedule,
            route: '/chauffeur/planning',
          ),
          Menu(
            title: 'Mes Gains',
            icon: Icons.attach_money,
            route: '/chauffeur/gains',
          ),
          Menu(
            title: 'Mon Véhicule',
            icon: Icons.car_repair,
            route: '/chauffeur/vehicule',
          ),
          Menu(
            title: 'Signaler Incident',
            icon: Icons.report_problem,
            route: '/chauffeur/incident',
          ),
          Menu(
            title: 'Documents',
            icon: Icons.description,
            route: '/chauffeur/documents',
          ),
          Menu(
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            route: '/chauffeur/notifications',
            badge: 3,
          ),
          Menu(
            title: 'Paramètres',
            icon: Icons.settings_outlined,
            route: '/chauffeur/parametres',
          ),
        ];

      case UserRole.ADMIN:
        return [
          Menu(
            title: 'Ma Compagnie',
            icon: Icons.business,
            route: '/admin/compagnie',
          ),
          Menu(
            title: 'Gestion Bus',
            icon: Icons.directions_bus,
            route: '/admin/bus',
          ),
          Menu(
            title: 'Chauffeurs',
            icon: Icons.people,
            route: '/admin/chauffeurs',
          ),
          Menu(
            title: 'Trajets',
            icon: Icons.route,
            route: '/admin/trajets',
          ),
          Menu(
            title: 'Réservations',
            icon: Icons.book_online,
            route: '/admin/reservations',
          ),
          Menu(
            title: 'Gestion Colis',
            icon: Icons.inventory,
            route: '/admin/colis',
          ),
          Menu(
            title: 'Finances',
            icon: Icons.account_balance,
            route: '/admin/finances',
          ),
          Menu(
            title: 'Rapports',
            icon: Icons.analytics,
            route: '/admin/rapport',
          ),
          Menu(
            title: 'Notifications',
            icon: Icons.notifications_outlined,
            route: '/admin/notifications',
            badge: 12,
          ),
          Menu(
            title: 'Paramètres',
            icon: Icons.settings_outlined,
            route: '/admin/parametres',
          ),
        ];
    }
  }

  // Méthode utilitaire pour obtenir les menus avec badges
  static List<Menu> getMenusWithBadges(UserRole role) {
    List<Menu> menus = getMenusByRole(role);

    // Exemple d'ajout de badges dynamiques
    for (int i = 0; i < menus.length; i++) {
      if (menus[i].route.contains('notifications')) {
        menus[i] = Menu(
          title: menus[i].title,
          icon: menus[i].icon,
          route: menus[i].route,
          badge: _getNotificationCount(role),
        );
      }
    }

    return menus;
  }

  // Méthode privée pour simuler le comptage des notifications
  static int _getNotificationCount(UserRole role) {
    switch (role) {
      case UserRole.CLIENT:
        return 5;
      case UserRole.DRIVER:
        return 3;
      case UserRole.ADMIN:
        return 12;
    }
  }

  // Méthode pour vérifier si un menu nécessite un badge
  static bool hasNotifications(String route) {
    return route.contains('notifications') ||
        route.contains('messages') ||
        route.contains('alerts');
  }
}