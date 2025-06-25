import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import * as dotenv from 'dotenv';

async function bootstrap() {
  // cargo el .env de forma global
  dotenv.config();

  const app = await NestFactory.create(AppModule);

  await app.listen(process.env.PORT ?? 3000);
  console.log(`🚀 App corriendo en: http://localhost:${process.env.PORT ?? 3000}`);
}
bootstrap();
