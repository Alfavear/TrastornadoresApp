import { buildCorsOptions } from './cors.config';

describe('buildCorsOptions (2.12)', () => {
  it('dev permite todo con credenciales', () => {
    const opts = buildCorsOptions({ NODE_ENV: 'development' });
    expect(opts.origin).toBe(true);
    expect(opts.credentials).toBe(true);
  });

  it('staging usa allowlist o defaults dev', () => {
    const withList = buildCorsOptions({
      NODE_ENV: 'staging',
      CORS_ORIGINS: 'https://a.test, https://b.test',
    });
    expect(withList.origin).toEqual(['https://a.test', 'https://b.test']);

    const withoutList = buildCorsOptions({ NODE_ENV: 'staging' });
    expect((withoutList.origin as string[]).length).toBeGreaterThan(0);
  });

  it('production solo usa CORS_ORIGINS (vacio = denegar todo)', () => {
    const opts = buildCorsOptions({
      NODE_ENV: 'production',
      CORS_ORIGINS: 'https://app.trastornadores.org',
    });
    expect(opts.origin).toEqual(['https://app.trastornadores.org']);

    const empty = buildCorsOptions({ NODE_ENV: 'production' });
    expect(empty.origin).toEqual([]);
  });

  it('ignora espacios y vacios en CORS_ORIGINS', () => {
    const opts = buildCorsOptions({
      NODE_ENV: 'production',
      CORS_ORIGINS: ' https://a.test ,, https://b.test, ',
    });
    expect(opts.origin).toEqual(['https://a.test', 'https://b.test']);
  });
});
