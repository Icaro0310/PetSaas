/// Resolve o asset de retrato pixel-art para a raca do pet.
///
/// Os assets em `assets/pet_faces/` sao os mesmos sprites da biblioteca
/// PetDeskSaas (tray.png de cada raca). A raca no modelo e texto livre,
/// por isso o matching e por palavras-chave sobre o nome normalizado.
library;

const _faceAssets = [
  'beagle',
  'black-cat',
  'border-collie',
  'bulldog',
  'calico',
  'corgi',
  'dachshund',
  'german-shepherd',
  'golden',
  'grey-tabby',
  'husky',
  'labrador',
  'maine-coon',
  'orange-tabby',
  'persian',
  'poodle',
  'pug',
  'shiba',
  'siamese',
  'srd-caramelo',
  'srd-preto',
  'tuxedo-cat',
  'yorkshire',
];

// Sinónimos/keywords -> slug da biblioteca. Ordem importa (mais especifico
// primeiro; 'srd' antes de raças para "vira-lata" nao colidir com nomes).
const _aliases = <String, List<String>>{
  'srd-caramelo': ['srd', 'vira-lata', 'vira lata', 'sem raca', 'sem raça', 'mestiço', 'mestico'],
  'srd-preto': ['vira-lata preto', 'srd preto'],
  'golden': ['golden', 'retriever'],
  'labrador': ['labrador', 'lab'],
  'german-shepherd': ['pastor alemao', 'pastor alemao', 'german shepherd', 'pastor'],
  'border-collie': ['border collie', 'collie'],
  'beagle': ['beagle'],
  'bulldog': ['bulldog', 'buldogue'],
  'corgi': ['corgi'],
  'dachshund': ['dachshund', 'salsicha', 'teckel', 'basset'],
  'husky': ['husky'],
  'poodle': ['poodle'],
  'pug': ['pug'],
  'shiba': ['shiba', 'akita'],
  'yorkshire': ['yorkshire', 'yorkie'],
  'black-cat': ['gato preto', 'black cat'],
  'calico': ['calico', 'tricolor'],
  'grey-tabby': ['grey tabby', 'cinza', 'cinzento', 'tigrado cinza'],
  'maine-coon': ['maine coon'],
  'orange-tabby': ['orange tabby', 'laranja', 'gato laranja', 'tigrado'],
  'persian': ['persa', 'persian'],
  'siamese': ['siames', 'siamês'],
  'tuxedo-cat': ['tuxedo', 'smoking'],
};

/// Normaliza o nome da raca (lowercase, sem acentos) para matching.
String _norm(String s) {
  const accents = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c', 'ñ': 'n',
  };
  var out = s.toLowerCase().trim();
  accents.forEach((a, r) => out = out.replaceAll(a, r));
  return out;
}

/// Devolve o asset `assets/pet_faces/<slug>.png` para a raca, ou null se nao
/// houver correspondencia. A raca e texto livre; o matching usa aliases e
/// substring sobre o nome normalizado.
String? petFaceAsset(String? breed) {
  if (breed == null || breed.trim().isEmpty) return null;
  final b = _norm(breed);

  for (final slug in _faceAssets) {
    if (b == slug || b == slug.replaceAll('-', ' ')) return slug;
  }
  for (final entry in _aliases.entries) {
    if (entry.value.any((a) => b.contains(_norm(a)))) return entry.key;
  }
  for (final slug in _faceAssets) {
    final stem = slug.split('-').first;
    if (stem.length >= 4 && b.contains(stem)) return slug;
  }
  return null;
}
