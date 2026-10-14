import { shouldEnableSwagger } from './swagger.config';

describe('shouldEnableSwagger (2.13)', () => {
  it('habilita en desarrollo por defecto', () => {
    expect(shouldEnableSwagger({ NODE_ENV: 'development' })).toBe(true);
  });

  it('habilita en staging/test por defecto', () => {
    expect(shouldEnableSwagger({ NODE_ENV: 'staging' })).toBe(true);
    expect(shouldEnableSwagger({})).toBe(true);
  });

  it('deshabilita en produccion por defecto', () => {
    expect(shouldEnableSwagger({ NODE_ENV: 'production' })).toBe(false);
  });

  it('permite forzar en produccion con ENABLE_SWAGGER=true', () => {
    expect(
      shouldEnableSwagger({
        NODE_ENV: 'production',
        ENABLE_SWAGGER: 'true',
      }),
    ).toBe(true);
  });
});
