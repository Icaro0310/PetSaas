/// Serviço para tratar deep links (/pet/:uuid e /join?token=...).
///
/// O roteamento real é feito pelo go_router; este serviço expõe helpers
/// para construir URIs públicos da página do pet e do convite de cuidador.
class DeepLinkService {
  DeepLinkService._();

  /// Base URL pública (web). Em produção, substituir pelo domínio real.
  static const String webBaseUrl = 'https://petcare-micro-saas.web.app';

  static String publicPetUrl(String qrCodeUuid) =>
      '$webBaseUrl/pet/$qrCodeUuid';

  static String inviteUrl(String token) => '$webBaseUrl/join?token=$token';
}
