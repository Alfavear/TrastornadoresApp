export interface CorsOptionsShape {
  origin: string[] | boolean;
  credentials: boolean;
  methods: string;
}

const DEV_ORIGINS = [
  'http://localhost:3000',
  'http://localhost:8080',
  'http://localhost:5000',
  'http://10.0.2.2:3000',
];

export function buildCorsOptions(
  env: NodeJS.ProcessEnv = process.env,
): CorsOptionsShape {
  const nodeEnv = env.NODE_ENV ?? 'development';

  if (nodeEnv === 'production') {
    const origins = (env.CORS_ORIGINS ?? '')
      .split(',')
      .map((o) => o.trim())
      .filter(Boolean);
    return {
      origin: origins,
      credentials: true,
      methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    };
  }

  if (nodeEnv === 'staging' || nodeEnv === 'test') {
    const origins = (env.CORS_ORIGINS ?? '')
      .split(',')
      .map((o) => o.trim())
      .filter(Boolean);
    return {
      origin: origins.length > 0 ? origins : DEV_ORIGINS,
      credentials: true,
      methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
    };
  }

  return {
    origin: true,
    credentials: true,
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
  };
}
