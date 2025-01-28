import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

//hosting app from port 3000, this sample can read and create string-data entities in a connected postgres database
async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
