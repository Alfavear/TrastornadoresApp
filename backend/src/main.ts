import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Initialize Firebase Admin
  try {
    const serviceAccount = require(path.join(__dirname, '..', 'firebase-service-account.json'));
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
    console.log('Firebase Admin initialized successfully');
  } catch (error) {
    console.warn('Could not initialize Firebase Admin (Check firebase-service-account.json)');
  }

  app.enableCors();
  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  const config = new DocumentBuilder()
    .setTitle('TrastornadoresApp API')
    .setDescription('API REST para la gestión de ministerios y cronogramas')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
    
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  await app.listen(3000);
  console.log(`Application is running on: ${await app.getUrl()}`);
}
bootstrap();
