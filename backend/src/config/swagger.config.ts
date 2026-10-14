export function shouldEnableSwagger(
  env: NodeJS.ProcessEnv = process.env,
): boolean {
  if (env.NODE_ENV === 'production') {
    return env.ENABLE_SWAGGER === 'true';
  }
  return true;
}
