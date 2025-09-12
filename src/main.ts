import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
import { ValidationPipe } from '@nestjs/common';
import { resolve } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';
import helmet from 'helmet';
import compression from 'compression';

async function bootstrap() {
  dotenv.config();

  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.use(helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", "data:", "https:"],
      },
    },
    crossOriginEmbedderPolicy: false, 
  }));
  app.use(compression());

  app.enableCors({
    origin: process.env.NODE_ENV === 'production'
      ? process.env.FRONTEND_URL
      : [
          'http://localhost:5173',
          'http://localhost:3000',
          /https:\/\/.*\.ngrok-free\.app$/,
          /https:\/\/.*\.ngrok\.io$/
        ],
    credentials: true,
  });

  app.useStaticAssets(resolve(process.cwd(), 'uploads'), {
    prefix: '/uploads/',
  });

  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
    disableErrorMessages: process.env.NODE_ENV === 'production', // esto es para Ocultar detalles de errores en produ
  }));

  const port = process.env.PORT || 3000;
  await app.listen(port);
  console.log(`FishSpot API running on port ${port}`);
  
  if (process.env.NODE_ENV !== 'production') {
    console.log(' Security middleware active');
    console.log(' Rate limiting enabled');
  }
}

bootstrap();

