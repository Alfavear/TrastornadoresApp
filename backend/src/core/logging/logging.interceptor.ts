import {
  CallHandler,
  ExecutionContext,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = context.switchToHttp().getRequest<{
      method?: string;
      url?: string;
      user?: { uid?: string };
    }>();
    const started = Date.now();

    return next.handle().pipe(
      tap({
        next: () => this.log(req, started, 'OK'),
        error: (err: unknown) => this.log(req, started, err),
      }),
    );
  }

  private log(
    req: { method?: string; url?: string; user?: { uid?: string } },
    started: number,
    outcome: unknown,
  ): void {
    const durationMs = Date.now() - started;
    if (process.env.NODE_ENV === 'production') {
      // JSON estructurado para agregadores (CloudWatch/Datadog/Loki).
      this.logger.log(
        JSON.stringify({
          method: req.method,
          url: req.url,
          uid: req.user?.uid,
          durationMs,
          outcome:
            outcome instanceof Error
              ? { error: outcome.message }
              : { status: 'OK' },
        }),
      );
    } else {
      this.logger.log(
        `${req.method ?? '?'} ${req.url ?? '?'} - ${durationMs}ms`,
      );
    }
  }
}
