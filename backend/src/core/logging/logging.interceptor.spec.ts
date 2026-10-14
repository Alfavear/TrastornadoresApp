/* eslint-disable @typescript-eslint/no-unsafe-member-access */
import { Logger } from '@nestjs/common';
import { of, throwError } from 'rxjs';
import { LoggingInterceptor } from './logging.interceptor';

function buildContext() {
  const req = { method: 'GET', url: '/schedule', user: { uid: 'u1' } };
  return {
    req,
    context: {
      switchToHttp: () => ({ getRequest: () => req }),
    } as never,
  };
}

describe('LoggingInterceptor (2.14)', () => {
  const OLD_ENV = process.env;
  let logSpy: jest.SpyInstance;

  beforeEach(() => {
    process.env = { ...OLD_ENV };
    logSpy = jest
      .spyOn(Logger.prototype, 'log')
      .mockImplementation(() => undefined);
  });

  afterEach(() => {
    process.env = OLD_ENV;
    logSpy.mockRestore();
  });

  it('loggea en texto en desarrollo', (done) => {
    process.env.NODE_ENV = 'development';
    const { context } = buildContext();
    const interceptor = new LoggingInterceptor();
    interceptor
      .intercept(context, { handle: () => of({ ok: true }) })
      .subscribe({
        next: () => {
          expect(logSpy).toHaveBeenCalled();
          expect(String(logSpy.mock.calls[0][0])).toContain('GET /schedule');
          done();
        },
      });
  });

  it('loggea JSON estructurado en produccion', (done) => {
    process.env.NODE_ENV = 'production';
    const { context } = buildContext();
    const interceptor = new LoggingInterceptor();
    interceptor
      .intercept(context, { handle: () => of({ ok: true }) })
      .subscribe({
        next: () => {
          const payload = JSON.parse(String(logSpy.mock.calls[0][0])) as Record<
            string,
            unknown
          >;
          expect(payload.method).toBe('GET');
          expect(payload.url).toBe('/schedule');
          expect(payload.uid).toBe('u1');
          expect(typeof payload.durationMs).toBe('number');
          done();
        },
      });
  });

  it('loggea errores sin romper el stream', (done) => {
    process.env.NODE_ENV = 'production';
    const { context } = buildContext();
    const interceptor = new LoggingInterceptor();
    interceptor
      .intercept(context, {
        handle: () => throwError(() => new Error('boom')),
      })
      .subscribe({
        error: (err: Error) => {
          expect(err.message).toBe('boom');
          expect(logSpy).toHaveBeenCalled();
          expect(String(logSpy.mock.calls[0][0])).toContain('boom');
          done();
        },
      });
  });
});
