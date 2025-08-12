import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
import { ValidationPipe } from '@nestjs/common';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  dotenv.config();

  const app = await NestFactory.create<NestExpressApplication>(AppModule);



  app.enableCors({
    origin: 'http://localhost:5173', 
    credentials: true,
  });
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads/',
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true, 
      transform: true    
    }),
  );

  await app.listen(process.env.PORT ?? 3000);
  console.log(`🚀 App corriendo en: http://localhost:${process.env.PORT ?? 3000}`);
}
bootstrap();
