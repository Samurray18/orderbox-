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
    'نظّم طلباتك، اربح أكثر',
  );
  String get storeDefault => _t('Ma boutique', 'متجري');

  // ---------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------
  String get navOrders => _t('Commandes', 'الطلبات');
  String get navProducts => _t('Produits', 'المنتجات');
  String get navDashboard => _t('Tableau', 'لوحة التحكم');
  String get navSettings => _t('Réglages', 'الإعدادات');

  // ---------------------------------------------------------------------
  // Common
  // ---------------------------------------------------------------------
  String get save => _t('Enregistrer', 'حفظ');
  String get cancel => _t('Annuler', 'إلغاء');
  String get delete => _t('Supprimer', 'حذف');
  String get edit => _t('Modifier', 'تعديل');
  String get add => _t('Ajouter', 'إضافة');
  String get search => _t('Rechercher', 'بحث');
  String get all => _t('Toutes', 'الكل');
  String get close => _t('Fermer', 'إغلاق');
  String get confirm => _t('Confirmer', 'تأكيد');
  String get retry => _t('Réessayer', 'إعادة المحاولة');
  String get today => _t("Aujourd'hui", 'اليوم');
  String get yesterday => _t('Hier', 'أمس');
  String get optional => _t('Facultatif', 'اختياري');
  String get seeAll => _t('Tout voir', 'عرض الكل');
  String get currency => _t('DA', 'دج');
  String get percent => '%';
  String get vsLastPeriod => _t('vs période précédente', 'مقارنة بالفترة السابقة');
  String get greetingMorning => _t('Bonjour', 'صباح الخير');
  String get greetingAfternoon => _t('Bon après-midi', 'مساء الخير');
  String get greetingEvening => _t('Bonsoir', 'مساء الخير');
  String get welcomeBack => _t('Ravi de vous revoir', 'مرحباً بعودتك');
  String get dashboardGreeting => _t('Votre activité', 'نشاطك');
  String get clearSearch => _t('Effacer', 'مسح');

  String ordersCount(String count) =>
      _t('$count commandes', '$count طلبات');
  String productsCount(String count) => _t('$count produits', '$count منتجات');

  String statusLabel(OrderStatus status) {
    return switch (status) {
      OrderStatus.newOrder => _t('Nouvelle', 'جديد'),
      OrderStatus.confirmed => _t('Confirmée', 'مؤكد'),
      OrderStatus.shipped => _t('Expédiée', 'تم الشحن'),
      OrderStatus.delivered => _t('Livrée', 'تم التسليم'),
      OrderStatus.returned => _t('Retournée', 'مرتجع'),
      OrderStatus.cancelled => _t('Annulée', 'ملغى'),
      OrderStatus.noAnswer => _t('Sans réponse', 'لا يجيب'),
    };
  }

  // ---------------------------------------------------------------------
  // Splash + onboarding
  // ---------------------------------------------------------------------
  String get onboardingSkip => _t('Passer', 'تخطي');
  String get onboardingNext => _t('Suivant', 'التالي');
  String get onboardingStart => _t("C'est parti", 'لنبدأ');
  String get onboarding1Title =>
      _t('Suivez toutes vos commandes au même endroit', 'تابع كل طلباتك في مكان واحد');
  String get onboarding1Body => _t(
    'De la première commande à la livraison, gardez une vue claire sur chaque client.',
    'من أول طلب إلى التسليم، احصل على رؤية واضحة لكل عميل.',
  );
  String get onboarding2Title =>
      _t('Confirmez vos clients en un tap sur WhatsApp', 'أكّد طلبات عملائك بضغطة واحدة على واتساب');
  String get onboarding2Body => _t(
    'Un message prêt à envoyer, dans la bonne langue, pour chaque commande.',
    'رسالة جاهزة للإرسال، باللغة المناسبة، لكل طلب.',
  );
  String get onboarding3Title =>
      _t('Voyez votre vrai bénéfice et réduisez les retours', 'اعرف أرباحك الحقيقية وقلّل المرتجعات');
  String get onboarding3Body => _t(
    'Des chiffres clairs sur vos revenus, vos marges et votre taux de retour.',
    'أرقام واضحة عن إيراداتك وهوامش ربحك ونسبة الإرجاع.',
  );

  // ---------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------
  String get ordersTitle => _t('Commandes', 'الطلبات');
  String get operations => _t('Opérations', 'العمليات');
  String get searchOrdersHint =>
      _t('Rechercher un client, un téléphone…', 'ابحث عن عميل أو رقم هاتف…');
  String get summaryToday => _t("Aujourd'hui", 'اليوم');
  String get summaryToConfirm => _t('À confirmer', 'بانتظار التأكيد');
  String get summaryDelivered => _t('Livrées', 'تم تسليمها');
  String get noOrdersTitle =>
      _t('Aucune commande pour le moment', 'لا توجد طلبات بعد');
  String get noOrdersBody => _t(
    'Ajoutez votre première commande et commencez à suivre vos clients.',
    'أضف طلبك الأول وابدأ بمتابعة عملائك.',
  );
  String get noResultsTitle => _t('Aucun résultat', 'لا توجد نتائج');
  String get noResultsBody => _t(
    'Essayez un autre nom, numéro ou statut.',
    'جرّب اسماً أو رقماً أو حالة أخرى.',
  );
  String get addOrder => _t('Nouvelle commande', 'طلب جديد');
  String get newOrderTitle => _t('Créer une commande', 'إنشاء طلب');
  String get editOrderTitle => _t('Modifier la commande', 'تعديل الطلب');
  String get orderDetailsTitle => _t('Détails de la commande', 'تفاصيل الطلب');
  String get customer => _t('Client', 'العميل');
  String get customerName => _t('Nom du client', 'اسم العميل');
  String get customerNameHint => _t('Ex. Aya Benali', 'مثال: آية بن علي');
  String get phone => _t('Téléphone', 'رقم الهاتف');
  String get phoneHint => _t('0551234567', '0551234567');
  String get wilaya => _t('Wilaya', 'الولاية');
  String get wilayaHint => _t('Choisir une wilaya', 'اختر الولاية');
  String get searchWilaya => _t('Rechercher une wilaya…', 'ابحث عن ولاية…');
  String get commune => _t('Commune', 'البلدية');
  String get communeHint => _t('Ex. Bab Ezzouar', 'مثال: باب الزوار');
  String get address => _t('Adresse', 'العنوان');
  String get addressHint =>
      _t('Rue, quartier, point de repère…', 'الشارع، الحي، علامة مميزة…');
  String get product => _t('Produit', 'المنتج');
  String get selectProduct => _t('Choisir un produit', 'اختر منتجاً');
  String get quantity => _t('Quantité', 'الكمية');
  String get unitPrice => _t('Prix unitaire', 'سعر الوحدة');
  String get deliveryPrice => _t('Frais de livraison', 'سعر التوصيل');
  String get status => _t('Statut', 'الحالة');
  String get notes => _t('Notes', 'ملاحظات');
  String get notesHint =>
      _t('Une précision pour la livraison…', 'ملاحظة حول التوصيل…');
  String get subtotal => _t('Sous-total', 'المجموع الفرعي');
  String get total => _t('Total', 'الإجمالي');
  String get profit => _t('Bénéfice', 'الربح');
  String get orderSummary => _t('Résumé', 'الملخص');
  String get saveOrder => _t('Enregistrer la commande', 'حفظ الطلب');
  String get orderSaved => _t('Commande enregistrée', 'تم حفظ الطلب');
  String get orderUpdated => _t('Commande mise à jour', 'تم تحديث الطلب');
  String get orderDeleted => _t('Commande supprimée', 'تم حذف الطلب');
  String get deleteOrder => _t('Supprimer la commande', 'حذف الطلب');
  String get deleteOrderBody => _t(
    'Cette action est définitive. La commande sera retirée de votre historique.',
    'هذا الإجراء نهائي. سيتم حذف الطلب من سجلك.',
  );
  String get statusUpdated => _t('Statut mis à jour', 'تم تحديث الحالة');
  String get whatsappConfirm => _t('Confirmer sur WhatsApp', 'التأكيد عبر واتساب');
  String get whatsappContact => _t('Contacter sur WhatsApp', 'التواصل عبر واتساب');
  String get callCustomer => _t('Appeler', 'اتصال');
  String get whatsappUnavailable =>
      _t("WhatsApp n'a pas pu s'ouvrir", 'تعذّر فتح واتساب');
  String get phoneCopied => _t('Numéro copié', 'تم نسخ الرقم');
  String get orderNumber => _t('Commande', 'الطلب');
  String get createdAt => _t('Créée le', 'أُنشئ في');
  String get deliveryInfo => _t('Livraison', 'التوصيل');
  String get item => _t('Article', 'المنتج');
  String get qtyShort => _t('Qté', 'الكمية');
  String get confirmOrder => _t('Confirmer la commande', 'تأكيد الطلب');
  String get markDelivered => _t('Marquer comme livrée', 'تحديد كمُسلّم');
  String get noNotes => _t('Aucune note', 'لا توجد ملاحظات');
  String get searchProduct => _t('Rechercher un produit…', 'ابحث عن منتج…');
  String get chooseStatus => _t('Changer le statut', 'تغيير الحالة');
  String get callNotSupported =>
      _t('Les appels ne sont pas disponibles ici', 'الاتصال غير متاح هنا');
  String get phoneRequired => _t('Ajoutez un numéro de téléphone', 'أضف رقم هاتف');

  // Validation
  String get requiredField => _t('Ce champ est obligatoire', 'هذا الحقل مطلوب');
  String get invalidPhone => _t(
    'Entrez un numéro algérien valide (ex. 0551234567)',
    'أدخل رقم هاتف جزائري صحيح (مثال 0551234567)',
  );
  String get invalidPrice => _t('Entrez un montant valide', 'أدخل مبلغاً صحيحاً');
  String get invalidQuantity =>
      _t('La quantité doit être supérieure à 0', 'يجب أن تكون الكمية أكبر من 0');
  String get selectWilayaError =>
      _t('Veuillez choisir une wilaya', 'يرجى اختيار الولاية');
  String get selectProductError =>
      _t('Veuillez choisir un produit', 'يرجى اختيار منتج');

  // ---------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------
  String get productsTitle => _t('Produits', 'المنتجات');
  String get catalogueSubtitle =>
      _t('Votre catalogue et vos marges', 'كتالوجك وهوامش ربك');
  String get noProductsTitle => _t('Votre catalogue est vide', 'كتالوجك فارغ');
  String get noProductsBody => _t(
    'Ajoutez vos produits pour calculer vos bénéfices automatiquement.',
    'أضف منتجاتك لحساب أرباحك تلقائياً.',
  );
  String get addProduct => _t('Ajouter un produit', 'إضافة منتج');
  String get editProduct => _t('Modifier le produit', 'تعديل المنتج');
  String get productName => _t('Nom du produit', 'اسم المنتج');
  String get productNameHint =>
      _t('Ex. Sac à main élégant', 'مثال: حقيبة أنيقة');
  String get productPrice => _t('Prix de vente', 'سعر البيع');
  String get productCost => _t("Prix d'achat", 'سعر التكلفة');
  String get productStock => _t('Stock', 'المخزون');
  String get productSaved => _t('Produit enregistré', 'تم حفظ المنتج');
  String get productUpdated => _t('Produit mis à jour', 'تم تحديث المنتج');
  String get productDeleted => _t('Produit supprimé', 'تم حذف المنتج');
  String get deleteProduct => _t('Supprimer le produit', 'حذف المنتج');
  String get deleteProductBody => _t(
    'Les commandes existantes ne seront pas modifiées.',
    'لن تتغير الطلبات الحالية.',
  );
  String get inStock => _t('En stock', 'متوفر');
  String get lowStock => _t('Stock faible', 'مخزون منخفض');
  String get outOfStock => _t('Rupture', 'نفد المخزون');
  String get margin => _t('Marge', 'الهامش');
  String get unit => _t('unité', 'قطعة');
  String get price => _t('Prix', 'السعر');
  String get cost => _t('Coût', 'التكلفة');
  String get stock => _t('Stock', 'المخزون');
  String get noProductMatch =>
      _t('Aucun produit ne correspond.', 'لا يوجد منتج مطابق.');
  String get productRequiredForOrder =>
      _t('Ajoutez un produit à votre catalogue.', 'أضف منتجاً إلى كتالوجك.');
  String get addProductFirst =>
      _t('Ajouter un premier produit', 'إضافة منتج أول');
  String get selectProductHint =>
      _t('Touchez pour choisir un produit', 'اضغط لاختيار منتج');
  String get allProducts => _t('Tous les produits', 'كل المنتجات');
  String get maxStock => _t('Stock maximum', 'الحد الأقصى للمخزون');

  // ---------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------
  String get dashboardTitle => _t('Tableau de bord', 'لوحة التحكم');
  String get dashboardSubtitle =>
      _t('Votre activité en un coup d’œil', 'نشاطك في لمحة');
  String get revenue => _t("Chiffre d'affaires", 'الإيرادات');
  String get profitLabel => _t('Bénéfice net', 'صافي الربح');
  String get returnRate => _t('Taux de retour', 'نسبة الإرجاع');
  String get revenueSub => _t('Commandes livrées', 'الطلبات المسلّمة');
  String get profitSub => _t('Après coût des produits', 'بعد تكلفة المنتجات');
  String get returnRateSub =>
      _t('sur les commandes expédiées', 'من الطلبات المرسلة');
  String get last7Days => _t('7 derniers jours', 'آخر 7 أيام');
  String get last30Days => _t('30 derniers jours', 'آخر 30 يوماً');
  String get allTime => _t('Tout', 'الكل');
  String get revenueChartTitle => _t('Revenus', 'الإيرادات');
  String get revenueChartSubtitle =>
      _t('Commandes livrées par jour', 'الطلبات المسلّمة يومياً');
  String get statusChartTitle =>
      _t('Répartition des statuts', 'توزيع الحالات');
  String get recentOrders => _t('Commandes récentes', 'أحدث الطلبات');
  String get noRecentOrders => _t('Pas encore de commande', 'لا توجد طلبات بعد');
  String get vsPrevious =>
      _t('vs période précédente', 'مقارنة بالفترة السابقة');
  String get totalOrders => _t('Commandes', 'الطلبات');
  String get deliveredShort => _t('Livrées', 'مسلّمة');
  String get pendingShort => _t('En attente', 'قيد الانتظار');
  String get marginShort => _t('Marge', 'الهامش');
  String get averageOrder => _t('Panier moyen', 'متوسط الطلب');
  String get dashboardEmptyTitle =>
      _t('Votre tableau de bord vous attend', 'لوحة التحكم بانتظارك');
  String get dashboardEmptyBody => _t(
    'Ajoutez des commandes pour voir vos revenus et votre bénéfice.',
    'أضف طلبات لرؤية إيراداتك وأرباحك.',
  );
  String get noSalesInPeriod =>
      _t('Aucune vente sur cette période', 'لا مبيعات في هذه الفترة');
  String get noSalesInPeriodBody => _t(
    'Changez de période ou ajoutez une commande livrée.',
    'غيّر الفترة أو أضف طلباً مسلّماً.',
  );
  String get chartRevenue => _t('Revenus', 'الإيرادات');
  String get deliveredOrders => _t('commandes livrées', 'طلب مسلّم');

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------
  String get settingsTitle => _t('Réglages', 'الإعدادات');
  String get settingsSubtitle =>
      _t('Personnalisez votre expérience', 'خصّص تجربتك');
  String get profile => _t('Profil', 'الملف');
  String get storeName => _t('Nom de la boutique', 'اسم المتجر');
  String get storeNameHint => _t('Ex. Ma boutique', 'مثال: متجري');
  String get editStoreName => _t('Modifier le nom', 'تعديل الاسم');
  String get storeNameSaved =>
      _t('Nom de la boutique mis à jour', 'تم تحديث اسم المتجر');
  String get appearance => _t('Apparence', 'المظهر');
  String get themeSystem => _t('Système', 'النظام');
  String get themeLight => _t('Clair', 'فاتح');
  String get themeDark => _t('Sombre', 'داكن');
  String get language => _t('Langue', 'اللغة');
  String get arabic => 'العربية';
  String get french => 'Français';
  String get languageSubtitle =>
      _t("L'application s'adapte automatiquement", 'يتكيّف التطبيق تلقائياً');
  String get dataSection => _t('Données', 'البيانات');
  String get restoreDemo =>
      _t('Réinitialiser les données de démo', 'استعادة بيانات العرض');
  String get restoreDemoBody => _t(
    'Remplace vos données par un jeu d’exemple réaliste.',
    'يستبدل بياناتك بمجموعة أمثلة واقعية.',
  );
  String get clearData => _t('Effacer toutes les données', 'حذف جميع البيانات');
  String get clearDataBody => _t(
    'Toutes vos commandes et produits seront supprimés définitivement.',
    'سيتم حذف جميع طلباتك ومنتجاتك نهائياً.',
  );
  String get dataCleared => _t('Données effacées', 'تم حذف البيانات');
  String get demoRestored =>
      _t('Données de démo restaurées', 'تم استعادة بيانات العرض');
  String get about => _t('À propos', 'حول التطبيق');
  String get version => _t('Version', 'الإصدار');
  String get madeIn => _t('Conçu en Algérie', 'صُنع في الجزائر');
  String get replayOnboarding => _t("Revoir l'introduction", 'إعادة عرض المقدمة');
  String get replayOnboardingSub =>
      _t('Relancez les écrans de bienvenue', 'أعد تشغيل شاشات الترحيب');
  String get onboardingReset =>
      _t("L'introduction sera affichée au prochain lancement", 'ستظهر المقدمة عند التشغيل القادم');
  String get settingsDemo => _t('Mode démo', 'وضع العرض');
  String get support => _t('Support', 'الدعم');
  String get appDescription => _t(
    'Gérez vos commandes, vos produits et vos bénéfices depuis une seule application.',
    'أدر طلباتك ومنتجاتك وأرباحك من تطبيق واحد.',
  );
  String get appearanceSystemHint =>
      _t('Suit le thème de votre téléphone', 'يتبع مظهر هاتفك');
  String get appearanceLightHint =>
      _t('Toujours lumineux et net', 'دائماً مضيء وواضح');
  String get appearanceDarkHint =>
      _t('Confortable pour les yeux', 'مريح للعينين');
  String get profileInitialsHint =>
      _t('Visible dans toute l’application', 'يظهر في جميع أنحاء التطبيق');
  String get resetOnboarding => _t(
    "L'introduction est réinitialisée",
    'تمت إعادة تعيين المقدمة',
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
      return 'مرحباً $customer 👋\nتم تأكيد طلب « $product ».\nالتوصيل إلى $wilaya.\nشكراً لثقتك — $store';
    }
    return 'Bonjour $customer 👋\nVotre commande « $product » est confirmée.\nLivraison vers $wilaya.\nMerci pour votre confiance — $store';
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
