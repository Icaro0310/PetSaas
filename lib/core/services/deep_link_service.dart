/// Servico para tratar deep links (/p/:uuid e /join?token=...).
///
/// O roteamento real e feito pelo go_router; este servico expoe helpers
/// para construir URIs publicos da pagina do pet e do convite de cuidador.
class DeepLinkService {
  DeepLinkService._();

  /// Base URL publica (web). Em producao, substituir pelo dominio real.
  /// TODO: Quando o dominio custom estiver configurado, trocar por:
  ///   static const String webBaseUrl = 'https://app.petcare.com';
  static const String webBaseUrl = 'https://moonlit-pothos-c56cd4.netlify.app';

  static String publicPetUrl(String qrCodeUuid) =>
      '$webBaseUrl/p/$qrCodeUuid';

  static String inviteUrl(String token) => '$webBaseUrl/join?token=$token';
}
