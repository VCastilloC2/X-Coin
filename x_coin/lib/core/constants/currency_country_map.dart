/// Mapeo entre el código ISO 4217 de una moneda (ej. `USD`) y el
/// código ISO 3166-1 alpha-2 de su país representativo (ej. `us`),
/// usado para construir la URL de la bandera oficial en FlagCDN:
/// `https://flagcdn.com/w40/{country_code}.png`.
///
/// Cubre el catálogo completo soportado por Frankfurter API más un
/// amplio conjunto de divisas adicionales, de forma que **cualquier**
/// moneda que el backend agregue en el futuro tenga alta probabilidad
/// de resolver su bandera sin tocar este archivo de nuevo.
class CurrencyCountryMap {
  CurrencyCountryMap._();

  static const Map<String, String> countryByCurrency = {
    'AED': 'ae', 'AFN': 'af', 'ALL': 'al', 'AMD': 'am', 'ANG': 'cw',
    'AOA': 'ao', 'ARS': 'ar', 'AUD': 'au', 'AWG': 'aw', 'AZN': 'az',
    'BAM': 'ba', 'BBD': 'bb', 'BDT': 'bd', 'BGN': 'bg', 'BHD': 'bh',
    'BIF': 'bi', 'BMD': 'bm', 'BND': 'bn', 'BOB': 'bo', 'BRL': 'br',
    'BSD': 'bs', 'BTN': 'bt', 'BWP': 'bw', 'BYN': 'by', 'BZD': 'bz',
    'CAD': 'ca', 'CDF': 'cd', 'CHF': 'ch', 'CLP': 'cl', 'CNY': 'cn',
    'COP': 'co', 'CRC': 'cr', 'CUP': 'cu', 'CVE': 'cv', 'CZK': 'cz',
    'DJF': 'dj', 'DKK': 'dk', 'DOP': 'do', 'DZD': 'dz', 'EGP': 'eg',
    'ERN': 'er', 'ETB': 'et', 'EUR': 'eu', 'FJD': 'fj', 'FKP': 'fk',
    'GBP': 'gb', 'GEL': 'ge', 'GHS': 'gh', 'GIP': 'gi', 'GMD': 'gm',
    'GNF': 'gn', 'GTQ': 'gt', 'GYD': 'gy', 'HKD': 'hk', 'HNL': 'hn',
    'HTG': 'ht', 'HUF': 'hu', 'IDR': 'id', 'ILS': 'il', 'INR': 'in',
    'IQD': 'iq', 'IRR': 'ir', 'ISK': 'is', 'JMD': 'jm', 'JOD': 'jo',
    'JPY': 'jp', 'KES': 'ke', 'KGS': 'kg', 'KHR': 'kh', 'KMF': 'km',
    'KPW': 'kp', 'KRW': 'kr', 'KWD': 'kw', 'KYD': 'ky', 'KZT': 'kz',
    'LAK': 'la', 'LBP': 'lb', 'LKR': 'lk', 'LRD': 'lr', 'LSL': 'ls',
    'LYD': 'ly', 'MAD': 'ma', 'MDL': 'md', 'MGA': 'mg', 'MKD': 'mk',
    'MMK': 'mm', 'MNT': 'mn', 'MOP': 'mo', 'MRU': 'mr', 'MUR': 'mu',
    'MVR': 'mv', 'MWK': 'mw', 'MXN': 'mx', 'MYR': 'my', 'MZN': 'mz',
    'NAD': 'na', 'NGN': 'ng', 'NIO': 'ni', 'NOK': 'no', 'NPR': 'np',
    'NZD': 'nz', 'OMR': 'om', 'PAB': 'pa', 'PEN': 'pe', 'PGK': 'pg',
    'PHP': 'ph', 'PKR': 'pk', 'PLN': 'pl', 'PYG': 'py', 'QAR': 'qa',
    'RON': 'ro', 'RSD': 'rs', 'RUB': 'ru', 'RWF': 'rw', 'SAR': 'sa',
    'SBD': 'sb', 'SCR': 'sc', 'SDG': 'sd', 'SEK': 'se', 'SGD': 'sg',
    'SHP': 'sh', 'SLE': 'sl', 'SOS': 'so', 'SRD': 'sr', 'SSP': 'ss',
    'STN': 'st', 'SYP': 'sy', 'SZL': 'sz', 'THB': 'th', 'TJS': 'tj',
    'TMT': 'tm', 'TND': 'tn', 'TOP': 'to', 'TRY': 'tr', 'TTD': 'tt',
    'TWD': 'tw', 'TZS': 'tz', 'UAH': 'ua', 'UGX': 'ug', 'USD': 'us',
    'UYU': 'uy', 'UZS': 'uz', 'VES': 've', 'VND': 'vn', 'VUV': 'vu',
    'WST': 'ws', 'YER': 'ye', 'ZAR': 'za', 'ZMW': 'zm', 'ZWL': 'zw',
  };

  /// Divisas sin un país único representativo: metales preciosos,
  /// derechos especiales de giro (FMI) o uniones monetarias
  /// multinacionales (varios países comparten la misma moneda, por
  /// lo que ninguna bandera individual sería correcta). Para estas se
  /// debe mostrar siempre el ícono de respaldo, nunca una bandera.
  static const Set<String> noFlagCurrencies = {
    'XDR', // Derechos Especiales de Giro (FMI)
    'XAU', 'XAG', 'XPD', 'XPT', // Metales preciosos
    'XOF', // Franco CFA (África Occidental, 8 países)
    'XAF', // Franco CFA (África Central, 6 países)
    'XCD', // Dólar del Caribe Oriental (8 territorios)
    'XPF', // Franco CFP (Polinesia/Nueva Caledonia)
  };

  /// Resuelve el código de país para una moneda, o `null` si no tiene
  /// un país único asociado (debe usarse el ícono de respaldo).
  static String? countryCodeFor(String isoCurrency) {
    final code = isoCurrency.toUpperCase();
    if (noFlagCurrencies.contains(code)) return null;
    return countryByCurrency[code];
  }
}
