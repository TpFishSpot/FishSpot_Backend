import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
import { ValidationPipe, NestApplicationOptions } from '@nestjs/common';
import { resolve, join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';
import helmet from 'helmet';
import compression from 'compression';
import * as bodyParser from 'body-parser';
import { readFileSync, existsSync } from 'fs';

async function bootstrap() {
  dotenv.config();

  
  const certPath = join(process.cwd(), 'src', 'cert');
  const keyFile = join(certPath, 'key.pem');
  const certFile = join(certPath, 'cert.pem');

  let httpsOptions: any = undefined;
  if (existsSync(keyFile) && existsSync(certFile)) {
    httpsOptions = {
      key: readFileSync(keyFile),
      cert: readFileSync(certFile),
    };
    console.log('🔒 HTTPS habilitado (certificados locales encontrados)');
  } else {
    console.warn('⚠️ Certificados no encontrados, ejecutando en HTTP');
  }

  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    httpsOptions,
    logger:false,       // logs de nest desactivados
  });

  app.use(bodyParser.json({ limit: '50mb' }));
  app.use(bodyParser.urlencoded({ limit: '50mb', extended: true }));

  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"],
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", 'data:', 'blob:', 'http:', 'https:'],
          connectSrc: ["'self'", 'http:', 'https:'],
        },
      },
      crossOriginEmbedderPolicy: false,
      crossOriginResourcePolicy: { policy: 'cross-origin' },
    }),
  );

  app.use(compression());

  app.enableCors({
  origin: (origin, callback) => {
    const whitelist = [
      'http://localhost:5173',
      'https://localhost:5173',
      `http://${process.env.IP_PRIVADA}:5173`,
      `https://${process.env.IP_PRIVADA}:5173`,
    ];

    if (!origin || whitelist.includes(origin)) {
      callback(null, true);
    } else if (origin && origin.match(/^https?:\/\/192\.168\.1\.\d+:5173$/)) {
      callback(null, true);
    } else {
      callback(new Error('CORS no permitido para ' + origin));
    }
  },
  credentials: true,
  allowedHeaders: ['Content-Type', 'Authorization'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
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

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      disableErrorMessages: process.env.NODE_ENV === 'production',
    }),
  );

  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');

  console.log(
    httpsOptions
      ? `🚀 FishSpot API corriendo en https://${process.env.IP_PRIVADA}:${port}`
      : `🚀 FishSpot API corriendo en http://${process.env.IP_PRIVADA}:${port}`,
  );
}

bootstrap();
