import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/order.dart';

/// Lightweight, dependency-free localisation for English, French and Arabic.
///
/// Every user-facing string lives here so all three languages stay in sync.
/// English is the default language of the app.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('fr'), Locale('ar')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  bool get isEnglish => locale.languageCode != 'fr' && locale.languageCode != 'ar';
  bool get isFrench => locale.languageCode == 'fr';
  bool get isArabic => locale.languageCode == 'ar';

  String _t(String en, String fr, String ar) {
    if (isArabic) return ar;
    if (isFrench) return fr;
    return en;
  }

  // Brand
  String get appName => _t('OrderBox DZ', 'OrderBox DZ', 'OrderBox DZ');
  String get tagline => _t(
        'Everything about your orders, in one place',
        'Toutes vos commandes, au même endroit',
        'كل شيء عن طلباتك، في مكان واحد',
      );
  String get storeDefault => _t('My Store', 'Ma boutique', 'متجرك');

  // Navigation
  String get navOrders => _t('Orders', 'Commandes', 'الطلبات');
  String get navProducts => _t('Products', 'Produits', 'المنتجات');
  String get navCustomers => _t('Customers', 'Clients', 'العملاء');
  String get navDashboard => _t('Home', 'Tableau', 'لوحة التحكم');
  String get navSettings => _t('Settings', 'Réglages', 'الإعدادات');

  // Fennecly sync
  String get syncFennecly => _t('Sync with Fennecly', 'Synchroniser avec Fennecly', 'مزامنة Fennecly');
  String get syncedFromFennecly => _t('Synced from Fennecly', 'Synchronisé depuis Fennecly', 'تمت المزامنة من Fennecly');
  String get fenneclySameDb => _t(
        'Same account as fennecly.online — same store, products, orders and customers',
        'Même compte que fennecly.online — même boutique, produits, commandes et clients',
        'نفس حساب fennecly.online — نفس المتجر والمنتجات والطلبات والعملاء',
      );

  // Customers
  String get customersTitle => _t('Customers', 'Clients', 'العملاء');
  String get noCustomersTitle => _t('No customers yet', 'Aucun client', 'لا يوجد عملاء بعد');
  String get noCustomersBody => _t(
        'Customers appear here automatically after your first order.',
        'Les clients apparaissent ici après votre première commande.',
        'سيظهر العملاء هنا بعد أول طلب.',
      );
  String get totalSpent => _t('Total spent', 'Dépenses', 'إجمالي الإنفاق');
  String get ordersWord => _t('orders', 'commandes', 'طلبات');

  // Actions
  String get save => _t('Save', 'Enregistrer', 'حفظ');
  String get cancel => _t('Cancel', 'Annuler', 'إلغاء');
  String get delete => _t('Delete', 'Supprimer', 'حذف');
  String get edit => _t('Edit', 'Modifier', 'تعديل');
  String get add => _t('Add', 'Ajouter', 'إضافة');
  String get search => _t('Search', 'Rechercher', 'بحث');
  String get all => _t('All', 'Tous', 'الكل');
  String get close => _t('Close', 'Fermer', 'إغلاق');
  String get confirm => _t('Confirm', 'Confirmer', 'تأكيد');
  String get retry => _t('Retry', 'Réessayer', 'إعادة المحاولة');
  String get today => _t('Today', 'Aujourd’hui', 'اليوم');
  String get yesterday => _t('Yesterday', 'Hier', 'أمس');
  String get optional => _t('Optional', 'Optionnel', 'اختياري');
  String get seeAll => _t('See all', 'Voir tout', 'عرض الكل');

  // Units & formatting
  String get currency => _t('DA', 'DA', 'دج');
  String get percent => _t('%', '%', '٪');
  String get vsLastPeriod => _t('vs previous period', 'vs période précédente', 'مقارنة بالفترة السابقة');

  // Greeting
  String greetingForHour(int hour) {
    if (hour < 12) return _t('Good morning', 'Bonjour', 'صباح الخير');
    if (hour < 18) return _t('Good afternoon', 'Bon après-midi', 'مساء الخير');
    return _t('Good evening', 'Bonsoir', 'مساء الخير');
  }

  String get welcomeBack => _t('Welcome back', 'Content de te revoir', 'أهلاً بعودتك');
  String get dashboardGreeting => _t('Your store at a glance', 'Votre boutique en un coup d’œil', 'متجرك في نظرة واحدة');

  // Search
  String get clearSearch => _t('Clear search', 'Effacer la recherche', 'مسح البحث');

  // Onboarding
  String get onboardingSkip => _t('Skip', 'Ignorer', 'تخطي');
  String get onboardingNext => _t('Next', 'Suivant', 'التالي');
  String get onboardingStart => _t('Get started', 'Commencer', 'ابدأ');
  String get onboarding1Title => _t('Everything about your orders', 'Toutes vos commandes', 'كل شيء عن طلباتك');
  String get onboarding1Body => _t(
        'Create, confirm, ship and track every order in one place.',
        'Créez, confirmez, expédiez et suivez chaque commande en un seul endroit.',
        'أنشئ وأكّد واشحن وتابع كل طلب في مكان واحد.',
      );
  String get onboarding2Title => _t('Work offline', 'Travaillez hors-ligne', 'اعمل دون إنترنت');
  String get onboarding2Body => _t(
        'Your data stays on the device and syncs when you are online.',
        'Vos données restent sur l’appareil et se synchronisent quand vous êtes en ligne.',
        'بياناتك تبقى على الجهاز وتتزامن عند الاتصال بالإنترنت.',
      );
  String get onboarding3Title => _t('Works with fennecly.online', 'Intégration fennecly.online', 'يعمل مع fennecly.online');
  String get onboarding3Body => _t(
        'Same account, store, products and orders as the web version.',
        'Même compte, boutique, produits et commandes que la version web.',
        'نفس الحساب والمتجر والمنتجات والطلبات في النسخة الويب.',
      );

  // Orders
  String get ordersTitle => _t('Orders', 'Commandes', 'الطلبات');
  String get operations => _t('Today’s operations', 'Opérations du jour', 'عمليات اليوم');
  String get searchOrdersHint => _t('Search a customer, phone, product…', 'Rechercher client, téléphone, produit…', 'ابحث عن عميل أو هاتف أو منتج…');
  String get summaryToday => _t('Today', 'Aujourd’hui', 'اليوم');
  String get summaryToConfirm => _t('To confirm', 'À confirmer', 'بانتظار التأكيد');
  String get summaryDelivered => _t('Delivered', 'Livrées', 'تم التوصيل');
  String get noOrdersTitle => _t('No orders yet', 'Aucune commande', 'لا توجد طلبات بعد');
  String get noOrdersBody => _t(
        'Create your first order and it will appear here.',
        'Créez votre première commande et elle apparaîtra ici.',
        'أنشئ أول طلب وستظهر هنا.',
      );
  String get noResultsTitle => _t('No results', 'Aucun résultat', 'لا توجد نتائج');
  String get noResultsBody => _t(
        'Try another name, phone or wilaya.',
        'Essayez un autre nom, téléphone ou wilaya.',
        'جرّب اسمًا أو هاتفًا أو ولاية أخرى.',
      );
  String get selectOrders => _t('Select orders', 'Sélectionner des commandes', 'تحديد الطلبات');
  String get addOrder => _t('New order', 'Nouvelle commande', 'طلب جديد');
  String get newOrderTitle => _t('New order', 'Nouvelle commande', 'طلب جديد');
  String get editOrderTitle => _t('Edit order', 'Modifier la commande', 'تعديل الطلب');
  String get orderDetailsTitle => _t('Order details', 'Détail de la commande', 'تفاصيل الطلب');
  String get customer => _t('Customer', 'Client', 'العميل');
  String get customerName => _t('Customer name', 'Nom du client', 'اسم العميل');
  String get customerNameHint => _t('e.g. Amel Azzouz', 'ex. Amel Azzouz', 'مثال: أمال عزوز');
  String get phone => _t('Phone', 'Téléphone', 'الهاتف');
  String get phoneHint => _t('0551 23 45 67', '0551 23 45 67', '0551 23 45 67');
  String get wilaya => _t('Wilaya', 'Wilaya', 'الولاية');
  String get wilayaHint => _t('Choose a wilaya', 'Choisissez une wilaya', 'اختر الولاية');
  String get searchWilaya => _t('Search wilaya', 'Rechercher une wilaya', 'ابحث عن الولاية');
  String get commune => _t('Commune', 'Commune', 'البلدية');
  String get communeHint => _t('e.g. Bab Ezzouar', 'ex. Bab Ezzouar', 'مثال: باب الزوار');
  String get address => _t('Address', 'Adresse', 'العنوان');
  String get addressHint => _t('Street, building, apartment…', 'Rue, immeuble, appartement…', 'الشارع، العمارة، الشقة…');
  String get product => _t('Product', 'Produit', 'المنتج');
  String get selectProduct => _t('Select a product', 'Choisissez un produit', 'اختر المنتج');
  String get quantity => _t('Quantity', 'Quantité', 'الكمية');
  String get unitPrice => _t('Unit price', 'Prix unitaire', 'سعر الوحدة');
  String get deliveryPrice => _t('Delivery price', 'Prix de livraison', 'سعر التوصيل');
  String get status => _t('Status', 'Statut', 'الحالة');
  String get notes => _t('Notes', 'Notes', 'ملاحظات');
  String get notesHint => _t('Internal notes (optional)', 'Notes internes (optionnel)', 'ملاحظات داخلية (اختياري)');
  String get subtotal => _t('Subtotal', 'Sous-total', 'المجموع الفرعي');
  String get total => _t('Total', 'Total', 'الإجمالي');
  String get profit => _t('Profit', 'Bénéfice', 'الربح');
  String get orderSummary => _t('Order summary', 'Résumé de la commande', 'ملخص الطلب');
  String get saveOrder => _t('Save order', 'Enregistrer la commande', 'حفظ الطلب');
  String get orderSaved => _t('Order saved', 'Commande enregistrée', 'تم حفظ الطلب');
  String get orderUpdated => _t('Order updated', 'Commande mise à jour', 'تم تحديث الطلب');
  String get orderDeleted => _t('Order deleted', 'Commande supprimée', 'تم حذف الطلب');
  String get deleteOrder => _t('Delete order?', 'Supprimer cette commande ?', 'حذف الطلب؟');
  String get deleteOrderBody => _t(
        'This order will be removed from the history. This action cannot be undone.',
        'Cette commande sera retirée de l’historique. Action irréversible.',
        'سيتم حذف هذا الطلب من السجل. لا يمكن التراجع.',
      );
  String get statusUpdated => _t('Status updated', 'Statut mis à jour', 'تم تحديث الحالة');
  String get whatsappConfirm => _t('Confirm on WhatsApp', 'Confirmer sur WhatsApp', 'تأكيد عبر واتساب');
  String get whatsappContact => _t('Contact on WhatsApp', 'Contacter sur WhatsApp', 'تواصل عبر واتساب');
  String get callCustomer => _t('Call customer', 'Appeler le client', 'الاتصال بالعميل');
  String get whatsappUnavailable => _t('WhatsApp unavailable', 'WhatsApp indisponible', 'واتساب غير متاح');
  String get phoneCopied => _t('Phone number copied', 'Numéro copié', 'تم نسخ الرقم');

  String get orderNumber => _t('Order #', 'Commande #', 'الطلب #');
  String get createdAt => _t('Created', 'Créée le', 'أُنشئت');
  String get deliveryInfo => _t('Delivery', 'Livraison', 'التوصيل');
  String get item => _t('item', 'article', 'قطعة');
  String get qtyShort => _t('Qty', 'Qté', 'الكمية');
  String get confirmOrder => _t('Confirm order', 'Confirmer la commande', 'تأكيد الطلب');
  String get markDelivered => _t('Mark as delivered', 'Marquer comme livrée', 'تحديد كمسلّم');
  String get noNotes => _t('No notes', 'Aucune note', 'لا توجد ملاحظات');

  String get searchProduct => _t('Search product…', 'Rechercher un produit…', 'ابحث عن منتج…');
  String get chooseStatus => _t('Change status', 'Changer le statut', 'تغيير الحالة');
  String get callNotSupported => _t('Calls are not available here', 'Les appels ne sont pas disponibles ici', 'الاتصال غير متاح هنا');
  String get phoneRequired => _t('Add a phone number', 'Ajoutez un numéro de téléphone', 'أضف رقم هاتف');
  String get callOutcomeTitle => _t('Call outcome', 'Résultat de l’appel', 'نتيجة المكالمة');
  String get callOutcomeAnswered => _t('Answered', 'Répondu', 'تم الرد');
  String get callOutcomeNoAnswer => _t('No answer', 'Sans réponse', 'بدون إجابة');
  String get callOutcomeCallback => _t('Call back', 'Rappel', 'إعادة الاتصال');
  String get callOutcomePending => _t('Pending', 'En attente', 'معلق');

  // Validation
  String get requiredField => _t('This field is required', 'Ce champ est obligatoire', 'هذا الحقل مطلوب');
  String get invalidPhone => _t(
        'Enter a valid Algerian number (e.g. 0551234567)',
        'Entrez un numéro algérien valide (ex. 0551234567)',
        'أدخل رقم هاتف جزائري صحيح (مثال 0551234567)',
      );
  String get invalidPrice => _t('Enter a valid amount', 'Entrez un montant valide', 'أدخل مبلغًا صحيحًا');
  String get invalidQuantity => _t('Enter a valid quantity', 'Quantité invalide', 'الكمية غير صحيحة');
  String get selectWilayaError => _t('Select a wilaya', 'Sélectionnez une wilaya', 'اختر الولاية');
  String get selectProductError => _t('Select a product', 'Sélectionnez un produit', 'اختر المنتج');

  // Products
  String get productsTitle => _t('Products', 'Produits', 'المنتجات');
  String get catalogueSubtitle => _t('Your products, well organised', 'Votre catalogue, bien organisé', 'منتجاتك منظمة');
  String get noProductsTitle => _t('No products yet', 'Aucun produit', 'لا توجد منتجات بعد');
  String get noProductsBody => _t(
        'Add your first product to start taking orders.',
        'Ajoutez votre premier produit pour commencer.',
        'أضف أول منتج لتبدأ استقبال الطلبات.',
      );
  String get addProduct => _t('Add product', 'Ajouter un produit', 'إضافة منتج');
  String get editProduct => _t('Edit product', 'Modifier le produit', 'تعديل المنتج');
  String get productName => _t('Product name', 'Nom du produit', 'اسم المنتج');
  String get productNameHint => _t('e.g. Chocolate milk 1L', 'ex. Lait chocolaté 1L', 'مثال: حليب بالشوكولاتة 1L');
  String get productPrice => _t('Price', 'Prix', 'السعر');
  String get productCost => _t('Cost price', 'Prix d’achat', 'سعر التكلفة');
  String get productStock => _t('Stock', 'Stock', 'المخزون');
  String get productSaved => _t('Product saved', 'Produit enregistré', 'تم حفظ المنتج');
  String get productUpdated => _t('Product updated', 'Produit mis à jour', 'تم تحديث المنتج');
  String get productDeleted => _t('Product deleted', 'Produit supprimé', 'تم حذف المنتج');
  String get deleteProduct => _t('Delete product?', 'Supprimer ce produit ?', 'حذف المنتج؟');
  String get deleteProductBody => _t(
        'This product will disappear from the catalogue.',
        'Ce produit disparaîtra du catalogue.',
        'سيختفي هذا المنتج من الكتالوج.',
      );
  String get inStock => _t('In stock', 'En stock', 'متوفر');
  String get lowStock => _t('Low stock', 'Stock faible', 'مخزون منخفض');
  String get outOfStock => _t('Out of stock', 'Rupture de stock', 'نفاد المخزون');
  String get margin => _t('Margin', 'Marge', 'الهامش');
  String get unit => _t('unit', 'unité', 'قطعة');
  String get price => _t('Price', 'Prix', 'السعر');
  String get cost => _t('Cost', 'Coût', 'التكلفة');
  String get stock => _t('Stock', 'Stock', 'المخزون');
  String get noProductMatch => _t('No matching product', 'Aucun produit ne correspond', 'لا يوجد منتج مطابق');
  String get productRequiredForOrder => _t('Add a product before creating an order', 'Ajoutez d’abord un produit', 'أضف منتجًا قبل إنشاء طلب');
  String get addProductFirst => _t('Start by adding a product', 'Commencez par ajouter un produit', 'ابدأ بإضافة منتج');
  String get selectProductHint => _t('Choose a product from the list', 'Choisissez un produit dans la liste', 'اختر منتجًا من القائمة');
  String get allProducts => _t('All products', 'Tous les produits', 'كل المنتجات');
  String get maxStock => _t('pieces in stock', 'pièces en stock', 'قطعة في المخزون');

  // Dashboard
  String get dashboardTitle => _t('Overview', 'Tableau de bord', 'لوحة التحكم');
  String get dashboardSubtitle => _t(
        'Sales, profit and returns at a glance',
        'Ventes, bénéfices et retours en un coup d’œil',
        'المبيعات والأرباح والمرتجعات في لمحة',
      );
  String get revenue => _t('Revenue', 'Chiffre d’affaires', 'المداخيل');
  String get profitLabel => _t('Net profit', 'Bénéfice net', 'صافي الربح');
  String get returnRate => _t('Return rate', 'Taux de retour', 'نسبة المرتجعات');
  String get revenueSub => _t('Orders delivered', 'Commandes livrées', 'الطلبات المُسلّمة');
  String get profitSub => _t('After product cost', 'Après coût des produits', 'بعد خصم تكلفة المنتجات');
  String get returnRateSub => _t(
        'out of the orders shipped',
        'sur les commandes expédiées',
        'من الطلبات المُرسلة',
      );
  String get last7Days => _t('7 last days', '7 derniers jours', 'آخر 7 أيام');
  String get last30Days => _t('30 last days', '30 derniers jours', 'آخر 30 يومًا');
  String get allTime => _t('All', 'Tout', 'الكل');
  String get analyticsTitle => _t('Analytics', 'Analytique', 'التحليلات');
  String get analyticsSubtitle => _t(
        'Your performance at a glance',
        'Vos performances en un coup d’œil',
        'أداؤك في لمحة',
      );
  String get revenueChartTitle => _t('Revenue', 'Revenus', 'المداخيل');
  String get revenueChartSubtitle => _t(
        'Orders delivered per day',
        'Commandes livrées par jour',
        'الطلبات المُسلّمة في اليوم',
      );
  String get statusChartTitle => _t('Status breakdown', 'Répartition des statistiques', 'توزيع الحالات');
  String get recentOrders => _t('Recent orders', 'Commandes récentes', 'الطلبات الأخيرة');
  String get noRecentOrders => _t('No recent orders', 'Aucune commande récente', 'لا توجد طلبات حديثة');
  String get vsPrevious => _t('vs previous period', 'vs période précédente', 'مقارنة بالفترة السابقة');
  String get totalOrders => _t('Total orders', 'Commandes', 'الطلبات');
  String get deliveredShort => _t('delivered', 'livrées', 'مُسلّمة');
  String get pendingShort => _t('pending', 'en attente', 'قيد الانتظار');
  String get marginShort => _t('margin', 'marge', 'الهامش');
  String get averageOrder => _t('Average basket', 'Panier moyen', 'متوسط السلة');
  String get dashboardEmptyTitle => _t('Nothing to show yet', 'Rien à afficher', 'لا شيء لعرضه بعد');
  String get dashboardEmptyBody => _t(
        'Create your first order and the numbers will build here.',
        'Créez votre première commande et les chiffres apparaîtront ici.',
        'أنشئ أول طلب وستظهر الأرقام هنا.',
      );
  String get noSalesInPeriod => _t('No sales in this period', 'Aucune vente sur la période', 'لا توجد مبيعات في هذه الفترة');
  String get noSalesInPeriodBody => _t(
        'When orders are delivered, they will appear here.',
        'Dès qu’une commande est marquée livrée, elle apparaît ici.',
        'عندما تُسلَّم الطلبات ستظهر هنا.',
      );
  String get chartRevenue => _t('Revenue', 'Chiffre d’affaires', 'المداخيل');
  String get deliveredOrders => _t('delivered orders', 'commandes livrées', 'طلبات مُسلّمة');

  // Status
  String statusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.newOrder:
        return _t('New', 'Nouvelle', 'جديد');
      case OrderStatus.confirmed:
        return _t('Confirmed', 'Confirmée', 'مؤكد');
      case OrderStatus.shipped:
        return _t('Shipped', 'Expédiée', 'مشحون');
      case OrderStatus.delivered:
        return _t('Delivered', 'Livrée', 'مُسلَّم');
      case OrderStatus.returned:
        return _t('Returned', 'Retournée', 'مرتجع');
      case OrderStatus.cancelled:
        return _t('Cancelled', 'Annulée', 'ملغى');
      case OrderStatus.noAnswer:
        return _t('No answer', 'Sans réponse', 'بدون رد');
    }
  }

  String get statusNew => _t('New', 'Nouvelle', 'جديد');
  String get statusConfirmed => _t('Confirmed', 'Confirmée', 'مؤكدة');
  String get statusShipped => _t('Shipped', 'Expédiée', 'مشحونة');
  String get statusDelivered => _t('Delivered', 'Livrée', 'مُسلَّمة');
  String get statusReturned => _t('Returned', 'Retournée', 'مرتجعة');
  String get statusCancelled => _t('Cancelled', 'Annulée', 'ملغاة');
  String get statusNoAnswer => _t('No answer', 'Sans réponse', 'بدون رد');

  // Settings
  String get settingsTitle => _t('Settings', 'Réglages', 'الإعدادات');
  String get settingsSubtitle => _t(
        'Store, theme, language, data',
        'Boutique, apparence, langue, données',
        'المتجر، المظهر، اللغة، البيانات',
      );
  String get profile => _t('Store', 'Boutique', 'المتجر');
  String get storeName => _t('Store name', 'Nom de la boutique', 'اسم المتجر');
  String get storeNameHint => _t('My store', 'Ma boutique', 'متجري');
  String get editStoreName => _t('Edit store name', 'Modifier le nom de la boutique', 'تعديل اسم المتجر');
  String get storeNameSaved => _t('Store name saved', 'Nom de la boutique enregistré', 'تم حفظ اسم المتجر');
  String get appearance => _t('Appearance', 'Apparence', 'المظهر');
  String get themeSystem => _t('System', 'Système', 'الجهاز');
  String get themeLight => _t('Light', 'Clair', 'فاتح');
  String get themeDark => _t('Dark', 'Sombre', 'داكن');
  String get language => _t('Language', 'Langue', 'اللغة');
  String get arabic => _t('Arabic', 'العربية', 'العربية');
  String get french => _t('French', 'Français', 'الفرنسية');
  String get english => _t('English', 'English', 'الإنجليزية');
  String get languageSubtitle => _t('English, French or Arabic', 'English, Français ou العربية', 'الإنجليزية أو الفرنسية أو العربية');
  String get dataSection => _t('Data', 'Données', 'البيانات');
  String get restoreDemo => _t('Restore demo data', 'Restaurer la démo', 'استعادة بيانات العرض');
  String get restoreDemoBody => _t(
        'Reload the sample store (orders, products, wilayas) to experiment.',
        'Rechargez le magasin de démonstration pour essayer l’app.',
        'إعادة تحميل المتجر التجريبي للتجربة.',
      );
  String get clearData => _t('Clear all data', 'Effacer toutes les données', 'مسح كل البيانات');
  String get clearDataBody => _t(
        'Deletes all local orders, products and customers on this device.',
        'Supprime sur cet appareil toutes les commandes, produits et clients locaux.',
        'يمسح كل الطلبات والمنتجات والعملاء المحلية على هذا الجهاز.',
      );
  String get dataCleared => _t('Local data cleared', 'Données locales effacées', 'تم مسح البيانات المحلية');
  String get demoRestored => _t('Demo data restored', 'Données de démo restaurées', 'تمت استعادة بيانات العرض');
  String get about => _t('About', 'À propos', 'حول التطبيق');
  String get version => _t('Version', 'Version', 'الإصدار');
  String get madeIn => _t('Made in Algeria', 'Fait en Algérie', 'صُنع في الجزائر');
  String get replayOnboarding => _t('Replay onboarding', 'Revoir l’intégration', 'إعادة عرض التعريف');
  String get replayOnboardingSub => _t(
        'Show the 3 intro screens again',
        'Revoir les 3 écrans d’introduction',
        'عرض شاشات التعريف الثلاث مرة أخرى',
      );
  String get onboardingReset => _t('Onboarding reset', 'Intégration réinitialisée', 'تمت إعادة ضبط التعريف');
  String get settingsDemo => _t('Demo mode', 'Mode démo', 'وضع العرض');
  String get support => _t('Support', 'Aide', 'الدعم');
  String get appDescription => _t(
        'OrderBox DZ helps Algerian e-sellers run their shop: orders, customers, products, deliveries and COD.',
        'OrderBox DZ aide les e-commerçants algériens à gérer leur boutique : commandes, clients, produits, livraisons et COD.',
        'يساعد OrderBox DZ البائعين الجزائريين عبر الإنترنت: الطلبات والعملاء والمنتجات والتوصيل والدفع عند الاستلام.',
      );
  String get appearanceSystemHint => _t('Follow device setting', 'Comme le système', 'حسب الجهاز');
  String get appearanceLightHint => _t('Always light', 'Toujours clair', 'فاتح دائمًا');
  String get appearanceDarkHint => _t('Always dark', 'Toujours sombre', 'داكن دائمًا');
  String get profileInitialsHint => _t(
        'Store name is used for your avatar initials',
        'Le nom de la boutique sert pour vos initiales',
        'يُستخدم اسم المتجر في الأحرف الأولى للرمز',
      );
  String get resetOnboarding => _t('Reset', 'Réinitialiser', 'إعادة الضبط');

  // Counts (formatted strings per language)
  String ordersCount(String count) => _t(
        '$count orders',
        '$count commandes',
        '$count طلبات',
      );
  String productsCount(String count) => _t(
        '$count products',
        '$count produits',
        '$count منتجات',
      );

  String whatsappOrderMessage({
    required String customer,
    required String product,
    required String wilaya,
    required String store,
  }) =>
      _t(
        'Hello $customer, your order at $store for $product delivered to $wilaya has been confirmed. Thank you!',
        'Bonjour $customer, votre commande chez $store pour $product livrée à $wilaya est confirmée. Merci !',
        'مرحبًا $customer، تم تأكيد طلبك في $store لـ $product مع التوصيل إلى $wilaya. شكرًا لك!',
      );

  /// Relative day formatter (Today / Yesterday / d/M/yyyy).
  String relativeDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return _t('Today', 'Aujourd’hui', 'اليوم');
    if (diff == 1) return yesterday;
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
