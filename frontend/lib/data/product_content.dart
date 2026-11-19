// Catálogo técnico detallado con descripciones, especificaciones y normas para Electro Industrial.
// Cumple con la normativa técnica colombiana (NTC 2050 / RETIE) y estándares de seguridad.

class ProductTechnicalData {
  final String shortDescription;
  final String longDescription;
  final Map<String, String> specs;
  final List<String> applications;
  final List<String>? includes;
  final List<String>? standards;
  final String? brand;
  final String? warranty;

  const ProductTechnicalData({
    required this.shortDescription,
    required this.longDescription,
    required this.specs,
    required this.applications,
    this.includes,
    this.standards,
    this.brand,
    this.warranty,
  });
}

const Map<String, ProductTechnicalData> productTechnicalCatalog = {
  // 1. CABLES
  'CBL-THN-12': ProductTechnicalData(
    shortDescription: 'Conductor de cobre suave para circuitos ramales residenciales y comerciales de 20 A.',
    longDescription:
        'Conductor unipolar de cobre electrolítico de 90 °C con aislamiento termoplástico en PVC y chaqueta exterior de poliamida (nylon). Diseñado para instalaciones en ductos conduit bajo condiciones secas o húmedas según NTC 2050. Instalación por personal calificado según RETIE.',
    specs: {
      'Calibre': '12 AWG',
      'Material': 'Cobre suave recocido',
      'Aislamiento': 'PVC + Chaqueta Nylon',
      'Tensión nominal': '600 V',
      'Temperatura máx.': '90 °C en seco / 75 °C en húmedo',
      'Capacidad corriente': '20 A (conforme NTC 2050)',
    },
    applications: [
      'Circuitos ramales de tomacorrientes e iluminación general',
      'Instalación en ductos embebidos o tubería EMT / PVC',
      'Tableros secundarios de distribución',
    ],
    includes: ['Venta por metro lineal continuo según pedido'],
    standards: [
      'NTC 2050 (Código Eléctrico Colombiano)',
      'UL 83 / NTC 1332',
      '// TODO: verificar con ficha del fabricante certificado de conformidad RETIE',
    ],
    brand: 'Nacional Certificado',
    warranty: '1 año de garantía en aislamiento',
  ),

  'CBL-ENC-314': ProductTechnicalData(
    shortDescription: 'Cable flexible de 3 conductores calibre 14 AWG para extensión y servicio extrapesado.',
    longDescription:
        'Cable multiconductor de cobre flexible clase K aislado con PVC y chaqueta exterior resistente a fricción, humedad y aceites livianos. Indicado para conexión de equipos portátiles, extensiones de taller y maquinaria monofásica con polo a tierra. Instalación por personal calificado según RETIE.',
    specs: {
      'Configuración': '3 conductores (Fase, Neutro, Tierra)',
      'Calibre': '14 AWG',
      'Tensión nominal': '300 / 500 V',
      'Temperatura máx.': '70 °C',
      'Chaqueta': 'PVC negro flexible retardante a la llama',
    },
    applications: [
      'Extensiones eléctricas de uso industrial y comercial',
      'Conexión móvil de motores, taladros y equipos monofásicos',
      'Alimentación de luminarias móviles en obra',
    ],
    includes: ['Venta por metro lineal continuo según pedido'],
    standards: [
      'NTC 2050',
      'NTC 2356',
      '// TODO: verificar con ficha del fabricante certificado RETIE',
    ],
    brand: 'Industrial Pro',
    warranty: '1 año contra fallas de manufactura',
  ),

  'CBL-THN-10': ProductTechnicalData(
    shortDescription: 'Cable unipolar de cobre calibre 10 AWG para alimentadores y cargas de hasta 30 A.',
    longDescription:
        'Conductor de cobre electrolítico de alta pureza con recubrimiento de PVC autoextinguible y película de nylon termorresistente. Apto para alimentación de tableros de distribución, circuitos de aires acondicionados y estufas eléctricas. Instalación por personal calificado según RETIE.',
    specs: {
      'Calibre': '10 AWG',
      'Material': 'Cobre electrolítico recocido',
      'Aislamiento': 'PVC termoplástico + nylon',
      'Tensión': '600 V',
      'Temperatura': '90 °C en seco / 75 °C en mojado',
      'Capacidad corriente': '30 A (NTC 2050)',
    },
    applications: [
      'Circuitos de fuerza para secadoras, estufas y calentadores',
      'Alimentadores secundarios entre medidor y tablero',
      'Conexión de bombas y motores residenciales',
    ],
    includes: ['Venta por metro lineal según requerimiento'],
    standards: [
      'NTC 2050',
      'UL 83',
      '// TODO: verificar con ficha del fabricante certificado RETIE',
    ],
    brand: 'Nacional Certificado',
    warranty: '1 año en integridad dieléctrica',
  ),

  'CBL-THN-14': ProductTechnicalData(
    shortDescription: 'Conductor unipolar de cobre calibre 14 AWG para circuitos de iluminación de 15 A.',
    longDescription:
        'Conductor de cobre suave para cableado interno de edificaciones bajo norma NTC 2050. Su capa de nylon facilita el deslizamiento en tuberías conduit sin desgarrar el aislamiento de PVC. Instalación por personal calificado según RETIE.',
    specs: {
      'Calibre': '14 AWG',
      'Material': 'Cobre sólido o cableado',
      'Aislamiento': 'PVC 90 °C + cubierta de nylon',
      'Tensión de operación': '600 V',
      'Capacidad corriente': '15 A máximo según norma',
    },
    applications: [
      'Circuitos de control y retorno de iluminación',
      'Alimentación de luminarias interiores empotradas y colgantes',
      'Señalización y enclavamientos en tableros',
    ],
    includes: ['Venta por metro lineal continuo'],
    standards: [
      'NTC 2050',
      'UL 83',
      '// TODO: verificar con ficha del fabricante certificado RETIE',
    ],
    brand: 'Nacional Certificado',
    warranty: '1 año de garantía',
  ),

  'CBL-DUP-216': ProductTechnicalData(
    shortDescription: 'Cable flexible dúplex tipo SPT 2x16 AWG para lámparas de mesa y aparatos livianos.',
    longDescription:
        'Cordón paralelo compuesto por dos conductores flexibles de cobre suave aislados integralmente con compuesto de PVC. Diseñado para interconexión visible de artefactos eléctricos residenciales y lámparas de baja potencia. No apto para incrustar en muros ni pisos.',
    specs: {
      'Calibre': '2 x 16 AWG',
      'Conductor': 'Cobre flexible multifilar',
      'Aislamiento': 'PVC paralelo con estría identificadora',
      'Tensión máxima': '300 V',
      'Temperatura máx.': '60 °C',
    },
    applications: [
      'Alimentación de lámparas portátiles y veladores',
      'Conexión de pequeños electrodomésticos clase II',
      'Extensiones caseras de baja exigencia',
    ],
    includes: ['Venta por metro lineal'],
    standards: [
      'NTC 2050',
      'UL 62',
    ],
    brand: 'Genérico Certificado',
    warranty: '6 meses por defecto de fábrica',
  ),

  'CBL-DES-08': ProductTechnicalData(
    shortDescription: 'Alambre de cobre desnudo calibre 8 AWG para mallas y electrodos de puesta a tierra.',
    longDescription:
        'Conductor sólido de cobre electrolítico al 99.9% de pureza sin aislamiento, con alta conductividad eléctrica y resistencia a corrosión salina. Esencial para bajantes de pararrayos, mallas de equipotencialización y unión a varillas de puesta a tierra. Instalación por personal calificado según RETIE.',
    specs: {
      'Calibre': '8 AWG sólido',
      'Pureza de cobre': '99.9% IACS',
      'Resistencia a corrosión': 'Alta en suelo natural',
      'Sección nominal': '8.37 mm²',
    },
    applications: [
      'Conexión entre barraje de tierra y electrodo copperweld',
      'Mallas de puesta a tierra residencial y de subestación',
      'Equipotencialización de estructuras metálicas',
    ],
    includes: ['Venta por metro o peso según pedido'],
    standards: [
      'ASTM B1 / ASTM B3',
      'RETIE Capítulo 15 (Sistemas de Puesta a Tierra)',
      'NTC 2050 Artículo 250',
    ],
    brand: 'Electrocobre Nacional',
    warranty: '5 años contra corrosión prematura',
  ),

  'CBL-CON-208': ProductTechnicalData(
    shortDescription: 'Cable concéntrico antifraude 2x8 AWG para acometidas aéreas monofásicas.',
    longDescription:
        'Cable concéntrico formado por conductor de fase central aislado con polietileno reticulado (XLPE) y neutro helicoidal perimetral protegido con chaqueta exterior en PVC negro resistente a rayos UV. Evita conexiones clandestinas directas en acometidas domiciliarias. Instalación por personal calificado según RETIE.',
    specs: {
      'Calibre': '2 x 8 AWG (Fase central + Neutro concéntrico)',
      'Aislamiento fase': 'XLPE 90 °C',
      'Chaqueta': 'PVC negro con protección UV',
      'Tensión': '600 V',
    },
    applications: [
      'Acometida aérea desde poste hasta caja de medidor',
      'Instalaciones monofásicas antifraude residenciales y rurales',
    ],
    includes: ['Venta por metro lineal'],
    standards: [
      'NTC 2050',
      'Especificaciones de operadores de red en Colombia',
      '// TODO: verificar con ficha del fabricante homologación de operador',
    ],
    brand: 'Redes Pro',
    warranty: '2 años en intemperie',
  ),

  'CBL-UTP-CAT6': ProductTechnicalData(
    shortDescription: 'Cable de red UTP Categoría 6 de 4 pares trenzados para voz y datos a Gigabit Ethernet.',
    longDescription:
        'Cable de datos de 4 pares balanceados con cruceta central dieléctrica para mitigar diafonía (crosstalk). Soporta anchos de banda de hasta 250 MHz para transmisión Gigabit en redes LAN estructuradas de oficinas y locales comerciales.',
    specs: {
      'Categoría': 'Cat 6 U/UTP',
      'Conductores': '4 pares trenzados calibre 23 AWG 100% cobre',
      'Frecuencia de trabajo': 'Hasta 250 MHz',
      'Chaqueta': 'PVC azul retardante a la llama (CM/CMR)',
    },
    applications: [
      'Cableado horizontal en sistemas de cableado estructurado',
      'Conexión de cámaras de seguridad IP y puntos de acceso WiFi',
      'Conexión de puestos de trabajo a switches de red',
    ],
    includes: ['Venta fraccionada por metro o bobina'],
    standards: [
      'ANSI/TIA-568.2-D',
      'ISO/IEC 11801',
    ],
    brand: 'DataLink',
    warranty: '1 año de garantía',
  ),

  // 2. PROTECCIÓN
  'BRK-220-20A': ProductTechnicalData(
    shortDescription: 'Interruptor termomagnético 2P de 20A para riel DIN contra sobrecargas y cortocircuitos.',
    longDescription:
        'Dispositivo de protección bifásica para tableros de distribución con fijación sobre riel simétrico DIN de 35 mm. Brinda seccionamiento simultáneo de dos fases mediante mecanismo de disparo térmico y magnético. Instalación por personal calificado según RETIE.',
    specs: {
      'Corriente nominal (In)': '20 A',
      'Número de polos': '2 polos (bipolar)',
      'Tensión operativa': '230 / 400 V AC',
      'Capacidad cortocircuito': '6 kA (IEC 60898-1)',
      'Curva de disparo': 'Curva C',
      'Montaje': 'Riel DIN 35 mm',
    },
    applications: [
      'Protección de circuitos bifásicos de climatización y calentadores',
      'Subalimentadores en tableros secundarios de distribución',
      'Protección de maquinaria monofásica a 220V',
    ],
    includes: ['1 interruptor bipolar en caja individual'],
    standards: [
      'IEC / EN 60898-1',
      '// TODO: verificar con ficha del fabricante sello RETIE del lote',
    ],
    brand: 'Industrial Standard',
    warranty: '2 años de garantía',
  ),

  'BRK-TOT-40A': ProductTechnicalData(
    shortDescription: 'Interruptor de caja moldeada totalizador 2x40A para corte y protección general.',
    longDescription:
        'Interruptor termomagnético industrial en caja moldeada (MCCB) diseñado como dispositivo de desconexión principal en acometidas residenciales o comerciales. Ofrece alta capacidad de ruptura ante fallas severas y robustez mecánica ante maniobras frecuentes. Instalación por personal calificado según RETIE.',
    specs: {
      'Corriente nominal': '40 A',
      'Polos': '2 polos',
      'Tensión asignada': '240 / 415 V AC',
      'Poder de corte': '10 kA a 240V',
      'Montaje': 'Fijación por tornillos en base de tablero',
    },
    applications: [
      'Corte general en tableros de distribución principal',
      'Interruptor de cabecera en acometidas monofásicas bifilares/trifilares',
      'Protección de tableros de bombeo y fuerza motriz',
    ],
    includes: ['1 interruptor caja moldeada', 'Tornillería de fijación y cubrebornes'],
    standards: [
      'IEC 60947-2',
      'NTC 2050',
      '// TODO: verificar con ficha del fabricante certificado RETIE',
    ],
    brand: 'PowerPro Industrial',
    warranty: '3 años de garantía técnica',
  ),

  'BRK-110-32A': ProductTechnicalData(
    shortDescription: 'Interruptor termomagnético 1P de 32A riel DIN para circuitos monofásicos de potencia.',
    longDescription:
        'Breaker monopolar para riel DIN diseñado para circuitos monofásicos con receptáculos dedicados de alta corriente o equipos de cocina eléctrica. Integra cámara de extinción de arco de múltiples placas para despeje rápido. Instalación por personal calificado según RETIE.',
    specs: {
      'Corriente nominal': '32 A',
      'Número de polos': '1 polo (monopolar)',
      'Tensión nominal': '120 / 240 V AC',
      'Capacidad interruptiva': '6 kA',
      'Curva': 'Curva C',
    },
    applications: [
      'Circuitos monofásicos especiales de calentadores de paso',
      'Protección de circuitos de soldadores monofásicos y compresores',
      'Seccionamiento de fase en cuadros de control',
    ],
    includes: ['1 interruptor monopolar DIN'],
    standards: [
      'IEC 60898-1',
      '// TODO: verificar con ficha del fabricante certificado RETIE',
    ],
    brand: 'Industrial Standard',
    warranty: '2 años de garantía',
  ),

  'TAB-DST-08': ProductTechnicalData(
    shortDescription: 'Tablero metálico de distribución para 8 circuitos tipo enchufable o DIN.',
    longDescription:
        'Gabinete metálico fabricado en lámina de acero galvanizada en frío con acabado de pintura electrostática epoxi-poliéster en polvo. Dispone de barraje de cobre estañado para neutro y barraje de tierra independiente conforme a RETIE.',
    specs: {
      'Capacidad': '8 circuitos / polos',
      'Material': 'Lámina de acero calibre 18 con pintura electrostática',
      'Grado de protección': 'NEMA 1 / IP20 para uso interior',
      'Barrajes': 'Cobre electrolítico con capacidad de 100 A',
    },
    applications: [
      'Centro de carga en apartamentos y residencias unifamiliares',
      'Distribución eléctrica en locales comerciales u oficinas',
    ],
    includes: ['1 tablero con puerta y chapa', 'Barra de neutro y barra de tierra'],
    standards: [
      'RETIE Artículo 20.23 (Cajas y Tableros)',
      'NEMA 1',
      'NTC 2050',
    ],
    brand: 'MetalRedes Colombia',
    warranty: '2 años contra corrosión',
  ),

  'TMC-GFC-15A': ProductTechnicalData(
    shortDescription: 'Tomacorriente dúplex GFCI 15A con botón de prueba y autodiagnóstico de falla a tierra.',
    longDescription:
        'Receptáculo de protección diferencial contra falla a tierra con sensibilidad de disparo de 4 a 6 mA. Integra luz LED indicadora de estado y sistema Tamper Resistant que previene inserción de objetos extraños. Instalación por personal calificado según RETIE.',
    specs: {
      'Corriente': '15 A',
      'Tensión': '125 V AC',
      'Sensibilidad': '4 - 6 mA Clase A',
      'Tiempo de respuesta': '< 25 ms',
      'Función': 'Autotest periódico automático',
    },
    applications: [
      'Zonas húmedas obligatorias: baños, cocinas, lavanderías y patios',
      'Tomacorrientes a la intemperie bajo caja protectora',
      'Talleres y zonas cercanas a tomas de agua',
    ],
    includes: ['1 tomacorriente GFCI', '1 placa de pared decorativa blanca', 'Tornillos de fijación'],
    standards: [
      'UL 943 Clase A',
      'UL 498',
      'RETIE Sección 20.10',
    ],
    brand: 'SafeHome Pro',
    warranty: '2 años de garantía',
  ),

  'PRT-DPS-20K': ProductTechnicalData(
    shortDescription: 'Supresor de sobretensiones transitorias DPS monobloque 20kA para riel DIN.',
    longDescription:
        'Dispositivo de protección contra sobretensiones inducidas por descargas atmosféricas o conmutaciones de red. Incorpora varistores de óxido metálico (MOV) de alta energía con indicador visual de vida útil. Instalación por personal calificado según RETIE.',
    specs: {
      'Corriente nominal (In)': '20 kA (8/20 µs)',
      'Corriente máxima (Imax)': '40 kA',
      'Nivel de protección (Up)': '≤ 1.5 kV',
      'Tensión de trabajo (Uc)': '275 V AC',
      'Montaje': 'Riel DIN 35 mm',
    },
    applications: [
      'Protección de electrodomésticos y equipos electrónicos sensibles',
      'Tableros principales de acometida en zonas de alto nivel isoceráunico',
      'Protección en sistemas de bombeo y telecomunicaciones',
    ],
    includes: ['1 módulo DPS para riel DIN'],
    standards: [
      'IEC 61643-11 Tipo 2',
      'RETIE Capítulo 18 (Protección contra Rayos)',
    ],
    brand: 'SurgeShield',
    warranty: '1 año de garantía',
  ),

  'CNT-MOD-25A': ProductTechnicalData(
    shortDescription: 'Contactor electromagnético modular de 25A en riel DIN para automatización.',
    longDescription:
        'Contactor modular silencioso para montaje en cuadros de distribución. Permite el control remoto de cargas de alumbrado, calefacción o ventilación mediante señal de mando de 220V AC. // TODO: verificar con ficha del fabricante configuración exacta de contactos 1NO+1NC vs 2NO.',
    specs: {
      'Corriente asignada': '25 A (categoría AC-1 / AC-7a)',
      'Tensión de bobina': '220 - 240 V AC 50/60 Hz',
      'Contactos': '1NO + 1NC // TODO: verificar con ficha del fabricante',
      'Montaje': 'Riel DIN simétrico 35 mm',
    },
    applications: [
      'Control centralizado de iluminación con fotoceldas o temporizadores',
      'Arranque de bombas de recirculación y calefactores',
      'Automatización de circuitos de fuerza en edificios',
    ],
    includes: ['1 contactor modular DIN'],
    standards: [
      'IEC / EN 61095',
      'IEC 60947-4-1',
    ],
    brand: 'AutoCtrl Modular',
    warranty: '1 año de garantía',
  ),

  'GRD-MOT-63A': ProductTechnicalData(
    shortDescription: 'Guardamotor termomagnético regulable de 40 a 63A para arranque y protección motriz.',
    longDescription:
        'Interruptor automático diseñado específicamente para la protección y maniobra directa de motores eléctricos trifásicos. Proporciona protección magnetotérmica ajustable compensada por temperatura ambiente y detección de pérdida de fase. Instalación por personal calificado según RETIE.',
    specs: {
      'Rango de regulación térmica': '40 a 63 A ajustable',
      'Disparo magnético': '13 x In (aproximado)',
      'Tensión asignada': '690 V AC',
      'Poder de corte (Icu)': '50 kA a 400V',
      'Mando': 'Botones pulsadores frontales I / O',
    },
    applications: [
      'Protección y arranque manual de bombas de agua y compresores',
      'Protección de motores trifásicos en bandas transportadoras',
      'Seccionamiento de motores industriales en línea de producción',
    ],
    includes: ['1 guardamotor regulable en caja original'],
    standards: [
      'IEC 60947-2',
      'IEC 60947-4-1',
      '// TODO: verificar con ficha del fabricante certificado RETIE',
    ],
    brand: 'MotoGuard Industrial',
    warranty: '2 años de garantía',
  ),

  'CJB-SOB-02': ProductTechnicalData(
    shortDescription: 'Caja plástica de derivación y paso 15x15x8 cm sobreponer con tapa hermética IP55.',
    longDescription:
        'Caja estanca termoplástica libre de halógenos diseñada para empalmes y derivaciones eléctricas en áreas interiores o semi-exteriores protegidas. Dispone de conos pasacables de goma recortables para entrada rápida de tubería conduit.',
    specs: {
      'Dimensiones': '150 x 150 x 80 mm',
      'Material': 'Polipropileno termoplástico de alta resistencia',
      'Grado de protección': 'IP55 / IK07',
      'Cierre': 'Tapa sujeta con 4 tornillos de plástico imperdibles',
    },
    applications: [
      'Caja de paso en redes eléctricas sobrepuestas industriales',
      'Alojamiento de borneras y empalmes en sótanos y parqueaderos',
      'Derivación de ductos de iluminación y fuerza',
    ],
    includes: ['1 caja plástica con tapa', '4 tornillos de fijación', 'Tapones cónicos de goma'],
    standards: [
      'IEC 60670-1',
      'RETIE Artículo 20.23',
    ],
    brand: 'BoxPlast Industrial',
    warranty: '1 año de garantía',
  ),

  // 3. ILUMINACIÓN
  'LED-PN-18W': ProductTechnicalData(
    shortDescription: 'Panel LED redondo 18W para incrustar con luz blanca fría 6500K y driver externo.',
    longDescription:
        'Luminaria de perfil ultra delgado fabricada en aleación de aluminio con difusor opalizado de polimetilmetacrilato (PMMA). Brinda una iluminación homogénea sin deslumbramiento ni parpadeo perceptible, reduciendo el consumo energético hasta en un 80% frente a fluorescentes.',
    specs: {
      'Potencia': '18 W',
      'Flujo luminoso': '1440 lúmenes (80 lm/W)',
      'Temperatura de color': '6500 K (Luz fría día)',
      'Tensión de entrada': '100 - 240 V AC 50/60 Hz',
      'Vida útil': '25.000 horas',
      'Diámetro de corte': '205 mm',
    },
    applications: [
      'Cielos rasos en drywall o PVC en oficinas y consultorios',
      'Iluminación general en salas residenciales y corredores',
      'Locales comerciales y vitrinas',
    ],
    includes: ['1 panel LED redondo', '1 driver electrónico multivoltaje', 'Resortes de fijación'],
    standards: [
      'RETILAP (Reglamento Técnico de Iluminación y Alumbrado Público)',
      'IEC 60598-1',
    ],
    brand: 'LumenTech Pro',
    warranty: '2 años de garantía',
  ),

  'LED-BB-9W': ProductTechnicalData(
    shortDescription: 'Bombillo LED 9W rosca E27 luz cálida 3000K para reemplazar lámparas incandescentes.',
    longDescription:
        'Lámpara LED con bulbo A60 termoplástico disipador de calor y rosca estándar E27. Proporciona encendido instantáneo al 100% de brillo sin calentamiento ambiental ni emisión de radiación infrarroja o UV.',
    specs: {
      'Potencia': '9 W (equivalente a 60 W incandescente)',
      'Flujo luminoso': '800 lúmenes',
      'Temperatura de color': '3000 K (Luz cálida)',
      'Base': 'E27 estándar',
      'Voltaje': '100 - 240 V AC',
      'Ángulo apertura': '220 grados',
    },
    applications: [
      'Lámparas residenciales decorativas de sala y alcobas',
      'Apliques de pared y lámparas de mesa',
      'Iluminación ambiente en restaurantes y cafeterías',
    ],
    includes: ['1 bombillo LED en empaque individual'],
    standards: [
      'RETILAP',
      'IEC 62560',
    ],
    brand: 'EcoLuz Colombia',
    warranty: '1 año de garantía',
  ),

  'LED-REF-50W': ProductTechnicalData(
    shortDescription: 'Reflector LED 50W extraplano para intemperie IP65 con soporte basculante de fijación.',
    longDescription:
        'Proyector de alta eficiencia con carcasa de aluminio inyectado a presión y vidrio templado resistente a choques térmicos. Diseñado para resistir lluvia continua y polución gracias a su estanquidad IP65 con prensaestopas sellado.',
    specs: {
      'Potencia': '50 W',
      'Flujo lumínico': '4500 lúmenes (90 lm/W)',
      'Temperatura color': '6500 K (Blanco frío)',
      'Protección': 'IP65 (resistente a lluvia y polvo)',
      'Tensión': '110 - 240 V AC',
      'Ángulo de haz': '120 grados',
    },
    applications: [
      'Iluminación de fachadas, jardines y accesos vehiculares',
      'Parqueaderos descubiertos y canchas deportivas',
      'Patios de carga y seguridad perimetral',
    ],
    includes: ['1 reflector con soporte metálico basculante', 'Cable de conexión de 30 cm con tierra'],
    standards: [
      'RETILAP',
      'IEC 60598-2-5',
    ],
    brand: 'LumenForce',
    warranty: '2 años de garantía',
  ),

  'LED-CNT-5M': ProductTechnicalData(
    shortDescription: 'Cinta LED 5050 SMD rollo de 5 metros 12V DC luz blanca con autoadhesivo 3M.',
    longDescription:
        'Tira flexible de circuito impreso con 60 diodos LED SMD 5050 por metro lineal. Permite corte cada 5 cm en puntos señalizados para adaptarse a medidas personalizadas en iluminación indirecta.',
    specs: {
      'Longitud': '5 metros',
      'Tipo de LED': 'SMD 5050 (60 LED/m)',
      'Tensión de trabajo': '12 V DC (requiere fuente conmutada)',
      'Consumo': '14.4 W por metro (72 W totales)',
      'Protección': 'IP20 para uso interior',
    },
    applications: [
      'Gargantas de yeso en cielos rasos para luz indirecta',
      'Iluminación bajo muebles de cocina y estanterías',
      'Biselado decorativo en barras y mostradores',
    ],
    includes: ['1 rollo de cinta flexible de 5m con cinta adhesiva posterior'],
    standards: [
      'RETILAP',
      'RoHS / CE',
    ],
    brand: 'LumiFlex',
    warranty: '1 año de garantía',
  ),

  'SNS-MOV-360': ProductTechnicalData(
    shortDescription: 'Sensor de movimiento infrarrojo pasivo PIR 360° para sobreponer en techo.',
    longDescription:
        'Detector de presencia por calor corporal con cabezal sensor de cobertura panorámica de 360 grados. Incluye reguladores analógicos de tiempo de retardo y umbral de luz ambiente (luxes) para evitar encendidos diurnos innecesarios.',
    specs: {
      'Ángulo de detección': '360 grados',
      'Rango de alcance': 'Hasta 6 metros de radio a 2.4 m de altura',
      'Carga máxima': 'Hasta 1200 W incandescente / 300 W LED',
      'Tiempo ajustable': '10 segundos a 7 minutos',
      'Sensibilidad lumínica': '3 a 2000 Lux ajustable',
    },
    applications: [
      'Pasillos de edificios y áreas de circulación común',
      'Baños públicos, escaleras de evacuación y parqueaderos',
      'Bodegas de archivo con encendido bajo demanda',
    ],
    includes: ['1 sensor de movimiento PIR', 'Chazos y tornillos para montaje en techo'],
    standards: [
      'IEC 60669-2-1',
      'RETILAP',
    ],
    brand: 'SensorTech Colombia',
    warranty: '1 año de garantía',
  ),

  'LED-EMG-DBL': ProductTechnicalData(
    shortDescription: 'Lámpara de emergencia doble reflector LED orientable con batería de 90 minutos.',
    longDescription:
        'Unidad autónoma de iluminación de emergencia equipada con batería recargable de libre mantenimiento y circuito de recarga automática. Se activa inmediatamente ante corte en el suministro eléctrico de la red para garantizar rutas de evacuación seguras.',
    specs: {
      'Autonomía': '90 minutos continuos mínimos',
      'Cabezales': '2 focos LED orientables de 3 W cada uno',
      'Batería': 'Batería interna de Ni-Cd / plomo sellada 3.6V - 6V',
      'Alimentación': '110 - 240 V AC permanente',
      'Indicadores': 'LED de carga y botón de prueba frontal',
    },
    applications: [
      'Rutas de evacuación en colegios, oficinas y centros médicos',
      'Pasillos comunes en conjuntos residenciales',
      'Bodegas industriales y locales comerciales obligados por norma',
    ],
    includes: ['1 lámpara de emergencia autónoma', 'Chazos de fijación a muro'],
    standards: [
      'RETILAP Artículo 430 (Sistemas de Iluminación de Emergencia)',
      'NTC 1705',
      'NFPA 101',
    ],
    brand: 'SafeLight Emergency',
    warranty: '1 año de garantía',
  ),

  'SOL-REF-100': ProductTechnicalData(
    shortDescription: 'Luminaria solar suburbana 100W con panel fotovoltaico integrado y control remoto.',
    longDescription:
        'Sistema autónomo de alumbrado solar compuesto por panel fotovoltaico monocristalino, batería de fosfato de hierro y litio (LiFePO4) de larga duración y módulo LED de alta luminosidad. No requiere zanjas ni cableado eléctrico de red.',
    specs: {
      'Potencia': '100 W LED equivalente',
      'Panel': 'Panel solar integrado en la carcasa superior',
      'Batería': 'Batería de Litio LiFePO4 de carga rápida (6-8 h sol)',
      'Autonomía': '10 a 12 horas de operación nocturna',
      'Control': 'Control remoto por infrarrojos con temporizador y modo radar',
      'Protección': 'IP65 hermético para intemperie',
    },
    applications: [
      'Fincas, condominios campestres y senderos peatonales',
      'Parqueaderos exteriores sin acometida cercana',
      'Iluminación de seguridad perimetral en predios rurales',
    ],
    includes: ['1 luminaria solar 100W', '1 control remoto con baterías', 'Brazalete de anclaje para tubo'],
    standards: [
      'RETILAP',
      'IEC 60598-2-3',
    ],
    brand: 'SolarLite Pro',
    warranty: '1 año de garantía en kit completo',
  ),

  'LED-OJB-7W': ProductTechnicalData(
    shortDescription: 'Ojo de buey LED 7W dirigible en aluminio para cielo raso luz neutra 4000K.',
    longDescription:
        'Spot empotrable basculante con aro exterior de aluminio macizo y reflector facetado antideslumbrante. Su cabezal permite orientar el haz de luz hasta 30 grados para acentuar elementos arquitectónicos, cuadros o muros de textura.',
    specs: {
      'Potencia': '7 W',
      'Flujo luminoso': '560 lúmenes',
      'Temperatura': '4000 K (Blanco neutro natural)',
      'Ángulo basculante': '30 grados de inclinación',
      'Diámetro corte': '75 mm',
    },
    applications: [
      'Iluminación de acento en galerías y salas de estar',
      'Vitrinas comerciales y estantes de exhibición',
      'Recepción y salas de espera de oficinas',
    ],
    includes: ['1 spot orientable con driver integrado y grapas'],
    standards: [
      'RETILAP',
      'IEC 60598-1',
    ],
    brand: 'LumenTech Pro',
    warranty: '2 años de garantía',
  ),

  'IND-HGB-100': ProductTechnicalData(
    shortDescription: 'Campana industrial High Bay 100W tipo OVNI para bodegas con disipador radial.',
    longDescription:
        'Luminaria suspendida de gran altura con diseño aerodinámico tipo UFO en fundición de aluminio inyectado. Incorpora driver de corriente constante y chips LED con índice de rendimiento cromático superior a 80 para naves industriales de hasta 8 metros de altura.',
    specs: {
      'Potencia': '100 W',
      'Eficacia': '130 lm/W (13.000 lúmenes)',
      'Factor de potencia': '> 0.95',
      'Protección': 'IP65 estanco / IK08 resistencia mecánica',
      'Temperatura': '5700 K blanco frío industrial',
    },
    applications: [
      'Bodegas de almacenamiento y centros de logística',
      'Talleres metalmecánicos y líneas de ensamble',
      'Hangares y gimnasios cubiertos',
    ],
    includes: ['1 campana High Bay UFO', '1 gancho de cáncamo para suspensión'],
    standards: [
      'RETILAP',
      'IEC 60598-2-1',
    ],
    brand: 'NovaTech Industrial',
    warranty: '3 años de garantía profesional',
  ),

  // 4. HERRAMIENTAS
  'HTL-MULT-3': ProductTechnicalData(
    shortDescription: 'Instrumento digital de medición de tensión AC/DC, corriente y continuidad con buzzer.',
    longDescription:
        'Medidor digital portátil para mantenimiento eléctrico industrial y residencial con pantalla LCD retroiluminada de 2000 cuentas. Incluye protección contra sobrecargas en rangos de medida y clasificación de seguridad CAT III 600V para trabajo seguro en tableros eléctricos.',
    specs: {
      'Categoría de seguridad': 'CAT III 600 V / CAT II 1000 V',
      'Tensión DC': '200 mV a 600 V (precisión ±0.5%)',
      'Tensión AC': '200 V a 600 V (precisión ±1.2%)',
      'Corriente DC': 'Hasta 10 A protegida por fusible cerámico',
      'Resistencia': '200 Ω a 2 MΩ',
      'Funciones': 'Prueba de diodos, buzzer de continuidad y retención Hold',
    },
    applications: [
      'Diagnóstico y verificación de circuitos en tableros de control',
      'Detección de continuidad en cableados y bobinados',
      'Verificación de niveles de tensión en tomacorrientes y acometidas',
    ],
    includes: [
      '1 multímetro digital con funda de goma antichoque',
      '1 par de puntas de prueba con capuchones protectores',
      '1 batería de 9V instalada',
      'Manual de usuario en español',
    ],
    standards: [
      'IEC 61010-1 (Seguridad para equipos de medición eléctrica)',
    ],
    brand: 'ElectroTech Tools',
    warranty: '1 año de garantía del fabricante',
  ),

  'HTL-PEL-8': ProductTechnicalData(
    shortDescription: 'Pinza pelacables y cortacables automática 8 pulgadas para calibres 10 a 24 AWG.',
    longDescription:
        'Herramienta ergonómica multifuncional con mordazas de agarre sincronizado que despojan la chaqueta de conductores sin marcar el cobre. Cuenta con tope regulable de longitud de desaislado y cortador integrado en el mango.',
    specs: {
      'Longitud': '8 pulgadas (205 mm)',
      'Capacidad pelado': '10 a 24 AWG (0.2 a 6.0 mm²)',
      'Capacidad ponchado': 'Terminales aislados 10-22 AWG',
      'Material mordaza': 'Acero al carbono tratado térmicamente',
    },
    applications: [
      'Pelado rápido de cables en montaje de tableros y cajas 4x4',
      'Instalación repetitiva de tomacorrientes e interruptores',
      'Crimpeado de terminales de ojal y pala en control industrial',
    ],
    includes: ['1 pinza pelacables automática en blíster'],
    standards: [
      'ANSI B107',
    ],
    brand: 'MasterGrip Tools',
    warranty: '1 año de garantía por desgaste anormal',
  ),

  'HTL-CIN-18': ProductTechnicalData(
    shortDescription: 'Cinta aislante de PVC retardante a la llama 18 metros negra para empalmes a 600V.',
    longDescription:
        'Cinta aislante profesional a base de policloruro de vinilo con adhesivo de caucho de alta adherencia que no deja residuos pegajosos. Resistente a abrasión, humedad, álcalis y rayos UV en empalmes de hasta 600 voltios y 80 °C.',
    specs: {
      'Dimensiones': '19 mm de ancho x 18 m de longitud x 0.15 mm espesor',
      'Rigidez dieléctrica': 'Hasta 600 V dieléctricos',
      'Temperatura operación': 'Hasta 80 °C',
      'Propiedad': 'Autoextinguible y retardante al fuego',
    },
    applications: [
      'Aislamiento eléctrico primario en empalmes de baja tensión',
      'Protección mecánica de chaquetas dañadas en cables',
      'Agrupamiento y codificación de fases en tableros',
    ],
    includes: ['1 rollo de cinta de 18 metros con envoltura de celofán'],
    standards: [
      'RETIE Sección 20.3 (Cintas Aislantes)',
      'UL 510',
      'NTC 1031',
    ],
    brand: 'Scotch / Industrial Grip',
    warranty: 'Garantía de adherencia en producto sellado',
  ),

  'HTL-DET-VOL': ProductTechnicalData(
    shortDescription: 'Detector de voltaje tipo lápiz sin contacto 90-1000V AC con linterna y alarma sonora.',
    longDescription:
        'Instrumento de seguridad personal tipo bolígrafo que detecta campos electrostáticos generados por tensión alterna sin contacto metálico. Emite pitido continuo y luz roja brillante en la punta al acercarse a conductores con energía.',
    specs: {
      'Rango detección': '90 a 1000 V AC',
      'Frecuencia': '50 / 60 Hz',
      'Categoría': 'CAT IV 1000 V',
      'Alarmas': 'Buzzer acústico y luz LED frontal ultra brillante',
      'Alimentación': '2 pilas AAA (incluidas)',
    },
    applications: [
      'Comprobación rápida de ausencia de tensión antes de intervenir un circuito',
      'Detección de fase vs neutro en tomacorrientes',
      'Localización de cortes internos en cables de extensión',
    ],
    includes: ['1 detector de voltaje sin contacto', '2 pilas AAA alcalinas', 'Clip de bolsillo'],
    standards: [
      'IEC 61010-1 CAT IV 1000V',
    ],
    brand: 'VoltAlert Pro',
    warranty: '1 año de garantía',
  ),

  'HTL-PNC-HDR': ProductTechnicalData(
    shortDescription: 'Ponchadora hidráulica manual de 10 a 300 mm² con 11 pares de dados hexagonales.',
    longDescription:
        'Crimpadora hidráulica manual con cabezal giratorio de 180 grados para facilitar el trabajo en espacios reducidos de subestaciones. Desarrolla una fuerza de compresión de hasta 16 toneladas garantizando contacto homogéneo y baja resistencia en terminales de cobre y aluminio.',
    specs: {
      'Rango prensado': '10 a 300 mm² (calibre 8 AWG a 600 MCM)',
      'Fuerza máxima': '16 toneladas métricas',
      'Tipo de compresión': 'Hexagonal profunda',
      'Dados incluidos': '11 matrices (10, 16, 25, 35, 50, 70, 95, 120, 150, 185, 240, 300 mm²)',
    },
    applications: [
      'Compresión de terminales de cobre en acometidas generales',
      'Prensado de conectores en transformadores y plantas eléctricas',
      'Armado de puentes de equipotencialización y cables de potencia',
    ],
    includes: ['1 ponchadora hidráulica', '11 juegos de dados intercambiables', 'Juego de sellos O-ring de repuesto', 'Maletín plástico de alto impacto'],
    standards: [
      'DIN 46235 para compresión hexagonal',
    ],
    brand: 'HydroCrimper Pro',
    warranty: '2 años de garantía mecánica',
  ),

  'HTL-DST-100': ProductTechnicalData(
    shortDescription: 'Juego de 6 destornilladores aislados 1000V con certificación VDE en estuche.',
    longDescription:
        'Herramientas manuales con vástago de acero al cromo-vanadio-molibdeno templado y aislamiento inyectado de doble capa ensayado a 10.000V. Mango ergonómico bimaterial con zonas antideslizantes para óptima transmisión de par de apriete sin fatiga.',
    specs: {
      'Aislamiento': 'Certificado VDE / 1000 V AC - 1500 V DC',
      'Puntas de pala': '3.0x75 mm, 4.0x100 mm, 5.5x125 mm',
      'Puntas de estrella': 'PH0x75 mm, PH1x80 mm, PH2x100 mm',
      'Material varilla': 'Acero Cr-V endurecido con acabado fosfatado negro',
    },
    applications: [
      'Instalación y apriete seguro de bornes en tableros energizados',
      'Montaje de interruptores termomagnéticos y contactores',
      'Mantenimiento en cuadros eléctricos bajo protocolos RETIE',
    ],
    includes: ['6 destornilladores aislados VDE', '1 buscapolos de prueba 110-250V', 'Estuche de lona con cremallera'],
    standards: [
      'IEC 60900 (Trabajos en tensión - Herramientas de mano)',
      'VDE GS',
    ],
    brand: 'InsulTech 1000V',
    warranty: 'Garantía de por vida contra rotura de vástago',
  ),

  'HTL-SND-30M': ProductTechnicalData(
    shortDescription: 'Sonda pasacables de nylon de 30 metros con punta flexible metálica guiadora.',
    longDescription:
        'Guía pasacables fabricada en monofilamento de nylon de alta tenacidad con excelente rigidez para evitar atascamientos en codos cerrados de 90 grados. Equipada con punta esférica flexible de acero niquelado y ojal de tracción en el extremo posterior.',
    specs: {
      'Longitud': '30 metros continuos',
      'Diámetro': '4.0 mm de espesor',
      'Material': 'Poliamida sólida resistente a fricción',
      'Resistencia a tracción': 'Hasta 120 kg de fuerza',
    },
    applications: [
      'Enhebrado de cables en tuberías conduit metálicas EMT o corrugadas',
      'Cableado de circuitos ramales en placas de entrepiso y muros',
      'Tendido de acometidas subterráneas residenciales',
    ],
    includes: ['1 sonda pasacables de 30 m con puntera metálica roscada'],
    standards: [
      'Calidad industrial para obras eléctricas',
    ],
    brand: 'CablePilot',
    warranty: '1 año de garantía en puntera y monofilamento',
  ),

  'HTL-PNZ-AMP': ProductTechnicalData(
    shortDescription: 'Pinza amperimétrica digital True-RMS 600A AC con lectura de voltaje y temperatura.',
    longDescription:
        'Instrumento de medición con pinza toroidal de 30 mm de apertura para medir corriente alterna sin interrumpir el conductor. Su tecnología True-RMS garantiza lecturas exactas en presencia de armónicos generados por variadores de frecuencia y fuentes conmutadas.',
    specs: {
      'Corriente AC': 'Hasta 600 A (True-RMS)',
      'Tensión AC/DC': 'Hasta 600 V',
      'Resistencia y continuidad': 'Hasta 40 MΩ con buzzer sonoro',
      'Temperatura': '-20 °C a 750 °C con termocupla tipo K',
      'Seguridad': 'CAT III 600 V',
    },
    applications: [
      'Balanceo de cargas entre fases en tableros principales',
      'Medición de corriente de arranque en motores industriales',
      'Detección de sobrecalentamiento y fugas en alimentadores',
    ],
    includes: [
      '1 pinza amperimétrica digital True-RMS',
      '1 par de cables de prueba con puntas aisladas',
      '1 sonda termocupla tipo K para temperatura',
      '2 pilas AAA alcalinas',
      'Estuche protector con cremallera',
    ],
    standards: [
      'IEC 61010-1 CAT III 600V',
      'IEC 61010-2-032',
    ],
    brand: 'MeterMaster Pro',
    warranty: '2 años de garantía del fabricante',
  ),

  'HTL-CAU-60W': ProductTechnicalData(
    shortDescription: 'Cautín tipo lápiz 60W para electrónica y empalmes con base metálica y soldadura.',
    longDescription:
        'Soldador eléctrico tipo lápiz con núcleo cerámico de calentamiento rápido y punta cónica de larga duración tratada contra oxidación. Adecuado para uniones eléctricas de precisión en tarjetas electrónicas y estañado de terminales.',
    specs: {
      'Potencia': '60 W',
      'Tensión de trabajo': '110 - 125 V AC',
      'Temperatura punta': 'Hasta 450 °C estable',
      'Punta': 'Punta de cobre revestida en hierro niquelado reemplazable',
      'Cable': 'Cordón con aislamiento térmico y clavija con polo a tierra',
    },
    applications: [
      'Soldadura y desoldadura en placas electrónicas de control',
      'Estañado de puntas de cables multifilares antes del borneo',
      'Reparación de empalmes en cables de señal y audio',
    ],
    includes: [
      '1 cautín eléctrico de 60W',
      '1 soporte metálico con esponja de limpieza humedecible',
      '1 tubo con soldadura de estaño-plomo 60/40 con resina',
    ],
    standards: [
      'IEC 60335-2-45 (Seguridad en herramientas electrotérmicas portátiles)',
    ],
    brand: 'SolderPro Precision',
    warranty: '1 año de garantía',
  ),
};
