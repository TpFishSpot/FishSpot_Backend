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
        imgSrc: ["'self'", "data:", "blob:", "http:", "https:"],
        connectSrc: ["'self'", "http:", "https:"],
      },
    },
    crossOriginEmbedderPolicy: false,
    crossOriginResourcePolicy: { policy: "cross-origin" },
  }));
  app.use(compression());

  app.enableCors({
    origin: process.env.NODE_ENV === 'production'
      ? process.env.FRONTEND_URL
      : [
          'http://localhost:5173',
          'http://localhost:3000',
          `${process.env.ipPrivada}`,
        ],
    credentials: true,
  });

  app.useStaticAssets(resolve(process.cwd(), 'uploads'), {
    prefix: '/uploads/',
    setHeaders: (res, path) => {
      res.setHeader('Access-Control-Allow-Origin', '*');
      res.setHeader('Access-Control-Allow-Methods', 'GET');
      res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
      res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
    },
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

