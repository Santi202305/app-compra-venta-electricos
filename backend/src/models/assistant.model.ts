export interface BotAnswer {
  key: string;
  label: string;
  text: string;
}

export const FAQ_DATA: Record<string, BotAnswer> = {
  horario: {
    key: 'horario',
    label: '🕒 Horario de atención',
    text: 'Atendemos de lunes a viernes de 7:30 a.m. a 6:00 p.m. y sábados de 8:00 a.m. a 2:00 p.m. Domingos y festivos cerrado.',
  },
  envios: {
    key: 'envios',
    label: '🚚 Tiempo de envío',
    text: 'Los envíos locales llegan el mismo día si pides antes de las 2:00 p.m. A otros municipios de Colombia, de 1 a 3 días hábiles.',
  },
  pagos: {
    key: 'pagos',
    label: '💳 Métodos de pago',
    text: 'Aceptamos Nequi, tarjeta débito/crédito, transferencia bancaria y pago contraentrega (Efecty).',
  },
  garantia: {
    key: 'garantia',
    label: '🛠️ Garantía',
    text: 'Todos los materiales eléctricos certificados bajo norma RETIE tienen garantía de 12 meses. Herramientas: 6 meses.',
  },
  devolucion: {
    key: 'devolucion',
    label: '↩️ Cambios y devoluciones',
    text: 'Dispones de 5 días hábiles para cambios o devoluciones con el material sin usar, empaque original y factura de compra.',
  },
};
