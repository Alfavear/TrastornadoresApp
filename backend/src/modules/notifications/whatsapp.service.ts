import { Injectable, Logger } from '@nestjs/common';

@Injectable()
export class WhatsappService {
  private readonly logger = new Logger(WhatsappService.name);

  /**
   * MOCK PROVIDER
   * Simula el envío de un mensaje de WhatsApp.
   * Más adelante, aquí se integrará Twilio, Meta Cloud API o Baileys.
   */
  async sendMessage(phone: string, message: string): Promise<boolean> {
    this.logger.log(`================================================`);
    this.logger.log(`🚀 [WHATSAPP MOCK] Enviando mensaje a: ${phone}`);
    this.logger.log(`------------------------------------------------`);
    this.logger.log(message);
    this.logger.log(`================================================`);

    // Simular latencia de red
    await new Promise((resolve) => setTimeout(resolve, 800));

    return true; // Simular éxito
  }
}
