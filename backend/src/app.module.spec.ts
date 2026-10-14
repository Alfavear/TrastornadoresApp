/* eslint-disable @typescript-eslint/unbound-method */
import {
  AppModule,
  THROTTLE_LIMIT_DEFAULT,
  THROTTLE_TTL_MS,
} from './app.module';
import { ScheduleController } from './modules/schedule/schedule.controller';

describe('AppModule (security hardening 2.11)', () => {
  it('expone constantes de throttling esperadas', () => {
    expect(THROTTLE_TTL_MS).toBe(60_000);
    expect(THROTTLE_LIMIT_DEFAULT).toBe(100);
  });

  it('AppModule importa ThrottlerModule (verifica imports)', () => {
    const imports = Reflect.getMetadata('imports', AppModule) as unknown[];
    expect(imports.length).toBeGreaterThan(0);
  });

  it('notifyGroup tiene throttle estricto anti-spam (10/min)', () => {
    const limit = Reflect.getMetadata(
      'THROTTLER:LIMITdefault',
      ScheduleController.prototype.notifyGroup,
    ) as number;
    const ttl = Reflect.getMetadata(
      'THROTTLER:TTLdefault',
      ScheduleController.prototype.notifyGroup,
    ) as number;
    expect(limit).toBe(10);
    expect(ttl).toBe(60_000);
  });

  it('notifyReminder tiene throttle estricto anti-spam (20/min)', () => {
    const limit = Reflect.getMetadata(
      'THROTTLER:LIMITdefault',
      ScheduleController.prototype.notifyReminder,
    ) as number;
    expect(limit).toBe(20);
  });
});
