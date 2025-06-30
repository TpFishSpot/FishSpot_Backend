import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';
import { ValidationPipe } from '@nestjs/common';

async function bootstrap() {
  // cargo el .env de forma global
  dotenv.config();

  const app = await NestFactory.create(AppModule);

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
