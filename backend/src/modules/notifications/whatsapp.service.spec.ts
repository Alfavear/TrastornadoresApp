import { WhatsappService } from './whatsapp.service';

describe('WhatsappService (mock provider)', () => {
  let service: WhatsappService;

  beforeEach(() => {
    service = new WhatsappService();
    jest.spyOn(service['logger'], 'log').mockImplementation(() => undefined);
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('debe retornar true al enviar', async () => {
    const result = await service.sendMessage('+573001234567', 'Hola');
    expect(result).toBe(true);
  });

  it('debe loggear telefono y mensaje', async () => {
    const logSpy = jest.spyOn(service['logger'], 'log');
    await service.sendMessage('3001', 'Recordatorio servicio');
    const allLogs = logSpy.mock.calls.map((c) => String(c[0])).join('\n');
    expect(allLogs).toContain('3001');
    expect(allLogs).toContain('Recordatorio servicio');
  });

  it('debe soportar mensaje grupal largo', async () => {
    const longMsg = 'A'.repeat(2000);
    const result = await service.sendMessage('3001', longMsg);
    expect(result).toBe(true);
  });

  it('debe soportar caracteres especiales y emojis', async () => {
    const result = await service.sendMessage(
      '+57 300 123 4567',
      '🙌 Hola *Ana*! 📅',
    );
    expect(result).toBe(true);
  });
});
