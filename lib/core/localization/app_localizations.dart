import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/order.dart';

/// Lightweight, dependency-free localisation for Arabic and French.
///
/// Every user-facing string lives here so both languages stay in sync.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('ar'), Locale('fr')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isArabic => locale.languageCode == 'ar';

  String _t(String fr, String ar) => isArabic ? ar : fr;

  // ---------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------
  String get appName => 'OrderBox DZ';
  String get tagline => _t(
    'Organisez vos commandes, gagnez plus',
    'Ù†Ø¸Ù‘Ù… Ø·Ù„Ø¨Ø§ØªÙƒØŒ Ø§Ø±Ø¨Ø­ Ø£ÙƒØ«Ø±',
  );
  String get storeDefault => _t('Ma boutique', 'Ù…ØªØ¬Ø±ÙŠ');

  // ---------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------
  String get navOrders => _t('Commandes', 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª');
  String get navProducts => _t('Produits', 'Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª');
  String get navCustomers => _t('Clients', 'Ø§Ù„Ø¹Ù…Ù„Ø§Ø¡');
  String get navDashboard => _t('Tableau', 'Ù„ÙˆØ­Ø© Ø§Ù„ØªØ­ÙƒÙ…');
  String get navSettings => _t('RÃ©glages', 'Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª');
  String get syncFennecly => _t('Synchroniser Fennecly', 'Ù…Ø²Ø§Ù…Ù†Ø© Fennecly');
  String get syncedFromFennecly => _t('DonnÃ©es Fennecly synchronisÃ©es', 'ØªÙ…Øª Ù…Ø²Ø§Ù…Ù†Ø© Ø¨ÙŠØ§Ù†Ø§Øª Fennecly');
  String get fenneclySameDb => _t('MÃªme base que fennecly.online', 'Ù†ÙØ³ Ù‚Ø§Ø¹Ø¯Ø© Ø¨ÙŠØ§Ù†Ø§Øª fennecly.online');
  String get customersTitle => _t('Clients', 'Ø§Ù„Ø¹Ù…Ù„Ø§Ø¡');
  String get noCustomersTitle => _t('Aucun client', 'Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ø¹Ù…Ù„Ø§Ø¡');
  String get noCustomersBody => _t('Les clients apparaÃ®tront ici Ã  partir des commandes.', 'Ø³ÙŠØ¸Ù‡Ø± Ø§Ù„Ø¹Ù…Ù„Ø§Ø¡ Ù‡Ù†Ø§ Ù…Ù† Ø®Ù„Ø§Ù„ Ø§Ù„Ø·Ù„Ø¨Ø§Øª.');
  String get totalSpent => _t('Total dÃ©pensÃ©', 'Ø¥Ø¬Ù…Ø§Ù„ÙŠ Ø§Ù„Ø¥Ù†ÙØ§Ù‚');
  String get ordersWord => _t('commandes', 'Ø·Ù„Ø¨Ø§Øª');

  // ---------------------------------------------------------------------
  // Common
  // ---------------------------------------------------------------------
  String get save => _t('Enregistrer', 'Ø­ÙØ¸');
  String get cancel => _t('Annuler', 'Ø¥Ù„ØºØ§Ø¡');
  String get delete => _t('Supprimer', 'Ø­Ø°Ù');
  String get edit => _t('Modifier', 'ØªØ¹Ø¯ÙŠÙ„');
  String get add => _t('Ajouter', 'Ø¥Ø¶Ø§ÙØ©');
  String get search => _t('Rechercher', 'Ø¨Ø­Ø«');
  String get all => _t('Toutes', 'Ø§Ù„ÙƒÙ„');
  String get close => _t('Fermer', 'Ø¥ØºÙ„Ø§Ù‚');
  String get confirm => _t('Confirmer', 'ØªØ£ÙƒÙŠØ¯');
  String get retry => _t('RÃ©essayer', 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„Ù…Ø­Ø§ÙˆÙ„Ø©');
  String get today => _t("Aujourd'hui", 'Ø§Ù„ÙŠÙˆÙ…');
  String get yesterday => _t('Hier', 'Ø£Ù…Ø³');
  String get optional => _t('Facultatif', 'Ø§Ø®ØªÙŠØ§Ø±ÙŠ');
  String get seeAll => _t('Tout voir', 'Ø¹Ø±Ø¶ Ø§Ù„ÙƒÙ„');
  String get currency => _t('DA', 'Ø¯Ø¬');
  String get percent => '%';
  String get vsLastPeriod => _t('vs pÃ©riode prÃ©cÃ©dente', 'Ù…Ù‚Ø§Ø±Ù†Ø© Ø¨Ø§Ù„ÙØªØ±Ø© Ø§Ù„Ø³Ø§Ø¨Ù‚Ø©');
  String get greetingMorning => _t('Bonjour', 'ØµØ¨Ø§Ø­ Ø§Ù„Ø®ÙŠØ±');
  String get greetingAfternoon => _t('Bon aprÃ¨s-midi', 'Ù…Ø³Ø§Ø¡ Ø§Ù„Ø®ÙŠØ±');
  String get greetingEvening => _t('Bonsoir', 'Ù…Ø³Ø§Ø¡ Ø§Ù„Ø®ÙŠØ±');
  String get welcomeBack => _t('Ravi de vous revoir', 'Ù…Ø±Ø­Ø¨Ø§Ù‹ Ø¨Ø¹ÙˆØ¯ØªÙƒ');
  String get dashboardGreeting => _t('Votre activitÃ©', 'Ù†Ø´Ø§Ø·Ùƒ');
  String get clearSearch => _t('Effacer', 'Ù…Ø³Ø­');

  String ordersCount(String count) =>
      _t('$count commandes', '$count Ø·Ù„Ø¨Ø§Øª');
  String productsCount(String count) => _t('$count produits', '$count Ù…Ù†ØªØ¬Ø§Øª');

  String statusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.newOrder => _t('Nouvelle', 'Ø¬Ø¯ÙŠØ¯'),
      OrderStatus.confirmed => _t('ConfirmÃ©e', 'Ù…Ø¤ÙƒØ¯'),
      OrderStatus.shipped => _t('ExpÃ©diÃ©e', 'ØªÙ… Ø§Ù„Ø´Ø­Ù†'),
      OrderStatus.delivered => _t('LivrÃ©e', 'ØªÙ… Ø§Ù„ØªØ³Ù„ÙŠÙ…'),
      OrderStatus.returned => _t('RetournÃ©e', 'Ù…Ø±ØªØ¬Ø¹'),
      OrderStatus.cancelled => _t('AnnulÃ©e', 'Ù…Ù„ØºÙ‰'),
      OrderStatus.noAnswer => _t('Sans rÃ©ponse', 'Ù„Ø§ ÙŠØ¬ÙŠØ¨'),
    };
  }

  // ---------------------------------------------------------------------
  // Splash + onboarding
  // ---------------------------------------------------------------------
  String get onboardingSkip => _t('Passer', 'ØªØ®Ø·ÙŠ');
  String get onboardingNext => _t('Suivant', 'Ø§Ù„ØªØ§Ù„ÙŠ');
  String get onboardingStart => _t("C'est parti", 'Ù„Ù†Ø¨Ø¯Ø£');
  String get onboarding1Title =>
      _t('Suivez toutes vos commandes au mÃªme endroit', 'ØªØ§Ø¨Ø¹ ÙƒÙ„ Ø·Ù„Ø¨Ø§ØªÙƒ ÙÙŠ Ù…ÙƒØ§Ù† ÙˆØ§Ø­Ø¯');
  String get onboarding1Body => _t(
    'De la premiÃ¨re commande Ã  la livraison, gardez une vue claire sur chaque client.',
    'Ù…Ù† Ø£ÙˆÙ„ Ø·Ù„Ø¨ Ø¥Ù„Ù‰ Ø§Ù„ØªØ³Ù„ÙŠÙ…ØŒ Ø§Ø­ØµÙ„ Ø¹Ù„Ù‰ Ø±Ø¤ÙŠØ© ÙˆØ§Ø¶Ø­Ø© Ù„ÙƒÙ„ Ø¹Ù…ÙŠÙ„.',
  );
  String get onboarding2Title =>
      _t('Confirmez vos clients en un tap sur WhatsApp', 'Ø£ÙƒÙ‘Ø¯ Ø·Ù„Ø¨Ø§Øª Ø¹Ù…Ù„Ø§Ø¦Ùƒ Ø¨Ø¶ØºØ·Ø© ÙˆØ§Ø­Ø¯Ø© Ø¹Ù„Ù‰ ÙˆØ§ØªØ³Ø§Ø¨');
  String get onboarding2Body => _t(
    'Un message prÃªt Ã  envoyer, dans la bonne langue, pour chaque commande.',
    'Ø±Ø³Ø§Ù„Ø© Ø¬Ø§Ù‡Ø²Ø© Ù„Ù„Ø¥Ø±Ø³Ø§Ù„ØŒ Ø¨Ø§Ù„Ù„ØºØ© Ø§Ù„Ù…Ù†Ø§Ø³Ø¨Ø©ØŒ Ù„ÙƒÙ„ Ø·Ù„Ø¨.',
  );
  String get onboarding3Title =>
      _t('Voyez votre vrai bÃ©nÃ©fice et rÃ©duisez les retours', 'Ø§Ø¹Ø±Ù Ø£Ø±Ø¨Ø§Ø­Ùƒ Ø§Ù„Ø­Ù‚ÙŠÙ‚ÙŠØ© ÙˆÙ‚Ù„Ù‘Ù„ Ø§Ù„Ù…Ø±ØªØ¬Ø¹Ø§Øª');
  String get onboarding3Body => _t(
    'Des chiffres clairs sur vos revenus, vos marges et votre taux de retour.',
    'Ø£Ø±Ù‚Ø§Ù… ÙˆØ§Ø¶Ø­Ø© Ø¹Ù† Ø¥ÙŠØ±Ø§Ø¯Ø§ØªÙƒ ÙˆÙ‡ÙˆØ§Ù…Ø´ Ø±Ø¨Ø­Ùƒ ÙˆÙ†Ø³Ø¨Ø© Ø§Ù„Ø¥Ø±Ø¬Ø§Ø¹.',
  );

  // ---------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------
  String get ordersTitle => _t('Commandes', 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª');
  String get operations => _t('OpÃ©rations', 'Ø§Ù„Ø¹Ù…Ù„ÙŠØ§Øª');
  String get searchOrdersHint =>
      _t('Rechercher un client, un tÃ©lÃ©phoneâ€¦', 'Ø§Ø¨Ø­Ø« Ø¹Ù† Ø¹Ù…ÙŠÙ„ Ø£Ùˆ Ø±Ù‚Ù… Ù‡Ø§ØªÙâ€¦');
  String get summaryToday => _t("Aujourd'hui", 'Ø§Ù„ÙŠÙˆÙ…');
  String get summaryToConfirm => _t('Ã€ confirmer', 'Ø¨Ø§Ù†ØªØ¸Ø§Ø± Ø§Ù„ØªØ£ÙƒÙŠØ¯');
  String get summaryDelivered => _t('LivrÃ©es', 'ØªÙ… ØªØ³Ù„ÙŠÙ…Ù‡Ø§');
  String get noOrdersTitle =>
      _t('Aucune commande pour le moment', 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø·Ù„Ø¨Ø§Øª Ø¨Ø¹Ø¯');
  String get noOrdersBody => _t(
    'Ajoutez votre premiÃ¨re commande et commencez Ã  suivre vos clients.',
    'Ø£Ø¶Ù Ø·Ù„Ø¨Ùƒ Ø§Ù„Ø£ÙˆÙ„ ÙˆØ§Ø¨Ø¯Ø£ Ø¨Ù…ØªØ§Ø¨Ø¹Ø© Ø¹Ù…Ù„Ø§Ø¦Ùƒ.',
  );
  String get noResultsTitle => _t('Aucun rÃ©sultat', 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù†ØªØ§Ø¦Ø¬');
  String get noResultsBody => _t(
    'Essayez un autre nom, numÃ©ro ou statut.',
    'Ø¬Ø±Ù‘Ø¨ Ø§Ø³Ù…Ø§Ù‹ Ø£Ùˆ Ø±Ù‚Ù…Ø§Ù‹ Ø£Ùˆ Ø­Ø§Ù„Ø© Ø£Ø®Ø±Ù‰.',
  );
  String get selectOrders => _t('Selectionner les commandes', 'Selectionner les commandes');
  String get addOrder => _t('Nouvelle commande', 'Ø·Ù„Ø¨ Ø¬Ø¯ÙŠØ¯');
  String get newOrderTitle => _t('CrÃ©er une commande', 'Ø¥Ù†Ø´Ø§Ø¡ Ø·Ù„Ø¨');
  String get editOrderTitle => _t('Modifier la commande', 'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø·Ù„Ø¨');
  String get orderDetailsTitle => _t('DÃ©tails de la commande', 'ØªÙØ§ØµÙŠÙ„ Ø§Ù„Ø·Ù„Ø¨');
  String get customer => _t('Client', 'Ø§Ù„Ø¹Ù…ÙŠÙ„');
  String get customerName => _t('Nom du client', 'Ø§Ø³Ù… Ø§Ù„Ø¹Ù…ÙŠÙ„');
  String get customerNameHint => _t('Ex. Aya Benali', 'Ù…Ø«Ø§Ù„: Ø¢ÙŠØ© Ø¨Ù† Ø¹Ù„ÙŠ');
  String get phone => _t('TÃ©lÃ©phone', 'Ø±Ù‚Ù… Ø§Ù„Ù‡Ø§ØªÙ');
  String get phoneHint => _t('0551234567', '0551234567');
  String get wilaya => _t('Wilaya', 'Ø§Ù„ÙˆÙ„Ø§ÙŠØ©');
  String get wilayaHint => _t('Choisir une wilaya', 'Ø§Ø®ØªØ± Ø§Ù„ÙˆÙ„Ø§ÙŠØ©');
  String get searchWilaya => _t('Rechercher une wilayaâ€¦', 'Ø§Ø¨Ø­Ø« Ø¹Ù† ÙˆÙ„Ø§ÙŠØ©â€¦');
  String get commune => _t('Commune', 'Ø§Ù„Ø¨Ù„Ø¯ÙŠØ©');
  String get communeHint => _t('Ex. Bab Ezzouar', 'Ù…Ø«Ø§Ù„: Ø¨Ø§Ø¨ Ø§Ù„Ø²ÙˆØ§Ø±');
  String get address => _t('Adresse', 'Ø§Ù„Ø¹Ù†ÙˆØ§Ù†');
  String get addressHint =>
      _t('Rue, quartier, point de repÃ¨reâ€¦', 'Ø§Ù„Ø´Ø§Ø±Ø¹ØŒ Ø§Ù„Ø­ÙŠØŒ Ø¹Ù„Ø§Ù…Ø© Ù…Ù…ÙŠØ²Ø©â€¦');
  String get product => _t('Produit', 'Ø§Ù„Ù…Ù†ØªØ¬');
  String get selectProduct => _t('Choisir un produit', 'Ø§Ø®ØªØ± Ù…Ù†ØªØ¬Ø§Ù‹');
  String get quantity => _t('QuantitÃ©', 'Ø§Ù„ÙƒÙ…ÙŠØ©');
  String get unitPrice => _t('Prix unitaire', 'Ø³Ø¹Ø± Ø§Ù„ÙˆØ­Ø¯Ø©');
  String get deliveryPrice => _t('Frais de livraison', 'Ø³Ø¹Ø± Ø§Ù„ØªÙˆØµÙŠÙ„');
  String get status => _t('Statut', 'Ø§Ù„Ø­Ø§Ù„Ø©');
  String get notes => _t('Notes', 'Ù…Ù„Ø§Ø­Ø¸Ø§Øª');
  String get notesHint =>
      _t('Une prÃ©cision pour la livraisonâ€¦', 'Ù…Ù„Ø§Ø­Ø¸Ø© Ø­ÙˆÙ„ Ø§Ù„ØªÙˆØµÙŠÙ„â€¦');
  String get subtotal => _t('Sous-total', 'Ø§Ù„Ù…Ø¬Ù…ÙˆØ¹ Ø§Ù„ÙØ±Ø¹ÙŠ');
  String get total => _t('Total', 'Ø§Ù„Ø¥Ø¬Ù…Ø§Ù„ÙŠ');
  String get profit => _t('BÃ©nÃ©fice', 'Ø§Ù„Ø±Ø¨Ø­');
  String get orderSummary => _t('RÃ©sumÃ©', 'Ø§Ù„Ù…Ù„Ø®Øµ');
  String get saveOrder => _t('Enregistrer la commande', 'Ø­ÙØ¸ Ø§Ù„Ø·Ù„Ø¨');
  String get orderSaved => _t('Commande enregistrÃ©e', 'ØªÙ… Ø­ÙØ¸ Ø§Ù„Ø·Ù„Ø¨');
  String get orderUpdated => _t('Commande mise Ã  jour', 'ØªÙ… ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø·Ù„Ø¨');
  String get orderDeleted => _t('Commande supprimÃ©e', 'ØªÙ… Ø­Ø°Ù Ø§Ù„Ø·Ù„Ø¨');
  String get deleteOrder => _t('Supprimer la commande', 'Ø­Ø°Ù Ø§Ù„Ø·Ù„Ø¨');
  String get deleteOrderBody => _t(
    'Cette action est dÃ©finitive. La commande sera retirÃ©e de votre historique.',
    'Ù‡Ø°Ø§ Ø§Ù„Ø¥Ø¬Ø±Ø§Ø¡ Ù†Ù‡Ø§Ø¦ÙŠ. Ø³ÙŠØªÙ… Ø­Ø°Ù Ø§Ù„Ø·Ù„Ø¨ Ù…Ù† Ø³Ø¬Ù„Ùƒ.',
  );
  String get statusUpdated => _t('Statut mis Ã  jour', 'ØªÙ… ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø­Ø§Ù„Ø©');
  String get whatsappConfirm => _t('Confirmer sur WhatsApp', 'Ø§Ù„ØªØ£ÙƒÙŠØ¯ Ø¹Ø¨Ø± ÙˆØ§ØªØ³Ø§Ø¨');
  String get whatsappContact => _t('Contacter sur WhatsApp', 'Ø§Ù„ØªÙˆØ§ØµÙ„ Ø¹Ø¨Ø± ÙˆØ§ØªØ³Ø§Ø¨');
  String get callCustomer => _t('Appeler', 'Ø§ØªØµØ§Ù„');
  String get whatsappUnavailable =>
      _t("WhatsApp n'a pas pu s'ouvrir", 'ØªØ¹Ø°Ù‘Ø± ÙØªØ­ ÙˆØ§ØªØ³Ø§Ø¨');
  String get phoneCopied => _t('NumÃ©ro copiÃ©', 'ØªÙ… Ù†Ø³Ø® Ø§Ù„Ø±Ù‚Ù…');
  String get orderNumber => _t('Commande', 'Ø§Ù„Ø·Ù„Ø¨');
  String get createdAt => _t('CrÃ©Ã©e le', 'Ø£ÙÙ†Ø´Ø¦ ÙÙŠ');
  String get deliveryInfo => _t('Livraison', 'Ø§Ù„ØªÙˆØµÙŠÙ„');
  String get item => _t('Article', 'Ø§Ù„Ù…Ù†ØªØ¬');
  String get qtyShort => _t('QtÃ©', 'Ø§Ù„ÙƒÙ…ÙŠØ©');
  String get confirmOrder => _t('Confirmer la commande', 'ØªØ£ÙƒÙŠØ¯ Ø§Ù„Ø·Ù„Ø¨');
  String get markDelivered => _t('Marquer comme livrÃ©e', 'ØªØ­Ø¯ÙŠØ¯ ÙƒÙ…ÙØ³Ù„Ù‘Ù…');
  String get noNotes => _t('Aucune note', 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ù…Ù„Ø§Ø­Ø¸Ø§Øª');
  String get searchProduct => _t('Rechercher un produitâ€¦', 'Ø§Ø¨Ø­Ø« Ø¹Ù† Ù…Ù†ØªØ¬â€¦');
  String get chooseStatus => _t('Changer le statut', 'ØªØºÙŠÙŠØ± Ø§Ù„Ø­Ø§Ù„Ø©');
  String get callNotSupported =>
      _t('Les appels ne sont pas disponibles ici', 'Ø§Ù„Ø§ØªØµØ§Ù„ ØºÙŠØ± Ù…ØªØ§Ø­ Ù‡Ù†Ø§');
  String get phoneRequired => _t('Ajoutez un numÃ©ro de tÃ©lÃ©phone', 'Ø£Ø¶Ù Ø±Ù‚Ù… Ù‡Ø§ØªÙ');
  String get callOutcomeTitle => _t('RÃ©sultat de l\u2019appel', 'Ø±Ø¢Â·ÙØ§Ø¯ Ù…Ø­Ø¯ Ø§Ù„ØªØ£ÙØ±');
  String get callOutcomeAnswered => _t('RÃ©pondu', 'ØªÙ… Ø±Ø°');
  String get callOutcomeNoAnswer => _t('Sans rÃ©ponse', 'Ø¨ÙØ§Ø³ Ø¯ÙØ§ Ø§Ù„ØªØ­Ø¯Ø¯Ø©');
  String get callOutcomeCallback => _t('Rappel', 'Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„ØªØ­Ø¯Ø¯');
  String get callOutcomePending => _t('En attente', 'Ø§Ù†ØªØµØ§Ø¨');

  // Validation
  String get requiredField => _t('Ce champ est obligatoire', 'Ù‡Ø°Ø§ Ø§Ù„Ø­Ù‚Ù„ Ù…Ø·Ù„ÙˆØ¨');
  String get invalidPhone => _t(
    'Entrez un numÃ©ro algÃ©rien valide (ex. 0551234567)',
    'Ø£Ø¯Ø®Ù„ Ø±Ù‚Ù… Ù‡Ø§ØªÙ Ø¬Ø²Ø§Ø¦Ø±ÙŠ ØµØ­ÙŠØ­ (Ù…Ø«Ø§Ù„ 0551234567)',
  );
  String get invalidPrice => _t('Entrez un montant valide', 'Ø£Ø¯Ø®Ù„ Ù…Ø¨Ù„ØºØ§Ù‹ ØµØ­ÙŠØ­Ø§Ù‹');
  String get invalidQuantity =>
      _t('La quantitÃ© doit Ãªtre supÃ©rieure Ã  0', 'ÙŠØ¬Ø¨ Ø£Ù† ØªÙƒÙˆÙ† Ø§Ù„ÙƒÙ…ÙŠØ© Ø£ÙƒØ¨Ø± Ù…Ù† 0');
  String get selectWilayaError =>
      _t('Veuillez choisir une wilaya', 'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ø§Ù„ÙˆÙ„Ø§ÙŠØ©');
  String get selectProductError =>
      _t('Veuillez choisir un produit', 'ÙŠØ±Ø¬Ù‰ Ø§Ø®ØªÙŠØ§Ø± Ù…Ù†ØªØ¬');

  // ---------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------
  String get productsTitle => _t('Produits', 'Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª');
  String get catalogueSubtitle =>
      _t('Votre catalogue et vos marges', 'ÙƒØªØ§Ù„ÙˆØ¬Ùƒ ÙˆÙ‡ÙˆØ§Ù…Ø´ Ø±Ø¨Ùƒ');
  String get noProductsTitle => _t('Votre catalogue est vide', 'ÙƒØªØ§Ù„ÙˆØ¬Ùƒ ÙØ§Ø±Øº');
  String get noProductsBody => _t(
    'Ajoutez vos produits pour calculer vos bÃ©nÃ©fices automatiquement.',
    'Ø£Ø¶Ù Ù…Ù†ØªØ¬Ø§ØªÙƒ Ù„Ø­Ø³Ø§Ø¨ Ø£Ø±Ø¨Ø§Ø­Ùƒ ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹.',
  );
  String get addProduct => _t('Ajouter un produit', 'Ø¥Ø¶Ø§ÙØ© Ù…Ù†ØªØ¬');
  String get editProduct => _t('Modifier le produit', 'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ù…Ù†ØªØ¬');
  String get productName => _t('Nom du produit', 'Ø§Ø³Ù… Ø§Ù„Ù…Ù†ØªØ¬');
  String get productNameHint =>
      _t('Ex. Sac Ã  main Ã©lÃ©gant', 'Ù…Ø«Ø§Ù„: Ø­Ù‚ÙŠØ¨Ø© Ø£Ù†ÙŠÙ‚Ø©');
  String get productPrice => _t('Prix de vente', 'Ø³Ø¹Ø± Ø§Ù„Ø¨ÙŠØ¹');
  String get productCost => _t("Prix d'achat", 'Ø³Ø¹Ø± Ø§Ù„ØªÙƒÙ„ÙØ©');
  String get productStock => _t('Stock', 'Ø§Ù„Ù…Ø®Ø²ÙˆÙ†');
  String get productSaved => _t('Produit enregistrÃ©', 'ØªÙ… Ø­ÙØ¸ Ø§Ù„Ù…Ù†ØªØ¬');
  String get productUpdated => _t('Produit mis Ã  jour', 'ØªÙ… ØªØ­Ø¯ÙŠØ« Ø§Ù„Ù…Ù†ØªØ¬');
  String get productDeleted => _t('Produit supprimÃ©', 'ØªÙ… Ø­Ø°Ù Ø§Ù„Ù…Ù†ØªØ¬');
  String get deleteProduct => _t('Supprimer le produit', 'Ø­Ø°Ù Ø§Ù„Ù…Ù†ØªØ¬');
  String get deleteProductBody => _t(
    'Les commandes existantes ne seront pas modifiÃ©es.',
    'Ù„Ù† ØªØªØºÙŠØ± Ø§Ù„Ø·Ù„Ø¨Ø§Øª Ø§Ù„Ø­Ø§Ù„ÙŠØ©.',
  );
  String get inStock => _t('En stock', 'Ù…ØªÙˆÙØ±');
  String get lowStock => _t('Stock faible', 'Ù…Ø®Ø²ÙˆÙ† Ù…Ù†Ø®ÙØ¶');
  String get outOfStock => _t('Rupture', 'Ù†ÙØ¯ Ø§Ù„Ù…Ø®Ø²ÙˆÙ†');
  String get margin => _t('Marge', 'Ø§Ù„Ù‡Ø§Ù…Ø´');
  String get unit => _t('unitÃ©', 'Ù‚Ø·Ø¹Ø©');
  String get price => _t('Prix', 'Ø§Ù„Ø³Ø¹Ø±');
  String get cost => _t('CoÃ»t', 'Ø§Ù„ØªÙƒÙ„ÙØ©');
  String get stock => _t('Stock', 'Ø§Ù„Ù…Ø®Ø²ÙˆÙ†');
  String get noProductMatch =>
      _t('Aucun produit ne correspond.', 'Ù„Ø§ ÙŠÙˆØ¬Ø¯ Ù…Ù†ØªØ¬ Ù…Ø·Ø§Ø¨Ù‚.');
  String get productRequiredForOrder =>
      _t('Ajoutez un produit Ã  votre catalogue.', 'Ø£Ø¶Ù Ù…Ù†ØªØ¬Ø§Ù‹ Ø¥Ù„Ù‰ ÙƒØªØ§Ù„ÙˆØ¬Ùƒ.');
  String get addProductFirst =>
      _t('Ajouter un premier produit', 'Ø¥Ø¶Ø§ÙØ© Ù…Ù†ØªØ¬ Ø£ÙˆÙ„');
  String get selectProductHint =>
      _t('Touchez pour choisir un produit', 'Ø§Ø¶ØºØ· Ù„Ø§Ø®ØªÙŠØ§Ø± Ù…Ù†ØªØ¬');
  String get allProducts => _t('Tous les produits', 'ÙƒÙ„ Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª');
  String get maxStock => _t('Stock maximum', 'Ø§Ù„Ø­Ø¯ Ø§Ù„Ø£Ù‚ØµÙ‰ Ù„Ù„Ù…Ø®Ø²ÙˆÙ†');

  // ---------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------
  String get dashboardTitle => _t('Tableau de bord', 'Ù„ÙˆØ­Ø© Ø§Ù„ØªØ­ÙƒÙ…');
  String get dashboardSubtitle =>
      _t('Votre activitÃ© en un coup dâ€™Å“il', 'Ù†Ø´Ø§Ø·Ùƒ ÙÙŠ Ù„Ù…Ø­Ø©');
  String get revenue => _t("Chiffre d'affaires", 'Ø§Ù„Ø¥ÙŠØ±Ø§Ø¯Ø§Øª');
  String get profitLabel => _t('BÃ©nÃ©fice net', 'ØµØ§ÙÙŠ Ø§Ù„Ø±Ø¨Ø­');
  String get returnRate => _t('Taux de retour', 'Ù†Ø³Ø¨Ø© Ø§Ù„Ø¥Ø±Ø¬Ø§Ø¹');
  String get revenueSub => _t('Commandes livrÃ©es', 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª Ø§Ù„Ù…Ø³Ù„Ù‘Ù…Ø©');
  String get profitSub => _t('AprÃ¨s coÃ»t des produits', 'Ø¨Ø¹Ø¯ ØªÙƒÙ„ÙØ© Ø§Ù„Ù…Ù†ØªØ¬Ø§Øª');
  String get returnRateSub =>
      _t('sur les commandes expÃ©diÃ©es', 'Ù…Ù† Ø§Ù„Ø·Ù„Ø¨Ø§Øª Ø§Ù„Ù…Ø±Ø³Ù„Ø©');
  String get last7Days => _t('7 derniers jours', 'Ø¢Ø®Ø± 7 Ø£ÙŠØ§Ù…');
  String get last30Days => _t('30 derniers jours', 'Ø¢Ø®Ø± 30 ÙŠÙˆÙ…Ø§Ù‹');
  String get allTime => _t('Tout', 'Ø§Ù„ÙƒÙ„');
  String get analyticsTitle => _t('Analytics', 'التحليلات');
  String get analyticsSubtitle => _t('Vue rapide de vos performances', 'أداؤك بلمحة');
  String get revenueChartTitle => _t('Revenus', 'Ø§Ù„Ø¥ÙŠØ±Ø§Ø¯Ø§Øª');
  String get revenueChartSubtitle =>
      _t('Commandes livrÃ©es par jour', 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª Ø§Ù„Ù…Ø³Ù„Ù‘Ù…Ø© ÙŠÙˆÙ…ÙŠØ§Ù‹');
  String get statusChartTitle =>
      _t('RÃ©partition des statuts', 'ØªÙˆØ²ÙŠØ¹ Ø§Ù„Ø­Ø§Ù„Ø§Øª');
  String get recentOrders => _t('Commandes rÃ©centes', 'Ø£Ø­Ø¯Ø« Ø§Ù„Ø·Ù„Ø¨Ø§Øª');
  String get noRecentOrders => _t('Pas encore de commande', 'Ù„Ø§ ØªÙˆØ¬Ø¯ Ø·Ù„Ø¨Ø§Øª Ø¨Ø¹Ø¯');
  String get vsPrevious =>
      _t('vs pÃ©riode prÃ©cÃ©dente', 'Ù…Ù‚Ø§Ø±Ù†Ø© Ø¨Ø§Ù„ÙØªØ±Ø© Ø§Ù„Ø³Ø§Ø¨Ù‚Ø©');
  String get totalOrders => _t('Commandes', 'Ø§Ù„Ø·Ù„Ø¨Ø§Øª');
  String get deliveredShort => _t('LivrÃ©es', 'Ù…Ø³Ù„Ù‘Ù…Ø©');
  String get pendingShort => _t('En attente', 'Ù‚ÙŠØ¯ Ø§Ù„Ø§Ù†ØªØ¸Ø§Ø±');
  String get marginShort => _t('Marge', 'Ø§Ù„Ù‡Ø§Ù…Ø´');
  String get averageOrder => _t('Panier moyen', 'Ù…ØªÙˆØ³Ø· Ø§Ù„Ø·Ù„Ø¨');
  String get dashboardEmptyTitle =>
      _t('Votre tableau de bord vous attend', 'Ù„ÙˆØ­Ø© Ø§Ù„ØªØ­ÙƒÙ… Ø¨Ø§Ù†ØªØ¸Ø§Ø±Ùƒ');
  String get dashboardEmptyBody => _t(
    'Ajoutez des commandes pour voir vos revenus et votre bÃ©nÃ©fice.',
    'Ø£Ø¶Ù Ø·Ù„Ø¨Ø§Øª Ù„Ø±Ø¤ÙŠØ© Ø¥ÙŠØ±Ø§Ø¯Ø§ØªÙƒ ÙˆØ£Ø±Ø¨Ø§Ø­Ùƒ.',
  );
  String get noSalesInPeriod =>
      _t('Aucune vente sur cette pÃ©riode', 'Ù„Ø§ Ù…Ø¨ÙŠØ¹Ø§Øª ÙÙŠ Ù‡Ø°Ù‡ Ø§Ù„ÙØªØ±Ø©');
  String get noSalesInPeriodBody => _t(
    'Changez de pÃ©riode ou ajoutez une commande livrÃ©e.',
    'ØºÙŠÙ‘Ø± Ø§Ù„ÙØªØ±Ø© Ø£Ùˆ Ø£Ø¶Ù Ø·Ù„Ø¨Ø§Ù‹ Ù…Ø³Ù„Ù‘Ù…Ø§Ù‹.',
  );
  String get chartRevenue => _t('Revenus', 'Ø§Ù„Ø¥ÙŠØ±Ø§Ø¯Ø§Øª');
  String get deliveredOrders => _t('commandes livrÃ©es', 'Ø·Ù„Ø¨ Ù…Ø³Ù„Ù‘Ù…');

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------
  String get settingsTitle => _t('RÃ©glages', 'Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª');
  String get settingsSubtitle =>
      _t('Personnalisez votre expÃ©rience', 'Ø®ØµÙ‘Øµ ØªØ¬Ø±Ø¨ØªÙƒ');
  String get profile => _t('Profil', 'Ø§Ù„Ù…Ù„Ù');
  String get storeName => _t('Nom de la boutique', 'Ø§Ø³Ù… Ø§Ù„Ù…ØªØ¬Ø±');
  String get storeNameHint => _t('Ex. Ma boutique', 'Ù…Ø«Ø§Ù„: Ù…ØªØ¬Ø±ÙŠ');
  String get editStoreName => _t('Modifier le nom', 'ØªØ¹Ø¯ÙŠÙ„ Ø§Ù„Ø§Ø³Ù…');
  String get storeNameSaved =>
      _t('Nom de la boutique mis Ã  jour', 'ØªÙ… ØªØ­Ø¯ÙŠØ« Ø§Ø³Ù… Ø§Ù„Ù…ØªØ¬Ø±');
  String get appearance => _t('Apparence', 'Ø§Ù„Ù…Ø¸Ù‡Ø±');
  String get themeSystem => _t('SystÃ¨me', 'Ø§Ù„Ù†Ø¸Ø§Ù…');
  String get themeLight => _t('Clair', 'ÙØ§ØªØ­');
  String get themeDark => _t('Sombre', 'Ø¯Ø§ÙƒÙ†');
  String get language => _t('Langue', 'Ø§Ù„Ù„ØºØ©');
  String get arabic => 'Ø§Ù„Ø¹Ø±Ø¨ÙŠØ©';
  String get french => 'FranÃ§ais';
  String get languageSubtitle =>
      _t("L'application s'adapte automatiquement", 'ÙŠØªÙƒÙŠÙ‘Ù Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ ØªÙ„Ù‚Ø§Ø¦ÙŠØ§Ù‹');
  String get dataSection => _t('DonnÃ©es', 'Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª');
  String get restoreDemo =>
      _t('RÃ©initialiser les donnÃ©es de dÃ©mo', 'Ø§Ø³ØªØ¹Ø§Ø¯Ø© Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø¹Ø±Ø¶');
  String get restoreDemoBody => _t(
    'Remplace vos donnÃ©es par un jeu dâ€™exemple rÃ©aliste.',
    'ÙŠØ³ØªØ¨Ø¯Ù„ Ø¨ÙŠØ§Ù†Ø§ØªÙƒ Ø¨Ù…Ø¬Ù…ÙˆØ¹Ø© Ø£Ù…Ø«Ù„Ø© ÙˆØ§Ù‚Ø¹ÙŠØ©.',
  );
  String get clearData => _t('Effacer toutes les donnÃ©es', 'Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª');
  String get clearDataBody => _t(
    'Toutes vos commandes et produits seront supprimÃ©s dÃ©finitivement.',
    'Ø³ÙŠØªÙ… Ø­Ø°Ù Ø¬Ù…ÙŠØ¹ Ø·Ù„Ø¨Ø§ØªÙƒ ÙˆÙ…Ù†ØªØ¬Ø§ØªÙƒ Ù†Ù‡Ø§Ø¦ÙŠØ§Ù‹.',
  );
  String get dataCleared => _t('DonnÃ©es effacÃ©es', 'ØªÙ… Ø­Ø°Ù Ø§Ù„Ø¨ÙŠØ§Ù†Ø§Øª');
  String get demoRestored =>
      _t('DonnÃ©es de dÃ©mo restaurÃ©es', 'ØªÙ… Ø§Ø³ØªØ¹Ø§Ø¯Ø© Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø¹Ø±Ø¶');
  String get about => _t('Ã€ propos', 'Ø­ÙˆÙ„ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚');
  String get version => _t('Version', 'Ø§Ù„Ø¥ØµØ¯Ø§Ø±');
  String get madeIn => _t('ConÃ§u en AlgÃ©rie', 'ØµÙÙ†Ø¹ ÙÙŠ Ø§Ù„Ø¬Ø²Ø§Ø¦Ø±');
  String get replayOnboarding => _t("Revoir l'introduction", 'Ø¥Ø¹Ø§Ø¯Ø© Ø¹Ø±Ø¶ Ø§Ù„Ù…Ù‚Ø¯Ù…Ø©');
  String get replayOnboardingSub =>
      _t('Relancez les Ã©crans de bienvenue', 'Ø£Ø¹Ø¯ ØªØ´ØºÙŠÙ„ Ø´Ø§Ø´Ø§Øª Ø§Ù„ØªØ±Ø­ÙŠØ¨');
  String get onboardingReset =>
      _t("L'introduction sera affichÃ©e au prochain lancement", 'Ø³ØªØ¸Ù‡Ø± Ø§Ù„Ù…Ù‚Ø¯Ù…Ø© Ø¹Ù†Ø¯ Ø§Ù„ØªØ´ØºÙŠÙ„ Ø§Ù„Ù‚Ø§Ø¯Ù…');
  String get settingsDemo => _t('Mode dÃ©mo', 'ÙˆØ¶Ø¹ Ø§Ù„Ø¹Ø±Ø¶');
  String get support => _t('Support', 'Ø§Ù„Ø¯Ø¹Ù…');
  String get appDescription => _t(
    'GÃ©rez vos commandes, vos produits et vos bÃ©nÃ©fices depuis une seule application.',
    'Ø£Ø¯Ø± Ø·Ù„Ø¨Ø§ØªÙƒ ÙˆÙ…Ù†ØªØ¬Ø§ØªÙƒ ÙˆØ£Ø±Ø¨Ø§Ø­Ùƒ Ù…Ù† ØªØ·Ø¨ÙŠÙ‚ ÙˆØ§Ø­Ø¯.',
  );
  String get appearanceSystemHint =>
      _t('Suit le thÃ¨me de votre tÃ©lÃ©phone', 'ÙŠØªØ¨Ø¹ Ù…Ø¸Ù‡Ø± Ù‡Ø§ØªÙÙƒ');
  String get appearanceLightHint =>
      _t('Toujours lumineux et net', 'Ø¯Ø§Ø¦Ù…Ø§Ù‹ Ù…Ø¶ÙŠØ¡ ÙˆÙˆØ§Ø¶Ø­');
  String get appearanceDarkHint =>
      _t('Confortable pour les yeux', 'Ù…Ø±ÙŠØ­ Ù„Ù„Ø¹ÙŠÙ†ÙŠÙ†');
  String get profileInitialsHint =>
      _t('Visible dans toute lâ€™application', 'ÙŠØ¸Ù‡Ø± ÙÙŠ Ø¬Ù…ÙŠØ¹ Ø£Ù†Ø­Ø§Ø¡ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚');
  String get resetOnboarding => _t(
    "L'introduction est rÃ©initialisÃ©e",
    'ØªÙ…Øª Ø¥Ø¹Ø§Ø¯Ø© ØªØ¹ÙŠÙŠÙ† Ø§Ù„Ù…Ù‚Ø¯Ù…Ø©',
  );

  // ---------------------------------------------------------------------
  // WhatsApp message
  // ---------------------------------------------------------------------
  String whatsappOrderMessage({
    required String customer,
    required String product,
    required String wilaya,
    required String store,
  }) {
    if (isArabic) {
      return 'Ù…Ø±Ø­Ø¨Ø§Ù‹ $customer ðŸ‘‹\nØªÙ… ØªØ£ÙƒÙŠØ¯ Ø·Ù„Ø¨ Â« $product Â».\nØ§Ù„ØªÙˆØµÙŠÙ„ Ø¥Ù„Ù‰ $wilaya.\nØ´ÙƒØ±Ø§Ù‹ Ù„Ø«Ù‚ØªÙƒ â€” $store';
    }
    return 'Bonjour $customer ðŸ‘‹\nVotre commande Â« $product Â» est confirmÃ©e.\nLivraison vers $wilaya.\nMerci pour votre confiance â€” $store';
  }

  /// Natural, time-aware greeting used on the Orders and Dashboard headers.
  String greetingForHour(int hour) {
    if (hour < 12) return greetingMorning;
    if (hour < 18) return greetingAfternoon;
    return greetingEvening;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
